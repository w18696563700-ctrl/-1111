---
owner: 联调发布 Agent
status: draft
purpose: 对 veto 阻断项 BLK-R0-ENV-PURITY 进行只读关闭评估；澄清主联调链与 pm2 旁路 smoke 链的职责、边界、风险、关闭路径与验收条件；不授予开发、迁移、部署或发版许可。
layer: L0 SSOT 配套文书
inputs:
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_asset_register_v1.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/round0_inventory_release_integration_agent.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/round0_inventory_validation_signoff.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/release_environment_rollback_baseline_addendum.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - /Users/wangweiwei/Desktop/展览装修之家总控/infra/scripts/bootstrap_cloud_host.sh
  - /Users/wangweiwei/Desktop/展览装修之家总控/infra/scripts/smoke.sh
  - /Users/wangweiwei/Desktop/展览装修之家总控/infra/nginx/cloud.conf
evidence_time_utc: 2026-04-01T19:52:03Z
---

# 环境纯度阻断关闭评估补充单

## 1. 问题定义

本单只回答 veto 阻断项 `BLK-R0-ENV-PURITY`：

- 为什么当前云端同时存在两套运行链：
  - 主联调链：`systemd + /srv/apps/*/current -> /srv/releases/** + 80 -> 3000/3001`
  - 旁路 smoke 链：`pm2 + /srv/workspaces/** + 3100/3101 + 127.0.0.1:18080`
- 这两套链分别承担什么职责
- 是否允许长期并存
- 如果要关闭阻断，应走哪条候选路径

**本单边界：**

- 只读 SSH、只读 HTTP、只读文书评估
- 不改代码、不改配置、不切进程、不 deploy、不发版

**本单不做：**

- 不实施关闭
- 不给出 shell 操作步骤
- 不把评估结论直接等同于关闭完成

---

## 2. 当前证据链

### 2.1 SSOT 与仓库基线

| 项 | 证据层级 | 结论 |
|----|----------|------|
| `project_asset_register_v1.md` | **仅本地仓库** | 已将 `BLK-R0-ENV-PURITY` 冻结为 open，原因是 `pm2 + /srv/workspaces/** + 3100/3101/18080` 并存 |
| `new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md` | **仅本地仓库** | 当前 `environment-purity gate` 明确 failed，且为 veto |
| `release_environment_rollback_baseline_addendum.md` | **仅文档声称** | active runtime 必须由 release artifact 选择，不得由 source workspace 充当正式切换单元 |
| `development_stage_cloud_host_override_addendum.md` | **仅文档声称** | 当前开发阶段有效本地验证入口仍是 `8080 -> 80`，不是 `18080` |
| `infra/nginx/cloud.conf` | **仅本地仓库** | 仓库主链样例只描述 `80 -> 3000/3001`，不含 `18080/3100/3101` |
| `infra/scripts/smoke.sh` | **仅本地仓库** | 默认 smoke 只探测 `3000/3001`，不探测 `3100/3101` |
| `infra/scripts/bootstrap_cloud_host.sh` | **仅本地仓库** | 会安装 `pm2`，但未把 `pm2` 定义为正式 active runtime |

### 2.2 主联调链只读核验

**证据层级：云端进程与配置**

```text
systemctl status exhibition-bff exhibition-server nginx
exhibition-bff.service    active (running)
exhibition-server.service active (running)
nginx.service             active (running)

systemctl show exhibition-bff
WorkingDirectory=/srv/apps/bff/current
ExecStart=/usr/bin/node dist/main.js
FragmentPath=/etc/systemd/system/exhibition-bff.service

systemctl show exhibition-server
WorkingDirectory=/srv/apps/server/current
ExecStart=/usr/bin/node dist/main.js
FragmentPath=/etc/systemd/system/exhibition-server.service

readlink -f /srv/apps/bff/current
/srv/releases/bff/20260331195903/apps/bff

readlink -f /srv/apps/server/current
/srv/releases/server/20260401023418

ss -ltnp
0.0.0.0:80    -> nginx
0.0.0.0:3000  -> node pid=518369
0.0.0.0:3001  -> node pid=518368
```

### 2.3 pm2 旁路链只读核验

**证据层级：云端进程与配置**

```text
pm2 ls
- bff-staging     pid 351218 online
- server-staging  pid 351200 online

pm2 describe bff-staging
script path   /srv/workspaces/exhibition-infra-monorepo/apps/bff/dist/apps/bff/src/main.js
exec cwd      /srv/workspaces/exhibition-infra-monorepo/apps/bff
node env      production
error log     /root/.pm2/logs/bff-staging-error.log
out log       /root/.pm2/logs/bff-staging-out.log

pm2 describe server-staging
script path   /srv/workspaces/exhibition-infra-monorepo/apps/server/dist/apps/server/src/main.js
exec cwd      /srv/workspaces/exhibition-infra-monorepo/apps/server
node env      production
error log     /root/.pm2/logs/server-staging-error.log
out log       /root/.pm2/logs/server-staging-out.log

ss -ltnp
0.0.0.0:3100       -> pid 351218
0.0.0.0:3101       -> pid 351200
127.0.0.1:18080    -> nginx
```

### 2.4 旁路 Nginx 只读核验

**证据层级：云端进程与配置**

云端 `exhibition-staging-smoke.conf` 摘录：

```nginx
upstream bff_staging_smoke_upstream { server 127.0.0.1:3100; }
upstream server_staging_smoke_upstream { server 127.0.0.1:3101; }

server {
    listen 127.0.0.1:18080;
    location /health/bff/live { proxy_pass http://bff_staging_smoke_upstream/health/live; }
    location /health/server/live { proxy_pass http://server_staging_smoke_upstream/health/live; }
    location ^~ /api/app/forum/ {
        proxy_set_header X-Actor-Id staging-smoke-buyer-admin;
        proxy_set_header X-User-Id staging-smoke-buyer-admin;
        proxy_set_header X-Organization-Id staging-smoke-org;
        proxy_set_header X-Actor-Role buyer_admin;
        rewrite ^/api/app/(.*)$ /bff/$1 break;
        proxy_pass http://bff_staging_smoke_upstream;
    }
    location ~ ^/api/app/(shell|workbench|forum|project|bid|order|milestone|file|message|profile|platform|contract|inspection|rating|dispute)(/.*)?$ {
        rewrite ^/api/app/(.*)$ /bff/$1 break;
        proxy_pass http://bff_staging_smoke_upstream;
    }
}
```

### 2.5 HTTP 只读对比

**证据层级：云端进程与配置**

| URL | HTTP | 响应体前缀 / 结论 |
|-----|------|-------------------|
| `http://127.0.0.1:80/health/bff/live` | `200` | `service=exhibition-bff, port=3000` |
| `http://127.0.0.1:80/health/server/live` | `200` | `service=exhibition-server, port=3001` |
| `http://127.0.0.1:18080/health/bff/live` | `200` | `service=exhibition-bff-staging, port=3100` |
| `http://127.0.0.1:18080/health/server/live` | `200` | `service=exhibition-server-staging, port=3101` |
| `http://127.0.0.1:80/api/app/exhibition/home` | `200` | 主联调链可返回首页聚合 |
| `http://127.0.0.1:18080/api/app/exhibition/home` | `404` | 旁路链未覆盖该路径 |
| `http://127.0.0.1:80/api/app/forum/feed` | `401` | 主链要求真实会话 |
| `http://127.0.0.1:18080/api/app/forum/feed` | `200` | 旁路链通过固定 header 注入返回 smoke 数据 |
| `http://127.0.0.1:80/api/app/file/index` | `200` | `skeleton_only` |
| `http://127.0.0.1:18080/api/app/file/index` | `200` | `skeleton_only` |

### 2.6 当前证据链小结

- 主联调链当前可由 `80 + systemd + /srv/releases/**` 识别为 active runtime。
- pm2 链不是通过主隧道入口暴露给本地前端的 active entry。
- 但 pm2 链并非“完全无影响”：
  - 它运行在同一台主机
  - 使用 app-facing 相同路径族
  - 对部分路径注入固定身份头
  - 使用 workspace 源码目录而不是 release artifact

---

## 3. 主链与旁路链分层说明

### 3.1 主联调链

| 维度 | 当前主链 |
|------|----------|
| 角色 | active runtime truth |
| 进程管理 | `systemd` |
| 工作目录 | `/srv/apps/*/current -> /srv/releases/**` |
| 对外入口 | `0.0.0.0:80` |
| 本地验证入口 | `ssh -N -L 8080:127.0.0.1:80 ...` |
| 端口 | `3000/3001` |
| 是否进入正式联调链 | 是 |
| 是否进入 rollback / release 基线 | 是，至少形式上符合 release artifact 口径 |

### 3.2 pm2 旁路链

| 维度 | 当前旁路链 |
|------|------------|
| 角色 | 本机 local-only smoke / staging 通道 |
| 进程管理 | `pm2` |
| 工作目录 | `/srv/workspaces/exhibition-infra-monorepo/apps/*` |
| 对外入口 | `127.0.0.1:18080` |
| 端口 | `3100/3101` |
| 是否进入正式联调链 | 否 |
| 是否进入 rollback / release 基线 | 否，当前不应进入 |

### 3.3 对 pm2 旁路链的定性

本次评估的定性结论：

- **职责上**：它更接近 `staging smoke 通道`
  - 因为 `18080` 只在本机监听
  - 因为 Nginx 明确注入固定 smoke 身份头
  - 因为路径覆盖是定向的，不是完整主链镜像
- **治理上**：它必须按 `不受控旁路 / shadow runtime` 对待
  - 因为它与 active runtime 共享同机资源
  - 因为它使用 workspace 源码目录运行
  - 因为它以 app-facing 相同路径族返回真实 HTTP 响应

因此它**不是**单纯“只读调试残留”，也**不能**算 active runtime。

---

## 4. 环境纯度风险定位

### 4.1 为什么构成环境纯度风险

| 风险点 | 说明 |
|--------|------|
| 主机同域并存 | 两套链在同一台主机上同时存活，不是跨环境天然隔离 |
| 路径族相同 | 两套链都处理 `/api/app/*`，只是入口不同 |
| 身份语义不同 | `18080` 对 `forum/feed` 注入固定身份后返回 `200`，而 `80` 返回真实会话 `401` |
| 运行单元不同 | 主链来自 release artifact；旁路来自 workspace 源码目录 |
| 日志与观察面分叉 | 主链看 `systemd` / active current；旁路看 `/root/.pm2/logs` / pm2 state |
| 错误判断风险 | 若不区分入口，容易把 smoke 结果误当 active runtime 结果 |

### 4.2 对主联调链判断的影响

- **当前仍可识别 active runtime。**
- 依据：
  - 本地主验证入口只映射到 `80`
  - `80` 对应 `systemd + /srv/releases/** + 3000/3001`
  - `18080` 仅本机监听，未进入 `8080 -> 80` 主隧道链

### 4.3 对 rollback 判断的影响

- **已影响 rollback 判断。**
- 理由：
  - 回滚基线要求 active runtime 由 release artifact 选择
  - pm2 链来自 `/srv/workspaces/**`，不能纳入正式 rollback 单元
  - 若继续并存而未隔离，容易把 smoke 链误当“备用运行单元”

### 4.4 对验收判断的影响

- **已影响验收判断。**
- 理由：
  - 同一路径族在 `80` 和 `18080` 上的行为不同
  - `forum/feed` 在 smoke 链返回 `200`，在主链返回 `401`
  - 若验收人员未明确入口，会得出矛盾结论

### 4.5 对发布判断的影响

- **已影响发布判断。**
- 理由：
  - 发布基线要求 active release selection 单一
  - pm2 workspace 链不应进入 release truth
  - 并存状态会阻断“环境单一、回滚单一、证据单一”的判断

### 4.6 是否允许长期并存

- **当前形态不允许长期并存。**
- 原因：
  - workspace source runtime 与 release runtime 并存
  - 路径族交叉
  - smoke 语义依赖固定身份注入
  - 缺少正式边界冻结，无法保证不污染 active truth

---

## 5. 候选关闭方案对比

### 5.1 方案 A：同机保留，但将 pm2 smoke 链正式隔离为受控旁路

**定义**

- 保留 `18080/3100/3101`
- 但把它正式冻结成独立 `staging-smoke` 旁路
- 明确不进入 active runtime、rollback、release、签收链

**前置条件**

- 必须形成独立 truth 文书，声明它不是 active runtime
- 必须明确 owner、用途、允许路径、禁止用途
- 必须把 `18080`、`3100/3101`、pm2 日志与观察面单列
- 必须明确：本地隧道与结果校验一律不以 `18080` 为依据

**优点**

- 保留现有 smoke 便利性
- 不立即失去固定身份的 smoke 入口

**缺点**

- 仍然同机并存，治理复杂度高
- 仍需解释为什么 workspace runtime 可以长期存在
- 关闭 blocker 的条件更苛刻，且需要新的边界冻结

### 5.2 方案 B：退役 pm2 workspace smoke 链，仅保留 systemd release 主链

**定义**

- 未来关闭 `pm2 + 3100/3101 + 18080`
- active runtime 只保留 `80 -> 3000/3001 -> /srv/releases/**`
- 若仍需 smoke，另行建设独立环境或 release-like smoke 单元

**前置条件**

- 证明当前 round 的只读验证需求可由主链承担
- 明确 smoke-only 能力是否仍需保留
- 准备回退依据：若关闭后需恢复 smoke，应有单独方案，不得把 workspace runtime 当正式回滚单元

**优点**

- 最直接恢复环境纯度
- active runtime、rollback、signoff 口径最清晰
- 与 `release_environment_rollback_baseline_addendum.md` 最一致

**缺点**

- 会失去当前 fixed-header smoke 便利性
- 若仍有 smoke 需求，需要后续新方案承接

### 5.3 方案 C：把 smoke 能力迁移成受治理的 release-like smoke 单元

**定义**

- 不保留 workspace + pm2
- 若必须保留 smoke，则迁移到单独 release artifact 或单独环境

**优点**

- 兼顾 smoke 与治理

**缺点**

- 成本最高
- 不适合当前 Round 0 立即关闭阻断

### 5.4 对比结论

| 方案 | 是否最有利于关闭 `BLK-R0-ENV-PURITY` | 主要问题 |
|------|--------------------------------------|----------|
| 方案 A | 否 | 仍然并存，关闭条件复杂 |
| 方案 B | 是 | 需要放弃当前同机 smoke 便利性 |
| 方案 C | 中 | 需要额外建设与冻结，周期长 |

---

## 6. 唯一推荐方案

**唯一推荐方案名称：方案 B《退役同机 pm2 workspace smoke 链，仅保留 systemd release 主链为唯一 active runtime》**

### 6.1 推荐理由

1. 它最符合现有 release / rollback 基线：
   - active runtime 来自 release artifact
   - 不来自 workspace source
2. 它最能消除当前最核心的环境纯度噪音：
   - 主链唯一
   - 观察面唯一
   - 回滚口径唯一
3. 它不要求在同机长期维护“解释成本很高”的双 runtime 并存

### 6.2 推荐边界

- 本单只推荐，不实施。
- 若后续仍需 smoke，不应继续回到 `pm2 + workspace + 18080` 的当前形态。
- smoke 能力应作为后续独立议题，在：
  - 独立环境
  - 或受治理的 release-like smoke 单元
 之中重建。

---

## 7. 不允许采用的方案

1. **静默保留现状，不补边界文书。**
   - 这不能关闭 blocker，只会继续污染 active runtime 判断。

2. **把 `18080` 或 `3100/3101` 重新解释成 active runtime 的一部分。**
   - 这与 release artifact 基线冲突。

3. **把 pm2 workspace 链当作正式 rollback 备用链。**
   - 这会把 source workspace 误当 runtime switching unit。

4. **未做前置核验就直接停 pm2 或删 smoke 配置。**
   - 这不是评估轮允许的动作，也不满足治理要求。

5. **继续使用仓库 `infra/nginx/cloud.conf` 样例替代线上 smoke 配置真相。**
   - 仓库样例不含 `18080/3100/3101`，不能解释当前旁路链。

---

## 8. 关闭验收条件

本阻断项只有在以下条件全部满足时，才可判定为关闭：

1. active runtime 仍唯一识别为：
   - `80 -> 3000/3001`
   - `systemd`
   - `/srv/releases/**`

2. `pm2 + 3100/3101 + 18080 + /srv/workspaces/**` 已不再构成 active runtime 同机并存链。
   - 关闭路径可以是退役
   - 或冻结为正式隔离旁路
   - 但必须有单一正式口径

3. 结果校验与阶段门禁文书明确：
   - 哪条链是 active runtime truth
   - 哪条链不是
   - rollback / release / signoff 依据只认哪条链

4. 若选择保留旁路，则必须额外满足：
   - 不得使用 workspace source 直接承载 active-like 语义
   - 不得进入本地主隧道与默认验证入口
   - 不得进入 release/rollback 基线

5. 关闭后必须复核：
   - `80` 的 health
   - `80` 的 canonical app-facing endpoint
   - `current -> /srv/releases/**`
   - `systemd` active 状态

---

## 9. 对 Round 1 准入的影响

### 9.1 当前影响

- 当前 `BLK-R0-ENV-PURITY` 仍然阻断：
  - Round 1 admission
  - 开发轮
  - 联调实施
  - 部署
  - 发版

### 9.2 当前可成立的判断

- **主联调链仍可视为 active runtime。**
- **pm2 旁路链已构成环境纯度风险。**
- **该阻断项当前未关闭，仅完成评估。**

### 9.3 建议口径

- 当前只允许总控把本单作为 blocker closure assessment 归档。
- 不允许将本单解释为：
  - blocker 已关闭
  - 环境已收敛
  - Round 1 已放行

---

## 10. 修订记录

| 版本 | 时间 | 说明 |
|------|------|------|
| v0.1 | 2026-04-01T19:52:03Z | 联调发布 Agent 只读完成 `BLK-R0-ENV-PURITY` 关闭评估；补齐主链与 pm2 旁路链职责、边界、风险、候选关闭路径、唯一推荐方案与关闭验收条件 |


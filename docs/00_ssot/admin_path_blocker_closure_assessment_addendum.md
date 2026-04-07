---
owner: 后端 Agent（云端）
status: frozen
purpose: Read-only closure assessment for veto blocker BLK-R0-ADMIN-PATH, based on local SSOT/contracts/controller review and live cloud Nginx/Server runtime evidence. This document defines why /api/admin/* does not close with canonical /server/admin/*, compares closure options, gives one recommended path, and sets acceptance gates without implementing any change.
layer: L0 SSOT 配套文书
blocker_id: BLK-R0-ADMIN-PATH
assessment_date_local: 2026-04-02
inputs_canonical:
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/round0_inventory_validation_signoff.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts
  - infra/nginx/cloud.conf
evidence_scope:
  - local docs/contracts/controller/config read-only review
  - cloud live Nginx read-only review
  - cloud live HTTP read-only probe
  - no code change
  - no Nginx change
  - no migration
  - no deploy
  - no release
---

# BLK-R0-ADMIN-PATH 阻断关闭评估附录

## 1. 问题定义

`BLK-R0-ADMIN-PATH` 的当前含义是：

- 外部入口当前使用 `/api/admin/*`。
- canonical admin truth 当前冻结在 `/server/admin/*`。
- live Nginx 把 `/api/admin/*` 转成了 upstream `/admin/*`，而不是 `/server/admin/*`。
- live Server controller 与 contracts 仍挂在 `/server/admin/*`。

因此，当前问题不是“Server Admin controller 不存在”，而是“外部 ingress 别名没有闭环到 canonical Server admin path”。

当前阻断只针对路径闭环，不涉及：

- 权限模型重写
- 审计模型重写
- 业务状态机变更
- 数据库迁移
- BFF 承接 admin 代理

## 2. 当前证据链

### 2.1 本地 formal truth 证据

- `docs/01_contracts/openapi.yaml` 当前存在 `/server/admin/exhibition/enterprise-hub/*`，未定义 `/api/admin/*`。
- `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts` 使用 `@Controller('server/admin/exhibition/enterprise-hub')`。
- `infra/nginx/cloud.conf` 仓库样例当前为：
  - `location /api/admin/`
  - `proxy_pass http://server_upstream/admin/;`
- `docs/00_ssot/project_asset_register_v1.md` 已将 `BLK-R0-ADMIN-PATH` 冻结为 open veto。
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md` 已将该项列为 `Gate 4` canonical path drift。
- `docs/00_ssot/round0_inventory_release_integration_agent.md` 与 `docs/00_ssot/round0_inventory_validation_signoff.md` 已明确裁定：
  - `/api/admin/*` 当前不闭环
  - canonical `/server/admin/*` 与 controller/openapi 一致

### 2.2 云端 live 运行态证据

云端 live Nginx 生效片段当前为：

```nginx
location /api/admin/ {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://server_upstream/admin/;
}
```

云端 live HTTP 只读探测结果：

- `GET http://127.0.0.1/api/admin/exhibition/enterprise-hub/applications`
  - `404`
  - body: `Cannot GET /admin/exhibition/enterprise-hub/applications`
- `GET http://127.0.0.1:3001/server/admin/exhibition/enterprise-hub/applications`
  - `403`
  - body: `ENTERPRISE_HUB_PERMISSION_DENIED`

证据含义非常明确：

- 请求已经到达 Server，但外部入口经 Nginx 后落在 `/admin/*`。
- 正确的 live Server 路由仍在 `/server/admin/*`，只是当前探测身份没有 admin 权限。
- 404 是路径错位，不是 controller 缺失。

### 2.3 消费面证据

- 当前仓库 `apps/admin` 仍是 skeleton。
- 在 `apps/admin`、`apps/mobile`、`apps/bff` 中未检出实际 `/api/admin/*` 或 `/server/admin/*` 调用代码。

结论：

- 当前受影响的首先是 ingress 闭环、联调验证与后续 Admin 接入规范。
- 当前不是已有生产 Admin 前端大面积回归问题。

## 3. 错位层级定位

### 3.1 分层结论

| 层级 | 当前判断 | 结论 |
|---|---|---|
| 外部 canonical path | 未在 contracts 中冻结为 `/api/admin/*`；当前 formal truth 仍是 `/server/admin/*` | 不是当前 runtime 404 的直接根因，但存在“ingress alias 未正式收口”的治理缺口 |
| Nginx 对外前缀 | 对外暴露的是 `/api/admin/*` | 是问题链入口 |
| upstream URI 拼接 | `proxy_pass http://server_upstream/admin/;` 把请求转成 `/admin/*` | 是当前 runtime 404 的直接根因 |
| Server controller 前缀 | controller 与 contracts 一致挂在 `/server/admin/*` | 不是根因，不建议把它当第一修复点 |

### 3.2 根因定位

本阻断的主根因在两层：

1. live Nginx 对外暴露了 `/api/admin/*` ingress。
2. live Nginx upstream URI 拼接把该 ingress 错映射为 `/admin/*`，没有闭环到 canonical `/server/admin/*`。

本阻断不在以下层：

- 不在 Server controller 前缀本身。
- 不在 OpenAPI canonical path 本身。
- 不在权限守卫是否存在。

## 4. 候选关闭方案对比

| 方案 | 核心做法 | 是否改 Nginx | 是否改 Server controller 前缀 | 是否改 contracts | 是否改前端 / Admin 调用 | 是否影响已有 `/api/app/*` | 是否影响当前联调主链 | 风险等级 | 推荐结论 |
|---|---|---|---|---|---|---|---|---|---|
| 方案 A: Ingress Alias 对齐 | 保持 canonical `/server/admin/*` 不变，仅让 `/api/admin/*` 在 ingress 层稳定映射到 `/server/admin/*` | 是 | 否 | 否 | 否，未来 Admin 继续打 `/api/admin/*` | 理论上不影响；但需 smoke `/api/app/*` | 只影响 admin 入口，不改变 `80 -> 3000/3001` 主链结构 | 中 | 推荐 |
| 方案 B: Server Prefix 下沉到 `/admin/*` | 保持当前 Nginx 不动，把 Server controller/contracts 从 `/server/admin/*` 改成 `/admin/*` | 否 | 是 | 是 | 外部 `/api/admin/*` 调用可不改，但所有 canonical 文书、直探、契约、验证脚本都要改 | 不直接影响 `/api/app/*` | 会改变 Server canonical path family，影响面大于单点 ingress | 高 | 不推荐 |

### 4.1 方案 A 说明

方案 A 的要点是：

- `docs/01_contracts/openapi.yaml` 继续把 `/server/admin/*` 视为 canonical truth。
- Server controller 继续维持 `@Controller('server/admin/...')`。
- Nginx 仅承担“外部 `/api/admin/*` ingress alias -> 内部 `/server/admin/*` truth path”的职责。

方案 A 的优点：

- 不改变 truth owner，不改 canonical family。
- 与 `AGENTS.md`、现有 contracts、现有 controller、现有 signoff 文书一致。
- blast radius 最小，影响点集中在 admin ingress，而不是整条 server admin family。
- 不要求 BFF 承接 admin，也不引入第二条 canonical path。

方案 A 的缺点：

- 需要改 live Nginx，并重新验证转发语义。
- 需要把 repo 样例 `infra/nginx/cloud.conf` 与 live 运行态同步，避免再次出现 repo/runtime drift。

### 4.2 方案 B 说明

方案 B 的要点是：

- 不改当前 Nginx `/api/admin/ -> /admin/` 行为。
- 反过来改 Server controller family 与 contracts，使其落在 `/admin/*`。

方案 B 的问题：

- 当前不只是 enterprise_hub 一条 admin 路由；`openapi` 里已有 reviews、security-events、governance、report-cases、enterprise-hub 等整组 `/server/admin/*`。
- 这会把“单点 ingress 错位”升级成“整个 admin canonical family 重写”。
- 现有 SSOT 中多处已把 admin-facing route family 冻结为 `/server/admin/*`。
- 该方案需要同步修改 contracts、generated contracts、Server controllers、验证脚本、历史签收口径，改动面明显更大。

## 5. 推荐关闭方案

### 5.1 唯一推荐方案

唯一推荐方案名称：

`方案 A｜Ingress Alias 对齐，保持 /server/admin/* 为 canonical truth`

### 5.2 推荐原因

- 当前 contracts 与 Server controller 已经一致，不应为了适配错误 ingress 去下沉 canonical truth。
- 当前 404 明确发生在 Nginx ingress 映射层，而不是 controller 层。
- `apps/admin` 当前还是 skeleton，当前最需要收口的是路径规范，而不是迁移调用方。
- 该方案不会引入第二条 admin truth path，也不会把 admin 路由下沉到 BFF。

### 5.3 关闭前置条件

在真正执行关闭动作前，至少需要先冻结以下前置条件：

1. 总控明确裁定：
   - canonical admin path family 继续保持 `/server/admin/*`
   - `/api/admin/*` 仅是外部 ingress alias，不升格为新的 canonical truth
2. 联调发布侧明确提供：
   - 目标 Nginx 映射策略
   - reload 窗口
   - 回滚方式
3. 结果校验侧明确准备：
   - unauthenticated 探测
   - admin-role 探测
   - `/api/app/*` 回归 smoke
4. repo baseline 必须同步收口：
   - `infra/nginx/cloud.conf` 不能继续保留与 active runtime 相冲突的 admin 映射样例

## 6. 不允许采用的方案

以下路径不应采用：

### 6.1 不允许方案一：新增 BFF admin 代理承接

原因：

- 违反“Admin 使用 controlled Server Admin APIs，不走 BFF”的冻结边界。
- 会把单一 admin truth 路由再包一层，形成新的聚合漂移。

### 6.2 不允许方案二：长期并存双 canonical family

例子：

- 同时长期支持 `/server/admin/*` 与 `/admin/*`
- 或同时长期支持 `/api/admin/*` 与 `/api/admin/server/admin/*`

原因：

- 会制造双路由口径。
- 会让 contracts、脚本、联调、排障都出现二义性。

### 6.3 不允许方案三：只改 contracts，不改 live ingress

原因：

- 这会把 formal truth 改到错误运行态上，而不是把运行态拉回真源。
- 会进一步放大 runtime 与 repo 的漂移。

## 7. 关闭验收条件

### 7.1 URL 验收条件

阻断项要被标记为“关闭”，至少要满足以下最小验收集：

1. `GET http://127.0.0.1:8080/api/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1`
   - 使用无 admin 权限上下文时，返回必须是 `401` 或 `403`
   - 明确不能再是 `404 Cannot GET /admin/...`
2. `GET http://127.0.0.1:8080/api/admin/exhibition/enterprise-hub/recommendation-slots?page=1&pageSize=1`
   - 使用无 admin 权限上下文时，返回必须是 `401` 或 `403`
   - 明确不能再是 `404 Cannot GET /admin/...`
3. `GET http://127.0.0.1:3001/server/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1`
   - 仍应返回 Server 层权限结论或业务结论
   - 不允许因关闭动作破坏 canonical `/server/admin/*`
4. `GET http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/recommendations?boardType=company`
   - 仍为 `200`
5. `GET http://127.0.0.1:8080/health/server/live`
   - 仍为 `200`

如果具备有效 admin 角色上下文，则以下 URL 还应返回 `200` 且 schema 与 contracts 对齐：

- `/api/admin/exhibition/enterprise-hub/applications?page=1&pageSize=1`
- `/api/admin/exhibition/enterprise-hub/recommendation-slots?page=1&pageSize=1`

### 7.2 必须同步更新的文书

若按推荐方案关闭，至少需要同步更新：

- `docs/00_ssot/project_asset_register_v1.md`
  - 将 `BLK-R0-ADMIN-PATH` 状态从 `Open` 改为关闭后状态
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
  - 更新 `Gate 4` canonical path drift 状态
- `docs/00_ssot/round0_inventory_release_integration_agent.md`
  - 追加关闭后的 live ingress 证据
- `docs/00_ssot/round0_inventory_validation_signoff.md`
  - 追加复核结论
- `infra/nginx/cloud.conf`
  - repo baseline 必须与 active runtime truth 对齐

若改走方案 B，则还必须额外更新：

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/**`
- 所有引用 `/server/admin/*` 的 admin family 文书

### 7.3 必须复核的角色

- 后端 Agent（云端）
- 联调发布 Agent
- 结果校验 Agent
- Codex 总控

如果在关闭动作同时引入真实 Admin 前端接入，再补充：

- Admin 接入责任角色

## 8. 对 Round 1 准入的影响

本评估的结论是：

- `BLK-R0-ADMIN-PATH` 当前仍未关闭。
- 本文书只完成“关闭评估”，没有完成“阻断关闭”。

即使后续按推荐方案成功关闭该项，也只意味着：

- `Gate 4` 的 admin path drift 子问题有机会解除

但它不自动意味着：

- Round 1 直接放行
- migration 放行
- deployment 放行
- release 放行

因为当前仍有其他 open blockers：

- `BLK-R0-APP-REWRITE-DRIFT`
- `BLK-R0-RUNTIME-REPO-DRIFT`
- `BLK-R0-ENV-PURITY`
- `BLK-R0-SERVER-GAP`
- `BLK-R0-FILE-LENGTH`

因此，对 Round 1 的准确影响是：

- 当前仍然 `No-Go`
- 仅在 `BLK-R0-ADMIN-PATH` 关闭后，才允许进入下一轮准入复核，而不是直接进入开发轮

## 9. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首版。完成 `BLK-R0-ADMIN-PATH` 只读关闭评估；确认根因位于 Nginx ingress / upstream URI 映射层；给出两条候选关闭路径并确定唯一推荐方案为“方案 A｜Ingress Alias 对齐，保持 /server/admin/* 为 canonical truth” |

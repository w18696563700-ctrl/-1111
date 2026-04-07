---
owner: 联调发布 Agent
status: assessment_only
purpose: 对 veto 阻断项 BLK-R0-APP-REWRITE-DRIFT 进行只读关闭评估，明确 /api/app canonical family、/bff internal runtime family、repo nginx 样例与 live Nginx 生效配置之间的边界，并给出唯一推荐关闭方案。
layer: L0 SSOT 配套文书
evidence_date_local: 2026-04-02
scope: read-only verification only
---

# app_api rewrite 漂移阻断关闭评估补充单

## 1. 问题定义

当前阻断项为：`BLK-R0-APP-REWRITE-DRIFT`。

该阻断项已在以下 active 文书中被登记为 `Open`：

- [project_asset_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_asset_register_v1.md)
- [new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md)
- [round0_inventory_validation_signoff.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/round0_inventory_validation_signoff.md)
- [round0_inventory_release_integration_agent.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/round0_inventory_release_integration_agent.md)

本次要回答的不是“当前链路通不通”本身，而是：

1. 当前 `/api/app/*` 为什么能够真实闭环。
2. 这个闭环里，哪些属于 canonical truth，哪些属于 live Nginx rewrite。
3. 当前 repo `infra/nginx/cloud.conf` 为什么不能代表 active runtime truth。
4. 这个阻断项未来应如何关闭。
5. 哪条关闭路径是唯一推荐方案。

本次文书的固定结论是：

- `/api/app/*` 仍然是唯一 canonical app-facing family。
- `/bff/*` 只能视为 internal runtime family。
- repo `infra/nginx/cloud.conf` 当前不能代表 active runtime truth。
- `BLK-R0-APP-REWRITE-DRIFT` **未关闭，仅完成评估**。

---

## 2. 当前证据链

### 2.1 canonical truth 证据

**证据层级：仅本地仓库**

从 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml) 与 [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md) 可确认：

- `/api/app/*` 仍是 Flutter App 的 canonical app-facing family。
- `BFF Routes` 明确写明 `BFF serves Flutter App only`，并按 route groups 冻结 app-facing 责任。
- `openapi.yaml` 中存在：
  - `GET /api/app/exhibition/home`
  - `GET /api/app/exhibition/enterprise-hub/recommendations`
  - `GET /api/app/forum/feed`
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
- 在上述 canonical 文书中 **未发现 `/bff/*` 路径族**。

补充核验结果：

```text
rg '/bff/' docs/01_contracts/openapi.yaml docs/03_bff/bff_routes.md
=> NO_BFF_PATH_IN_CANONICAL_DOCS
```

### 2.2 repo Nginx 样例证据

**证据层级：仅本地仓库**

仓库样例 [cloud.conf](/Users/wangweiwei/Desktop/展览装修之家总控/infra/nginx/cloud.conf) 当前形态为：

```nginx
location /api/app/ {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://bff_upstream/;
}
```

该样例的特点是：

- 只有一个 `/api/app/` 单块入口
- 没有 `rewrite`
- 没有 `/health/bff/ready`、`/health/server/ready`
- 没有 `location = /api/app/exhibition/workbench`
- 没有 `^~ /api/app/forum/`
- 没有 `^~ /api/app/bff/forum/`
- 没有 `~ ^/api/app/(auth|shell|workbench|exhibition|forum|project|bid|order|milestone|file|message|profile|platform|contract|inspection|rating|dispute)`

### 2.3 live Nginx 生效证据

**证据层级：云端进程与配置**

云端 `47.108.180.198` 只读核验到的 `/etc/nginx/conf.d/exhibition.conf` 摘录为：

```nginx
upstream bff_upstream {
    server 127.0.0.1:3000;
}

upstream server_upstream {
    server 127.0.0.1:3001;
}

location /health/bff/live {
    proxy_pass http://bff_upstream/health/live;
}

location /health/bff/ready {
    proxy_pass http://bff_upstream/health/ready;
}

location /health/server/live {
    proxy_pass http://server_upstream/health/live;
}

location /health/server/ready {
    proxy_pass http://server_upstream/health/ready;
}

location = /api/app/exhibition/workbench {
    rewrite ^/api/app/exhibition/workbench$ /bff/exhibition/workbench break;
    proxy_pass http://bff_upstream;
}

location ^~ /api/app/forum/ {
    rewrite ^/api/app/(.*)$ /bff/$1 break;
    proxy_pass http://bff_upstream;
}

location ~ ^/api/app/(auth|shell|workbench|exhibition|forum|project|bid|order|milestone|file|message|profile|platform|contract|inspection|rating|dispute)(/.*)?$ {
    rewrite ^/api/app/(.*)$ /bff/$1 break;
    proxy_pass http://bff_upstream;
}
```

### 2.4 BFF controller 前缀证据

**证据层级：仅本地仓库**

当前 repo 中可直接定位到的 BFF controller 前缀为：

```text
apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts
@Controller('bff/exhibition/enterprise-hub')

apps/bff/src/routes/forum/forum.controller.ts
@Controller('bff/forum')

apps/bff/src/routes/file/file.controller.ts
@Controller('bff/file')
```

这说明当前 BFF 运行态要命中这些 controller，外部 `/api/app/*` 必须在 ingress 侧被翻译到 `/bff/*`。

### 2.5 只读 HTTP 证据

#### 本地隧道入口

**证据层级：隧道实测**

| URL | HTTP | 响应体前缀 / 结论 |
|---|---:|---|
| `http://127.0.0.1:8080/api/app/exhibition/home` | `200` | 命中 exhibition home 聚合 |
| `http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/recommendations?boardType=company` | `200` | 命中 enterprise_hub recommendations |
| `http://127.0.0.1:8080/api/app/forum/feed` | `401` | `source":"bff"`，说明命中了 BFF forum 路由 |
| `http://127.0.0.1:8080/api/app/file/index` | `200` | `status":"skeleton_only"`，说明命中了 BFF file 路由 |
| `http://127.0.0.1:8080/api/app/file/access?fileAssetId=test&mode=view` | `401` | `source":"bff"`，说明命中了 BFF file access 路由 |

#### 云端本机 `:80`

**证据层级：云端进程与配置**

| URL | HTTP | 响应体前缀 / 结论 |
|---|---:|---|
| `http://127.0.0.1:80/api/app/exhibition/home` | `200` | 与隧道入口一致 |
| `http://127.0.0.1:80/api/app/forum/feed` | `401` | 与隧道入口一致，`source":"bff"` |
| `http://127.0.0.1:80/api/app/file/index` | `200` | 与隧道入口一致，`skeleton_only` |

#### BFF 内部 `:3000`

**证据层级：云端进程与配置**

| URL | HTTP | 响应体前缀 / 结论 |
|---|---:|---|
| `http://127.0.0.1:3000/bff/exhibition/enterprise-hub/recommendations?boardType=company` | `200` | 内部 `/bff/exhibition/...` 真实可达 |
| `http://127.0.0.1:3000/bff/forum/feed` | `401` | 内部 `/bff/forum/*` 真实可达 |
| `http://127.0.0.1:3000/bff/file/index` | `200` | 内部 `/bff/file/*` 真实可达 |
| `http://127.0.0.1:3000/bff/file/access?fileAssetId=test&mode=view` | `401` | 内部 `/bff/file/access` 真实可达 |

### 2.6 当前 `/api/app/*` 为什么能闭环

当前 `/api/app/*` 之所以能闭环，证据链为：

1. canonical 外部 family 仍然是 `/api/app/*`
2. live Nginx 将 `/api/app/*` **rewrite** 为 `/bff/*`
3. BFF active runtime 的 controller 前缀实际在 `/bff/*`
4. `:80` 与 `:3000` 探测结果相互印证

因此，当前闭环并不是“repo 样例单块 `/api/app/` 直转”带来的，而是 **live ingress rewrite + active runtime `/bff/*` controller** 共同构成的。

---

## 3. canonical path 与 internal runtime path 的边界

### 3.1 `/api/app/*` 的边界

- **当前 `/api/app/*` 仍然是唯一 canonical app-facing family。**
- 它受下列 canonical truth 共同约束：
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
  - [project_asset_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_asset_register_v1.md)
  - [new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md)

### 3.2 `/bff/*` 的边界

- **`/bff/*` 只能视为 internal runtime family。**
- 它当前承担的是：
  - BFF controller 的内部运行前缀
  - Nginx ingress rewrite 之后的 upstream path family
- 它**不能**升格为：
  - Flutter 产品契约路径
  - `openapi.yaml` 的 app-facing canonical family
  - 任何面对产品/前端的替代 contract family

### 3.3 live Nginx rewrite 的职责

当前 live Nginx rewrite 既不是“纯可忽略别名”，也不是“产品契约真相根”。

准确定位应当是：

- 它是 **ingress alias**
- 它是 **active runtime truth 的一部分**
- 它是 **允许存在但必须冻结的运行时实现细节**

含义是：

1. 它负责把 canonical `/api/app/*` 导向内部 runtime `/bff/*`
2. 它不能自己定义产品语义
3. 但 active runtime 如果依赖它闭环，它就必须被正式冻结，不能只停留在云端私有配置里

---

## 4. repo 样例与 live Nginx 的差异清单

| 差异面 | repo `infra/nginx/cloud.conf` | live `exhibition.conf` | 影响 |
|---|---|---|---|
| `/health/*/ready` | 无 | 有 `/health/bff/ready`、`/health/server/ready` | repo 样例低估 active runtime 健康入口 |
| `/api/app` location 模式 | 单一 `location /api/app/` | 多 `location`，含 exact、prefix、regex | repo 样例不能表达实际 location 优先级 |
| URI 处理 | 无 `rewrite`，`proxy_pass http://bff_upstream/;` | 多处 `rewrite ^/api/app/(.*)$ /bff/$1 break; proxy_pass http://bff_upstream;` | repo 样例无法解释 `/api/app/*` 为什么能命中 `/bff/*` controller |
| `/api/app/exhibition/*` | 全部落在单块 `/api/app/` | `workbench` 有 exact location，其余 exhibition 由 regex family 统一 rewrite | live 对 exhibition family 有更细入口控制 |
| `/api/app/forum/*` | 依赖单块 `/api/app/` | 独立 `^~ /api/app/forum/` rewrite 到 `/bff/forum/*` | forum 映射不是 repo 样例能表达的单层剥离 |
| `/api/app/file/*` | 依赖单块 `/api/app/` | 经 regex family rewrite 到 `/bff/file/*` | live 允许 `/api/app/file/index`、`/api/app/file/access` 到达 runtime |
| `/api/app/bff/*` | 无 | 有并行 `/api/app/bff/*` rewrite 规则 | live 有额外 alias 家族，repo 样例未体现 |
| upstream `3000/3001` | 有 | 有 | upstream 端口本身无漂移 |

### 4.1 为什么 repo 样例不能代表 active runtime truth

根因不是 upstream 端口错了，而是 **ingress path translation model 错了**。

当前 repo 样例表达的是：

- `/api/app/exhibition/home` -> upstream `/exhibition/home`

但当前 runtime controller 实际在：

- `/bff/exhibition/...`
- `/bff/forum/...`
- `/bff/file/...`

所以，如果只看 repo 样例，就无法解释为什么：

- `GET /api/app/exhibition/home` 实际返回 `200`
- `GET /api/app/forum/feed` 实际返回 `401 source=bff`
- `GET /api/app/file/index` 实际返回 `200 skeleton_only`

### 4.2 `/api/app/file/*` 的额外风险

当前 live runtime 通过 `/api/app/file/index` 与 `/api/app/file/access` 暴露了 app-facing reachable path。

但 canonical docs 当前只冻结了：

- `POST /api/app/file/upload/init`
- `POST /api/app/file/upload/confirm`

因此：

- `/api/app/file/index`
- `/api/app/file/access`

当前已是 **live reachable**，但**还不是已冻结的 canonical contract**。

这意味着本阻断评估不能简单得出“把 live Nginx 全量抄回 repo 就算关闭”，否则会把未冻结的 live reachable path 一并误升级为 repo baseline truth。

---

## 5. 候选关闭方案对比

| 方案 | 核心动作 | 优点 | 残留问题 | 是否建议作为单独关闭路径 |
|---|---|---|---|---|
| 方案 A：仅回写 repo baseline | 把 `infra/nginx/cloud.conf` 改写成当前 live rewrite 规则 | repo 样例与 live 更接近 | 仍缺 active override 说明；无法单独解释 `/api/app` canonical 与 `/bff` internal 边界；容易把 live reachable 非 canonical path 误写成产品真相 | 不建议 |
| 方案 B：仅新增 active override 文书 | 新增文书冻结 active runtime rewrite，repo 样例不动 | 能先把 live ingress 真相说清 | repo 继续保留误导性样例；未来 review 仍会把 stale sample 当 active truth；runtime/repo drift 仍未消除 | 不建议 |
| 方案 C：双轨冻结关闭方案 | 先以 active override 文书接管 active runtime rewrite truth，再在受控后续轮同步 repo baseline | 同时解决 active truth 冻结与 repo 误导问题；能明确 `/api/app` canonical、`/bff` internal 的边界 | 需要两步，不是本轮可实施事项；还要处理 `/api/app/file/index|access` 的 contract/暴露策略 | **唯一推荐** |

### 5.1 如果只回写文书、不回写 repo 样例

会留下的风险：

1. `infra/nginx/cloud.conf` 继续被误当成 active runtime truth。
2. 后续执行角色可能根据 stale sample 做错误联调或错误修复判断。
3. `/api/app` 与 `/bff` 的翻译关系只存在文书层，不存在 repo baseline 层，runtime/repo drift 仍然可重复发生。

### 5.2 如果只回写 repo 样例、不新增 active override 说明

会留下的风险：

1. 缺少一份正式文书明确声明：
   - `/api/app/*` 仍是 canonical family
   - `/bff/*` 只是 internal runtime family
2. 容易把 live rewrite 误读为“产品 contract 迁移到了 `/bff/*`”。
3. 容易把 `/api/app/file/index|access` 这种 live reachable path 静默吸收入 repo 样例，而不先过 contracts / BFF truth 审查。

---

## 6. 唯一推荐方案

### 6.1 推荐方案名称

**方案 C：双轨冻结关闭方案**

### 6.2 推荐方案内容

该方案不是“立即实施动作”，而是未来 blocker closure 的唯一推荐路径：

1. **先新增 active runtime rewrite baseline / override 文书**
   - 明确声明：
     - `/api/app/*` 仍是唯一 canonical app-facing family
     - `/bff/*` 仅是 internal runtime family
     - 当前 live Nginx rewrite 是 active runtime truth 的一部分
   - 同时列明 live `location` / `rewrite` / `proxy_pass` 规则与适用范围

2. **再执行 repo baseline 同步**
   - 在受控后续轮中将 `infra/nginx/cloud.conf` 同步到被冻结的 active runtime baseline
   - 或者将现有样例替换成一个明确标注为 active runtime baseline 的 repo 文件

3. **在关闭前补齐 app-facing contract 边界审查**
   - 对 `/api/app/file/index`
   - 对 `/api/app/file/access`
   - 决定它们是：
     - 进入 canonical contracts
     - 还是被后续 runtime 缩回 internal-only / no-route

### 6.3 为什么这是唯一推荐方案

因为当前问题不是单一“配置没抄回 repo”，而是三层同时漂移：

1. canonical 外部 family
2. live ingress rewrite
3. repo baseline 样例

只有双轨冻结，才能同时保证：

- 不把 `/bff/*` 升格为产品 contract
- 不把 stale repo sample 继续留作 active truth
- 不把 live reachable 但未冻结的 `/api/app/file/index|access` 悄悄制度化

---

## 7. 不允许采用的方案

以下方案不允许作为本阻断的关闭方案：

1. **只改 live Nginx，不改 repo、不补文书**
   - 原因：这是运行变更，不是评估；且会继续扩大云端私有真相。

2. **把 `/bff/*` 直接升格为 canonical app-facing family**
   - 原因：违背当前 contracts 与 `bff_routes.md`。

3. **只复制 live Nginx 到 repo 样例就宣布关闭**
   - 原因：仍未冻结 canonical `/api/app` 与 internal `/bff` 的边界。

4. **只新增文书，不处理 repo 样例漂移，就宣布关闭**
   - 原因：repo 侧误导仍在，`BLK-R0-APP-REWRITE-DRIFT` 不能算真正关闭。

5. **把当前 live reachable `/api/app/file/index|access` 自动视作已冻结 contract**
   - 原因：当前 canonical docs 未给出该结论。

---

## 8. 关闭验收条件

`BLK-R0-APP-REWRITE-DRIFT` 未来只能在以下条件全部满足后才可关闭：

1. 有一份正式 active runtime rewrite baseline / override 文书冻结当前 ingress 真相。
2. 文书中明确写出：
   - `/api/app/*` 是唯一 canonical app-facing family
   - `/bff/*` 是 internal runtime family
3. `infra/nginx/cloud.conf` 不再与 active runtime rewrite 规则漂移。
4. 本地与云端只读探测继续一致：
   - `8080/api/app/exhibition/home`
   - `80/api/app/exhibition/home`
   - `3000/bff/exhibition/enterprise-hub/recommendations`
   - `8080/api/app/forum/feed`
   - `3000/bff/forum/feed`
   - `8080/api/app/file/index`
   - `3000/bff/file/index`
   - `8080/api/app/file/access?...`
   - `3000/bff/file/access?...`
5. `/api/app/file/index|access` 的 contract 归属被明确处理：
   - 冻结为 canonical
   - 或被明确排除并在 runtime 收窄

在上述条件完成前，本阻断只能维持：

- `Open`
- `未关闭，仅完成评估`

---

## 9. 对 Round 1 准入的影响

- 当前 [new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md) 已将该问题纳入 veto 口径：
  - `no cloud-only truth drift at active runtime`
- 因此在本阻断关闭前：
  - **No-Go for Round 1 admission**
  - **No-Go for implementation**
  - **No-Go for migration / deployment / release**

本次文书的作用仅是：

- 让总控在下一轮 blocker closure 口令中有明确的候选路径与唯一推荐方案
- 不构成关闭动作本身

### 9.1 本文书的明确裁决

1. **当前 `/api/app/*` 仍然是唯一 canonical app-facing family。**
2. **`/bff/*` 只能视为 internal runtime family。**
3. **当前 repo 样例不能代表 active runtime truth。**
4. **当前 `BLK-R0-APP-REWRITE-DRIFT` 未关闭，仅完成评估。**

---

## 10. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首次形成 `BLK-R0-APP-REWRITE-DRIFT` 只读关闭评估文书；完成 canonical truth、repo sample、live Nginx、隧道实测、云端 `:80`、BFF `:3000` 直探的交叉评估，并给出唯一推荐方案 |


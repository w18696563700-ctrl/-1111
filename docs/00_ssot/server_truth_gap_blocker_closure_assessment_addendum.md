---
owner: 后端 Agent（云端）
status: frozen
purpose: Read-only closure assessment for blocker BLK-R0-SERVER-GAP. This document explains why live BFF forum/file routes can be hit while current Server truth for forum/uploads/file access is still missing, classifies the gap type, compares closure paths, gives one recommended path, and defines acceptance gates without implementing any change.
layer: L0 SSOT 配套文书
blocker_id: BLK-R0-SERVER-GAP
assessment_date_local: 2026-04-02
inputs_canonical:
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - docs/00_ssot/round0_inventory_server_agent_cloud.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
  - docs/00_ssot/round0_inventory_validation_signoff.md
  - docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md
  - docs/00_ssot/app_api_rewrite_drift_closure_assessment_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/app.module.ts
  - apps/server/src/modules/**
  - apps/bff/src/routes/forum/**
  - apps/bff/src/routes/file/**
  - apps/bff/src/core/http/server-client.service.ts
evidence_scope:
  - local SSOT/contracts/source read-only review
  - cloud live runtime file read-only review
  - cloud localhost HTTP read-only probe
  - no code change
  - no config change
  - no database change
  - no deploy
  - no release
---

# BLK-R0-SERVER-GAP 阻断关闭评估附录

## 1. 问题定义

`BLK-R0-SERVER-GAP` 的当前问题不是“BFF forum/file 路由是否存在”，而是：

- 为什么 live BFF 已能命中 `/bff/forum/*`、`/bff/file/*`
- 但对应的 `Server` truth path
  - `/server/forum/*`
  - `/server/uploads/*`
  - `/server/file/access`
  当前仍未在本地 repo 或 live runtime 中形成闭环

本轮只读评估的结论先行如下：

1. 当前 live BFF forum/file 命中，主要因为 active BFF `dist` 已真实挂载这些 controller/module。
2. 当前 `Server` active chain 只看到 `EnterpriseHubModule`，没有 forum/uploads/file access module 或 controller。
3. 当前缺口不是“这些能力本来不该由 Server 承担”。
4. 当前缺口的主因是：
   - `Server` truth 在当前 active chain 中真实缺实现
   - 同时叠加 `BFF repo/runtime drift`
   - 同时叠加部分 path 没进入 primary `openapi.yaml` 冻结

唯一需要明确排除的是：

- `GET /bff/file/index`
  - 这是 BFF skeleton 路由
  - 没有调用上游 truth path
  - 不能被当成 `Server` file truth 已存在的证据

## 2. 当前证据链

### 2.1 本地 repo 证据

`Server` 本地 repo 当前情况：

- `apps/server/src/app.module.ts` 仅引入 `EnterpriseHubModule`
- `apps/server/src/modules/**` 当前仅能定位到 `enterprise_hub/**`
- 未定位到 forum/uploads/file access 模块、controller、service

`BFF` 本地 repo 当前情况：

- `apps/bff/src/routes/forum/**` 与 `apps/bff/src/routes/file/**` 目录存在
- `apps/bff/src/core/http/server-client.service.ts` 负责直连 `Server`
- 本地 `forum/file` 源码显式依赖：
  - `/server/forum/*`
  - `/server/uploads/init`
  - `/server/uploads/confirm`
  - `/server/file/access`
- 但本地 `apps/bff/src/routes/routes.module.ts` 只挂 `EnterpriseHubModule`

这说明：

- 本地 repo 已经存在 forum/file 的 upstream 假设
- 但本地 repo 既不是当前 `BFF` active runtime 的可靠代表
- 更不是当前 `Server` truth 已实现的证据

### 2.2 contracts / SSOT 证据

`docs/01_contracts/openapi.yaml` 当前冻结情况：

- 已冻结大量 app-facing forum path：
  - `/api/app/forum/feed`
  - `/api/app/forum/topic/metadata`
  - `/api/app/forum/topic/list`
  - `/api/app/forum/topic/detail`
  - `/api/app/forum/post/detail`
  - `/api/app/forum/post/comments`
  - `/api/app/forum/post/comment`
  - `/api/app/forum/post/like`
  - `/api/app/forum/post/bookmark`
  - `/api/app/forum/topic/follow`
  - `/api/app/forum/publish`
  - `/api/app/forum/draft/save`
  - `/api/app/forum/draft/list`
  - `/api/app/forum/draft/delete`
  - `/api/app/forum/search`
  - `/api/app/forum/me/index`
  - `/api/app/forum/me/posts`
  - `/api/app/forum/me/comments`
  - `/api/app/forum/me/bookmarks`
  - `/api/app/forum/me/follows`
  - `/api/app/forum/interaction/inbox`
- 已冻结 file app-facing upload path：
  - `/api/app/file/upload/init`
  - `/api/app/file/upload/confirm`
- primary `openapi.yaml` 当前未冻结：
  - `/server/forum/*`
  - `/server/uploads/*`
  - `/server/file/access`
  - `/api/app/file/index`
  - `/api/app/file/access`

SSOT / BFF boundary 当前口径：

- `forum truth remains owned by Server`
- `BFF` 只能做 forum route-group shaping，不能拥有 forum truth
- upload flow 必须仍是 `init -> direct upload -> confirm`
- `FileAsset` 是 file truth
- `BFF` 只 shape shared file access，不拥有 file truth
- forum published attachment access 方向明确要求复用 shared `/api/app/file/*` family

因此：

- forum truth 与 shared upload/file truth 依然都应回到 `Server`
- 当前不是“能力边界本来就不应由 Server 承担”

### 2.3 cloud live runtime 证据

#### 2.3.1 BFF live probe

无头探测：

- `GET http://127.0.0.1:3000/bff/forum/feed`
  - `401 AUTH_SESSION_INVALID`
  - 来源：BFF 鉴权前置
- `GET http://127.0.0.1:3000/bff/file/index`
  - `200`
  - body: `skeleton_only`
  - 来源：BFF 本地 skeleton 路由
- `GET http://127.0.0.1:3000/bff/file/access?fileAssetId=test&mode=view`
  - `401 AUTH_SESSION_INVALID`
  - 来源：BFF 鉴权前置

带最小 actor 头探测：

- `GET http://127.0.0.1:3000/bff/forum/feed?scope=square`
  - `404`
  - `code=FORUM_FEED_FAILED`
  - `message=Cannot GET /server/forum/feed?scope=square`
  - `source=server`
- `GET http://127.0.0.1:3000/bff/file/access?fileAssetId=test&mode=view`
  - `404`
  - `code=FILE_ACCESS_FAILED`
  - `details.originalMessage=Cannot GET /server/file/access?...`
  - `source=server`
- `POST http://127.0.0.1:3000/bff/file/upload/init`
  - 空 body 时 `400 FILE_UPLOAD_INIT_INVALID`
  - 最小合法 body 时 `404 FILE_UPLOAD_INIT_FAILED`
  - `message=Cannot POST /server/uploads/init`
  - `source=server`
- `POST http://127.0.0.1:3000/bff/file/upload/confirm`
  - 空 body 时 `400 FILE_UPLOAD_CONFIRM_REQUIRED`
  - 最小合法 body 时 `404`
  - `details.originalMessage=Cannot POST /server/uploads/confirm`
  - `source=server`

这说明：

- BFF forum/file controller 确实命中了
- 但一旦越过 BFF 自身鉴权或参数校验，就会撞到 Server raw 404

#### 2.3.2 Server live probe

直接探测 `Server`：

- `GET http://127.0.0.1:3001/server/forum/feed`
  - raw `404 Cannot GET /server/forum/feed`
- `GET http://127.0.0.1:3001/server/forum/topic/list?categoryKey=all`
  - raw `404 Cannot GET /server/forum/topic/list`
- `POST http://127.0.0.1:3001/server/forum/draft/delete`
  - raw `404 Cannot POST /server/forum/draft/delete`
- `GET http://127.0.0.1:3001/server/forum/me/posts?pageSize=1`
  - raw `404 Cannot GET /server/forum/me/posts`
- `GET http://127.0.0.1:3001/server/uploads/init`
  - raw `404 Cannot GET /server/uploads/init`
- `POST http://127.0.0.1:3001/server/uploads/init`
  - raw `404 Cannot POST /server/uploads/init`
- `POST http://127.0.0.1:3001/server/uploads/confirm`
  - raw `404 Cannot POST /server/uploads/confirm`
- `GET http://127.0.0.1:3001/server/file/access?fileAssetId=test&mode=view`
  - raw `404 Cannot GET /server/file/access?...`

这说明：

- 当前 active `Server` chain 中，这些 truth path family 不是权限问题
- 不是路径错位问题
- 而是 controller/path family 根本没挂上

#### 2.3.3 80 口对照

带最小 actor 头：

- `GET http://127.0.0.1/api/app/forum/feed?scope=square`
  - `404 FORUM_FEED_FAILED`
  - `source=server`
- `GET http://127.0.0.1/api/app/file/access?fileAssetId=test&mode=view`
  - `404 FILE_ACCESS_FAILED`
  - `source=server`
- `POST http://127.0.0.1/api/app/file/upload/init`
  - `404 FILE_UPLOAD_INIT_FAILED`
  - `source=server`
- `POST http://127.0.0.1/api/app/file/upload/confirm`
  - `404`
  - `details.originalMessage=Cannot POST /server/uploads/confirm`
  - `source=server`

这说明：

- `80 -> Nginx -> BFF` app-facing 主链是通的
- 当前错误是 BFF 命中后转发到缺失的 Server truth path

### 2.4 active runtime 文件证据

live BFF `dist` 已确认：

- `routes.module.js` 当前实际挂入了 `ForumModule` 与 `FileModule`
- `forum.controller.js` 当前 active runtime 暴露了：
  - `feed`
  - `topic/metadata`
  - `topic/list`
  - `topic/detail`
  - `post/detail`
  - `post/comments`
  - `post/comment`
  - `post/like`
  - `post/bookmark`
  - `draft/save`
  - `publish`
  - `draft/list`
  - `draft/delete`
  - `search`
  - `me/index`
  - `me/posts`
  - `me/comments`
  - `me/bookmarks`
- `file.controller.js` 当前 active runtime 暴露了：
  - `index`
  - `upload/init`
  - `upload/confirm`
  - `access`

live Server `dist` 已确认：

- `dist/app.module.js` 只引入 `EnterpriseHubModule`
- `current` 目录下未定位到 forum/upload/file module tree

因此：

- BFF runtime 命中是事实
- Server truth 未挂载也是事实
- 当前更像“BFF 先行 + Server truth 缺失”的失配，而不是“Server truth 已存在但 repo 忘了回库”

## 3. BFF 依赖的 upstream truth map

### 3.1 forum

#### 当前 active runtime 已暴露的 forum family

| BFF active route family | upstream truth path |
|---|---|
| `GET /bff/forum/feed` | `GET /server/forum/feed` |
| `GET /bff/forum/topic/metadata` | `GET /server/forum/topic/metadata` |
| `GET /bff/forum/topic/list` | `GET /server/forum/topic/list` |
| `GET /bff/forum/topic/detail` | `GET /server/forum/topic/detail` |
| `GET /bff/forum/post/detail` | `GET /server/forum/post/detail` |
| `GET /bff/forum/post/comments` | `GET /server/forum/post/comments` |
| `POST /bff/forum/post/comment` | `POST /server/forum/post/comment` |
| `POST /bff/forum/post/like` | `POST /server/forum/post/like` |
| `POST /bff/forum/post/bookmark` | `POST /server/forum/post/bookmark` |
| `POST /bff/forum/draft/save` | `POST /server/forum/draft/save` |
| `POST /bff/forum/publish` | `POST /server/forum/publish` |
| `GET /bff/forum/draft/list` | `GET /server/forum/draft/list` |
| `POST /bff/forum/draft/delete` | `POST /server/forum/draft/delete` |
| `GET /bff/forum/search` | `GET /server/forum/search` |
| `GET /bff/forum/me/index` | `GET /server/forum/me/index` |
| `GET /bff/forum/me/posts` | `GET /server/forum/me/posts` |
| `GET /bff/forum/me/comments` | `GET /server/forum/me/comments` |
| `GET /bff/forum/me/bookmarks` | `GET /server/forum/me/bookmarks` |

#### 本地 repo source 还假定存在、但当前 active dist 未暴露的 forum family

| source-only route family | assumed upstream truth path | 当前判断 |
|---|---|---|
| `GET /bff/forum/author/profile` | `GET /server/forum/author/profile` | 本地 source 有；active dist controller 未暴露 |
| `GET /bff/forum/author/posts` | `GET /server/forum/author/posts` | 本地 source 有；active dist controller 未暴露 |
| `GET /bff/forum/draft/detail` | `GET /server/forum/draft/detail` | 本地 source 有；active dist controller 未暴露 |
| `POST /bff/forum/report/submit` | `POST /server/forum/report/submit` | 本地 source 有；active dist controller 未暴露 |
| `POST /bff/forum/post/edit` | `POST /server/forum/post/edit` | 本地 source 有；active dist controller 未暴露 |
| `POST /bff/forum/post/delete` | `POST /server/forum/post/delete` | 本地 source 有；active dist controller 未暴露 |

### 3.2 file

| BFF route | upstream truth path | 当前说明 |
|---|---|---|
| `GET /bff/file/index` | 无 | BFF skeleton_only，不是 Server truth 证据 |
| `POST /bff/file/upload/init` | `POST /server/uploads/init` | 当前 upstream raw 404 |
| `POST /bff/file/upload/confirm` | `POST /server/uploads/confirm` | 当前 upstream raw 404 |
| `GET /bff/file/access` | `GET /server/file/access` | 当前 upstream raw 404 |

## 4. contracts / SSOT / Server repo / Server runtime 四层对照

| path family | contracts / OpenAPI | SSOT | Server repo | Server runtime | 当前状态与诊断 |
|---|---|---|---|---|---|
| `/server/forum/feed` | 对应 app-facing `/api/app/forum/feed` 已冻结；internal `/server/forum/feed` 未在 primary `openapi.yaml` 冻结 | forum truth owner 已冻结为 `Server` | 未实现 | raw 404 | 主因是 `Server` truth 缺实现；同时 internal truth path 未进入 primary contracts |
| `/server/forum/*` 当前 active runtime family | 对应多数 `/api/app/forum/*` 已冻结；但 internal `/server/forum/*` family 未写入 primary `openapi.yaml` | forum truth 归 `Server`，BFF 不得持有 forum truth | 未实现 | family sample 全为 raw 404 | 这是当前 blocker 主体：`Server` truth 缺实现为主，叠加 BFF/runtime 先行 |
| `/server/forum/*` source-only extra family | author/profile、draft/detail、post/edit/delete、report/submit 未在 primary `openapi.yaml` 冻结 | 方向上仍属 forum truth，不应落到 BFF | repo source 假定存在 | active dist controller 未暴露 | 这是 source/runtime drift，不应拿来证明当前 live truth 已存在 |
| `/server/uploads/init` | 对应 `/api/app/file/upload/init` 已冻结；internal `/server/uploads/init` 未冻结 | 三段式 upload 与 `FileAsset` truth 已冻结 | 未实现 | raw `GET/POST 404` | `Server` shared upload truth 缺实现 |
| `/server/uploads/confirm` | 对应 `/api/app/file/upload/confirm` 已冻结；internal `/server/uploads/confirm` 未冻结 | 三段式 upload 与 `FileAsset` truth 已冻结 | 未实现 | raw `POST 404` | `Server` shared upload truth 缺实现 |
| `/server/file/access` | primary `openapi.yaml` 未冻结 `/server/file/access`，也未冻结 `/api/app/file/access` | 附件读取方向已在 SSOT/BFF boundary 冻结为 shared `/api/app/file/*`，且 BFF 不拥有 file truth | 未实现 | raw `GET 404` | `Server` file access truth 缺实现，同时 primary contracts 也未补齐 |
| `/api/app/file/index` | 未冻结 | 未冻结为正式 truth surface | 不适用 | live runtime 可见 | `未冻结但 runtime 可见`；是 BFF skeleton route，不构成 blocker 关闭证据 |

### 4.1 对四种可能性的正式裁定

#### A. 真相实现缺失

结论：`成立，而且是主因。`

证据：

- 当前 active `Server` repo 与 `dist` 都只看到 `EnterpriseHubModule`
- `/server/forum/*`、`/server/uploads/*`、`/server/file/access` raw probe 全部 404

#### B. repo 未回库

结论：`对 BFF 成立，对当前 Server active chain 不足以成立。`

解释：

- `BFF` 明确存在 repo/runtime drift
- 但当前 `Server` active chain 上没有看到“truth 已在 runtime 存在，只是本地 repo 没回库”的证据
- 对 `Server` 当前更接近“active chain 就没有”

#### C. active runtime 未冻结

结论：`成立，但不是主因。`

解释：

- BFF active runtime 与本地 repo 明显不一致
- 但即使只看 active runtime，本轮 raw `Server` probe 仍然是 404
- 所以 runtime 未冻结解释不了 `Server` truth 缺失本身

#### D. 能力边界本来就不应由 Server 承担

结论：`不成立。`

解释：

- forum truth owner 在 SSOT 明确仍是 `Server`
- shared upload/file truth 在 SSOT 明确仍应回到 `Server + FileAsset`
- BFF 只能做 shaping / auth consolidation / error normalization

## 5. 候选关闭方案对比

| 方案 | 是否需要补 Server truth | 是否需要回收 BFF 路由 | 是否需要补 contracts | 是否需要补 SSOT | 是否影响当前 `/api/app/forum/*` 与 `/api/app/file/*` | 风险等级 | 推荐结论 |
|---|---|---|---|---|---|---|---|
| 方案 A｜Truth-first 补齐 Server family，并保住当前 app-facing surface | 是 | 否，原则上保留当前已命中的 app-facing surface | 是 | 是 | 目标是保住当前已命中的 forum/file 主链，并把缺失 truth 补齐到后端 | 高 | 推荐 |
| 方案 B｜回收当前无 truth 背书的 BFF forum/file surface，收缩到已闭环最小面 | 否或只补极少 | 是 | 是 | 是 | 会直接影响当前 `/api/app/forum/*`、`/api/app/file/*` 入口，可造成主链收缩 | 极高 | 不推荐 |

### 5.1 方案 A 说明

方案 A 的含义是：

1. 承认当前已命中的 app-facing forum/file surface 是 active runtime 事实
2. 不让 BFF 接管 truth ownership
3. 反向补齐当前 BFF 已依赖的 `Server` truth family，至少覆盖当前 active runtime 真正打到的最小集：
   - `/server/forum/*` active family
   - `/server/uploads/init`
   - `/server/uploads/confirm`
   - `/server/file/access`
4. 同步把 contracts / SSOT / repo / release 收口为单一真相

优点：

- 与 `Server` truth ownership、shared `FileAsset` truth 边界一致
- 不会靠 BFF 越界来关闭 blocker
- 能保住当前 app-facing forum/file 联调链

缺点：

- 成本最高
- 不只是补 `Server`，还要同步处理 BFF repo/runtime drift 与 contracts 漏项

### 5.2 方案 B 说明

方案 B 的含义是：

1. 不先补 `Server` truth
2. 直接回收当前 BFF 已暴露、但没有 `Server` truth 背书的 forum/file surface
3. 通过收缩 runtime 暂时消失 blocker

问题：

- `/api/app/forum/*` 已是当前外部主链的一部分
- `/api/app/file/upload/init|confirm` 在 primary `openapi.yaml` 已冻结
- `/api/app/file/access` 虽未进 primary `openapi.yaml`，但 SSOT/BFF boundary 已明确方向
- 该方案会把“truth 缺失”改成“入口消失”，本质上是收缩而不是闭环

## 6. 唯一推荐方案

### 6.1 唯一推荐方案名称

`方案 A｜Truth-first 补齐 Server forum/uploads/file-access family，并收口 repo/runtime/contracts/SSOT`

### 6.2 推荐理由

- 当前 forum truth 和 shared file truth 都明确不应下沉到 BFF
- 当前 raw 404 发生在 `Server`，不是路径错位，也不是权限拒绝
- 关闭这个 blocker 的唯一正确方向，是把 truth 补回 `Server`
- 同时要把当前 active BFF surface 正式冻结并回库，否则只会把 `Server` gap 变成新的 repo/runtime gap

### 6.3 当前不推荐把 blocker 降级的理由

- `/server/forum/*` family 当前仍 raw 404
- `/server/uploads/init|confirm` 当前仍 raw 404
- `/server/file/access` 当前仍 raw 404
- `/api/app/forum/*` 与 `/api/app/file/*` 当前仍依赖 BFF 对缺失 upstream 的 error wrapping

因此：

- 当前不能把 `BLK-R0-SERVER-GAP` 从 blocker / veto 降级

## 7. 不允许采用的方案

### 7.1 不允许方案一：把 forum/file truth 临时下沉给 BFF

原因：

- 直接违反 `BFF must not own forum truth`
- 直接违反 shared `FileAsset` truth 边界

### 7.2 不允许方案二：拿 `/bff/file/index` 的 skeleton_only 当关闭证据

原因：

- 该路径没有命中 `Server`
- 它只是 BFF skeleton，占位信息里还明确写着 `truthOwner=Server.evidence`

### 7.3 不允许方案三：仅根据 BFF runtime 可命中就判定 Server truth 已存在

原因：

- 当前已经证明 BFF 命中后会转成 `Server` raw 404
- “BFF 有响应”不等于“Server truth 已闭环”

## 8. 关闭验收条件

若要把 `BLK-R0-SERVER-GAP` 标记为关闭，最小验收集至少应满足：

### 8.1 Server raw path 验收

1. `GET http://127.0.0.1:3001/server/forum/feed?scope=square`
   - 不再出现 raw `Cannot GET /server/forum/feed`
   - 应返回 `200 / 401 / 403 / controlled business error` 之一
2. `GET http://127.0.0.1:3001/server/forum/topic/list?categoryKey=all`
   - 不再出现 raw `Cannot GET /server/forum/topic/list`
3. `POST http://127.0.0.1:3001/server/forum/draft/delete`
   - 不再出现 raw `Cannot POST /server/forum/draft/delete`
4. `POST http://127.0.0.1:3001/server/uploads/init`
   - 不再出现 raw `Cannot POST /server/uploads/init`
5. `POST http://127.0.0.1:3001/server/uploads/confirm`
   - 不再出现 raw `Cannot POST /server/uploads/confirm`
6. `GET http://127.0.0.1:3001/server/file/access?fileAssetId=test&mode=view`
   - 不再出现 raw `Cannot GET /server/file/access`

### 8.2 BFF / app-facing 验收

1. `GET http://127.0.0.1:3000/bff/forum/feed?scope=square` 带最小 actor 头
   - 不再返回 `FORUM_FEED_FAILED + Cannot GET /server/forum/feed`
2. `POST http://127.0.0.1:3000/bff/file/upload/init` 带合法 payload
   - 不再返回 `Cannot POST /server/uploads/init`
3. `POST http://127.0.0.1:3000/bff/file/upload/confirm` 带最小合法 payload
   - 不再返回 `Cannot POST /server/uploads/confirm`
4. `GET http://127.0.0.1:3000/bff/file/access?...` 带最小 actor 头
   - 不再返回 `Cannot GET /server/file/access`
5. `GET http://127.0.0.1:80/api/app/forum/feed?scope=square`
   - 与 `3000/bff/forum/feed` 保持同结果等级
6. `POST http://127.0.0.1:80/api/app/file/upload/init`
   - 与 `3000/bff/file/upload/init` 保持同结果等级
7. `POST http://127.0.0.1:80/api/app/file/upload/confirm`
   - 与 `3000/bff/file/upload/confirm` 保持同结果等级
8. `GET http://127.0.0.1:80/api/app/file/access?...`
   - 与 `3000/bff/file/access` 保持同结果等级

### 8.3 文书与角色验收

至少需要同步更新：

- `docs/00_ssot/project_asset_register_v1.md`
- `docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md`
- `docs/00_ssot/round0_inventory_server_agent_cloud.md`
- `docs/00_ssot/round0_inventory_release_integration_agent.md`
- `docs/00_ssot/round0_inventory_validation_signoff.md`
- `docs/00_ssot/bff_runtime_repo_drift_closure_assessment_addendum.md`
- `docs/00_ssot/app_api_rewrite_drift_closure_assessment_addendum.md`
- `docs/01_contracts/openapi.yaml`

至少需要复核的角色：

- 后端 Agent（云端）
- BFF Agent（云端）
- 联调发布 Agent
- 结果校验 Agent
- Codex 总控

## 9. 对 Round 1 准入的影响

本评估的正式结论是：

- `BLK-R0-SERVER-GAP` 当前仍未关闭
- 当前至少部分 path 仍是 `Server` truth 缺口
- 当前不允许把该项降级

具体影响：

- 当前仍然 `No-Go for Round 1`
- 即使后续按推荐方案关闭，也只是清掉一个关键 blocker
- 它不自动解除：
  - `BLK-R0-APP-REWRITE-DRIFT`
  - `BLK-R0-RUNTIME-REPO-DRIFT`
  - `BLK-R0-ENV-PURITY`
  - `BLK-R0-FILE-LENGTH`

## 10. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首版。完成 `BLK-R0-SERVER-GAP` 只读关闭评估；确认 `BFF` forum/file live 命中来自 active `dist`，确认当前 `Server` active chain 缺少 forum/uploads/file-access truth family，确认主因是 `Server` truth 缺实现，唯一推荐方案为“方案 A｜Truth-first 补齐 Server forum/uploads/file-access family，并收口 repo/runtime/contracts/SSOT” |

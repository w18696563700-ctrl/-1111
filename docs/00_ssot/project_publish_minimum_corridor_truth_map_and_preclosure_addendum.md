---
owner: 后端 Agent（云端）
status: frozen
purpose: Read-only truth mapping and pre-closure sheet for the project publish minimum-success corridor only. This document freezes the current truth map for project create/detail and the three-step upload chain, compares local repo/contracts/live runtime, defines what is existing vs missing vs compatibility-only, and names the single recommended closure path before any formal dispatch.
layer: L0 SSOT 配套文书
assessment_date_local: 2026-04-02
scope:
  - /exhibition/projects/create
  - POST /api/app/project/create
  - GET /api/app/project/detail
  - POST /api/app/file/upload/init
  - direct upload
  - POST /api/app/file/upload/confirm
evidence_scope:
  - local docs/contracts/source read-only review
  - cloud live runtime file read-only review
  - cloud localhost HTTP read-only probe
  - no code change
  - no config change
  - no database change
  - no build
  - no deploy
  - no release
inputs_canonical:
  - docs/00_ssot/control_priority_ruling_round0_global_veto_vs_project_publish_board_freeze_chain_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - docs/00_ssot/server_truth_gap_blocker_closure_assessment_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/**
  - apps/server/src/**
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
---

# 项目发布最小成功走廊真相映射与关闭前置单

## 1. 问题定义

本附录只回答项目发布最小成功走廊的 truth 问题，不讨论 bid/order/contract/milestone/inspection/rating/dispute。

本轮固定结论先行：

1. `POST /api/app/project/create` 当前 live BFF 已实际承接，但内部转发到 `POST /server/projects` 后撞上 live Server raw `404`。
2. `GET /api/app/project/detail` 当前 live BFF 已实际承接，但内部转发到 `GET /server/projects/{projectId}` 后，会把 upstream `404` 归一化成 BFF `404 AUTH_RESOURCE_UNAVAILABLE`。
3. publish 场景下文件三段上传链的 truth owner 仍然是 `Server`，且 business truth 仍应落在 `FileAsset`，不是 `objectKey`；对当前项目发布走廊，移动端已实际使用 `businessType=project`、`fileKind=evidence`。
4. `/server/projects` 当前在 primary contracts 中仍只是 skeleton/compatibility family，不是已经闭环的 internal canonical truth family。
5. 若该板块进入正式派工，最小必备关闭项不是“先补 BFF 页面”，而是先冻结并补齐：
   - project create/detail internal truth family
   - upload init/confirm internal truth family
   - repo/runtime 一致口径
   - 该 touch-set 的 file-length 治理前置

## 2. 最小成功走廊 Truth Map

| 走廊项 | app-facing path | BFF internal path | Server canonical path | truth owner | 当前状态 |
|---|---|---|---|---|---|
| 项目创建 | `POST /api/app/project/create` | `POST /bff/project/create` | `POST /server/projects` | `Server.project` | app-facing contract 已冻结；移动端消费已存在；live BFF dist 已挂载并转发到 `/server/projects`；primary contracts 仅有 placeholder skeleton；live Server raw `404` |
| 项目详情 | `GET /api/app/project/detail?projectId=...` | `GET /bff/project/detail?projectId=...` | `GET /server/projects/{projectId}` | `Server.project` read truth | app-facing contract 已冻结；移动端消费已存在；live BFF dist 已挂载并转发到 `/server/projects/{projectId}`；primary contracts 未冻结该 internal read path；live BFF 当前把 upstream `404` 归一化成 `AUTH_RESOURCE_UNAVAILABLE` |
| 上传初始化 | `POST /api/app/file/upload/init` | `POST /bff/file/upload/init` | `POST /server/uploads/init` | `Server` shared upload truth | app-facing contract 已冻结；移动端消费已存在；移动端当前 publish 参数为 `businessType=project`、`fileKind=evidence`；local BFF source 已有 file orchestrator；primary contracts 未冻结 `/server/uploads/init`；live Server raw `404` |
| direct upload | `directUpload.url` from init response | 无 BFF canonical path，直传对象存储 | 无业务 canonical path；仅 transport URL | bytes transport 不拥有 business truth；truth 仍由 `Server` 持有 | 该步骤在 contracts 中只以 signed directive skeleton 形式存在；它不是 business truth，不应被误写成 BFF/OSS truth owner |
| 上传确认 | `POST /api/app/file/upload/confirm` | `POST /bff/file/upload/confirm` | `POST /server/uploads/confirm` | `Server + FileAsset` | app-facing contract 已冻结；local BFF source/runtime 已存在；primary contracts 未冻结 `/server/uploads/confirm`；live Server raw `404`；当前 live BFF 会把 upstream `404` 包成 `FILE_UPLOAD_CONFIRM_REQUIRED` 受控失败 |

### 2.1 当前 live internal compatibility 别名

active BFF dist 额外带有以下 compatibility/internal aliases：

- `POST /bff/project`
- `GET /bff/project`
- `GET /bff/project/:projectId`

本附录裁定：

- 这些路径不能升格为项目发布板块的 internal truth。
- 当前板块应只沿用与 app-facing 对齐的 internal BFF corridor：
  - `/bff/project/create`
  - `/bff/project/detail`

## 3. repo / contracts / runtime 三层对照

| 主题 | local repo | contracts | live runtime | 结论 |
|---|---|---|---|---|
| `/exhibition/projects/create` 入口 | 已存在，`project_create_page.dart` 与 `exhibition_routes.dart` 已接线 | 不适用 | 页面消费资产已存在 | 可沿用 |
| `/api/app/project/create` | 移动端 canonical path 常量已存在 | 已冻结，`202 + projectId` | `80 -> BFF` 可达；带最小头与合法 body 时返回 `404 PROJECT_CREATE_FAILED`，消息为 `Cannot POST /server/projects` | app-facing 已存在；Server truth 未闭环 |
| `/api/app/project/detail` | 移动端 canonical path 常量已存在，detail continuation 已存在 | 已冻结，返回 `ProjectReadModel` | `80 -> BFF` 可达；带最小头时返回 `404 AUTH_RESOURCE_UNAVAILABLE` | app-facing 已存在；BFF 以受控错误遮蔽 upstream missing truth |
| BFF project source | 本地 `apps/bff/src/routes/project` 目录为空；`RoutesModule` 只挂 `EnterpriseHubModule` | 不适用 | active dist 已存在 `ProjectModule/ProjectController/ProjectService` | 明确 runtime/repo drift |
| BFF project internal mapping | 本地 repo 不可作为当前权威来源 | 不适用 | active dist 明确：`create -> POST /server/projects`，`detail -> GET /server/projects/{projectId}` | 当前 internal mapping 只能以 live dist 证据登记 |
| Server project source | 本地 `apps/server/src/modules/project` 目录存在但为空；`AppModule` 未挂 project module | `/server/projects` 只有 skeleton，占位至 contract freeze | live Server `POST /server/projects` raw `404`；`GET /server/projects?projectId=...` raw `404`；dist 中无 project module | project truth 未实现 |
| Server project detail internal path | 本地 repo 未见 controller/service | primary `openapi.yaml` 未冻结 `GET /server/projects/{projectId}` | active BFF dist 依赖该 path；live Server 实际缺失 | 必须补 contracts + 实现 |
| `/api/app/file/upload/init` | 移动端消费、BFF file source 已存在 | 已冻结 | 带最小头与合法 body 时返回 `404 FILE_UPLOAD_INIT_FAILED`，消息为 `Cannot POST /server/uploads/init` | app-facing 已存在；Server upload truth 未闭环 |
| direct upload | 移动端消费已存在 | init response 中有 `directUpload.url/method/headers` skeleton | 取决于 init 成功；当前因 init 未通而无法进入 | transport step 不是 truth |
| `/api/app/file/upload/confirm` | 移动端消费、BFF file source 已存在 | 已冻结，强调 `FileAsset` confirmation skeleton | 带最小头与合法 body 时返回 `404` 包装错误，`originalMessage=Cannot POST /server/uploads/confirm` | app-facing 已存在；Server confirm truth 未闭环 |
| upload internal paths | local BFF source 已写死 `/server/uploads/init|confirm` | primary `openapi.yaml` 未冻结 `/server/uploads/init|confirm` | live Server raw `404` | 必须补 contracts + 实现 |
| upload truth owner | local SSOT 明确 `Server`、`FileAsset`、`objectKey not truth` | app-facing upload contracts 已体现 `FileAsset` confirmation 与 `objectKey` 非真相 | live BFF skeleton 仍写明 `truthOwner=Server.evidence` | truth owner 已冻结，但 internal path/实现未闭环 |
| publish upload businessType | 移动端当前实际发送 `businessType=project`、`fileKind=evidence` | primary contracts 冻结了字段名，但未冻结 publish-specific 枚举与 binding 语义 | live runtime 因 upstream 404 未能证成 | 必须补 SSOT |
| corridor error codes | 移动端已有 `PROJECT_CREATE_INVALID`、`AUTH_RESOURCE_UNAVAILABLE` 等消费面 | generated error codes 已有 `PROJECT_CREATE_INVALID`、`AUTH_RESOURCE_UNAVAILABLE`、`FILE_UPLOAD_CONFIRM_REQUIRED`；未见 `PROJECT_CREATE_FAILED`、`FILE_UPLOAD_INIT_FAILED`、`FILE_UPLOAD_INIT_INVALID` | live BFF 当前实际会返回这些未冻结 code | corridor 错误码仍有 contract gap |

## 4. 当前哪些存在 / 不存在 / compatibility / 必须补什么

### 4.1 已存在

- `/exhibition/projects/create` 前端入口与 create/detail continuation 已存在。
- `/api/app/project/create`、`/api/app/project/detail`、`/api/app/file/upload/init`、`/api/app/file/upload/confirm` app-facing contracts 已冻结。
- 移动端当前 publish 上传参数已存在且可读：
  - `businessType=project`
  - `fileKind=evidence`
- local BFF file source 已存在。
- live BFF runtime 已真实挂载：
  - `/bff/project/create`
  - `/bff/project/detail`
  - `/bff/file/upload/init`
  - `/bff/file/upload/confirm`

### 4.2 不存在

- primary contracts 中不存在 `GET /server/projects/{projectId}`。
- primary contracts 中不存在 `POST /server/uploads/init`。
- primary contracts 中不存在 `POST /server/uploads/confirm`。
- local Server source 中不存在已挂载的 project truth module/controller/service。
- live Server runtime 中不存在 project truth 与 shared upload truth controller。

### 4.3 只是历史遗留或 compatibility family

- `/server/projects` 当前仍是 skeleton/compatibility family：
  - primary `openapi.yaml` 只有 placeholder `202`
  - 没有 requestBody freeze
  - 没有 detail read pair
  - live runtime 未实现
- active BFF dist 的以下路径应视为 compatibility/internal alias，而不是本轮 truth：
  - `POST /bff/project`
  - `GET /bff/project`
  - `GET /bff/project/:projectId`

### 4.4 必须补 contracts

- 把 `POST /server/projects` 从 placeholder skeleton 升级为最小 corridor 内部命令合同。
- 新增并冻结 `GET /server/projects/{projectId}`。
- 冻结 `POST /server/uploads/init` 与 `POST /server/uploads/confirm` 的 internal truth 合同。
- 补齐 corridor 实际会暴露的错误码，至少复核：
  - `PROJECT_CREATE_FAILED`
  - `FILE_UPLOAD_INIT_FAILED`
  - `FILE_UPLOAD_INIT_INVALID`

### 4.5 必须补 SSOT

- 冻结项目发布最小走廊 internal truth family：
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
  - `POST /server/uploads/init`
  - `POST /server/uploads/confirm`
- 冻结 publish 场景 upload truth：
  - `businessType=project`
  - `fileKind=evidence`
  - confirm 产出 `FileAsset` truth
  - `objectKey` 只是 storage location
- 冻结“detail 走廊最小读模型”边界：
  - 继续沿用 shared `ProjectReadModel`
  - 当前不要求把项目附件列表扩展进 detail read model

### 4.6 必须补实现

- Server project create truth
- Server project detail read truth
- Server upload init truth
- Server upload confirm truth
- repo 内 BFF project source 与 active runtime 对齐

## 5. `/server/projects` 当前判定

本附录的明确裁决是：

- `/server/projects` **当前仍是 compatibility/skeleton family**
- 它**还不是**本轮已闭环的 canonical internal truth family

判断依据：

1. primary `openapi.yaml` 对 `/server/projects` 仍写着 `Project creation skeleton`。
2. 当前没有配对的 `GET /server/projects/{projectId}` internal contract。
3. local Server source 没有已挂载 project truth。
4. live Server `POST /server/projects` raw `404`。

但本附录同时给出唯一推荐方向：

- **不要发明新的 internal family**
- 应在后续关闭动作中把当前 `/server/projects` family 升级为项目发布最小走廊的 canonical internal truth family

准确含义是：

- 保留 `POST /server/projects`
- 增补 `GET /server/projects/{projectId}`
- 不再另造 `/server/project/create`、`/server/project/detail` 或 `/server/project-publish/*`

## 6. 最小关闭清单

### 6.1 先补 truth

1. 冻结项目发布最小走廊 internal truth family：
   - `POST /server/projects`
   - `GET /server/projects/{projectId}`
   - `POST /server/uploads/init`
   - `POST /server/uploads/confirm`
2. 冻结 publish upload 语义：
   - `businessType=project`
   - `fileKind=evidence`
   - confirm 生成 `FileAsset`
   - `FileAsset` 是 shared file truth
   - direct upload 只传字节，不产生业务真相
3. 冻结 corridor detail 边界：
   - create 成功只返回 `projectId`
   - detail 只返回 shared `ProjectReadModel`
   - 当前不强制 detail 承担项目附件 read projection

### 6.2 再补 contracts

1. 升级 `POST /server/projects` 的 request/response。
2. 新增 `GET /server/projects/{projectId}`。
3. 新增 `POST /server/uploads/init`。
4. 新增 `POST /server/uploads/confirm`。
5. 补 corridor 实际错误码登记。

### 6.3 再补 BFF

1. 让 repo 中的 BFF source 与 active runtime route graph 一致。
2. 保持 app-facing 只走：
   - `/api/app/project/create`
   - `/api/app/project/detail`
   - `/api/app/file/upload/init`
   - `/api/app/file/upload/confirm`
3. 保持 internal BFF corridor 只走：
   - `/bff/project/create`
   - `/bff/project/detail`
   - `/bff/file/upload/init`
   - `/bff/file/upload/confirm`
4. 禁止把 compatibility aliases 升格为 truth。

### 6.4 最后补 frontend consumption

1. 保持 `/exhibition/projects/create` 不改为直连 Server。
2. 继续用 `projectId` 做 detail continuation。
3. 继续用 `businessType=project`、`fileKind=evidence` 走三段上传链。
4. 不在前端补第二状态机或自造 project/upload truth。

## 7. 唯一推荐关闭路径

唯一推荐关闭路径名称：

`方案 A｜沿用并升级 /server/projects + /server/uploads 家族为项目发布最小走廊 internal truth`

推荐理由：

- 它与当前 live BFF dist 的实际转发路径一致，blast radius 最小。
- 它不要求新造第二条 internal family。
- 它符合 `Server` 仍是唯一 truth owner、`BFF` 只做 app-facing orchestration 的冻结边界。
- 它能把“当前 skeleton/compatibility family”收口成 formal truth，而不是继续追着 cloud-only dist 写临时适配。

## 8. 不允许采用的路径

### 8.1 不允许方案一：新造 `/server/project-publish/*`

原因：

- 会把当前已有 `/server/projects` family 彻底分叉成第二家族。
- 会增加 contracts、BFF、Server、文书四层的变更面。

### 8.2 不允许方案二：让 BFF 接管 project 或 upload truth

原因：

- 违反 `BFF never owns business truth`。
- 违反 `Server remains the only business truth owner for the current publish board`。

### 8.3 不允许方案三：继续把 cloud dist 当唯一实施真相

原因：

- 当前 local repo 与 live dist 已严重漂移。
- 若不先收口 repo/runtime truth，后续派工会直接污染实施基线。

### 8.4 不允许方案四：把 direct upload URL 或 `objectKey` 当真相

原因：

- direct upload 只是 transport。
- `objectKey` 不是业务真相。
- 当前真相仍应落在 `FileAsset`，后续若需要业务绑定，再进入项目侧 binding truth。

## 9. 对《项目发布板块正式派工单》的准入条件

本附录给出的准入条件是：

1. 项目发布最小走廊 truth map 已冻结为单一口径。
2. `/server/projects` family 已从 skeleton/compatibility 升级到 formal internal truth。
3. `/server/uploads/init|confirm` 已进入 primary contracts。
4. repo BFF route graph 与 active runtime 一致，不再依赖 cloud-only dist 做实施真相。
5. live Server 至少满足最小 corridor 验证：
   - `POST /api/app/project/create` 返回 `202` + `projectId`
   - `GET /api/app/project/detail?projectId=<fresh>` 返回 `200`
   - `POST /api/app/file/upload/init` 返回 signed directive
   - direct upload 成功
   - `POST /api/app/file/upload/confirm` 返回 `200` 且产出 `FileAsset`
6. 项目发布 touch-set 的 file-length 前置已处理：
   - 至少对 `project_create_page.dart` 与相关 route registry 给出 formal exemption 或拆分安排
7. 全局 shared veto 需重新复核，不得跳过：
   - `BLK-R0-APP-REWRITE-DRIFT`
   - `BLK-R0-RUNTIME-REPO-DRIFT`
   - `BLK-R0-ENV-PURITY`
   - `BLK-R0-FILE-LENGTH`
   - 以及阶段门禁对项目发布仍然构成前置的其他 shared blocker

本附录的结论不是“现在可以发正式派工单”，而是：

- 当前仍然 `No-Go`
- 仅完成了项目发布最小走廊的 truth 前置映射与关闭准备

## 10. 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v0.1 | 2026-04-02 | 首版。完成项目发布最小成功走廊的 truth map、repo/contracts/runtime 三层对照、`/server/projects` family 判定、最小关闭清单与唯一推荐关闭路径冻结。 |

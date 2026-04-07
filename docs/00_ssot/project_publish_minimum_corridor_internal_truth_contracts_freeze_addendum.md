---
owner: 文书冻结
status: frozen
purpose: Freeze the minimum-corridor internal truth families and contract patch scope for project publish, limited to docs/contracts only and without entering any implementation round.
layer: L0 SSOT addendum
freeze_date_local: 2026-04-02
inputs:
  - docs/00_ssot/control_priority_ruling_round0_global_veto_vs_project_publish_board_freeze_chain_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_truth_map_and_preclosure_addendum.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/new_workflow_v2_round0_exit_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
change_scope:
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
non_scope:
  - apps/mobile/**
  - apps/bff/**
  - apps/server/**
  - infra/**
  - database
  - deployment
  - release
---

# 项目发布最小走廊 internal truth / contract 冻结补丁单

## 1. 冻结对象

本补丁单只冻结 `项目发布最小走廊` 所需的 internal truth family 与对应
`L2 contracts` 补丁，不进入任何业务代码开发、配置变更、数据库变更、部署或发版。

本轮正式冻结的 internal truth paths 仅限：

- `POST /server/projects`
- `GET /server/projects/{projectId}`
- `POST /server/uploads/init`
- `POST /server/uploads/confirm`

本轮继续沿用且不改 family 的 app-facing corridor 仅限：

- `/exhibition/projects/create`
- `POST /api/app/project/create`
- `GET /api/app/project/detail`
- `POST /api/app/file/upload/init`
- direct upload
- `POST /api/app/file/upload/confirm`

## 2. 冻结范围与明确非目标

本轮允许动作仅有两项：

- 回写 `docs/01_contracts/openapi.yaml`
- 新增本补丁单

本轮明确非目标：

- 不新增 `/server/project/*`
- 不新增 `/server/project-publish/*`
- 不新增第二条 upload truth family
- 不把 compatibility alias 升格为 canonical truth
- 不扩到 bid / order / contract / milestone / inspection / rating /
  dispute
- 不扩到 project list 扩展
- 不扩到 project attachment read model 扩展
- 不把 `create` 成功返回扩成 full `Project` read model
- 不把 direct upload 误写成业务真相创建步骤

## 3. app-facing 与 internal truth 映射表

| 走廊项 | app-facing surface | internal truth pair | 本轮冻结结果 |
|---|---|---|---|
| 项目创建 | `POST /api/app/project/create` | `POST /server/projects` | request 与 app-facing 同源，使用同一 `ProjectCreateRequest`；success 固定为 `202 + projectId` |
| 项目详情 | `GET /api/app/project/detail` | `GET /server/projects/{projectId}` | 返回共享 `ProjectReadModel`；不新增 detail-only 第二模型 |
| 上传初始化 | `POST /api/app/file/upload/init` | `POST /server/uploads/init` | 冻结为 shared upload init request/response；truth owner 仍是 `Server` |
| direct upload | `directUpload.url` | 无新增业务 canonical path | 只传 transport bytes；不创造业务真相 |
| 上传确认 | `POST /api/app/file/upload/confirm` | `POST /server/uploads/confirm` | confirm 才产出 `FileAsset` truth；`objectKey` 不升格为 business truth |

补充裁定：

- 当前项目发布板块不得把 active BFF compatibility aliases 升格为 truth：
  - `POST /bff/project`
  - `GET /bff/project`
  - `GET /bff/project/:projectId`
- 当前项目发布最小走廊只承认已冻结的 app-facing corridor 与本轮冻结的
  `/server/projects`、`/server/uploads/*` family。

## 4. `/server/projects` 升级原则

- 继续沿用现有 `POST /server/projects` family，不另造新 family。
- request body 必须与 `POST /api/app/project/create` 保持同源约束：
  - required:
    - `title`
    - `buildingType`
    - `budgetAmount`
    - `provinceName`
    - `cityName`
    - `detailAddress`
    - `scopeSummary`
  - optional:
    - `districtName`
    - `plannedStartAt`
    - `plannedEndAt`
    - `description`
- 其中：
  - `districtName` omitted / `null` = 当前未单独提供区县层级
  - `plannedStartAt` / `plannedEndAt` 格式固定为 `YYYY-MM-DD`
  - `plannedStartAt` / `plannedEndAt` omitted / `null` = 当前计划时间窗未确认
- success 仍固定为：
  - HTTP `202`
  - body 仅含 `projectId`
- 本轮不允许把该 path 扩成：
  - full `ProjectReadModel`
  - bid handoff
  - order handoff
  - preview/payment/publish-commit 第二命令族

## 5. `/server/projects/{projectId}` 新增原则

- 新增 `GET /server/projects/{projectId}`，并明确它是
  `GET /api/app/project/detail` 的 internal truth pair。
- 返回模型固定为共享 `ProjectReadModel`。
- 对本轮新解冻的地址与范围字段：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  create 与 detail 命名必须完全一致。
- `GET /api/app/project/detail` 必须承担这些字段的回读语义；在 create 已提交且
  truth 已存储时，detail 不允许把这些字段重新塞回 `description` 或改名输出。
- `project/list` 与 workbench 当前不需要承载这些字段；若当前阶段未提供这些字段，
  可保持 omitted / `null`，但一旦承载，字段名与语义必须与 detail 完全一致。
- 不允许新增 detail-only 第二模型。
- 不允许在本轮把项目附件 read projection、bid compare、order conversion、
  collaboration 或后链语义塞进 detail contract。

## 6. `/server/uploads/init|confirm` 冻结原则

- `POST /server/uploads/init` 是
  `POST /api/app/file/upload/init` 的 internal truth pair。
- `POST /server/uploads/confirm` 是
  `POST /api/app/file/upload/confirm` 的 internal truth pair。
- upload truth owner 仍然只允许是 `Server`。
- init 的职责只限于发放 shared three-step upload strategy：
  - `uploadSessionId`
  - `directUpload`
  - `confirm`
- confirm 的职责只限于确认上传并产出 `FileAsset` truth reference。
- `objectKey` 仍然只是 storage location，不得升格为 business truth。
- direct upload 仍然不是业务 canonical path，只是对象存储 transport step。

## 7. publish upload binding 冻结

项目发布最小走廊的 publish upload binding 本轮正式冻结为：

- `businessType=project`
- `fileKind=evidence`

同时冻结以下解释：

- direct upload 只传 transport bytes，不创造业务真相。
- `businessId` 继续保留为 shared upload family 的 carried binding field；
  本轮不新造 publish-only `businessId` 语义。
- 只有 `POST /server/uploads/confirm` 成功后，才允许形成可被业务引用的
  `FileAsset` truth。
- 在 confirm 之前，object storage 上的 transport object 不能被视为
  project truth、evidence truth 或业务完成态。

## 8. corridor error codes 冻结建议

本轮至少冻结以下错误码建议：

| 错误码 | 所属走廊位置 | 本轮裁定 |
|---|---|---|
| `PROJECT_CREATE_FAILED` | `POST /api/app/project/create` 对应 internal create truth 缺失或上游失败 | 先登记为 implementation gate 前置项；不在本轮直接写入 primary contracts |
| `FILE_UPLOAD_INIT_FAILED` | `POST /api/app/file/upload/init` 对应 internal upload init truth 缺失或上游失败 | 先登记为 implementation gate 前置项；不在本轮直接写入 primary contracts |
| `FILE_UPLOAD_INIT_INVALID` | `POST /api/app/file/upload/init` 参数校验失败 | 先登记为 implementation gate 前置项；不在本轮直接写入 primary contracts |

本轮之所以不把上述三项直接升格进 primary contracts，理由固定为：

- 当前授权编辑面只限：
  - `docs/01_contracts/openapi.yaml`
  - 本补丁单
- 本轮主目标是冻结最小走廊 internal truth path family 及 request/response
  同源关系，不是重开全局错误码体系。
- `project_publish_minimum_corridor_truth_map_and_preclosure_addendum.md`
  已确认这些错误码属于 corridor implementation gate gap，需要在后续实施前
  与错误码台账、生成产物、BFF 受控失败归一规则一起补齐。

因此本轮正式结论是：

- 这三项错误码已被点名冻结为必须关闭的 implementation gate 前置项。
- 它们不是本轮 primary contracts 的新增写入项。

## 9. 对后续后端/BFF/前端派工的输入条件

本补丁单只提供后续派工的输入真相，不等于实施放行。

对后端后续派工的输入条件：

- 只允许实现：
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
  - `POST /server/uploads/init`
  - `POST /server/uploads/confirm`
- 必须遵守：
  - create success 仅 `202 + projectId`
  - detail 返回共享 `ProjectReadModel`
  - confirm 产出 `FileAsset` truth
  - 不越界到 bid/order/contract 等后链

对 BFF 后续派工的输入条件：

- 只允许维护 app-facing 到 internal truth 的映射：
  - `POST /api/app/project/create` -> `POST /server/projects`
  - `GET /api/app/project/detail` -> `GET /server/projects/{projectId}`
  - `POST /api/app/file/upload/init` -> `POST /server/uploads/init`
  - `POST /api/app/file/upload/confirm` -> `POST /server/uploads/confirm`
- 不允许：
  - 升格 compatibility alias
  - 自造第二状态机
  - 把 upload truth 挪到 BFF

对前端后续派工的输入条件：

- 继续只消费既有 app-facing corridor。
- create 成功后继续只用 `projectId` 做 detail continuation。
- 上传继续只走三段链，并以：
  - `businessType=project`
  - `fileKind=evidence`
  - confirmed `FileAsset`
  为唯一业务引用口径。
- 不允许直连 `Server`，不允许自造 project/upload truth。

总门禁条件保持不变：

- 本补丁单本身不解除 `Round 0` 的 `No-Go for development`。
- 后续若要进入实施轮，仍需总控基于门禁链重新裁定。

## 10. 修订记录

- `2026-04-02`
  - 新增本补丁单
  - 正式冻结项目发布最小走廊 internal truth family：
    - `POST /server/projects`
    - `GET /server/projects/{projectId}`
    - `POST /server/uploads/init`
    - `POST /server/uploads/confirm`
  - 在 `docs/01_contracts/openapi.yaml` 中补齐上述四条 internal truth
    contracts
  - 正式冻结 publish upload binding：
    - `businessType=project`
    - `fileKind=evidence`
  - 将 `PROJECT_CREATE_FAILED`、`FILE_UPLOAD_INIT_FAILED`、
    `FILE_UPLOAD_INIT_INVALID` 冻结为 implementation gate 前置项

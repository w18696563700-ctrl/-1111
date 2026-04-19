---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract family for the corrected full publish-workbench and extension mainline, so the next backend truth and persistence round proceeds on a single meaning for verified-runtime, read-corridor, page-shell, and boundary-only contract roles.
layer: L2 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《发布项目工作台及延伸功能全链 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `发布项目工作台及延伸功能全链`
- 本冻结单只服务于：
  - 当前对象 app-facing contract family
  - 四容器对应最小 contract role
  - verified-runtime / read-corridor / page-shell / boundary-only 的 contract 边界
  - upload 复用边界
  - controlled unavailable / invalid-state / frozen-boundary 语义
- 本冻结单不进入：
  - persistence freeze
  - backend / BFF / frontend 实现
  - integration
  - `release-prep`
  - production release

## 2. Contract Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮是 corrected full object 的正式 contract freeze。
- 当前不允许再把：
  - `订单承接与履约承接主链`
    当成 full mainline contract family
- 当前不允许把：
  - page-shell 节点
  - boundary-only 节点
    偷写成 active command contract family
- 当前正式写死：
  - `发布项目工作台及延伸功能全链`
    才是当前 contract 视角下的真实主线对象
  - `订单承接与履约承接主链`
    只保留为 subordinate screenshot-derived continuation subchain

## 3. Canonical App-facing Path Family Freeze

- 当前 contract family 只允许纳入以下对象：
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit` 的 shell / handoff contract position
  - `POST /api/app/inspection/submit` 的 shell / handoff contract position
  - `POST /api/app/dispute/open` 的 shell / handoff contract position
- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 4. `project_chain` Contract Freeze

- `project_chain` 是当前对象里最成熟的 continuation slice。
- `GET /api/app/exhibition/workbench` 当前只承担：
  - summary
  - handoff
- 以下路径共同构成当前对象里最成熟的 contract asset group：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`

### 4.1 Minimum Semantics

- 最小语义至少包括：
  - `recentProjectId`
  - `canCreateProject`
  - `projectId`
  - `publicProject`
  - `privateProgress`

### 4.2 Hard Boundary

- `workbench` 不是 public home。
- `workbench` 不是第二项目状态机。
- `workbench` 不是 `bid / award / order conversion` owner。
- `project_publish_board` 复用关系继续有效：
  - `project/create`
  - upload 三段式
    继续复用既有 publish corridor
- 但当前 full object 不得偷换成：
  - “只有 publish corridor”

## 5. `order_chain` Contract Freeze

- `order_chain` 当前是 subordinate continuation slice。
- `activeOrderId` 只是 continuation carrier。
- 当前只允许冻结：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `POST /api/app/dispute/open` 的 shell / handoff position

### 5.1 Read-corridor Rule

- `order/detail` 与 `contract/detail` 当前是 read-corridor asset。
- `dispute/open` 当前不得写成 active command family 已成立。

### 5.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/order/create`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 6. `fulfillment_chain` Contract Freeze

- `fulfillment_chain` 当前也是 subordinate continuation slice。
- `activeMilestoneId` 只是 continuation carrier。
- 当前只允许冻结：
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit` 的 shell / handoff position
  - `POST /api/app/inspection/submit` 的 shell / handoff position

### 6.1 Read-corridor Rule

- `milestone/list` 与 `inspection/detail` 当前是 read-corridor asset。
- `milestone/submit` 与 `inspection/submit` 当前不得写成 active command family 已成立。

### 6.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/inspection/recheck`
  - approval / governance console
  - 第二履约状态机

## 7. `extension_boundary` Contract Freeze

- `extension_boundary` 不是完整业务子链。
- 它只承接 boundary-state 与 limited continuation posture。
- 当前只允许写清：
  - 合同详情续接
  - 争议开启续接
  - `ratingEntryState`
  - `disputeWithdrawState`
- 当前必须明确：
  - `评价入口边界` 当前不是 open action
  - `争议撤回边界` 当前不是 open action
  - 不得把边界说明写成 live capability
  - 不得把它扩成 `rating / dispute` full contract family

## 8. Verified Runtime vs Shell Contract Split

- 当前四类 contract 语义正式写死如下：
  1. verified runtime contract
     - `GET /api/app/exhibition/workbench`
     - `POST /api/app/project/create`
     - `GET /api/app/project/detail`
     - `GET /api/app/project/list`
     - `GET /api/app/my/projects`
     - `GET /api/app/my/projects/{projectId}`
  2. read-corridor contract
     - `GET /api/app/order/detail`
     - `GET /api/app/contract/detail`
     - `GET /api/app/milestone/list`
     - `GET /api/app/inspection/detail`
  3. page-shell / handoff-only contract
     - `POST /api/app/milestone/submit`
     - `POST /api/app/inspection/submit`
     - `POST /api/app/dispute/open`
  4. boundary-only / frozen-state contract
     - `评价入口边界`
     - `争议撤回边界`
     - `ratingEntryState`
     - `disputeWithdrawState`
- 当前必须明确：
  - route / page existence != runtime contract closure
  - summary presence != downstream truth closure
  - historical subchain docs != current full object closure

## 9. Upload / Publish Corridor Reuse Boundary

- `project/create` 继续复用当前 publish corridor。
- 文件材料继续复用：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- 当前必须明确：
  - upload truth 不得反客为主
  - `objectKey` 不是 business truth
  - 不得借本轮扩成：
    - preview 第二协议族
    - payment 第二协议族
    - publish-commit 第二协议族

## 10. Workbench / My-project / Owner Boundary

- `workbench` 只是 summary + handoff。
- `my-project` 只是 private carry reuse。
- `Server` 是唯一 business truth owner。
- `BFF` 只是 app-facing aggregation layer。
- Flutter 只是 consumer。
- 当前必须明确：
  - `my-project` 不能被写成 `workbench` 替代物
  - `workbench` 不能被写成：
    - `my-project` 真值页
    - `project detail` 真值页
    - `order detail` 真值页

## 11. Non-goals

- 当前 non-goals 明确如下：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`
  - payment / billing / settlement / tax
  - governance / reporting / moderation console
  - history / list / reporting 扩面
  - bid / award / order conversion 扩面

## 12. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for backend truth / persistence freeze authoring`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

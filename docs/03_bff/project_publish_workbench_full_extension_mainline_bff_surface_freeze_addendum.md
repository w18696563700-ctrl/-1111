---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF app-facing transport, shaping, handoff, upload-signing, and error-envelope boundary for the corrected full publish-workbench and extension mainline only.
layer: L4 BFF
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《发布项目工作台及延伸功能全链 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `发布项目工作台及延伸功能全链`
- 本冻结单只服务于：
  - 当前对象 app-facing transport / shaping boundary
  - 当前对象 query / command handoff 最小边界
  - 当前对象 verified runtime / read-corridor / shell-handoff / boundary-only 的 BFF surface 区分
  - 当前对象 upload signing / visibility trimming / error envelope 最小边界
  - 当前对象 controlled unavailable / invalid-state / frozen-boundary 的 app-facing normalization
- 本冻结单不进入：
  - frontend 文书
  - `apps/bff/**` 实现
  - integration
  - `release-prep`
  - production release

## 2. BFF Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮是 corrected full object 的正式 BFF surface freeze。
- 当前不允许再把：
  - `订单承接与履约承接主链`
    当成 full mainline BFF object
- 当前不允许把：
  - shell 节点
  - boundary 节点
    偷写成 active command surface 已成立
- 当前不允许借 BFF 文书把排除项偷偷并入。
- `订单承接与履约承接主链`
  当前只保留为：
  - subordinate screenshot-derived continuation subchain
  - subordinate stop-line asset

## 3. BFF Truth Boundary

- `BFF` 只允许做：
  - auth consolidation
  - app-facing aggregation
  - upload signing
  - response shaping
  - light idempotency
  - visibility trimming
  - controlled unavailable / invalid-state / frozen-boundary normalization
- `BFF` 不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / closed / withdrawable / rateable` 推导
  - 本地把 shell 节点升级成 active command family
- `Server` 仍是唯一 truth owner。
- Flutter 只是 consumer。
- `workbench` / `my-project` 不是 BFF truth owner。

## 4. Canonical App-facing Path Family Freeze

- 当前 BFF surface 只允许冻结以下 app-facing path / position：
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
  - `POST /api/app/milestone/submit` 的 shell / handoff surface position
  - `POST /api/app/inspection/submit` 的 shell / handoff surface position
  - `POST /api/app/dispute/open` 的 shell / handoff surface position
- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 5. `project_chain` BFF Surface Freeze

- `project_chain` 是当前对象里最成熟的 continuation slice。
- `GET /api/app/exhibition/workbench`
  只承担：
  - summary
  - handoff surface
- 以下路径共同构成当前对象里最成熟的一组 BFF surface asset：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`

### 5.1 Minimum App-facing Semantics

- 最小 app-facing 语义至少包括：
  - `recentProjectId`
  - `canCreateProject`
  - `projectId`
  - `publicProject`
  - `privateProgress`

### 5.2 Hard Boundary

- `workbench` 不是 public home。
- `workbench` 不是第二项目状态机。
- `workbench` 不是 `bid / award / order conversion` owner。
- `project_publish_board` 复用关系继续有效：
  - `project/create`
  - upload 三段式
    继续复用既有 publish corridor
- 但当前 full object 不得偷换成：
  - “只有 publish corridor”

## 6. `order_chain` BFF Surface Freeze

- `order_chain` 当前是 subordinate continuation slice。
- `activeOrderId` 只是 continuation carrier。
- 当前只允许冻结：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `POST /api/app/dispute/open` 的 shell / handoff surface position

### 6.1 Surface Role

- `order/detail` 与 `contract/detail` 当前只代表：
  - read-corridor surface
- `dispute/open` 当前不得写成：
  - active command surface 已成立

### 6.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/order/create`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 7. `fulfillment_chain` BFF Surface Freeze

- `fulfillment_chain` 当前也是 subordinate continuation slice。
- `activeMilestoneId` 只是 continuation carrier。
- 当前只允许冻结：
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit` 的 shell / handoff surface position
  - `POST /api/app/inspection/submit` 的 shell / handoff surface position

### 7.1 Surface Role

- `milestone/list` 与 `inspection/detail` 当前只代表：
  - read-corridor surface
- `milestone/submit` 与 `inspection/submit` 当前不得写成：
  - active command surface 已成立

### 7.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/inspection/recheck`
  - approval / governance console
  - 第二履约状态机

## 8. `extension_boundary` BFF Surface Freeze

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
  - 不得把它扩成 `rating / dispute` full BFF surface family

## 9. Verified Runtime vs Read Corridor vs Shell vs Boundary Split

- 当前四类 BFF surface 语义正式写死如下：
  1. verified development-stage runtime surface
     - `workbench`
     - `project/create`
     - `project/detail`
     - `project/list`
     - `my-project` private carry
  2. active read-corridor surface
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  3. shell / handoff surface position
     - `milestone/submit`
     - `inspection/submit`
     - `dispute/open`
  4. boundary-only / frozen-state surface marker
     - `ratingEntryState`
     - `disputeWithdrawState`
     - `评价入口边界`
     - `争议撤回边界`
- 当前必须明确：
  - route / page existence != runtime closure
  - summary presence != downstream truth closure
  - historical subchain docs != current full object closure
  - shell / handoff position != active command family already implemented

## 10. Upload Signing / Error Envelope / Visibility Boundary

- upload 继续复用三段式：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- `BFF` 只负责：
  - upload signing
  - response shaping
  - visibility trimming
  - controlled unavailable / invalid-state / frozen-boundary normalization
- `objectKey` 不是 business truth。
- 当前必须明确：
  - 不得借此扩成 payment / publish-commit / moderation / reporting 第二协议族
  - 不得吞掉 `Server` 核心失败语义
  - 不得自造本地业务完成语义

## 11. Workbench / My-project / Derived Projection Boundary

- `workbench` 只是 summary + handoff。
- `my-project` 只是 private carry reuse。
- `summary label` / `state label` / UI wording 永远不是真值。
- derived projection 不能反向覆盖 `Server` canonical truth。
- 当前必须明确：
  - `my-project` 不能被写成 `workbench` 替代物
  - `workbench` 不能被写成：
    - `my-project` 真值页
    - `project detail` 真值页
    - `order detail` 真值页

## 12. Non-goals / Stage Conclusion

### 12.1 Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating/submit`
- `dispute/withdraw`
- payment / billing / settlement / tax
- governance / reporting / moderation console
- history / list / reporting 扩面
- bid / award / order conversion 扩面
- implementation unlock

### 12.2 Stage Conclusion

- `Go for frontend consumption freeze authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

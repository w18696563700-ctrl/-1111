---
owner: Codex 总控
status: frozen
purpose: >
  Refresh the formal L3 backend truth authority for the current
  `项目发布对象簇`, aligning the Server-owned query, command, persistence, and
  status-flow boundary with the live repo and formally downgrading stale
  lower-layer exclusions.
layer: L3 Backend
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/app.module.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/my_project/my-project.private-progress.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.service.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.presenter.ts
  - apps/server/src/modules/rating/rating.query.service.ts
  - apps/server/src/modules/rating/rating.write.service.ts
  - apps/server/test/project-publish-eligibility.test.cjs
  - apps/server/test/s2-order-contract-fulfillment-read-corridor.test.cjs
  - apps/server/test/rating-entry-submit.test.cjs
  - apps/server/test/historical-projects-semantics.test.cjs
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md
---

# 《项目发布对象簇 L3 backend truth 一致性刷新补充单》

## Pricing Boundary Note

自 `2026-04-29` 起，若当前项目已接入
[platform_pricing_backend_truth_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md)
定义的收费主线，则本文件中对 `payment / billing` 的 generic excluded 结论，不得被误读成自动否掉该收费子主线。

当前正式解释固定为：

1. generic `payment / billing center` 仍然 excluded
2. 但 `project publish -> bid participation request -> bid submit` 上的收费子主线，已由 `platform_pricing_backend_truth_master_v1` 单独取得 authority
3. 本对象簇继续持有 `project publish / bid submit` 主锚点，但收费专属聚合归 `platform_pricing` 子主线持有

## 1. Scope

- 本冻结单只覆盖：
  - 当前 `project publish object cluster`
- 本冻结单只服务于：
  - `Server truth / query / command / persistence / status flow`
  - `workbench / my-project` 的 derived projection boundary
  - 当前同对象 `tests` 的 truth verification position
- 本冻结单不进入：
  - BFF / frontend implementation
  - implementation dispatch
  - integration
  - `release-prep`
  - production release

## 2. L3 Freeze Conclusion

- 当前 `Server` 是本对象簇唯一 truth owner。
- 当前 `Server` 不再允许把以下动作写成对象外：
  - `contract confirm / amend`
  - `milestone submit`
  - `inspection submit / recheck`
  - `rating entry / submit`
  - `dispute open / withdraw`
- 当前 backend 当前 included module family 固定为：
  - `project`
  - `my_project`
  - `exhibition_workbench`
  - `trading_read_corridor`
  - `trading_shell_handoff`
  - `rating`
- `workbench` 当前只承接：
  - summary
  - handoff
  - boundary-state projection
- `my-project` 当前只承接：
  - owner-private continuation projection
  - `privateProgress / evaluationStatus` derived read model
- `BFF` 和 Flutter 当前都不是 truth owner。

## 3. 当前直接沿用资产

- 上位 authority 沿用：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md`
- 当前 backend truth 直接沿用源码资产：
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/trading_shell_handoff/**`
  - `apps/server/src/modules/rating/**`
- 当前同对象直接沿用文书资产：
  - `docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_*`
  - `docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_*`
  - `docs/00_ssot/inspection_phase3_*`
  - `docs/00_ssot/rating_entry_minimal_*`
  - `docs/00_ssot/dispute_entry_minimal_*`
- 当前 truth verification 直接沿用测试资产：
  - `apps/server/test/project-publish-eligibility.test.cjs`
  - `apps/server/test/s2-order-contract-fulfillment-read-corridor.test.cjs`
  - `apps/server/test/rating-entry-submit.test.cjs`
  - `apps/server/test/historical-projects-semantics.test.cjs`

## 4. 当前 Included Family

- 当前 query family：
  - `project` list / detail / edit detail / my-project detail
  - `exhibition_workbench` summary projection
  - `trading_read_corridor` for:
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - `rating` for:
    - `rating/entry`
- 当前 command family：
  - `project`:
    - `create`
    - `save`
    - `submit`
    - `publish`
  - `trading_shell_handoff`:
    - `contract/confirm`
    - `contract/amend`
    - `milestone/submit`
    - `inspection/submit`
    - `inspection/recheck`
    - `dispute/open`
    - `dispute/withdraw`
  - `rating`:
    - `rating/submit`
- 当前 persistence family：
  - `projects`
  - `project_attachments`
  - `orders`
  - `contracts`
  - `milestones`
  - `inspections`
  - `disputes`
  - `ratings`
  - `file_assets`
  - `evidences`
  - `audit_logs`
- 当前 derived projection family：
  - `exhibition_workbench.presenter`
    输出：
    - `project_chain`
    - `order_chain`
    - `fulfillment_chain`
    - `extension_boundary`
  - `my_project.private_progress`
    派生：
    - `formalCompletionStatus`
    - `evaluationStatus`
    但不创建第二状态机

## 5. 当前 status flow / command truth

- `project` 当前 truth flow：
  - `draft -> submitted -> published`
  - owner and publish eligibility remain `Server`-owned
- `contract` 当前 truth flow：
  - `pending_confirm -> active -> amended`
  - `confirmContract`
    基于 `orderId`
    更新 `public.contracts.state`
  - `amendContract`
    基于 `orderId`
    更新 `public.contracts.state` 与 `amend_count`
- `milestone` 当前 truth posture：
  - query-side visible states 至少包括：
    - `pending_submission`
    - `submitted`
  - `submitMilestone`
    当前是 `Server`-owned shell / handoff gate
  - 它校验 current milestone truth 是否允许继续 handoff
    但 accepted body 只回 `milestoneId`
  - 当前不得把这条 path 误写成更宽的第二 milestone workflow
- `inspection` 当前 truth posture：
  - query-side visible states 至少包括：
    - `draft`
    - `submitted`
    - `rechecked`
  - `submitInspection`
    当前是 `Server`-owned shell / handoff gate
  - `recheckInspection`
    当前是 persisted state advance：
    - `submitted -> rechecked`
    - 并更新 `recheck_count`
- `rating` 当前 truth flow：
  - `rating/entry` 只在 buyer-scoped completed order 上，
    且存在 persisted draft rating truth row 时可读
  - `rating/submit`
    更新 `public.ratings.state`
    为 `submitted`
- `dispute` 当前 truth posture：
  - `dispute/open`
    当前是 order-bound shell / handoff gate
  - 它当前返回 accepted shell carrier，
    不在 accepted response 中创设 app-facing dispute identity
  - `dispute/withdraw`
    基于 `orderId`
    读取 latest visible dispute truth，
    并更新 `public.disputes.state`
    为 `withdrawn`

## 6. 当前 Excluded Family

- 当前明确 excluded：
  - `bid`
  - `order/create`
  - `payment / billing`
  - `forum`
  - `Admin`
- 当前明确 excluded backend semantics：
  - `BFF` owned persistence
  - Flutter local truth tables
  - `workbench` command-desk truth
  - `rating detail / list / moderation workflow`
  - `dispute governance workspace / history center`
  - `contract clause editor / legal review system`
  - `inspection governance queue / multi-round console`
- 当前也明确 excluded：
  - implementation unlock
  - implementation dispatch
  - integration
  - `release-prep`
  - production release

## 7. 被正式降级的旧文书或旧条款

- `docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md`：
  - `4.1 Explicitly Excluded Persistence Family`
  - `6.2 Hard Boundary`
  - `7.2 Hard Boundary`
  - `8. extension_boundary`
  - `9. shell / boundary split`
  中把 `ratings`、`disputes`、`contract confirm/amend`、
  `inspection/recheck`、`dispute/withdraw`
  继续写成 excluded family 或 boundary-only family 的条款，
  当前正式降级为 `2026-04-11 historical baseline only`
- `docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md`：
  - `2. Refreshed Backend Freeze Conclusion`
  - `4.2 Explicitly Excluded Persistence Family`
  - `7. contract/detail`
  - `10` 之后对 `contract/confirm`、`contract/amend`、
    `inspection/recheck`、`rating/*`、`dispute/*`
    的排除口径，
    当前正式降级为 `subordinate continuation historical clauses only`
- 旧口径中把 `workbench` 或 `my-project`
  误写成 order / contract / fulfillment / rating / dispute truth owner 的条款，
  当前一律降级为历史误读，不再拥有当前 authority

## 8. 当前层唯一 authority 优先级

- `1`
  - 本文件
- `2`
  - 当前 repo 的 `apps/server/src/modules/project/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/trading_shell_handoff/**`
  - `apps/server/src/modules/rating/**`
  - 对应当前 server tests
- `3`
  - `docs/01_contracts/openapi.yaml`
  - 上位 `L0 authority refresh + ruling + stage gate`
- `4`
  - 当前同对象直接沿用子链文书与 sidecar freeze
- `5`
  - 已被正式降级的旧 `full_extension_mainline`
    与 `order_intake_and_fulfillment_mainline`
    backend 文书

## 9. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for L4 BFF surface consistency refresh authoring`
  - `No-Go for implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

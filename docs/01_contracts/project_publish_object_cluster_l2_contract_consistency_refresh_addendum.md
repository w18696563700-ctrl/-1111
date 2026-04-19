---
owner: Codex 总控
status: frozen
purpose: >
  Refresh the formal L2 contract authority for the current `项目发布对象簇`,
  aligning the current app-facing family with the live repo, explicitly
  including the presently active order/fulfillment/extension actions, and
  formally downgrading stale exclusion clauses from earlier lower-layer docs.
layer: L2 Contracts
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts
  - apps/bff/src/routes/rating/app-rating.controller.ts
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/test/shell_app_test.dart
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
---

# 《项目发布对象簇 L2 contract 一致性刷新补充单》

## 1. Scope

- 本冻结单只覆盖：
  - 当前 `project publish object cluster`
- 本冻结单只服务于：
  - 当前 app-facing canonical path family
  - 当前 request anchor / response / error boundary
  - 当前 `workbench -> project -> order -> contract -> milestone -> inspection -> rating -> dispute`
    的同对象 contract closure
- 本冻结单不进入：
  - backend truth / persistence
  - BFF / frontend implementation
  - implementation dispatch
  - integration
  - `release-prep`
  - production release

## 2. L2 Freeze Conclusion

- 当前 `L2 contract` 不再允许把当前对象簇解释成：
  - 只有 `project publish minimum corridor`
  - 或只有 `order/detail -> contract/detail -> milestone/list -> inspection/detail`
- 当前 `L2 contract` 正式纳入：
  - `contract confirm / amend`
  - `milestone submit`
  - `inspection submit / recheck`
  - `rating entry / submit`
  - `dispute open / withdraw`
- 当前 `workbench` 仍然只是一组：
  - summary
  - handoff
  - boundary-state
    contract
- `workbench` 当前不是：
  - active command desk
  - 第二状态机
  - 第二 detail family
- `dispute withdraw` 的当前 canonical request anchor
  正式锁定为：
  - `orderId`
- `disputeId`
  当前只出现在：
  - accepted response carrier
  - persisted truth / test evidence
  - 不再是 app-facing request anchor

## 3. 当前直接沿用资产

- 上位 authority 沿用：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md`
- 当前 canonical contract snapshot 沿用：
  - `docs/01_contracts/openapi.yaml`
- 当前同对象直接沿用文书资产：
  - `docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_*`
  - `docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_*`
  - `docs/00_ssot/inspection_phase3_detail_submit_contract_closure_addendum.md`
  - `docs/00_ssot/inspection_phase3_trigger_recheck_contract_addendum.md`
  - `docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md`
  - `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`
- 当前 repo 直接沿用 carrier / verification 资产：
  - `apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts`
  - `apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts`
  - `apps/bff/src/routes/rating/app-rating.controller.ts`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/bff/test/trading-read-corridor-order-contract.test.cjs`
  - `apps/bff/test/trading-read-corridor-milestone-inspection.test.cjs`
  - `apps/bff/test/trading-shell-handoff-submit-error-cleanup.test.cjs`
  - `apps/bff/test/rating-entry-submit.test.cjs`
  - `apps/mobile/test/shell_app_test.dart`
  - `apps/mobile/test/phase23_entry_test.dart`
  - `apps/mobile/test/inspection_phase3_test.dart`
  - `apps/mobile/test/rating_entry_test.dart`
  - `apps/mobile/test/dispute_entry_test.dart`

## 4. 当前 Included Family

- `project_chain` 当前 included family：
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `POST /api/app/project/save`
  - `POST /api/app/project/submit`
  - `POST /api/app/project/publish`
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/edit/detail`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
- `project_chain` 当前 included semantics：
  - project list / detail / filter / pagination / expiry trimming
  - project create / edit / save / submit / publish
  - owner-private `my/projects` continuation
- `order_chain` 当前 included family：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- `order_chain` 当前 request anchor：
  - `order/detail` uses query `orderId`
  - `contract/detail` uses query `orderId`
  - `contract/confirm` uses body `orderId`
  - `contract/amend` uses body `orderId`
  - `dispute/open` uses body `orderId`
  - `dispute/withdraw` uses body `orderId`
- `fulfillment_chain` 当前 included family：
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
- `fulfillment_chain` 当前 request anchor：
  - `milestone/list` uses query `orderId`
  - `milestone/submit` uses body `milestoneId`
  - `inspection/detail` uses query `milestoneId`
  - `inspection/submit` uses body `inspectionId`
  - `inspection/recheck` uses body `inspectionId`
- `extension_boundary` 当前 included family：
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - workbench `ratingEntryState`
  - workbench `disputeWithdrawState`
- `rating` 当前 request anchor：
  - `rating/entry` uses query `orderId`
  - `rating/submit` uses body `orderId`
- `dispute withdraw` 当前 accepted carrier：
  - returns `disputeId + orderId + state + summary`
  - but request anchor remains `orderId`

## 5. 当前 Excluded Family

- 当前明确 excluded：
  - `bid`
  - `POST /api/app/order/create`
  - `payment / billing`
  - `forum`
  - `Admin`
- 当前明确 excluded contract semantics：
  - 把 workbench 写成 active command desk
  - 新开 `rating detail / history / moderation` family
  - 新开 `dispute detail / list / governance` family
  - 新开 `contract history / list / legal review` family
  - 新开 `inspection list / governance console / rectification workspace` family
  - 新开 implementation / integration / release-prep / production release 口径
- 已有 owner-private attachment corridor：
  - 继续只按其专属冻结链沿用
  - 本轮不把它重新扩写成新的独立主线

## 6. 被正式降级的旧文书或旧条款

- `docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md`：
  - `3. Canonical App-facing Path Family Freeze`
  - `5.2 Hard Boundary`
  - `6.2 Hard Boundary`
  - `7. extension_boundary`
  - `11. Non-goals`
  中把 `contract/confirm`、`contract/amend`、`inspection/recheck`、
  `rating/submit`、`dispute/withdraw` 排除在当前对象外的条款，
  当前正式降级为 `2026-04-11 historical baseline only`
- `docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md`：
  - `2. Refreshed Contract Freeze Conclusion`
  - `3.3 Adjacent-but-excluded Runtime`
  - `3.4 Explicitly Excluded Path Family`
  - `5.2 Hard Boundary`
  中把 `contract/confirm`、`contract/amend`、`inspection/recheck`、
  `rating/*`、`dispute/withdraw`
  继续写成当前对象外或邻接排除项的条款，
  当前正式降级为 `subordinate continuation historical clauses only`
- `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`：
  - 关于 `dispute withdraw` 以缺少 `disputeId`
    作为 app-facing invalid-request anchor 的历史条款，
    当前正式降级
  - 当前 request anchor authority 以：
    - `docs/01_contracts/openapi.yaml`
    为准
  - 当前 canonical request anchor 是：
    - `orderId`

## 7. 当前层唯一 authority 优先级

- `1`
  - 本文件
- `2`
  - `docs/01_contracts/openapi.yaml`
    作为当前 canonical path / request anchor / response / error snapshot
- `3`
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md`
- `4`
  - 当前 repo 的同对象 route/controller/tests 证据
  - 当前同对象直接沿用子链文书
- `5`
  - 已被正式降级的旧 `full_extension_mainline` 与
    `order_intake_and_fulfillment_mainline` 下层 contract 文书

## 8. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for L3 backend truth consistency refresh authoring`
  - `No-Go for implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

---
owner: Codex 总控
status: frozen
purpose: >
  Refresh the formal L4 BFF surface authority for the current
  `项目发布对象簇`, aligning the app-facing mapping, payload shaping, and error
  normalization boundary with the live repo while forbidding any second state
  machine or truth takeover.
layer: L4 BFF
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/bff/src/routes/trading_read_corridor/trading-read-corridor.service.ts
  - apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.service.ts
  - apps/bff/src/routes/rating/rating.service.ts
  - apps/bff/test/project-lifecycle.test.cjs
  - apps/bff/test/project-showcase-filter-create-refactor.test.cjs
  - apps/bff/test/trading-read-corridor-order-contract.test.cjs
  - apps/bff/test/trading-read-corridor-milestone-inspection.test.cjs
  - apps/bff/test/trading-shell-handoff-submit-error-cleanup.test.cjs
  - apps/bff/test/rating-entry-submit.test.cjs
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_refreshed_bff_surface_freeze_addendum.md
  - docs/03_bff/bff_routes.md
---

# 《项目发布对象簇 L4 BFF surface 一致性刷新补充单》

## 1. Scope

- 本冻结单只覆盖：
  - 当前 `project publish object cluster`
- 本冻结单只服务于：
  - app-facing mapping
  - payload shaping
  - error normalization
  - read-only transport vs shell / handoff transport split
  - workbench summary transport boundary
- 本冻结单不进入：
  - frontend implementation
  - implementation dispatch
  - integration
  - `release-prep`
  - production release

## 2. L4 Freeze Conclusion

- `BFF` 当前只做：
  - app-facing mapping
  - payload shaping
  - auth/header forwarding
  - controlled error normalization
  - visibility trimming
  - light idempotency
- `BFF` 当前不得做：
  - truth owner
  - 第二状态机
  - 本地 business completion judgement
  - 本地 `rateable / withdrawable / recheckable` truth invention
- 当前 `BFF` 不再允许把以下 family 写成对象外：
  - `contract confirm / amend`
  - `inspection recheck`
  - `rating entry / submit`
  - `dispute withdraw`
- 当前 `workbench` 在 `BFF` 侧仍然只是一条：
  - summary / handoff / boundary-state surface
  - 不是 active command desk

## 3. 当前直接沿用资产

- 上位 authority 沿用：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md`
- 当前 BFF source 直接沿用资产：
  - `apps/bff/src/routes/routes.module.ts`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/trading_shell_handoff/**`
  - `apps/bff/src/routes/rating/**`
- 当前同对象直接沿用文书资产：
  - `docs/03_bff/bff_routes.md`
  - `docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_*`
  - `docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_*`
  - `docs/00_ssot/inspection_phase3_*`
  - `docs/00_ssot/rating_entry_minimal_*`
  - `docs/00_ssot/dispute_entry_minimal_*`
- 当前 verification 直接沿用测试资产：
  - `apps/bff/test/project-lifecycle.test.cjs`
  - `apps/bff/test/project-showcase-filter-create-refactor.test.cjs`
  - `apps/bff/test/trading-read-corridor-order-contract.test.cjs`
  - `apps/bff/test/trading-read-corridor-milestone-inspection.test.cjs`
  - `apps/bff/test/trading-shell-handoff-submit-error-cleanup.test.cjs`
  - `apps/bff/test/rating-entry-submit.test.cjs`

## 4. 当前 Included Family

- 当前 route-module family：
  - `exhibition_workbench`
  - `project`
  - `my_project`
  - `trading_read_corridor`
  - `trading_shell_handoff`
  - `rating`
- 当前 read-only app-facing family：
  - `GET /api/app/exhibition/workbench`
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/edit/detail`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `GET /api/app/rating/entry`
- 当前 command / handoff app-facing family：
  - `POST /api/app/project/create`
  - `POST /api/app/project/save`
  - `POST /api/app/project/submit`
  - `POST /api/app/project/publish`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/milestone/submit`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- 当前 mapping / shaping boundary：
  - `trading_read_corridor.service`
    只 forward current ids and shape read models
  - `trading_shell_handoff.service`
    只 normalize request anchors, forward to `/server/*`, and shape accepted carriers
  - `rating.service`
    只 normalize `orderId`, fail-close missing anchors, and shape rating entry / submit carriers
  - `exhibition_workbench.service`
    只校验四个 summary containers 都存在，不生成第二 summary truth

## 5. 当前 Excluded Family

- 当前明确 excluded：
  - `bid`
  - `order/create`
  - `payment / billing`
  - `forum`
  - `Admin`
- 当前明确 excluded BFF semantics：
  - 本地 contract workflow truth
  - 本地 inspection workflow truth
  - 本地 rating / dispute truth
  - 第二 workbench state machine
  - 第二 my-project state machine
  - list/history/governance/reporting projections for current action family
  - new implementation / integration / release-prep / production release 口径

## 6. 被正式降级的旧文书或旧条款

- `docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md`：
  - `4. Canonical App-facing Path Family Freeze`
  - `6.2 Hard Boundary`
  - `7.2 Hard Boundary`
  - `8. extension_boundary`
  中把 `contract/confirm`、`contract/amend`、`inspection/recheck`、
  `rating/submit`、`dispute/withdraw`
  排除在当前对象外的条款，
  当前正式降级为 `2026-04-11 historical baseline only`
- `docs/03_bff/order_intake_and_fulfillment_mainline_refreshed_bff_surface_freeze_addendum.md`：
  - `2. Refreshed BFF Freeze Conclusion`
  - `5.2 Adjacent But Excluded Runtime`
  - `5.3 Explicitly Excluded Path Family`
  - `7.2 Hard Boundary`
  中把 `dispute/open` 仅写成邻接 runtime，
  或把 `contract/confirm`、`contract/amend`、`inspection/recheck`、
  `rating/*`、`dispute/withdraw`
  排除出当前对象的条款，
  当前正式降级为 `subordinate continuation historical clauses only`
- `docs/03_bff/bff_routes.md`：
  - `Contract Phase 3 Boundary`
  - `Inspection Phase 3 Boundary`
  - `Rating Next-stage Boundary`
  中仍按 planning 语义描述这些 family 的条款，
  在与当前 repo 冲突处当前正式降级为 `historical planning clauses only`

## 7. 当前层唯一 authority 优先级

- `1`
  - 本文件
- `2`
  - 当前 repo 的 `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/trading_shell_handoff/**`
  - `apps/bff/src/routes/rating/**`
  - 对应当前 BFF tests
- `3`
  - `docs/01_contracts/openapi.yaml`
  - 上位 `L0 authority refresh + ruling + stage gate`
- `4`
  - `docs/03_bff/bff_routes.md`
    与当前同对象直接沿用子链文书中未冲突部分
- `5`
  - 已被正式降级的旧 `full_extension_mainline`
    与 `order_intake_and_fulfillment_mainline`
    BFF 文书

## 8. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for L5 frontend consumption consistency refresh authoring`
  - `No-Go for implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

---
owner: Codex 总控
status: frozen
purpose: >
  Refresh the formal L5 frontend consumption authority for the current
  `项目发布对象簇`, aligning the actual Flutter route registry, page carriers,
  consumer layer, and workbench view-model with the live repo while
  downgrading stale historical route-authority claims.
layer: L5 Frontend
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - docs/04_frontend/ui_state_contract.md
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/dispute_withdraw_page.dart
  - apps/mobile/test/shell_app_test.dart
  - apps/mobile/test/phase23_entry_test.dart
  - apps/mobile/test/inspection_phase3_test.dart
  - apps/mobile/test/rating_entry_test.dart
  - apps/mobile/test/dispute_entry_test.dart
  - apps/mobile/test/exhibition_home_test.dart
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_refreshed_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
---

# 《项目发布对象簇 L5 frontend consumption 一致性刷新补充单》

## 1. Scope

- 本冻结单只覆盖：
  - 当前 `project publish object cluster`
- 本冻结单只服务于：
  - 当前 Flutter route registry
  - 当前 page carrier
  - 当前 consumer layer
  - 当前 workbench view-model / boundary-state posture
- 本冻结单不进入：
  - implementation dispatch
  - integration
  - `release-prep`
  - production release

## 2. L5 Freeze Conclusion

- 当前 frontend authority 以：
  - 现行 route registry
  - 现行 page carrier
  - 现行 consumer layer
  - 现行 tests
    为准
- 当前 frontend 不再允许把以下 direct route authority
  当成现行承载面：
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/ratings/submit`
  - `/exhibition/inspections/recheck`
- 上述 direct routes 当前正式降级为：
  - `historical sidecar only`
- 当前这些动作的真实 carrier 固定为：
  - `ContractDetailPage`
    承载 `confirm + amend`
  - `InspectionDetailPage`
    承载 `recheck`
  - `RatingEntryPage`
    承载 `submit`
- `DisputeWithdrawPage`
  当前仍是现行独立 minimal page carrier
- `workbench` 当前仍然只是一组：
  - summary
  - handoff
  - boundary-state
    consumption
- `workbench` 当前不是：
  - active command desk
  - 第二 detail page
  - 第二 workflow state machine

## 3. 当前直接沿用资产

- 上位 authority 沿用：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
  - `docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_stage_gate_checklist_addendum.md`
- 当前 route / carrier 直接沿用源码资产：
  - `apps/mobile/lib/shell/navigation/app_router.dart`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model*.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/dispute_withdraw_page.dart`
- 当前直接沿用 UI / state 合同资产：
  - `docs/04_frontend/ui_state_contract.md`
- 当前 verification 直接沿用测试资产：
  - `apps/mobile/test/shell_app_test.dart`
  - `apps/mobile/test/phase23_entry_test.dart`
  - `apps/mobile/test/inspection_phase3_test.dart`
  - `apps/mobile/test/rating_entry_test.dart`
  - `apps/mobile/test/dispute_entry_test.dart`
  - `apps/mobile/test/exhibition_home_test.dart`
  - `apps/mobile/test/exhibition_mainline_flow_test.dart`

## 4. 当前 Included Family

- 当前 route registry 已正式注册：
  - `/exhibition/workbench`
  - `/exhibition/projects`
  - `/exhibition/projects/create`
  - `/exhibition/projects/edit`
  - `/exhibition/projects/detail`
  - `/exhibition/my/projects`
  - `/exhibition/my/projects/detail`
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/milestones`
  - `/exhibition/milestones/submit`
  - `/exhibition/inspections/detail`
  - `/exhibition/inspections/submit`
  - `/exhibition/ratings/entry`
  - `/exhibition/disputes/open`
  - `/exhibition/disputes/withdraw`
- 当前 page carrier family：
  - `ExhibitionPage`
    只承载 workbench summary
  - `ProjectCreatePage`
    承载 `create / edit / save / submit / publish` continuation
  - `OrderDetailPage`
    承载 order read，并继续 handoff 到 `contract detail / rating entry / dispute open`
  - `ContractDetailPage`
    承载 `contract/detail + confirm + amend`
  - `MilestoneListPage`
    承载 milestone read
  - `MilestoneSubmitPage`
    承载 `milestone submit`
  - `InspectionDetailPage`
    承载 `inspection/detail + recheck`
  - `InspectionSubmitPage`
    承载 `inspection submit`
  - `RatingEntryPage`
    承载 `rating/entry + submit`
  - `DisputeOpenPage`
    承载 `dispute open`
  - `DisputeWithdrawPage`
    承载 `dispute withdraw`
- 当前 consumer / view-model family：
  - `ExhibitionConsumerLayer`
    提供 `load* / submit* / confirm* / amend* / open* / withdraw*`
    当前全部 canonical BFF 调用入口
  - `ExhibitionWorkbenchViewModelAdapter`
    与 `exhibition_workbench_view_model_sections.dart`
    只把 workbench 消费成：
    - `project_chain`
    - `order_chain`
    - `fulfillment_chain`
    - `extension_boundary`
  - 当前 workbench nodes 只直接放开：
    - project create
    - project showcase
    - order detail
    - milestone list
    - inspection detail
  - 当前 workbench 不直接放开：
    - contract confirm / amend
    - inspection recheck
    - rating submit
    - dispute withdraw

## 5. 当前 Excluded Family

- 当前明确 excluded：
  - `/exhibition/orders/create`
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/submit`
- 当前明确 excluded frontend semantics：
  - 把 workbench 写成 active command desk
  - 把 route shell 误写成 runtime closure
  - 本地自造 `withdrawable / rateable / recheckable` truth
  - `bid / payment / forum / Admin`
    扩进当前对象簇下的 current carrier authority

## 6. 被正式降级的旧文书或旧条款

- `docs/04_frontend/flutter_screen_map.md`：
  - `Phase 2.3` 与 `Phase 3 / Next stage`
    下关于：
    - `/exhibition/contracts/confirm`
    - `/exhibition/contracts/amend`
    - `/exhibition/ratings/submit`
    - `/exhibition/inspections/recheck`
    的独立 route authority 条款，
    当前正式降级为 `historical sidecar only`
- 这些 direct routes 的当前 authority
  以：
  - `apps/mobile/lib/shell/navigation/app_router.dart`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - 当前 page carriers
  - `apps/mobile/test/shell_app_test.dart`
    为准
- `apps/mobile/test/shell_app_test.dart`
  已直接确认：
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/submit`
    当前进入 `route unavailable`
  - 这四条 direct routes 不再拥有现行 page authority
- `docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md`：
  - `4. Canonical Route / Page Carrier Freeze`
  - `6.2 Hard Boundary`
  - `7.2 Hard Boundary`
  - `8. extension_boundary`
  中把 `contract/confirm`、`contract/amend`、`inspection/recheck`、
  `rating/submit`、`dispute/withdraw`
  排除出当前对象的条款，
  当前正式降级为 `2026-04-11 historical baseline only`
- `docs/04_frontend/order_intake_and_fulfillment_mainline_refreshed_frontend_consumption_freeze_addendum.md`：
  - `3.1 Adjacent But Excluded Page`
  - `5.1 Adjacent But Excluded Route / Page`
  - `5.2 Explicitly Excluded Route / Page`
  中继续把 `dispute/open`、`contract/confirm`、`contract/amend`、
  `inspection/recheck`、`rating/*`、`dispute/withdraw`
  写成当前对象外的条款，
  当前正式降级为 `subordinate continuation historical clauses only`

## 7. 当前层唯一 authority 优先级

- `1`
  - 本文件
- `2`
  - `apps/mobile/lib/shell/navigation/app_router.dart`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - 当前 page carriers
  - 当前 mobile tests
- `3`
  - `docs/01_contracts/openapi.yaml`
  - `docs/04_frontend/ui_state_contract.md`
  - 上位 `L0 authority refresh + ruling + stage gate`
- `4`
  - 当前同对象直接沿用子链文书
  - `docs/04_frontend/flutter_screen_map.md`
    中未与当前 repo 冲突的辅助说明
- `5`
  - 已被正式降级的旧 `full_extension_mainline`
    与 `order_intake_and_fulfillment_mainline`
    frontend 文书和历史 direct-route 条款

## 8. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for source_of_truth_map registration refresh`
  - `No-Go for implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

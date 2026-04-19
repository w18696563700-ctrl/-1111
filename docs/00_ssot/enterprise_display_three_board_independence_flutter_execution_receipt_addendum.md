---
owner: Codex 总控
status: active
purpose: Record the execution receipt for the bounded Flutter implementation round of enterprise-display three-board independence, including route-identity cutover, workbench shell alignment, and targeted verification results.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_dispatch_bundle_addendum.md
---

# 《enterprise display three-board independence Flutter execution receipt》

## 1. Scope Closure

- 当前 receipt 只覆盖：
  - `apps/mobile/**` bounded implementation
  - private route identity cutover
  - workbench shell and board-copy alignment
- 当前 receipt 不覆盖：
  - authenticated integration
  - cloud runtime mutation
  - release

## 2. Delivered Docs

- [enterprise_display_three_board_independence_flutter_implementation_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_stage_gate_checklist_addendum.md)
- [enterprise_display_three_board_independence_flutter_implementation_dispatch_bundle_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_dispatch_bundle_addendum.md)

## 3. Touched Code

- 修改：
  - [exhibition_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart)
  - [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart)
  - [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart)
  - [enterprise_hub_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart)
  - [enterprise_hub_workbench_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart)
- 当前轮一并收口的 direct mobile surfaces：
  - [enterprise_hub_workbench_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart)
  - [enterprise_hub_published_change_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart)
  - [enterprise_hub_application_status_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_application_status_page.dart)
  - [enterprise_hub_workbench_page_load.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart)
  - [enterprise_hub_workbench_page_shell.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart)
  - [enterprise_hub_workbench_page_basic_profile_actions.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_basic_profile_actions.dart)
  - [enterprise_hub_workbench_page_media_actions.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart)
  - [enterprise_hub_workbench_page_submit_actions.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_submit_actions.dart)
  - [enterprise_hub_workbench_page_case_actions.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart)
  - [enterprise_hub_apply_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart)
- 修改测试：
  - [enterprise_hub_workbench_stage1_relayout_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart)
  - [profile_company_enterprise_display_entry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/profile_company_enterprise_display_entry_test.dart)
- 新增测试：
  - [enterprise_hub_board_scoped_transport_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/enterprise_hub_board_scoped_transport_test.dart)

## 4. Effective Result

- 已新增 private fixed-board route family：
  - `/exhibition/company-display/workbench`
  - `/exhibition/factory-display/workbench`
  - `/exhibition/supplier-display/workbench`
  - `/exhibition/company-display/cases/editor`
  - `/exhibition/factory-display/cases/editor`
  - `/exhibition/supplier-display/cases/editor`
  - `/exhibition/company-display/status`
  - `/exhibition/factory-display/status`
  - `/exhibition/supplier-display/status`
- shared legacy `/exhibition/enterprise/**` family 继续保留为 compatibility alias；router 仍能兼容旧 query-carried `boardType`。
- profile 三入口现在都通过同一套 board-neutral published-change 探测逻辑，不再只给 factory 特例。
- workbench header 已去掉 `SegmentedButton` board switcher；当前页板块由 route family 固定，不再由 query 驱动切换。
- private consumer canonical family 已切换到：
  - `/api/app/exhibition/enterprise-hub/company/**`
  - `/api/app/exhibition/enterprise-hub/factory/**`
  - `/api/app/exhibition/enterprise-hub/supplier/**`
- fixed-board canonical request 已收口：
  - list / detail / recommendations / ensure-shell / applications / createCase / changes/current 不再显式塞 `boardType / applyBoardType`
  - published-change family 也已随 board 固定 path family 一起切过去
- private copy 已对齐：
  - `公司展示工作台 / 工厂展示工作台 / 供应商展示工作台`
  - `公司展示变更工作台 / 工厂展示变更工作台 / 供应商展示变更工作台`
  - `公司展示状态 / 工厂展示状态 / 供应商展示状态`

## 5. Verification

- 静态检查：
  - `cd apps/mobile && flutter analyze`
- 当前分析结果：
  - `0` errors
  - 仍有 `37` 条 repository-existing info / warnings，均不在本轮 Flutter 三板块独立化 write set 内
- 定向测试通过：
  - `cd apps/mobile && flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart test/profile_company_enterprise_display_entry_test.dart test/enterprise_hub_board_scoped_transport_test.dart`
  - `10 passed`
  - `0 failed`

## 6. Residual Risks

- authenticated tunnel smoke 仍未执行，所以这轮还没拿到带登录态的 end-to-end runtime 回执。
- shared legacy `/exhibition/enterprise/**` family 仍在兼容期，当前不能误删。
- `public-cases / caseId / applicationId / formal-info / location/resolve` 仍保留 shared carrier；这不阻塞三入口独立感，但后续若要彻底消掉 shared carrier 语义，还需要单独再开一轮。
- `个人/团队展示` 仍然是 placeholder，本轮没有放行。

## 7. Formal Conclusion

- `Flutter implementation gate`：已执行
- `Package A / route identity cutover`：已完成
- `Package B / workbench shell and board-copy alignment`：已完成
- `apps/mobile/**` bounded implementation：已完成
- 下一步若继续，只能进入：
  - authenticated integration verification
  - 或再单独开 `legacy route bridge removal` / deeper carrier cleanup round

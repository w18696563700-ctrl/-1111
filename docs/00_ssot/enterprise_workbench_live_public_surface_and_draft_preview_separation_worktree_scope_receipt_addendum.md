# Enterprise Workbench Live Public Surface And Draft Preview Separation Worktree Scope Receipt Addendum

## Date
- 2026-04-19

## Purpose
- 固化本轮“工厂展示工作台首屏公开真值与当前变更稿预览分离”的实际收口范围。
- 避免后续再把本轮改动和当前仓库中已有的大面积脏工作区混在一起。

## This Round Direct Scope
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - published-change workbench state 增补 `public detail` 读取结果承载。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
  - published-change workbench 同时读取 `changes/current`、`changes/current/status`、`public detail`。
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - 顶部 published-change 区块顺序调整为：
    - `已发布展示变更`
    - `线上公开展示`
    - `当前变更稿预览`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart`
  - 新增 `线上公开展示` section。
  - 将原 `预览展示页` 更名为 `当前变更稿预览`，并维持默认折叠。
- `apps/mobile/test/profile_company_enterprise_display_entry_test.dart`
  - 工厂展示入口 published-change corridor 回归更新。
- `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
  - published-change 顶部双 surface 结构回归更新。
- `apps/mobile/test/enterprise_hub_routes_test.dart`
  - published-change route 回归更新，并补 public detail fake transport。
- `docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_truth_ruling_addendum.md`
- `docs/01_contracts/enterprise_workbench_live_public_surface_and_draft_preview_separation_contract_compatibility_addendum.md`
- `docs/04_frontend/enterprise_workbench_live_public_surface_and_draft_preview_separation_frontend_surface_addendum.md`

## Current Git Shape For Direct Scope
- `M apps/mobile/test/enterprise_hub_routes_test.dart`
- `?? apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `?? apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
- `?? apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
- `?? apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart`
- `?? apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
- `?? apps/mobile/test/profile_company_enterprise_display_entry_test.dart`
- `?? docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_truth_ruling_addendum.md`
- `?? docs/01_contracts/enterprise_workbench_live_public_surface_and_draft_preview_separation_contract_compatibility_addendum.md`
- `?? docs/04_frontend/enterprise_workbench_live_public_surface_and_draft_preview_separation_frontend_surface_addendum.md`
- `?? docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_worktree_scope_receipt_addendum.md`

## Verified In This Round
- `flutter test test/profile_company_enterprise_display_entry_test.dart`
- `flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart --plain-name "published change mode keeps snapshot corridor after relayout"`
- `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise published change workbench consumes changes current family and separates live snapshot from current snapshot"`
- `flutter analyze lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart test/profile_company_enterprise_display_entry_test.dart test/enterprise_hub_workbench_stage1_relayout_test.dart test/enterprise_hub_routes_test.dart`

## Clearly Out Of Scope Dirty Areas
- `apps/bff/src/**`
  - 当前存在大面积修改与新增，不属于本轮 mobile workbench top surface 修复。
- `apps/server/src/**`
  - 当前存在大面积修改，不属于本轮 mobile 顶部 surface 分离。
- `apps/mobile/lib/features/exhibition/**`
  - 除本收口单列出的 `enterprise_hub_workbench_*` 文件外，其余 exhibition 子域脏改均不应默认为本轮内容。
- `apps/mobile/lib/features/profile/**`
  - 除此前已冻结的入口拆分相关内容外，本轮未继续扩展 profile 侧实现范围。
- `docs/01_contracts/**`, `docs/02_backend/**`, `docs/03_bff/**`, `docs/04_frontend/**`
  - 当前仓库已有大量 addendum，不应把它们误当成这轮新增范围。
- `apps/admin/**`
  - 独立脏区，与本轮无关。

## Next Cleanup Guidance
- 如果后续需要整理本轮成果，优先只看本收口单列出的 direct scope 文件。
- 不要从当前总工作区反推“所有 enterprise_hub 相关改动都属于这轮”。
- 若后续需要提交或搬运，应把本收口单作为最小范围清单。

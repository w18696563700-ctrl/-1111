# Enterprise Workbench Live Public Surface And Draft Preview Separation Stage Minimal File Pack Addendum

## Date
- 2026-04-19

## Purpose
- 给出本轮“工厂展示工作台首屏公开真值与当前变更稿预览分离”可直接暂存/提交的最小文件包。
- 避免从当前总工作区中误选无关脏文件。

## Recommended Pack A
- 用途：
  - 只暂存本轮实现与回归，不带收口说明文档。
- 文件：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart`
  - `apps/mobile/test/profile_company_enterprise_display_entry_test.dart`
  - `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
  - `apps/mobile/test/enterprise_hub_routes_test.dart`

## Recommended Pack B
- 用途：
  - 暂存本轮实现、回归、真值冻结和工作区收口说明。
- 文件：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart`
  - `apps/mobile/test/profile_company_enterprise_display_entry_test.dart`
  - `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
  - `apps/mobile/test/enterprise_hub_routes_test.dart`
  - `docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_truth_ruling_addendum.md`
  - `docs/01_contracts/enterprise_workbench_live_public_surface_and_draft_preview_separation_contract_compatibility_addendum.md`
  - `docs/04_frontend/enterprise_workbench_live_public_surface_and_draft_preview_separation_frontend_surface_addendum.md`
  - `docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_worktree_scope_receipt_addendum.md`
  - `docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_stage_minimal_file_pack_addendum.md`

## Direct Stage Command For Pack A
```bash
git add \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart \
  apps/mobile/test/profile_company_enterprise_display_entry_test.dart \
  apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart \
  apps/mobile/test/enterprise_hub_routes_test.dart
```

## Direct Stage Command For Pack B
```bash
git add \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart \
  apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_snapshot_sections.dart \
  apps/mobile/test/profile_company_enterprise_display_entry_test.dart \
  apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart \
  apps/mobile/test/enterprise_hub_routes_test.dart \
  docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_truth_ruling_addendum.md \
  docs/01_contracts/enterprise_workbench_live_public_surface_and_draft_preview_separation_contract_compatibility_addendum.md \
  docs/04_frontend/enterprise_workbench_live_public_surface_and_draft_preview_separation_frontend_surface_addendum.md \
  docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_worktree_scope_receipt_addendum.md \
  docs/00_ssot/enterprise_workbench_live_public_surface_and_draft_preview_separation_stage_minimal_file_pack_addendum.md
```

## Recommendation
- 如果你只想先收代码，选 `Pack A`。
- 如果你希望后续追责、复盘、交接都不再口头化，选 `Pack B`。
- 当前仓库过脏，默认更建议 `Pack B`，因为它能把这轮真值边界一起钉住。

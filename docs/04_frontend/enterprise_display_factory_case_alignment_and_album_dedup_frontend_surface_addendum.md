---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter surface repair for post-submit case-entry alignment and company/factory detail album de-dup.
layer: L4 Frontend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_factory_case_alignment_and_album_dedup_truth_ruling_addendum.md
  - docs/01_contracts/enterprise_display_factory_case_alignment_and_album_dedup_contract_compatibility_addendum.md
  - docs/04_frontend/factory_detail_optimization_remediation_frontend_surface_addendum_v1_1.md
  - docs/04_frontend/enterprise_detail_company_sample_and_home_module_sync_frontend_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
---

# 《enterprise display factory case alignment and album dedup frontend surface》

## 1. Scope

- 当前只补：
  - generic workbench -> case editor 的入口纠偏
  - company/factory detail 的正文画册去重语义
  - 对应定点回归

## 2. Post-submit Continue-edit Rule

- 当 generic workbench 已处于 `post-submit` application 语义时：
  - `继续编辑` 必须直接进入 published-change case editor route
  - 不得再预灌 live case seed 到 published-change case editor
- 若旧 route 仍以 generic case-editor 方式进入：
  - 当前页面加载阶段必须自动切入 `changes/current`
  - 不得停留在半 live 半 draft 的中间态

## 3. Detail Album Rule

- `company detail`
  - 不额外渲染独立正文 `企业画册` 区
- `factory detail`
  - 正文独立 `企业画册` 区继续隐藏
- `EnterpriseDetailVisualGallerySection`
  - 只维持真实 `album` 语义
  - 空 album 时显示空态，不再回退 case cover

## 4. Required Tests

- post-submit 工厂案例点击 `继续编辑` 后直接进入 current-change carrier
- company/factory detail 不出现独立正文 `企业画册`
- detail visual gallery 在无 album 时保持空态语义

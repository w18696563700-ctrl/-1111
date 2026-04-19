---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend repair surface for enterprise-display company/factory board separation, case continuation image echo fallback, and detail gallery fallback only.
layer: L4 Frontend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_display_company_factory_case_media_repair_contract_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_form_state.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_format_support.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_media_support.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
---

# 《enterprise display company/factory 串板块与案例媒体回显 frontend surface freeze》

## 1. Scope

- 当前 frontend freeze 只补：
  - company / factory 标题与所属公司语义
  - 工厂案例继续编辑图片回显 fallback
  - detail gallery fallback 生效
  - 对应回归测试
- 当前不补：
  - 详情页整体重排
  - 新 board 筛选交互
  - direct-to-server bypass

## 2. Continue-edit Fallback Rule

- `继续编辑` 当前必须满足：
  - 先使用已有 workbench case summary carrier 预灌图片
  - 再使用 case detail 增量覆盖
- 当 detail 缺少 `caseImageUrlMap` 时：
  - 不得清空当前已知图片
  - 不得直接退成空占位而无任何 fallback

## 3. Naming Presentation Rule

- factory 标题当前必须与公司主体名分开呈现：
  - 标题显示工厂名
  - 辅助行显示所属公司或主体名
- 当前不得继续把 `name` 同时当作：
  - factory 标题兜底
  - 所属公司行来源

## 4. Detail Gallery Rule

- company / factory detail 当前允许在 `visualGallery` 为空时消费 case cover fallback。
- 当前不得继续让：
  - `fallbackImages` 成为死参数
  - gallery section 只对 supplier 开放

## 5. Allowed Write Set

- 当前 frontend 允许：
  - `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_case_actions.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_form_state.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_format_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_media_support.dart`
  - 与上述直接相关的 `test`

## 6. Required Tests

- 当前 frontend 至少必须补：
  - `continue edit` 在 URL map 缺失时仍能显示既有 remote image
  - factory 标题 / 所属公司行断言
  - company / factory detail gallery fallback 生效断言

## 7. Anti-revert

- 不得伪造图片成功态来掩盖 upstream carrier 缺失。
- 不得在 Flutter 侧自创第二套 factory/company truth。
- 不得把 case continuation 回退成只能依赖私有 detail 一次性完整返回。

## 8. Formal Conclusion

- 当前 frontend surface 已冻结为：
  - bounded fallback and semantics repair only
  - no new capability expansion


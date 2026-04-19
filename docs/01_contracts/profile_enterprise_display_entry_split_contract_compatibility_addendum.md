---
owner: Codex 总控
status: frozen
purpose: Record that the profile enterprise-display entry split is contract-compatible and reuses existing boardType routes.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/profile_enterprise_display_entry_split_truth_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
---

# 《profile enterprise display entry split contract compatibility addendum》

## 1. No New Path Family

- 当前不新增：
  - profile 新 path family
  - enterprise display 新 path family
  - personal/team 新 workbench path

## 2. Existing Route Reuse

- 公司入口继续复用：
  - `enterpriseApplyWithBoardType('company')`
- 工厂入口继续复用：
  - `enterpriseApplyWithBoardType('factory')`
- 供应商入口继续复用：
  - `enterpriseApplyWithBoardType('supplier')`
- 个人/团队继续复用：
  - 既有占位提示语义

## 3. Compatibility Conclusion

- 本轮属于：
  - `profile entry split`
  - `route handoff simplification`
- 本轮不属于：
  - contract widening
  - route mutation
  - business truth rewrite

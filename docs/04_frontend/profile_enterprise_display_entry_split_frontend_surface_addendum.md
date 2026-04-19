---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter surface repair that splits the enterprise-display workbench entry into four direct asset entries under 我的资产.
layer: L4 Frontend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/profile_enterprise_display_entry_split_truth_ruling_addendum.md
  - docs/01_contracts/profile_enterprise_display_entry_split_contract_compatibility_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
---

# 《profile enterprise display entry split frontend surface》

## 1. Scope

- 当前只补：
  - `我的资产` 分组内入口拆分
  - 删除单一总入口的点击弹层依赖
  - 对应定点回归

## 2. Target Surface

- `我的资产` 入口顺序固定为：
  - `我的项目`
  - `我的论坛`
  - `我的公司展示`
  - `我的工厂展示`
  - `我的供应商展示`
  - `我的个人/团队展示`

## 3. Required Tests

- profile 私域整理视图显示 6 个资产入口
- 工厂入口可直接进入既有工厂工作台
- 个人/团队入口继续显示占位提示

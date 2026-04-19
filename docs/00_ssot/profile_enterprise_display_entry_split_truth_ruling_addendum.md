---
owner: Codex 总控
status: frozen
purpose: Freeze the truth ruling for splitting the single enterprise-display workbench entry into four direct asset entries under 我的资产.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/profile_enterprise_display_entry_split_stage_gate_checklist_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
---

# 《profile enterprise display entry split truth ruling》

## 1. Scope

- 当前只改：
  - `我的 -> 我的资产` 分组内的企业展示入口组织
- 当前不改：
  - exhibition 楼首页
  - company / factory / supplier 真实工作台
  - case editor / published-change / detail

## 2. Entry Truth

- 原单一入口：
  - `企业展示入驻工作台`
- 正式裁决替换为 4 个直达入口：
  - `我的公司展示`
  - `我的工厂展示`
  - `我的供应商展示`
  - `我的个人/团队展示`

## 3. Route Truth

- `我的公司展示`
  - 继续直达 `enterpriseApplyWithBoardType('company')`
- `我的工厂展示`
  - 继续直达 `enterpriseApplyWithBoardType('factory')`
- `我的供应商展示`
  - 继续直达 `enterpriseApplyWithBoardType('supplier')`
- `我的个人/团队展示`
  - 继续保留占位提示，不扩写真实工作台

## 4. Non-goals

- 不修改任何已有企业展示业务语义
- 不新增中转弹层
- 不重做 `我的资产` 其它入口

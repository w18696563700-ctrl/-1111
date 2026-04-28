---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter surface change for Quote Basis Material Package V1
  full-format material uploads and the prepublish detail page title context.
layer: L5 Frontend
freeze_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_full_format_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_full_format_contract_addendum.md
  - docs/04_frontend/quote_basis_material_package_v1_frontend_surface_addendum.md
---

# 《报价依据资料包 V1 全格式 frontend surface addendum》

## 1. Publisher Surface

发布方 5 类资料入口均显示为支持全格式文件。Flutter 不再因选择了不同资料类型而清空已选文件，也不再用资料类型拦截 MIME。

## 2. Prepublish Detail Title

当 `我的项目详情` 承接到 `submitted` 项目时，AppBar 标题显示：

`我的项目详情（预发布补齐资料并发布页）`

其中括号说明只作为页面定位文案，不新增状态。

## 3. Option Judgment

- 更稳：标题提示用户当前处于预发布补资料和发布确认页，不改状态机。
- 更省成本：复用现有我的项目详情页和附件区。
- 更适合当前阶段：收敛预发布页职责，不回到创建页堆交易动作。
- 风险更大：只改 UI 文案但不改本地选择校验，会让用户仍然上传失败。

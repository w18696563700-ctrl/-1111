---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter surface for Quote Basis Material Package V1 across the
  publisher workbench and supplier bid-submit page.
layer: L5 Frontend
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/02_backend/quote_basis_material_package_v1_backend_truth_addendum.md
  - docs/03_bff/quote_basis_material_package_v1_bff_surface_addendum.md
---

# 《报价依据资料包 V1 frontend surface》

## 1. Publisher Surface

发布方 `我的项目 -> 我的发布 -> 项目详情` 的附件区用户名固定为：

- `报价依据资料`

上传入口固定为 5 类：

- 效果图
- 尺寸图 / 施工图
- 材质图 / 材料样板
- 设备物料清单
- 服务清单

Flutter 继续复用三段式上传：

`upload init -> direct upload -> upload confirm -> bind project attachment`

不得把新材质图写成 `other_material`。

## 2. Supplier Surface

竞标提交第二步固定为：

- `第二步 查看报价依据资料`

展示采用九宫格能力，但 V1 只有 5 个真实格子。每个格子对应一个资料类型；未上传时显示发布方暂未上传。接单方不得看到上传、删除、绑定等 owner 管理动作。

温馨提示固定为：

> 建议先将资料下载到手机，再导入电脑完成报价测算和方案整理。下载后的资料仅用于本项目竞标，请勿外传。

## 3. View / Download

接单方点击资料时调用：

- `GET /api/app/file/access`
- `projectId={projectId}`
- `accessScope=bid_material`
- `mode=preview | download`

Flutter 不缓存长期 OSS URL，不把列表响应中的 `fileAssetId` 当下载授权。

## 4. Format Policy

经 `docs/04_frontend/quote_basis_material_package_full_format_frontend_surface_addendum.md`
补充冻结，发布方 5 类资料入口均显示支持全格式文件；Flutter 不再按资料类型拦截 MIME。

## 5. Option Judgment

- 更稳：五类资料共用一套 Flutter 枚举，发布方与接单方同源展示，不把文件格式写成业务分类规则。
- 更省成本：复用既有上传、绑定、列表和 file-access action。
- 更适合当前阶段：仅改展览发布/竞标链路，不扩模板中心和工程量清单。
- 风险更大：继续使用 `other_material` 或在接单方直接展示 owner 管理能力。

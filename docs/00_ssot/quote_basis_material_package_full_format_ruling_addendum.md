---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the full-format file policy for Quote Basis Material Package V1 while
  keeping the five canonical attachment kinds, FileAsset truth chain, and
  owner-private / bidder-read boundaries unchanged.
layer: L0 SSOT
freeze_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/02_backend/quote_basis_material_package_v1_backend_truth_addendum.md
  - docs/03_bff/quote_basis_material_package_v1_bff_surface_addendum.md
  - docs/04_frontend/quote_basis_material_package_v1_frontend_surface_addendum.md
---

# 《报价依据资料包 V1 全格式资料口径 ruling》

## 1. Conclusion

`报价依据资料包 V1` 的 5 个业务分类不变：

- `effect_image`
- `construction_doc`
- `material_sample`
- `equipment_material_list`
- `service_list`

本轮只调整文件格式策略：以上 5 类均支持全格式文件上传、绑定、读取和下载。`attachmentKind` 继续表示报价依据资料的业务分类，不再承担文件格式白名单含义。

## 2. Current Minimum Closure

- 发布方在预发布补齐资料并发布页 / 我的项目详情上传 5 类报价依据资料。
- 上传链路仍为 `init -> direct upload -> confirm -> bind project attachment`。
- 绑定真相仍为 `FileAsset + project_attachments`。
- 接单方只读投影继续复用 `bid-materials`。
- `other_material` 继续只是历史兼容值，不进入新主路径。

## 3. Boundary

- 不新增 `prepublish/prepublished` 状态。
- 不新增第二套附件 family。
- 不按 OSS `objectKey`、文件名或 MIME 反推业务分类。
- 不把报价依据资料包扩成模板中心、工程量清单中心或交易总控台。

## 4. Option Judgment

- 更稳：保留 5 个 `attachmentKind` 作业务分类，只放宽文件格式，避免把格式限制误写成第二状态机。
- 更省成本：复用现有上传、确认、绑定、列表、file access 和 bid-materials 投影。
- 更适合当前阶段：只解决报价依据资料收集能力，不扩订单、支付、合同和履约。
- 风险更大：继续按资料类型限制 MIME，会让“服务清单可传表格、效果图只能传图片”这类前端口径反复返工；把全格式理解成新增附件中心风险更大。

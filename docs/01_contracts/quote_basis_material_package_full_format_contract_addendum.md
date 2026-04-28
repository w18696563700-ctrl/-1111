---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contract delta that Quote Basis Material Package V1 accepts
  full-format files across all five canonical attachment kinds.
layer: L2 Contracts
freeze_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_full_format_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《报价依据资料包 V1 全格式 contract addendum》

## 1. Contract Delta

`ProjectQuoteBasisMaterialKind` 枚举不变。`ProjectAttachmentReadModel.mimeType` 和 `ProjectBidMaterialReadModel.mimeType` 不再按 `attachmentKind` 做格式白名单收窄。

允许策略调整为：

- 5 个报价依据资料分类均可绑定任意有效 MIME。
- 无法识别的扩展名可按 `application/octet-stream` 进入上传和绑定。
- `mimeType` 是文件技术属性，不是业务分类真源。

## 2. Preserved Contract

- `attachmentKind` 必须仍是 5 个 V1 枚举之一。
- `FileAsset.businessType = project`。
- `FileAsset.fileKind = project_attachment`。
- `project_attachments.project_id` 必须等于 path 中的 `projectId`。
- `other_material` 不进入 `ProjectQuoteBasisMaterialKind` 或 bid-materials 投影。

## 3. Option Judgment

- 更稳：合同只放宽 MIME，不放宽 `attachmentKind`、权限、访问和真值链。
- 更省成本：不新增接口字段，不新增上传业务类型。
- 更适合当前阶段：让发布方一次性补齐工厂报价需要的原始资料。
- 风险更大：继续把 MIME 白名单写在 L2，会阻断 CAD、压缩包、图片以外效果资料和供应商常见原始文档。

---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server-side binding rule change for Quote Basis Material Package
  V1 full-format files.
layer: L3 Backend
freeze_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_full_format_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_full_format_contract_addendum.md
  - docs/02_backend/quote_basis_material_package_v1_backend_truth_addendum.md
---

# 《报价依据资料包 V1 全格式 backend truth addendum》

## 1. Conclusion

Server 继续校验项目归属、owner 权限、附件走廊状态、`FileAsset` 归属和 `attachmentKind` 五类枚举。Server 不再按 `attachmentKind` 拦截 MIME family。

## 2. Persisted Truth

- `project_attachments.attachment_kind` 仍是报价依据资料分类真源。
- `project_attachments.mime_type` 仅记录文件技术属性。
- `file_assets.mimeType` 可为常见 MIME 或 `application/octet-stream`。

## 3. Preserved No-Go

- 不允许新写入 `other_material`。
- 不放宽 owner-private / bid-material access 权限。
- 不用 MIME 推断业务分类。

## 4. Option Judgment

- 更稳：Server 只守业务真相和权限，不再把资料分类和格式混成一套隐式规则。
- 更省成本：删除绑定阶段 MIME-kind 组合校验即可，不动表结构。
- 更适合当前阶段：满足报价依据资料收集，不扩大交易后链路。
- 风险更大：保留按类型 MIME 拦截会导致 Flutter 放开后 Server 绑定失败，形成假能力。

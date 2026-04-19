---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth ownership and carrier split for business-license OCR
  preview fields versus formal certification truth fields, including mandatory
  admission of the full major business-license field set.
layer: L3 Backend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_license_field_collection_ruling_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
---

# 《认证资料营业执照字段收录补全 Backend Truth 补充冻结》

## 1. Truth Split

- `Server` 是营业执照正式认证字段的唯一 truth owner。
- `OCR provider response` 不是正式认证真值 owner。
- `OCR preview object` 只是一段临时识别结果。
- `formal certification truth object` 必须落在 `Server` 自有 carrier 上，并通过正式 current read model 对外暴露。

## 2. Mandatory Formal Truth Set

当前正式认证真值最小集合冻结为：

- `legalName`
- `uscc`
- `licenseFileId`
- `address`
- `establishedAt`
- `legalPerson`
- `businessType`
- `registeredCapital`
- `businessTerm`
- `businessScope`

## 3. Canonical Carrier Rule

- 正式认证字段必须由 `Server` 持有的认证/组织 carrier 负责落库与读取。
- `licenseFileId` 继续绑定正式文件真值 carrier。
- `address / establishedAt / legalPerson / businessType / registeredCapital / businessTerm / businessScope`
  当前必须进入与认证 current object 对齐的正式 persistence/read chain。
- 以下对象不得成为正式认证字段唯一载体：
  - OCR provider payload
  - 前端本地缓存
  - BFF response shaping cache
  - 临时预览 DTO

## 4. Preview Layer Rule

以下字段在 OCR preview 层仍然允许是：

- `partial`
- `nullable`
- `provider-shaped`

但当前 backend truth 已冻结它们必须拥有正式 persistence carrier：

- `legalPerson`
- `businessType`
- `registeredCapital`
- `businessTerm`
- `businessScope`

## 5. Derived-vs-Canonical Rule

| Field family | Canonical or derived | Current rule |
|---|---|---|
| `legalName / uscc / licenseFileId / address / establishedAt / legalPerson / businessType / registeredCapital / businessTerm / businessScope` | canonical | must be persisted and read back from `Server` truth |
| OCR preview payload fields | derived / temporary | may be shown for preview only |
| `businessType` raw OCR output | derived / temporary | must be normalized before entering formal truth |

## 6. `businessType` Correction Rule

- 当前禁止把以下值落入正式认证真值 carrier：
  - `QRCode`
  - 文档类型标签
  - 扫描类型标签
  - OCR provider 的版式/分类标签
- 若 OCR 原文命中上述噪声：
  - 可保留在 preview layer
  - formal truth 中必须归一为 `null`
  - 不得写入 `certification/current.businessType`

## 7. Prohibited Truth Mixing

- 不得把 OCR provider 原始字段与正式认证 DB truth 混写为同一层级真值。
- 不得把 `BFF` 整形结果倒灌成 backend truth。
- 不得把 Flutter 预览确认状态或页面缓存冒充正式认证 truth。
- 不得跳过 `businessType` 规范化，直接把 OCR 噪声入库。

## 8. Formal Conclusion

- 当前 backend truth 最小补全目标已经写死为：
  - 让营业执照主要字段整体进入正式认证真值链
- OCR preview 继续存在，但不再是 `legalPerson / businessType / registeredCapital / businessTerm / businessScope`
  的唯一载体。

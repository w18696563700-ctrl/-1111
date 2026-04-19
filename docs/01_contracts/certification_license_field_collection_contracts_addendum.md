---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contract boundary for business-license OCR preview fields and
  formal certification current fields, including mandatory formal-field
  admission and OCR-only preview semantics.
layer: L2 Contracts
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_license_field_collection_ruling_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
---

# 《认证资料营业执照字段收录补全 Contracts 补充冻结》

## 1. Scope

- 本文书覆盖两个 app-facing contracts family：
  - `POST /api/app/profile/certification/license/ocr`
  - `GET /api/app/profile/certification/current`
- 本文书不扩写：
  - 新路径
  - 新认证状态
  - 非营业执照证件族

## 2. Contract Split

### 2.1 OCR Preview Contract

- `license/ocr` 返回的是：
  - `OCR preview object`
- 该对象允许：
  - `partial`
  - `nullable`
  - `provider-shaped`
- 该对象不代表：
  - 已正式收录
  - 已入库真值
  - 已出现在 `certification/current`

### 2.2 Formal Current Contract

- `certification/current` 返回的是：
  - `formal certification current object`
- 该对象只允许暴露已被冻结为正式真值的字段。
- 当前最小必收字段为：
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

## 3. Field Matrix

| Field | `license/ocr` preview | `certification/current` formal truth |
|---|---|---|
| `legalName` | allowed | required |
| `uscc` | allowed | required |
| `licenseFileId` | not OCR-derived | required in current object |
| `address` | allowed | required |
| `establishedAt` | allowed | required |
| `legalPerson` | allowed | required |
| `businessType` | allowed with correction | required after correction |
| `registeredCapital` | allowed | required |
| `businessTerm` | allowed | required |
| `businessScope` | allowed | required |

## 4. Contract Rules

- `licenseFileId` 是正式认证对象字段，不是 OCR provider 原始字段。
- `address / establishedAt` 当前已被冻结为必须进入 `certification/current` 的正式字段。
- `legalPerson / registeredCapital / businessTerm / businessScope` 当前也已被冻结为必须进入 `certification/current` 的正式字段。
- `businessType` 当前已被冻结为必须进入 `certification/current` 的正式字段，但必须先完成噪声过滤与规范化。
- `license/ocr` 返回同名字段时：
  - 仍只代表 OCR 预览候选值
  - 不得被视为已正式收录，除非同字段已出现在 `certification/current`

## 5. `businessType` Contract Correction

- `businessType` 在 `license/ocr` 中只可作为候选预览值。
- 若 provider 返回值疑似以下语义：
  - `QRCode`
  - 文档类型
  - 扫描类型
  - 版式标签
- 当前 contract 允许：
  - 在 preview 层保留为原始识别候选值
  - 在 formal current 层降为 `null`
- 当前 contract 禁止：
  - 将其透传为 `certification/current.businessType`
  - 将其标注为企业主体类型正式收录值

## 7. Formal Conclusion

- `license/ocr` 是预览合同，不是正式认证 truth 合同。
- `certification/current` 是正式认证当前态合同，当前至少必须稳定包含：
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

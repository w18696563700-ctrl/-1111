---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF shaping boundary for business-license OCR preview fields and
  formal certification current fields, including mandatory pass-through of
  the expanded formal field set and corrected businessType handling.
layer: L4 BFF
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_license_field_collection_ruling_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
---

# 《认证资料营业执照字段收录补全 BFF Surface 补充冻结》

## 1. BFF Responsibility Boundary

- `BFF` 只负责：
  - app-facing route shaping
  - auth consolidation
  - nullable normalization
  - response field trimming within frozen truth scope
- `BFF` 不负责：
  - 定义正式认证字段真值
  - 自建 OCR 字段采信规则
  - 自建第二套认证状态机

## 2. Route Surface Split

| Route family | BFF role | Hard boundary |
|---|---|---|
| `profile/certification/license/ocr` | shape preview response | may expose preview-only fields, but must not imply formal truth |
| `profile/certification/current` | shape formal current response | must expose only formal truth fields approved in current round |

## 3. Mandatory BFF Surface Rule

- 在 `certification/current` 上，BFF 当前必须稳定承接并对外输出：
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
- 若上游当前缺失 `address / establishedAt`：
  - 这属于 truth-chain 未闭合
  - 不允许由 BFF 自造默认值或伪推导值补齐

## 4. Preview-only Field Rule

- 在 `license/ocr` 上，BFF 可以整形以下预览字段：
  - `legalPerson`
  - `businessType`
  - `registeredCapital`
  - `businessTerm`
  - `businessScope`
- 但必须明确保持其为：
  - preview-only
  - optional
  - non-canonical

## 5. `businessType` Correction Rule

- BFF 不得把以下内容归一成正式企业类型：
  - `QRCode`
  - 文档类型
  - 扫描类型
  - provider 分类标签
- 若上游 OCR 返回这些值：
  - BFF 可原样保留在 preview surface
  - BFF 不得把它们映射进 `certification/current.businessType`
  - formal current 层只能透传经过 Server 规范化后的结果

## 6. Forbidden Behaviors

- 不得绕过 Server 真值，自己在 `certification/current` 中补造字段。
- 不得把 preview-only 字段升级成 current truth。
- 不得用 BFF fallback 逻辑掩盖 backend truth 缺口。

## 7. Formal Conclusion

- BFF 对 `license/ocr` 和 `certification/current` 的职责分层已经冻结：
  - `ocr` = preview shaping
  - `current` = formal truth shaping
- 营业执照主要字段已进入正式 current surface 必收范围。

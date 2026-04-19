---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption boundary for business-license OCR preview
  fields and formal certification truth fields, including display split,
  wording guardrails, and prohibition on treating preview data as formal truth.
layer: L5 Frontend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/certification_license_field_collection_ruling_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
---

# 《认证资料营业执照字段收录补全 Frontend Surface 补充冻结》

## 1. Frontend Consumption Split

- Flutter 当前必须严格区分：
  - `OCR preview fields`
  - `formal certification truth fields`
- Flutter 不得把 `license/ocr` 结果直接当成“已正式收录”。
- Flutter 不得因为预览看到了字段，就假定 `certification/current` 也已经成立。

## 2. Formal Truth Fields To Consume

在正式认证 current surface 上，Flutter 只允许把以下字段当作正式真值消费：

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

## 3. Preview-only Fields In UI

以下字段在 OCR 预览层仍然允许显示候选值：

- `legalPerson`
- `businessType`
- `registeredCapital`
- `businessTerm`
- `businessScope`

但前提是：

- OCR 预览必须标明“识别结果预览”
- 是否已正式收录，以 `certification/current` 为准

## 4. UI Copy Guardrail

- 对 `license/ocr` 预览层，前端文案应表达：
  - 识别结果预览
  - 待正式收录
  - 可能为空或不完整
- 对 `certification/current` 正式层，前端文案才允许表达：
  - 当前认证资料
  - 当前正式收录字段

## 5. `businessType` Display Correction

- Flutter 不得把 `QRCode`、文档类型、扫描类型、provider 标签显示成企业类型正式值。
- 若 OCR 预览命中这类值：
  - 只能作为 OCR 识别异常或噪声预览处理
  - 不得进入正式当前资料展示区

## 6. Forbidden Behaviors

- 不得前端本地把 preview-only 字段提升成正式字段。
- 不得在 UI 上补造 `address / establishedAt`。
- 不得自建第二套认证字段状态机。
- 不得用 OCR 预览值覆盖 `certification/current` 正式字段。

## 7. Formal Conclusion

- Flutter 当前正式消费边界已经冻结：
  - `current` 页面只认正式真值字段
  - `ocr` 页面只认预览字段
- 营业执照主要字段已经进入正式 current consumption 必收范围。

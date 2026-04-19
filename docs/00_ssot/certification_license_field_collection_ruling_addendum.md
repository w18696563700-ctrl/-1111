---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the boundary between business-license OCR preview fields and formal
  certification truth fields, and explicitly rule which license fields must be
  formally collected in the current round.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
---

# 《认证资料营业执照字段收录补全裁决单》

## 1. Scope

- 本裁决只覆盖：
  - 营业执照 `OCR 预览字段`
  - 正式认证 `truth fields`
  - `certification/current` 的 app-facing 收录边界
- 本裁决不覆盖：
  - OCR provider 选型
  - 认证业务代码改造
  - 新增认证状态机
  - 非营业执照类证件

## 2. Final Ruling

- 当前必须正式区分两类对象：
  - `OCR preview fields`
  - `formal certification truth fields`
- `OCR provider` 返回值不是正式认证真值。
- `OCR preview` 允许 `partial / nullable / provider-shaped`。
- 正式认证真值必须落在明确 carrier 上，不允许只停留在 UI 预览或临时 OCR 响应里。

## 3. Mandatory Formal Truth Fields

以下字段即日起必须进入正式认证真值：

| Field | Current ruling | Reason |
|---|---|---|
| `legalName` | formal truth | 已是当前正式认证核心字段 |
| `uscc` | formal truth | 已是当前正式认证核心字段 |
| `licenseFileId` | formal truth | 证照文件真值绑定字段 |
| `address` | formal truth | 营业执照住所是正式认证资料的一部分 |
| `establishedAt` | formal truth | 成立日期是正式认证资料的一部分 |
| `legalPerson` | formal truth | 法定代表人属于营业执照主要登记字段 |
| `businessType` | formal truth after correction | 企业类型属于营业执照主要登记字段，但必须先做 OCR 噪声纠偏 |
| `registeredCapital` | formal truth | 注册资本属于营业执照主要登记字段 |
| `businessTerm` | formal truth | 营业期限属于营业执照主要登记字段 |
| `businessScope` | formal truth | 经营范围属于营业执照主要登记字段 |

## 4. Per-field Admission Rulings

| Field | Current ruling | Admission decision |
|---|---|---|
| `legalPerson` | formal truth | 当前批准进入正式认证真值 |
| `businessType` | formal truth after correction | 当前批准进入正式认证真值，但必须先经过噪声过滤与规范化 |
| `registeredCapital` | formal truth | 当前批准进入正式认证真值 |
| `businessTerm` | formal truth | 当前批准进入正式认证真值 |
| `businessScope` | formal truth | 当前批准进入正式认证真值 |

## 5. `businessType` Correction Rule

- `businessType` 当前已批准进入正式认证真值，但只能在完成纠偏后入库与对外暴露。
- 当前正式禁止把以下内容收录成企业类型正式真值：
  - `QRCode`
  - 文档类型
  - 扫描类型
  - OCR provider 输出的版式标签
  - 与营业主体类型无关的识别噪声
- 若 OCR 返回值与上述内容混淆：
  - 可在预览层降为缺失值或异常提示
  - 不得写入正式认证 truth
  - 不得经由 BFF/Flutter 文案包装后冒充正式企业类型

## 6. Current Runtime Meaning

- 当前 active runtime 已证明：
  - OCR 预览链能返回较完整营业执照字段
  - 正式认证真值链与 `certification/current` 仍未稳定承接全部营业执照主要字段
- 因此本轮正式裁决：
  - 认证正式收录不再允许只停留在 `legalName / uscc / licenseFileId / address / establishedAt`
  - 营业执照主要字段必须整体进入正式 carrier 与 `certification/current` surface

## 7. Hard Prohibitions

- 不得把 OCR provider 原样输出视为正式认证真值。
- 不得把 UI 预览字段视为已经入库或已经正式收录。
- 不得在 `businessType` 上把 `QRCode`、文档类型、扫描类型误收成企业类型。
- 不得让 `BFF` 或 `Flutter` 自建第二套认证字段真值。
- 不得绕过 `businessType` 纠偏规则，直接把 OCR 噪声写入正式真值。

## 8. Formal Conclusion

- 当前正式认证真值字段最小必收集合为：
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
- 当前 OCR 预览层仍允许显示同一组营业执照字段，但它们只有在进入正式 carrier 后，才允许被视为正式认证资料。
- 当前 `businessType` 已进入正式真值，但必须适用严格纠偏规则。

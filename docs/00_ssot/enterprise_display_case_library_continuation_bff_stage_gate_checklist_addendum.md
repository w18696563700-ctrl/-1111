---
owner: Codex 总控
status: active
purpose: Freeze the stage gate before the BFF package for enterprise display case-library continuation.
layer: L0 SSOT
---

# 《enterprise display case library continuation BFF stage gate checklist》

## 当前阶段目标

本阶段只允许：

1. 在 `BFF` 接入：
   - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
   - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
2. 保持 BFF 只做 transport / normalization / error mapping

本阶段不允许：

- 先发 Flutter 包
- 先接 published corridor runtime
- 在 BFF 自持第二套 case truth

## 门禁核查

### 1. 真源门禁

- passed
- 依据：
  - [enterprise_display_case_library_continuation_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md)

### 2. 契约门禁

- passed
- 依据：
  - [enterprise_display_case_library_continuation_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md)

### 3. 后端真相门禁

- passed
- 依据：
  - [enterprise_display_case_library_continuation_backend_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_backend_result_verification_conclusion_addendum.md)

### 4. 架构边界门禁

- passed
- 依据：
  - 当前轮到 BFF transport layer
  - 不允许 BFF 自持 `listing-owned case` 真相

### 5. 一票否决门禁

- active veto gates:
  - 不得把 `boardType` 再塞回 direct case update payload
  - 不得在 BFF 偷做 published corridor fallback
  - 不得在 BFF 自持 case-edit state

## 结论

- allowed now:
  - `case continuation BFF package`
- not allowed now:
  - `Flutter package`
  - `published corridor runtime`

## 下一步唯一动作

下一步只允许发：

- `enterprise display case continuation / BFF package`

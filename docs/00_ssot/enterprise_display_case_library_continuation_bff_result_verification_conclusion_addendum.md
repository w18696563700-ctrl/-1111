---
owner: Codex 总控
status: frozen
purpose: Record the verification conclusion for the BFF package of enterprise display case-library continuation.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/enterprise_display_case_library_continuation_bff_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_case_library_continuation_bff_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display case library continuation BFF result verification conclusion》

## 1. 本轮验收范围

本轮只验收：

1. `BFF` 是否补入：
   - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
   - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
2. `BFF` 是否保持：
   - transport / normalization / error mapping only
3. `BFF` 是否继续把 direct continuation 与 published corridor 分开

本轮不验收：

- `Flutter` case continue-edit 接线
- `published corridor` runtime

## 2. 验收结论

- verdict:
  - `PASS WITH RISK`

## 3. 已独立确认通过项

### 3.1 app-facing surface 已补入

- [app-enterprise-hub.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts)
  已补入：
  - `GET cases/:caseId`
  - `PUT cases/:caseId`
- [enterprise-hub.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts)
  已补入：
  - `GET cases/:caseId`
  - `PUT cases/:caseId`

### 3.2 BFF transport / shaping 已补入

- [enterprise-hub.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts)
  已补入：
  - `getCaseDetail()`
  - `updateCase()`
- [enterprise-hub.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts)
  已补入：
  - `toEnterpriseHubCaseDetailResponse()`
  - `toEnterpriseHubCaseUpdateResponse()`

### 3.3 独立验证通过

- `cd apps/bff && npm run build`
  - passed
- `cd apps/bff && node --test test/enterprise-hub-case-continuation-transport.test.cjs`
  - passed
  - `4 / 4`

## 4. 当前风险

### 4.1 formal contract owner drift 尚未完全收口

- [enterprise-hub.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts)
  当前在 `ENTERPRISE_CASE_UPDATE_ROUTE_CONTRACT.errorCodes` 中直接写入了裸字符串：
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- 该 code 当前未由：
  - [error-codes.ts](/Users/wangweiwei/Desktop/展览装修之家总控/packages/contracts/src/generated/error-codes.ts)
  正式承接

正式判断：

- 当前 runtime transport 可以工作
- 但 `generated contract owner -> BFF requireErrorCode()` 这条 formal chain 还没有完全打通

### 4.2 回执中的状态码表述与当前 contract 真值不一致

- 当前 openapi direct case update 对 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 的定义落在：
  - `400`
- 当前 server 真实返回类型也是：
  - `BadRequest`
- 但本轮 BFF 回执把它写成了：
  - `409`

正式判断：

- 当前实现仍能按 `payload.code` 保留：
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- 但验收上不能把这条状态码漂移当成已经完全收口

## 5. 总控裁决

- `BFF package = PASS WITH RISK`
- `Flutter package = No-Go`

原因：

1. app-facing surface 已成
2. 但 formal contract owner drift 尚未完全清零
3. 当前不允许把 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 继续以裸字符串和错误状态码理解带入下一层

## 6. 下一步唯一动作

下一步只允许进入：

- `case continuation error-code contract sync patch`

在该 patch 完成前：

- `Flutter case continuation package` = `No-Go`

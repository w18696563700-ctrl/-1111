---
owner: Codex 总控
status: active
purpose: Execution prompt for the BFF package that exposes enterprise display case-library continuation through the app-facing surface.
layer: L0 SSOT
---

# 《enterprise display case library continuation BFF execution prompt》

## 执行角色

- BFF Agent

## 读取顺序

执行前必须强制阅读：

1. [enterprise_display_case_library_continuation_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md)
2. [enterprise_display_case_library_continuation_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md)
3. [enterprise_display_case_library_continuation_backend_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_backend_result_verification_conclusion_addendum.md)
4. [enterprise_display_case_library_continuation_bff_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_case_library_continuation_bff_stage_gate_checklist_addendum.md)
5. [docs/01_contracts/openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 唯一目标

你这轮只负责在 `BFF` 暴露企业展示案例库继续编辑的 app-facing surface。

当前唯一目标固定为：

1. 接入 `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
2. 接入 `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
3. 保持 BFF 只做 transport / normalization / error mapping
4. 不把 direct continuation 与 published corridor 混在一起

## 允许修改

- `apps/bff/src/routes/enterprise_hub/**`
- 与本轮最小 BFF 闭环直接相关的最小测试文件

## 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不实现 `changes/current` runtime
- 不在 BFF 自持第二套 case truth
- 不在 direct update payload 中重新引入 `boardType`

## 必须完成

1. controller surface
- `app-enterprise-hub.controller.ts` 与 `enterprise-hub.controller.ts`
  都必须补入：
  - `GET cases/:caseId`
  - `PUT cases/:caseId`

2. service surface
- `EnterpriseHubService` 必须补入：
  - `getCaseDetail(caseId, headers)`
  - `updateCase(caseId, payload, headers)`
- `updateCase` 只允许透传冻结字段：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- 不允许透传：
  - `boardType`

3. read model / response shaping
- `GET cases/:caseId` 必须输出 app-facing case detail carrier
- `PUT cases/:caseId` 继续输出最小 update ack：
  - `caseId`
  - `caseStatus`

4. error mapping
- direct case update 至少要能收口：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ENTERPRISE_HUB_CASE_NOT_FOUND`
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`

## 最低测试要求

至少补齐：

1. `GET cases/:caseId` controller / service 能正确转发
2. `PUT cases/:caseId` controller / service 能正确转发
3. `updateCase` 不接受 `boardType`
4. `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 能正确透给 app-facing surface
5. canonical path 与现有错误归一化不被破坏

## 完成标准

结果必须证明：

1. BFF 已具备 direct case continuation app-facing surface
2. BFF 没有偷持有 case-edit state
3. direct continuation 与 published corridor 仍然分离

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把整个 BFF package 写成已完成

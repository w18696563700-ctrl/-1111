---
owner: Codex 总控
status: active
purpose: Freeze the independent verification dispatch for enterprise_hub V1 residual-risk closure after backend, BFF, and frontend receipts are all available for the current bounded re-entry round.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
  - docs/00_ssot/enterprise_hub_v1_backend_residual_risk_closure_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_hub_v1_bff_residual_risk_closure_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_hub_v1_frontend_residual_risk_closure_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_hub_v1_frontend_residual_risk_closure_receipt_addendum.md
  - docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
freeze_date_local: 2026-04-10
---

# 《enterprise_hub V1 residual-risk closure 独立复核派工单》

## 1. Scope

- 本派工单只适用于：
  - `enterprise_hub V1`
- 本派工单只复核：
  - `residual-risk closure`
- 本派工单不代表：
  - release-prep 放行
  - production release 放行
  - `enterprise_hub V1` 全量 closure

## 2. Receipt Gate

- 当前 receipt gate 已满足：
  - backend cloud receipt：
    - `/srv/apps/server/current/tmp/enterprise_hub_v1_backend_residual_risk_closure_receipt_addendum.md`
  - BFF cloud receipt：
    - `/srv/apps/bff/current/tmp/enterprise_hub_v1_bff_residual_risk_closure_receipt_addendum.md`
  - frontend local receipt：
    - [enterprise_hub_v1_frontend_residual_risk_closure_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_hub_v1_frontend_residual_risk_closure_receipt_addendum.md)

## 3. Current Verification Target

- 当前独立复核只回答四个问题：
  1. `apps/bff` full build 是否已在当前 verifier 环境独立通过
  2. `home card -> real list entity -> real detail` 是否已在 formal `80/8080` chain 上真实闭合
  3. `authenticated application-status` 是否已在真实 `session + organization context` 下真实闭合
  4. 当前是否允许把 `enterprise_hub V1` 从 `integration with risk` 推进到 `integration-risk closure complete`

## 4. Fixed Runtime Entry

- formal tunnel entry：
  - `http://127.0.0.1:8080`
- cloud formal chain：
  - `80 -> 3000 -> 3001`
- 当前固定真实账号样本：
  - `mobile = 18696563700`
  - `otpCode = 000000`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`

## 5. Fixed Sample Set

- `company`
  - `enterpriseId = e2a016f4-0b6a-497d-902c-409413858ca9`
  - `applicationId = 3c13d38c-1b7c-4435-ad12-b244cb8902a5`
- `factory`
  - `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `applicationId = c1e83c6f-4637-407f-8d41-5c1413821874`
- `supplier`
  - `enterpriseId = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
  - `applicationId = 9402b153-337b-4ea4-8b47-fcc9b317a0ad`

## 6. Mandatory Verification Steps

1. 先核对三份回执是否存在且内容与当前对象一致。
2. 独立重跑 BFF full build：
   - `ssh root@47.108.180.198 'cd /srv/apps/bff/current && npm run build'`
3. 独立核对 formal health：
   - `GET http://127.0.0.1:8080/health/bff/live`
4. 使用真实登录态：
   - `POST /api/app/auth/otp/login`
   - `POST /api/app/profile/organization/switch`
5. 独立核对首页卡片 exposure：
   - `GET /api/app/exhibition/home`
   - 必须确认：
     - `excellent_company`
     - `excellent_factory`
     - `excellent_supplier`
6. 独立核对三类真实列表：
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=10`
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory&page=1&pageSize=10`
   - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=supplier&page=1&pageSize=10`
   - 不能再只接受 `items=[]`
7. 独立核对三类真实 detail：
   - `GET /api/app/exhibition/enterprise-hub/enterprises/e2a016f4-0b6a-497d-902c-409413858ca9?boardType=company`
   - `GET /api/app/exhibition/enterprise-hub/enterprises/bf5ff83a-26e7-4138-8157-042fb38a5f46?boardType=factory`
   - `GET /api/app/exhibition/enterprise-hub/enterprises/c0576f5c-854c-4b78-9f93-6d57e55d8b47?boardType=supplier`
8. 独立核对真实 application-status：
   - `GET /api/app/exhibition/enterprise-hub/applications/c1e83c6f-4637-407f-8d41-5c1413821874`
   - 期望：
     - `200`
     - `applicationStatus=approved`
9. 独立重跑 frontend bounded proof：
   - `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart`
   - 必要时补跑本轮修改文件 `flutter analyze`

## 7. Hard Rules

- 不得把回执改写成通过
- 不得把 page-level demo/fake transport 当成通过
- 不得把 `items=[]` 继续写成 real entity chain 已闭合
- 不得把 `401 / 403 / 404` 受控中间态写成“用户可正常完成”
- 如任一关键步骤失败，必须原样记录状态码或 build 错误

## 8. Expected Output

- 结果校验 Agent 输出必须至少回答：
  1. `apps/bff` full build 是否独立通过
  2. `company / factory / supplier` 三类真实实体链是否全部独立通过
  3. `application-status approved` 是否在真实认证组织上下文下独立通过
  4. 当前是否仍然只是 `integration with risk`
  5. 当前是否允许进入下一轮 `integration-risk closure review conclusion`

## 9. Next Unique Action

- 下一步唯一动作：
  - 把本派工单对应的执行口令发给 `结果校验 Agent`

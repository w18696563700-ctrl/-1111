---
owner: Backend Agent
status: completed
purpose: Record the real Package A Server governance truth implementation result for the enterprise display published change corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package A Server governance truth execution receipt》

## 1. 修改文件清单

- `apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts`
- `apps/server/src/modules/enterprise_hub/entities/enterprise-change-request.entity.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change.types.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-app.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-admin.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts`
- `apps/server/test/enterprise-hub-published-change-governance.test.cjs`
- `docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md`

## 2. 每个修改点对应的冻结事实编号

### 2.1 `enterprise-hub.constants.ts` + `enterprise-hub.errors.ts`

- 对应冻结事实：
  - contract freeze `5.1`
  - contract freeze `10`
  - execution prompt `controlled error`
- 本次落实：
  - 冻结 `EnterpriseHubChangeRequestStatus`
  - 补齐 `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE`
  - 继续复用 `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`

### 2.2 `entities/enterprise-change-request.entity.ts`

- 对应冻结事实：
  - truth freeze `4.2`
  - truth freeze `4.3`
  - contract freeze `3`
  - contract freeze `8`
- 本次落实：
  - 新增单一 `listing-owned change request` persistence truth
  - 同一 listing 的 current carrier 与治理 carrier 共同锚定这一真相

### 2.3 `enterprise-hub-published-change.types.ts` + `enterprise-hub-published-change.presenter.ts`

- 对应冻结事实：
  - contract freeze `3`
  - contract freeze `5`
  - contract freeze `7`
- 本次落实：
  - 冻结 app-facing current/status response shaping
  - 冻结 Admin queue/detail/review/apply response shaping
  - 保持 app-facing 与 Admin-facing 共用同一 status vocabulary

### 2.4 `enterprise-hub-published-change-snapshot.service.ts`

- 对应冻结事实：
  - truth freeze `4.1`
  - contract freeze `3.2`
  - contract freeze `4`
- 本次落实：
  - 从 live listing / live profile / live contact / live cases 投影 draft snapshot
  - save family 只改 draft snapshot，不碰 live truth

### 2.5 `enterprise-hub-published-change-support.service.ts`

- 对应冻结事实：
  - truth freeze `4.2`
  - truth freeze `4.3`
  - contract freeze `3`
  - contract freeze `4`
  - contract freeze `8`
  - contract freeze `9`
- 本次落实：
  - current change carrier 只认 `listing-owned` active request
  - active status 只允许单条，若同一 listing 出现多条 active request，runtime 直接收口为 `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
  - `GET /changes/current` 只读当前 active carrier，不隐式建单
  - `GET /changes/current/status` 在无 active request 时返回非持久化 draft 状态投影，不向库里落新 request

### 2.6 `enterprise-hub-published-change-app.service.ts`

- 对应冻结事实：
  - truth freeze `3.2`
  - truth freeze `5`
  - contract freeze `4`
  - contract freeze `5`
  - contract freeze `8`
- 本次落实：
  - save family 继续只写 current change carrier
  - submit 从 `draft / revision_required` 进入 `submitted`
  - submit 不写 live listing，不写 live cases

### 2.7 `enterprise-hub-published-change-live-write.service.ts`

- 对应冻结事实：
  - truth freeze `4.1`
  - truth freeze `5`
  - contract freeze `8`
  - contract freeze `9`
- 本次落实：
  - 只有 apply 才把 approved snapshot 写入 live listing / profile / contact / cases
  - save / submit / review / approved 都不更新 live listing

### 2.8 `enterprise-hub-published-change-admin.service.ts`

- 对应冻结事实：
  - truth freeze `5`
  - contract freeze `6`
  - contract freeze `7`
  - contract freeze `8`
  - contract freeze `9`
- 本次落实：
  - Admin detail read / review 承接治理 intake
  - `submitted` 先进入 `under_review`
  - `review.action=approved|revision_required|rejected` 与 `apply` 保持两步分离
  - `apply` 前强校验当前状态必须为 `approved` 且未 `applied`

### 2.9 `enterprise-hub-truth.controller.ts` + `enterprise-hub-admin.controller.ts` + `enterprise-hub.module.ts`

- 对应冻结事实：
  - execution prompt `1`
  - execution prompt `2`
  - stage gate 当前阶段目标 `current change carrier` / `Admin governance truth`
- 本次落实：
  - materialize `changes/current` 全 family
  - materialize Admin `change-requests` 全 family
  - module wiring 只落在 Server truth 层，不越级改 BFF / Flutter / Admin

### 2.10 `enterprise-hub-published-change-governance.test.cjs`

- 对应冻结事实：
  - truth freeze `4.3`
  - truth freeze `5`
  - truth freeze `6`
  - contract freeze `5`
  - contract freeze `6`
  - contract freeze `8`
  - contract freeze `9`
- 本次落实：
  - 补齐单 active request、save 不污染 live、`submitted -> under_review -> approved -> applied`、`revision_required` 回同单继续修改、invalid transition 错误码等断言

## 3. current change carrier 实现说明

- carrier 锚定对象仍是单一 `listing-owned change request`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
  - 只回读当前 active carrier
  - 若当前无 active carrier，则回 live snapshot + `currentChangeRequest=null`
  - 不隐式创建数据库记录
- `PUT /changes/current/basic`
- `PUT /changes/current/profiles/company`
- `PUT /changes/current/profiles/factory`
- `PUT /changes/current/profiles/supplier`
- `POST /changes/current/cases`
- `PUT /changes/current/cases/{caseId}`
- `DELETE /changes/current/cases/{caseId}`
  - 以上 save family 只允许写 current editable carrier
  - 当前只有 `draft` 与 `revision_required` 可编辑
  - `submitted / under_review / approved` 不允许继续编辑，也不会新建并行 active request
- `GET /changes/current/status`
  - 若存在 active carrier，则直接回读该条 request 的真实状态
  - 若不存在 active carrier，则返回非持久化 `draft` 状态投影，不会额外建单

## 4. Admin governance truth 实现说明

- `GET /server/admin/exhibition/enterprise-hub/change-requests`
  - 作为统一 review queue 读取面
  - 回读同一条 `listing-owned change request`
- `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
  - 读取 live snapshot + governed draft snapshot + change request state
  - 若当前 request 处于 `submitted`，则在此治理 intake 进入 `under_review`
- `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
  - 只承接 `approved / revision_required / rejected`
  - 若当前仍是 `submitted`，先进入 `under_review` 再执行 review action
  - 非法流转统一返回 `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
- `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
  - 只接受 `approved` 且未 `applied`
  - apply 成功后 request 状态写为 `applied`

## 5. `approve / apply` 分离说明

- `approved` 只表示 review 通过
- `approved` 不会更新 live listing
- `apply` 才调用 live write service，将 approved snapshot 写入 live listing truth
- runtime 已把 `review` 与 `apply` 分成两个独立入口、两个独立状态动作、两个独立断言分支

## 6. live listing apply 边界说明

- save draft 只改 `enterprise_change_request.draft_*`
- submit 只改 request 状态与治理时间戳
- review 只改 request 治理状态与 review 信息
- 只有 apply 才会：
  - 更新 live listing basic truth
  - 更新当前主板块 profile truth
  - 更新 live case truth
  - 更新主联系人公开展示 truth
- 因此 live listing 不会被 current change save 直接污染

## 7. 新增或更新的测试清单

- `apps/server/test/enterprise-hub-published-change-governance.test.cjs`
  - same listing reuses one active change request and save draft does not mutate live listing or live cases
  - status read does not create persisted draft carrier when no active change request exists
  - same listing cannot create parallel active change requests
  - submit under_review approved applied keeps live listing unchanged until apply and then updates live truth
  - revision_required returns to the same changeRequestId and can continue editing
  - invalid transitions return `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
  - published change corridor is unavailable when live listing is not published and visible

## 8. build / test 结果

- build:
  - `cd apps/server && npm run build`
  - 结果：通过
- targeted test:
  - `cd apps/server && node --test test/enterprise-hub-published-change-governance.test.cjs`
  - 结果：7 passed, 0 failed

## 9. 当前剩余未闭合项

- 本轮要求内未发现剩余未闭合项
- 当前未实现项仍限于本 package scope 外内容：
  - Package B Admin surface dispatch
  - Package C BFF aggregation dispatch
  - Package D Flutter consumption dispatch
- 上述三项不属于本回执宣称完成范围

## 10. 是否允许进入 Package B dispatch

- 允许
- 依据：
  - Package A `Server` 已具备 published change corridor 治理真相
  - app-facing 与 Admin-facing 已锚定同一条 `listing-owned change request`
  - `approve` 与 `apply` 已在 runtime 分离
  - live listing 已被 apply-only 边界保护

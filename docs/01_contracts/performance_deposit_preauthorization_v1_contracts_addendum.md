---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L2 contract family for `payment MVP / 履约保证金预授权`, including only the minimum app-facing current-offer, order-create, freeze-init, order-status, and appeal contracts without unlocking backend truth freeze, BFF surface freeze, frontend surface freeze, implementation unlock, integration, or launch.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_contracts_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/performance_deposit_preauthorization_rules_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/01_contracts/payment_billing_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# `payment MVP / 履约保证金预授权` Contracts Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 履约保证金预授权`
  - execution-oriented `L2` contracts freeze
- 本文只冻结：
  - current-offer contract
  - deposit-order create contract
  - freeze-init contract
  - order-status contract
  - appeal contract
- 本文当前不代表：
  - project 主链已接入保证金 execution
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime deposit freeze pass

## B. Current Contract-layer Meaning

- 当前 contract package 只服务于：
  - 预授权冻结候选的最小 app-facing contract family
  - freeze / release / deduction / appeal 结果读回
  - 当前用户侧申诉入口
- 当前 contract package 明确不服务于：
  - membership charging
  - wallet / balance
  - offline manual deposit
  - settlement / clearing
  - invoice / tax
  - finance-admin
  - project 主链硬 gate 改写

## C. Route Family Boundary

- Flutter App canonical path 仍只允许在：
  - `/api/app/*`
- 当前 `履约保证金预授权` execution-oriented route family 冻结为：
  - `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/current-offer`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/freeze-init`
  - `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/appeals`
- 本轮不得创建：
  - bare `/deposit/*`
  - bare `/payment/*`
  - bare `/settlement/*`
  - bare `/invoice/*`
  - 直接挂到 `project publish / bid / contract` 当前主链 gate 的 route family

## D. Current-offer Contract

- `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/current-offer` 至少返回：
  - `depositRequirementStatus`
  - `depositEligibilityStatus`
  - `depositTierCode`
  - `freezeAmount`
  - `currency`
  - `bindingReference`
  - `channelCandidates`
  - `updatedAt`
- `bindingReference` 至少包含：
  - `referenceFamilyKey`
  - `referenceId`
  - `referenceLabel`
  - `phaseHint`
- 当前 contract 只允许把 `bindingReference` 写成：
  - trade-performance candidate binding
- 当前不得偷换成：
  - 项目主链已正式接线 truth
  - 当前 bid / contract gate 已经依赖冻结成功

## E. Deposit-order Create Contract

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders` request 至少包含：
  - `bindingReference`
  - `expectedTierCode`
  - `expectedFreezeAmount`
  - `expectedCurrency`
  - `idempotencyKey`
- response 至少包含：
  - `depositOrderId`
  - `orderStatus`
  - `freezeAmount`
  - `currency`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 contract 明确不允许：
  - 前端本地推导金额真相
  - BFF 本地决定 tier truth

## F. Freeze-init Contract

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/freeze-init` request 至少包含：
  - `payChannel`
  - `clientPlatform`
  - `idempotencyKey`
- `payChannel` 当前只允许写成：
  - `alipay_preauthorization_candidate`
  - `wechat_deposit_pending_verification`
- response 至少包含：
  - `freezeInitStatus`
  - `depositOrderId`
  - `paymentReferenceId`
  - `channelActionType`
  - `channelPayload`
  - `callbackAwaiting`
  - `expiresAt`
  - `updatedAt`
- 当前 contract 继续写死：
  - `wechat_deposit_pending_verification` 只表示 candidate，不表示已放行能力

## G. Order-status Contract

- `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}` 至少返回：
  - `depositOrderId`
  - `orderStatus`
  - `freezeStatus`
  - `releaseStatus`
  - `deductionStatus`
  - `appealStatus`
  - `bindingReference`
  - `amountSummary`
  - `channelSummary`
  - `updatedAt`
- 当前最小状态族冻结为：
  - `created`
  - `pending_freeze`
  - `freezing`
  - `frozen`
  - `release_pending`
  - `released`
  - `deduction_pending`
  - `deducted_partial`
  - `deducted_full`
  - `appeal_pending`
  - `appeal_reviewing`
  - `closed`
  - `failed`
- 当前状态 contract 明确不表示：
  - 项目主链当前已依赖这些状态推进
  - admin 裁定台细节已冻结

## H. Appeal Contract

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/appeals` request 至少包含：
  - `appealReasonCode`
  - `appealStatement`
  - `evidenceRefs`
  - `idempotencyKey`
- 一个 `evidenceRef` 至少包含：
  - `fileAssetId` 或 `evidenceId`
- response 至少包含：
  - `appealRequestId`
  - `appealApplyStatus`
  - `depositOrderId`
  - `updatedAt`
- 当前 contract 不冻结：
  - admin-side adjudication workflow detail
  - final governance console operations

## I. Error-family Freeze

- 当前 contract package 依赖并扩展的最小 error family 只允许包括：
  - `AUTH_*`
  - `DEPOSIT_REQUIREMENT_UNAVAILABLE`
  - `DEPOSIT_ORDER_CREATE_REJECTED`
  - `DEPOSIT_ORDER_NOT_FOUND`
  - `DEPOSIT_FREEZE_INIT_REJECTED`
  - `DEPOSIT_ORDER_RESULT_UNAVAILABLE`
  - `DEPOSIT_APPEAL_APPLY_REJECTED`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- unknown critical error code 不得被 BFF / Flutter 转成伪成功

## J. Truth-owner Contract Rules

- truth owner 继续固定为：
  - `Server.payment_billing`
  - `Server.trade_governance`
- `BFF` 当前只允许：
  - request shaping
  - auth consolidation
  - response shaping
  - controlled failure normalization
- `BFF` 当前不得：
  - 持有第二保证金状态机
  - 本地裁定责任归属
  - 本地补写冻结 / 扣划结果
- Flutter 当前只允许：
  - 调 app-facing canonical path
  - 展示冻结 / 解冻 / 扣划 / 申诉结果
- Flutter 当前不得：
  - 本地判断该不该扣
  - 本地判定冻结已成功即主链已过 gate

## K. Retained No-Go

- 当前继续明确 `No-Go`：
  - generic deposit center
  - wallet / balance / offline transfer
  - settlement / clearing contracts
  - invoice / tax contracts
  - finance-admin contracts
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## L. Formal Conclusion

- 当前正式结论如下：
  - `performance_deposit_preauthorization_v1_contracts_addendum` 已冻结为 `payment MVP / 履约保证金预授权` 的第一份 execution-oriented `L2` contract family
  - 当前 app-facing route family 固定在 `/api/app/profile/credit-and-constraints/deposit-preauthorization/*`
  - 当前 package 只冻结最小 current-offer / order / freeze-init / result / appeal contracts
  - 当前 package 不改写既有 `我的信用与约束` posture contracts，也不授予 implementation unlock

---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 BFF surface for `payment MVP / 履约保证金预授权`, including only bounded app-facing current-offer, order-create, freeze-init, order-status, and appeal shaping without unlocking frontend surface freeze, implementation unlock, integration, release-prep, or launch.
layer: L3 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_bff_surface_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/performance_deposit_preauthorization_v1_contracts_addendum.md
  - docs/02_backend/performance_deposit_preauthorization_v1_backend_truth_addendum.md
  - docs/03_bff/credit_deposit_transaction_guarantee_v1_bff_surface_addendum.md
  - docs/03_bff/payment_billing_v1_bff_surface_addendum.md
---

# `payment MVP / 履约保证金预授权` BFF Surface Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 履约保证金预授权`
  - execution-oriented `docs/03_bff` package
- 本文只冻结：
  - current-offer shaping
  - order-create shaping
  - freeze-init shaping
  - order-status shaping
  - appeal shaping
  - controlled failure shaping
- 本文当前不代表：
  - frontend surface freeze
  - implementation unlock
  - runtime freeze success
  - launch approval

## B. Current BFF-surface Meaning

- 当前 BFF-surface package 只服务于：
  - app-facing canonical path shaping
  - auth consolidation
  - response shaping
  - controlled failure normalization
- `BFF` 当前只允许：
  - forward
  - normalize
  - shape
- `BFF` 当前不得：
  - 持有第二保证金状态机
  - 持有第二扣划真相
  - 本地裁定责任归属
  - 把 provider raw payload 变成 app-facing permanent semantics

## C. Allowed Route Family

- 当前 route family 冻结为：
  - `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/current-offer`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/freeze-init`
  - `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}`
  - `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/appeals`
- 当前 route rules：
  - 必须继续挂在 `/api/app/profile/credit-and-constraints/deposit-preauthorization/*`
  - 不创建 bare `/deposit/*`
  - 不创建 bare `/payment/*`
  - 不创建 bare `/settlement/*`
  - 不接入项目主链当前 gate route family

## D. Current-offer Shaping

- `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/current-offer` 只允许 shape：
  - `depositRequirementStatus`
  - `depositEligibilityStatus`
  - `depositTierCode`
  - `freezeAmount`
  - `currency`
  - `bindingReference`
  - `channelCandidates`
  - `updatedAt`
- 当前 hard rules：
  - `bindingReference` 只保持 trade-performance candidate binding 语义
  - 不得 shape 成项目主链当前已依赖冻结成功

## E. Order-create Shaping

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders` response 只允许 shape：
  - `depositOrderId`
  - `orderStatus`
  - `freezeAmount`
  - `currency`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - `BFF` 不得本地推导金额真相
  - `BFF` 不得本地决定 tier truth
  - `BFF` 不得伪装 create success 来掩盖 backend rejection

## F. Freeze-init Shaping

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/freeze-init` response 只允许 shape：
  - `freezeInitStatus`
  - `depositOrderId`
  - `paymentReferenceId`
  - `channelActionType`
  - `channelPayload`
  - `callbackAwaiting`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - `alipay_preauthorization_candidate` 只保持 candidate 语义
  - `wechat_deposit_pending_verification` 只保持 pending-verification 语义
  - provider 私有协议字段不得被 BFF 伪装成长期平台语义

## G. Order-status Shaping

- `GET /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}` 只允许 shape：
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
- 当前 hard rules：
  - 不得 shape 成项目主链当前已依赖这些状态推进
  - 不得 shape 出完整 admin adjudication 细节

## H. Appeal Shaping

- `POST /api/app/profile/credit-and-constraints/deposit-preauthorization/orders/{depositOrderId}/appeals` response 只允许 shape：
  - `appealRequestId`
  - `appealApplyStatus`
  - `depositOrderId`
  - `updatedAt`
- 当前 hard rules：
  - evidence attachment 只保留引用语义
  - 不得 shape 成完整治理后台操作流

## I. Controlled Error Family

- 当前 controlled error family 冻结为：
  - `AUTH_*`
  - `DEPOSIT_REQUIREMENT_UNAVAILABLE`
  - `DEPOSIT_ORDER_CREATE_REJECTED`
  - `DEPOSIT_ORDER_NOT_FOUND`
  - `DEPOSIT_FREEZE_INIT_REJECTED`
  - `DEPOSIT_ORDER_RESULT_UNAVAILABLE`
  - `DEPOSIT_APPEAL_APPLY_REJECTED`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- `BFF` 只允许：
  - normalize
  - preserve app-facing meaning
  - shape controlled unavailable / rejection output
- `BFF` 不得：
  - hide route drift behind fake success
  - invent freeze-success semantics
  - swallow unknown critical error codes

## J. Retained No-Go

- 当前继续明确 `No-Go`：
  - generic deposit center surface
  - wallet / balance / offline transfer surface
  - settlement / clearing surface
  - invoice / tax surface
  - finance-admin surface
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## K. Formal Conclusion

- 当前正式结论如下：
  - `performance_deposit_preauthorization_v1_bff_surface_addendum` 已冻结为 `payment MVP / 履约保证金预授权` 的第一份 execution-oriented `L3` BFF surface
  - 当前 package 只冻结最小 current-offer / order-create / freeze-init / order-status / appeal shaping
  - 当前 package 不改写既有 `credit_deposit_transaction_guarantee_v1_bff_surface_addendum` 的 bounded posture surface，也不授予 implementation unlock

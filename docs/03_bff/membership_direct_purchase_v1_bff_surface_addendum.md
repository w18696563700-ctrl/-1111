---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 BFF surface for `payment MVP / 会员直购`, including only bounded app-facing purchase-offer, order-create, pay-init, order-result, and refund shaping without unlocking frontend surface freeze, implementation unlock, integration, release-prep, or launch.
layer: L3 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_bff_surface_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/02_backend/membership_direct_purchase_v1_backend_truth_addendum.md
  - docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md
---

# `payment MVP / 会员直购` BFF Surface Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 会员直购`
  - execution-oriented `docs/03_bff` package
- 本文只冻结：
  - purchase-offer shaping
  - order-create shaping
  - pay-init shaping
  - order-result shaping
  - refund shaping
  - controlled failure shaping
- 本文当前不代表：
  - frontend surface freeze
  - implementation unlock
  - runtime payment success
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
  - 持有第二 membership-order 状态机
  - 持有第二 payment truth
  - 本地判定 entitlement 已生效
  - 把 provider raw payload 变成 app-facing primary truth

## C. Allowed Route Family

- 当前 route family 冻结为：
  - `GET /api/app/profile/membership/purchase-offers`
  - `POST /api/app/profile/membership/orders`
  - `POST /api/app/profile/membership/orders/{membershipOrderId}/pay-init`
  - `GET /api/app/profile/membership/orders/{membershipOrderId}`
  - `POST /api/app/profile/membership/orders/{membershipOrderId}/refund-apply`
  - `GET /api/app/profile/membership/orders/{membershipOrderId}/refund`
- 当前 route rules：
  - 必须继续挂在 `/api/app/profile/membership/*`
  - 不创建 bare `/payment/*`
  - 不创建 bare `/billing/*`
  - 不创建 bare `/wallet/*`
  - 不接入项目主链当前 gate route family

## D. Purchase-offer Shaping

- `GET /api/app/profile/membership/purchase-offers` 只允许 shape：
  - `offers`
  - `currentOrganizationMembershipContext`
  - `channelCandidates`
  - `commercialDisclosure`
  - `updatedAt`
- 一个 `offer` 只允许 shape：
  - `skuCode`
  - `skuName`
  - `membershipLevel`
  - `durationDays` 或 `durationMonths`
  - `priceAmount`
  - `currency`
  - `entitlementSummary`
  - `isRenewable`
  - `isUpgradable`
  - `status`
- 当前 hard rules：
  - provider-specific 长期营销文案不是 BFF truth
  - channel candidate 不得被改写成永久可用承诺

## E. Order-create Shaping

- `POST /api/app/profile/membership/orders` response 只允许 shape：
  - `membershipOrderId`
  - `orderStatus`
  - `payableAmount`
  - `currency`
  - `entitlementPreview`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - `BFF` 不得自写价格真相
  - `BFF` 不得生成第二 idempotency 语义
  - `BFF` 不得伪装 create success 来掩盖 backend rejection

## F. Pay-init Shaping

- `POST /api/app/profile/membership/orders/{membershipOrderId}/pay-init` response 只允许 shape：
  - `paymentInitStatus`
  - `membershipOrderId`
  - `paymentReferenceId`
  - `channelActionType`
  - `channelPayload`
  - `callbackAwaiting`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - `wechat_candidate / alipay_candidate` 只保持 candidate 语义
  - provider SDK 私有字段不得被 BFF 伪装成平台永久语义

## G. Order-result Shaping

- `GET /api/app/profile/membership/orders/{membershipOrderId}` 只允许 shape：
  - `membershipOrderId`
  - `orderStatus`
  - `paymentStatus`
  - `entitlementStatus`
  - `skuSnapshot`
  - `amountSummary`
  - `channelSummary`
  - `failureReasonCode`
  - `updatedAt`
- 当前 hard rules：
  - `paid` 不得被 shape 成 entitlement 已生效
  - `active` 才能表达 entitlement materialization 完成

## H. Refund Shaping

- `POST /api/app/profile/membership/orders/{membershipOrderId}/refund-apply` response 只允许 shape：
  - `refundApplyStatus`
  - `refundRequestId`
  - `membershipOrderId`
  - `updatedAt`
- `GET /api/app/profile/membership/orders/{membershipOrderId}/refund` 只允许 shape：
  - `refundRequestId`
  - `refundStatus`
  - `refundDecisionSummary`
  - `refundAmount`
  - `updatedAt`
- 当前 hard rules：
  - 不得把 finance-admin 审批台细节塞进 app-facing refund result

## I. Controlled Error Family

- 当前 controlled error family 冻结为：
  - `AUTH_*`
  - `MEMBERSHIP_SKU_UNAVAILABLE`
  - `MEMBERSHIP_ORDER_CREATE_REJECTED`
  - `MEMBERSHIP_ORDER_NOT_FOUND`
  - `MEMBERSHIP_PAY_INIT_REJECTED`
  - `MEMBERSHIP_PAYMENT_RESULT_UNAVAILABLE`
  - `MEMBERSHIP_REFUND_APPLY_REJECTED`
  - `MEMBERSHIP_REFUND_RESULT_UNAVAILABLE`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- `BFF` 只允许：
  - normalize
  - preserve app-facing meaning
  - shape controlled unavailable / rejection output
- `BFF` 不得：
  - hide route drift behind fake success
  - invent payment-success semantics
  - swallow unknown critical error codes

## J. Retained No-Go

- 当前继续明确 `No-Go`：
  - wallet / balance / recharge / withdrawal surface
  - invoice / tax full surface
  - settlement / clearing surface
  - finance-admin surface
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## K. Formal Conclusion

- 当前正式结论如下：
  - `membership_direct_purchase_v1_bff_surface_addendum` 已冻结为 `payment MVP / 会员直购` 的第一份 execution-oriented `L3` BFF surface
  - 当前 package 只冻结最小 purchase-offer / order-create / pay-init / order-result / refund shaping
  - 当前 package 不改写既有 `membership_entitlement_v1_bff_surface_addendum` 的 bounded read surface，也不授予 implementation unlock

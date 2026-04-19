---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L2 contract family for `payment MVP / 会员直购`, including only the minimum app-facing purchase-offer, order-create, pay-init, order-result, and refund-result contracts without unlocking backend truth freeze, BFF surface freeze, frontend surface freeze, implementation unlock, integration, or launch.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_contracts_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# `payment MVP / 会员直购` Contracts Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 会员直购`
  - execution-oriented `L2` contracts freeze
- 本文只冻结：
  - purchase-offer contract
  - order-create contract
  - pay-init contract
  - order-result contract
  - refund-apply / refund-result contract
- 本文当前不代表：
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime payment pass
  - launch approval

## B. Current Contract-layer Meaning

- 当前 contract package 只服务于：
  - 会员直购最小支付闭环
  - payment success -> entitlement result readback
  - refund apply / refund result readback
- 当前 contract package 明确不服务于：
  - wallet
  - balance
  - stored value
  - membership 与 deposit 混付
  - invoice / tax full system
  - split settlement / clearing
  - finance-admin

## C. Route Family Boundary

- Flutter App canonical path 仍只允许在：
  - `/api/app/*`
- 当前 `会员直购` execution-oriented route family 冻结为：
  - `GET /api/app/profile/membership/purchase-offers`
  - `POST /api/app/profile/membership/orders`
  - `POST /api/app/profile/membership/orders/{membershipOrderId}/pay-init`
  - `GET /api/app/profile/membership/orders/{membershipOrderId}`
  - `POST /api/app/profile/membership/orders/{membershipOrderId}/refund-apply`
  - `GET /api/app/profile/membership/orders/{membershipOrderId}/refund`
- 本轮不得创建：
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/wallet/*`
  - bare `/settlement/*`
  - `project` mainline payment route family

## D. Purchase-offer Contract

- `GET /api/app/profile/membership/purchase-offers` 至少返回：
  - `offers`
  - `currentOrganizationMembershipContext`
  - `channelCandidates`
  - `commercialDisclosure`
  - `updatedAt`
- 一个 `offer` 至少包含：
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
- 当前 contract 明确不冻结：
  - final provider-specific marketing copy
  - long-term channel availability promise
  - finance-admin price override flow

## E. Order-create Contract

- `POST /api/app/profile/membership/orders` request 至少包含：
  - `skuCode`
  - `purchaseIntentType`
  - `expectedAmount`
  - `expectedCurrency`
  - `idempotencyKey`
- `purchaseIntentType` 当前只允许：
  - `new_purchase`
  - `renewal`
  - `upgrade_candidate`
- response 至少包含：
  - `membershipOrderId`
  - `orderStatus`
  - `payableAmount`
  - `currency`
  - `entitlementPreview`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 contract 明确不允许：
  - 前端自写价格真相
  - 由 BFF 生成第二订单状态机

## F. Pay-init Contract

- `POST /api/app/profile/membership/orders/{membershipOrderId}/pay-init` request 至少包含：
  - `payChannel`
  - `clientPlatform`
  - `idempotencyKey`
- `payChannel` 当前只允许写成：
  - `wechat_candidate`
  - `alipay_candidate`
- response 至少包含：
  - `paymentInitStatus`
  - `membershipOrderId`
  - `paymentReferenceId`
  - `channelActionType`
  - `channelPayload`
  - `callbackAwaiting`
  - `expiresAt`
  - `updatedAt`
- 当前 contract 只冻结 app-facing generic envelope，不冻结：
  - provider SDK private fields truth
  - provider signature algorithm detail
  - provider settlement detail

## G. Order-result Contract

- `GET /api/app/profile/membership/orders/{membershipOrderId}` 至少返回：
  - `membershipOrderId`
  - `orderStatus`
  - `paymentStatus`
  - `entitlementStatus`
  - `skuSnapshot`
  - `amountSummary`
  - `channelSummary`
  - `failureReasonCode`
  - `updatedAt`
- 当前最小状态族冻结为：
  - `created`
  - `pending_pay`
  - `paying`
  - `paid`
  - `granting`
  - `active`
  - `closed`
  - `failed`
  - `refunded`
  - `refund_partially_processed`
  - `refund_completed`
- 当前状态语义必须继续写死：
  - `paid` 不等于 entitlement 已生效
  - `active` 才表示 entitlement 写入完成

## H. Refund Contracts

- `POST /api/app/profile/membership/orders/{membershipOrderId}/refund-apply` request 至少包含：
  - `refundReasonCode`
  - `refundStatement`
  - `idempotencyKey`
- response 至少包含：
  - `refundApplyStatus`
  - `refundRequestId`
  - `membershipOrderId`
  - `updatedAt`
- `GET /api/app/profile/membership/orders/{membershipOrderId}/refund` 至少返回：
  - `refundRequestId`
  - `refundStatus`
  - `refundDecisionSummary`
  - `refundAmount`
  - `updatedAt`
- 当前 refund contract 不冻结：
  - 人工财务审核台
  - bank-side settlement detail
  - tax / invoice result

## I. Error-family Freeze

- 当前 contract package 依赖并扩展的最小 error family 只允许包括：
  - `AUTH_*`
  - `MEMBERSHIP_SKU_UNAVAILABLE`
  - `MEMBERSHIP_ORDER_CREATE_REJECTED`
  - `MEMBERSHIP_ORDER_NOT_FOUND`
  - `MEMBERSHIP_PAY_INIT_REJECTED`
  - `MEMBERSHIP_PAYMENT_RESULT_UNAVAILABLE`
  - `MEMBERSHIP_REFUND_APPLY_REJECTED`
  - `MEMBERSHIP_REFUND_RESULT_UNAVAILABLE`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- unknown critical error code 不得被 BFF / Flutter 吞掉后伪装成 success

## J. Truth-owner Contract Rules

- truth owner 继续固定为：
  - `Server.membership`
  - `Server.payment`
- `BFF` 当前只允许：
  - request shaping
  - auth consolidation
  - response shaping
  - controlled failure normalization
- `BFF` 当前不得：
  - 定义第二 membership-order 状态机
  - 本地判定 entitlement 是否已生效
- Flutter 当前只允许：
  - 调 app-facing canonical path
  - 展示 purchase / payment / entitlement / refund 结果
- Flutter 当前不得：
  - 直接信任支付弹窗为最终真相
  - 本地补写 entitlement 状态

## K. Retained No-Go

- 当前继续明确 `No-Go`：
  - wallet / balance / recharge / withdrawal
  - invoice / tax full contracts
  - settlement / clearing contracts
  - finance-admin contracts
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## L. Formal Conclusion

- 当前正式结论如下：
  - `membership_direct_purchase_v1_contracts_addendum` 已冻结为 `payment MVP / 会员直购` 的第一份 execution-oriented `L2` contract family
  - 当前 app-facing route family 固定在 `/api/app/profile/membership/*`
  - 当前 package 只冻结最小 purchase / order / pay-init / result / refund contracts
  - 当前 package 不改写既有 `我的会员` bounded read contracts，也不授予 implementation unlock

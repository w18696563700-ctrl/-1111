---

## Pricing Mainline Override Note

本文件继续保留 `payment MVP / 会员直购` 的独立保留位意义。

但自 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 生效后，本文件不得再被误读为当前展览收费执行主线的 Flutter authority。

当前正式解释固定如下：

1. 会员直购不是当前展览收费最小闭环的一部分
2. 本文件不是当前 `200 / 4000 / deal confirmation` 收费主线 owner
3. 当前会员相关收费仍属于保留但暂不开通 package
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 frontend surface for `payment MVP / 会员直购`, including only bounded purchase-offer, order-create, pay-init, order-result, refund, and controlled-failure consumption under `我的会员`, without unlocking implementation, integration, release-prep, or launch.
layer: L3 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_frontend_surface_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/03_bff/membership_direct_purchase_v1_bff_surface_addendum.md
  - docs/02_backend/membership_direct_purchase_v1_backend_truth_addendum.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md
---

# `payment MVP / 会员直购` Frontend Surface Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 会员直购`
  - execution-oriented `docs/04_frontend` package
- 本文只冻结：
  - purchase-offer consume surface
  - order-create consume surface
  - pay-init consume surface
  - order-result consume surface
  - refund consume surface
  - controlled-failure / fail-closed surface
- 本文当前不代表：
  - implementation unlock
  - runtime payment success
  - launch approval

## B. Current Frontend-surface Meaning

- 当前 frontend-surface package 只服务于：
  - bounded consume
  - bounded page-state
  - controlled failure
  - non-magical retry / handoff
- Flutter 当前只允许：
  - consume canonical app-facing path
  - display bounded order and entitlement result
  - display bounded refund result
- Flutter 当前不得：
  - 本地判定支付成功即权益已生效
  - 本地补写价格真相
  - 本地缓存长期 payment truth
  - 自动切组织掩盖 channel / truth 偏差

## C. Entry And Page-family Rule

- 当前 execution-oriented membership surface 只允许继续挂在：
  - `我的楼 / 我的会员`
- 当前允许的最小 page family 只限：
  - 购买方案页
  - 订单确认页
  - 支付发起承接页
  - 订单结果页
  - 退款申请 / 退款结果页
- 当前 hard rules：
  - 不得挤掉 `我的项目 / 我的论坛 / 设置`
  - 不得把 `我的楼` 变成 member operating console
  - 不得把 `我的会员` 变成 full payment center

## D. Purchase-offer Consume Surface

- purchase-offer 页只允许展示：
  - `offers`
  - `currentOrganizationMembershipContext`
  - `channelCandidates`
  - `commercialDisclosure`
  - `updatedAt`
- 一个 `offer` 只允许展示：
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
  - candidate commercial copy 不是最终购买承诺
  - channel candidate 不是长期可用承诺

## E. Order-create / Confirm Surface

- 订单确认页只允许消费和展示：
  - `membershipOrderId`
  - `orderStatus`
  - `payableAmount`
  - `currency`
  - `entitlementPreview`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - 不得允许手填 debug id 走主路径
  - 不得本地合成“已创建成功”来掩盖 backend rejection

## F. Pay-init Surface

- 支付发起承接页只允许消费和展示：
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
  - provider private payload 只作为通道承接所需数据，不是前端真相根

## G. Order-result Surface

- 订单结果页只允许消费和展示：
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
  - `paid` 不得显示成最终权益已生效
  - `active` 才允许显示为权益写入完成
  - unknown critical fields / states 必须 fail-closed

## H. Refund Surface

- 退款申请 / 结果页只允许消费和展示：
  - `refundApplyStatus`
  - `refundRequestId`
  - `membershipOrderId`
  - `refundStatus`
  - `refundDecisionSummary`
  - `refundAmount`
  - `updatedAt`
- 当前 hard rules：
  - 不得展示 finance-admin 台的内部审批细节
  - 不得伪造“退款已完成”掩盖 unavailable

## I. Controlled Failure / Fail-closed Rule

- 当前 frontend 必须支持：
  - `MEMBERSHIP_SKU_UNAVAILABLE`
  - `MEMBERSHIP_ORDER_CREATE_REJECTED`
  - `MEMBERSHIP_ORDER_NOT_FOUND`
  - `MEMBERSHIP_PAY_INIT_REJECTED`
  - `MEMBERSHIP_PAYMENT_RESULT_UNAVAILABLE`
  - `MEMBERSHIP_REFUND_APPLY_REJECTED`
  - `MEMBERSHIP_REFUND_RESULT_UNAVAILABLE`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
  - `AUTH_*`
- 当前 hard rules：
  - 不得 hide route drift behind fake success
  - 不得 rewrite unavailable into fake empty state
  - 不得自动续跳到项目主链

## J. Retained No-Go

- 当前继续明确 `No-Go`：
  - wallet / balance / recharge / withdrawal UI
  - invoice / tax full UI
  - settlement / clearing UI
  - finance-admin UI
  - implementation unlock
  - runtime implementation

## K. Formal Conclusion

- 当前正式结论如下：
  - `membership_direct_purchase_v1_frontend_surface_addendum` 已冻结为 `payment MVP / 会员直购` 的第一份 execution-oriented `L3` frontend surface
  - 当前 package 只冻结最小 purchase-offer / order-create / pay-init / order-result / refund consume surface
  - 当前 package 不改写既有 `membership_entitlement_v1_frontend_surface_addendum` 的 bounded read surface，也不授予 implementation unlock

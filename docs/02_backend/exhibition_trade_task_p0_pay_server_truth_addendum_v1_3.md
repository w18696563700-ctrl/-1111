---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 Server truth ownership for `exhibition_trade_task_p0_pay`,
  covering Server-owned aggregate roots, canonical business truth, permission
  truth, payment-channel truth, callback truth, derived-vs-canonical split, and
  retained No-Go boundaries before persistence/state/audit freeze and before any
  backend, BFF, Flutter, integration, or release implementation.
layer: L3 Backend
freeze_date_local: 2026-04-27
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/00_ssot/exhibition_trade_task_p0_pay_l2_contract_review_freeze_addendum_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/02_backend/payment_billing_v1_backend_truth_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/audit_log_spec.md
  - docs/02_backend/db_schema.md
---

# 展览平台任务发布与交易收费规则 P0-Pay Server Truth Addendum V1.3

## 1. Scope

本文件只冻结 `exhibition_trade_task_p0_pay` 的 `L3 Server truth`。

本文件覆盖：

1. Server 唯一 truth owner。
2. P0-Pay 聚合根。
3. 明价竞标单平台服务费预授权业务真相。
4. 询价报价单发单诚意金业务真相。
5. 合同确认后平台服务费正式扣取业务真相。
6. 支付订单、支付通道交易、支付回调、状态推进的真相归属。
7. 项目真实性材料与声明的 Server 真相。
8. 消息楼只读资金状态派生边界。

本文件不覆盖：

1. migration 文件。
2. table column 最终实现细节。
3. BFF surface freeze。
4. Flutter consumption freeze。
5. `apps/server/**` 实现。
6. 支付通道 SDK 细节。
7. 履约保证金。
8. 钱包、余额、金币、资金池。
9. 清分结算、发票、财务后台。

## 2. Backend Truth Conclusion

当前正式冻结：

- `Server` 是 P0-Pay 唯一业务真相 owner。
- `Server` 是 P0-Pay 唯一资金状态 owner。
- `Server` 是 P0-Pay 唯一支付回调 owner。
- `Server` 是 P0-Pay 唯一审计 owner。

以下对象不是 truth owner：

1. Flutter。
2. BFF。
3. Admin。
4. 消息楼。
5. `profile/payment-and-billing-status/*`。
6. `profile/credit-and-constraints/*`。
7. Flutter local cache。
8. BFF read projection。

## 3. Relation To Earlier Truth

旧真相中，`项目交易骨架 P0` 曾排除 payment / billing / deposit / guarantee / credit / membership。

本文件只在以下新对象内有界覆盖：

- `exhibition_trade_task_p0_pay`

覆盖内容仅限：

1. 明价竞标单平台服务费预授权。
2. 询价报价单发单诚意金。
3. 合同确认后平台服务费。
4. 上述三类资金动作的订单、交易、回调、状态、审计真相。

不覆盖：

1. 通用 payment。
2. 通用 billing。
3. 履约保证金。
4. 会员支付。
5. profile 旁路支付状态页。
6. wallet / balance / coins / funds pool。

## 4. Server-owned Aggregate Roots

P0-Pay Server truth 最小聚合根冻结为：

| Aggregate | Server-owned truth | 说明 |
|---|---|---|
| `TradeTask` | 任务类型、发布主体、真实性等级、任务状态 | 明价竞标单 / 询价报价单共同业务锚点 |
| `TradeTaskAuthenticity` | 真实性材料、真实性声明、等级计算 | 只能引用 confirmed `FileAsset` |
| `FixedPriceBid` | 明价竞标报价、方案、报价状态 | 服务费预授权的业务锚点 |
| `PlatformServiceFeeAuthorization` | 服务费预授权金额、规则快照、授权状态 | 中标前只预授权，不真实扣费 |
| `InquiryQuoteTaskDeposit` | 发单诚意金金额、支付、退回、扣除状态 | 200 元固定诚意金 |
| `InquiryQuotation` | 询价报价、席位占用、方案 | P0 默认 5 席 |
| `InquiryResultProcessing` | 选择、关闭、取消说明与处理时限 | 决定诚意金退回 / 扣除候选 |
| `ContractConfirmation` | 最终成交确认金额与双方确认状态 | 平台服务费正式扣取节点 |
| `PlatformServiceFeeCharge` | 合同确认后平台服务费实扣状态 | 按最终成交确认金额计算 |
| `PaymentOrder` | 订单级支付 / 预授权 / 退款 / 释放真相 | 所有资金动作共用订单锚点 |
| `PaymentTransaction` | 支付通道交易真相 | 发起、查询、通道引用 |
| `PaymentCallbackEvent` | 回调接收、验签、幂等处理真相 | Server 唯一回调入口 |
| `P0PayAuditEvent` | 业务与资金状态审计真相 | 可落到统一 `audit_logs` |

## 5. TradeTask Truth

`TradeTask` 最小真相语义：

- `taskId`
- `taskType`
- `publisherOrganizationId`
- `projectName`
- `cityCode`
- `projectType`
- `exhibitionName`
- `area`
- `buildStartAt`
- `dismantleAt`
- `requirementDescription`
- `budgetAmount`
- `budgetRange`
- `quoteDeadlineAt`
- `contactId`
- `authenticityLevel`
- `status`

`taskType`：

- `fixed_price_bid`
- `inquiry_quote`

Server truth rules：

1. 发布资格必须由 Server 根据当前会话、组织、认证和信用约束裁决。
2. 未认证主体不能公开发布明价竞标单。
3. 询价单可进入低可信或平台审核状态，但不得伪装成 T1/T2。
4. BFF 不得本地提升 `authenticityLevel`。
5. Flutter 不得本地改写 `taskStatus`。

## 6. Authenticity Truth

`TradeTaskAuthenticity` 最小真相语义：

- `taskId`
- `materialFileAssetIds`
- `materialTypes`
- `declarationSnapshot`
- `authenticityLevel`
- `ruleVersion`
- `ruleSnapshotHash`
- `confirmedAt`

Server truth rules：

1. 真实性材料只能引用 confirmed `FileAsset`。
2. `objectKey` 不是业务真相。
3. 真实性声明必须保存规则版本和快照。
4. P0-Pay 只做 T0/T1/T2。
5. T3/T4 只保留扩展位，不进入当前实现。

## 7. Fixed-price Bid And Service Fee Authorization Truth

`FixedPriceBid` 最小真相语义：

- `bidId`
- `taskId`
- `factoryOrganizationId`
- `quotedAmount`
- `quoteValidUntil`
- `taxIncluded`
- `transportIncluded`
- `installationIncluded`
- `proposalSnapshot`
- `attachmentFileAssetIds`
- `bidStatus`
- `createdAt`

`PlatformServiceFeeAuthorization` 最小真相语义：

- `authorizationId`
- `taskId`
- `bidId`
- `factoryOrganizationId`
- `quotedAmount`
- `feeRate`
- `estimatedFeeAmount`
- `currency`
- `paymentOrderId`
- `authorizationStatus`
- `ruleVersion`
- `ruleSnapshotHash`
- `agreementTextSnapshot`
- `agreedAt`
- `authorizedAt`
- `releasedAt`
- `chargedAt`
- `refundedAt`

Server truth rules：

1. P0 平台服务费率固定为 3%。
2. 预授权金额按工厂报价计算。
3. 报名时只做预授权，不做真实扣平台服务费。
4. 未中标自动释放预授权。
5. 中标后进入合同确认待扣。
6. 合同确认生效后才可正式扣平台服务费。
7. 发布方毁约或项目条件重大变化，必须释放或退回工厂预授权。
8. 工厂中标后无故拒签，最多按竞标违约规则部分处理，不得默认全额扣服务费预授权。

## 8. Inquiry Deposit And Quotation Truth

`InquiryQuoteTaskDeposit` 最小真相语义：

- `depositId`
- `taskId`
- `publisherOrganizationId`
- `amount`
- `currency`
- `paymentOrderId`
- `depositStatus`
- `paidAt`
- `refundedAt`
- `deductedAt`
- `deductionReason`
- `ruleVersion`
- `ruleSnapshotHash`

Server truth rules：

1. 发单诚意金金额固定为 200 元。
2. 名称必须是“发单诚意金”。
3. 不得在 Server 文案、错误或状态中称为押金、罚款、保证金或平台扣款。
4. 合规处理后退回。
5. 逾期不处理、恶意询价、虚假发布、绕单成立，可扣除并记录信用。
6. 工厂提交询价报价不支付报价费。

`InquiryQuotation` 最小真相语义：

- `quotationId`
- `taskId`
- `factoryOrganizationId`
- `quotedAmount`
- `proposalSnapshot`
- `attachmentFileAssetIds`
- `quotationStatus`
- `seatNo`
- `createdAt`

Seat truth rules：

1. P0 默认 `seatLimit = 5`。
2. `seatUsed >= 5` 后关闭报价入口。
3. 席位占用由 Server 事务裁决。
4. BFF / Flutter 不得本地发号或抢占席位。

## 9. Inquiry Result Processing Truth

`InquiryResultProcessing` 最小真相语义：

- `processingId`
- `taskId`
- `processingAction`
- `selectedQuotationId`
- `reasonCode`
- `reasonText`
- `processedBy`
- `processedAt`
- `depositOutcome`
- `creditImpactCandidate`

Server truth rules：

1. 报价截止后 48 小时内必须处理。
2. 超过 48 小时提醒。
3. 超过 72 小时标记异常。
4. 超过 7 天未处理，可扣发单诚意金并记录信用。
5. 发布方选择、关闭说明、取消说明均必须由 Server 留痕。

## 10. Contract Confirmation And Final Service Fee Truth

`ContractConfirmation` 最小真相语义：

- `contractConfirmationId`
- `taskId`
- `selectedBidId`
- `selectedQuotationId`
- `publisherOrganizationId`
- `factoryOrganizationId`
- `finalConfirmedAmount`
- `currency`
- `publisherConfirmedAt`
- `factoryConfirmedAt`
- `contractStatus`
- `contractFileAssetIds`

`PlatformServiceFeeCharge` 最小真相语义：

- `chargeId`
- `taskId`
- `contractConfirmationId`
- `factoryOrganizationId`
- `finalConfirmedAmount`
- `feeRate`
- `finalFeeAmount`
- `paymentOrderId`
- `chargeStatus`
- `chargedAt`
- `refundedAt`

Server truth rules：

1. 最终成交确认金额是平台服务费唯一收费真值。
2. 发布预算、初始报价、口头估价、未确认报价区间都不是收费真值。
3. 合同确认才是正式扣平台服务费节点。
4. 中标不等于立即成交。
5. 合同金额变化时，服务费必须重新计算。

## 11. Payment Order And Channel Truth

`PaymentOrder` 最小真相语义：

- `paymentOrderId`
- `businessType`
- `businessId`
- `payerOrganizationId`
- `amount`
- `currency`
- `channel`
- `merchantOrderId`
- `channelOrderId`
- `status`
- `createdAt`
- `updatedAt`

`businessType`：

- `platform_service_fee_authorization`
- `platform_service_fee_charge`
- `inquiry_deposit_payment`
- `inquiry_deposit_refund`
- `authorization_release`

Server truth rules：

1. 每个资金动作都是订单级动作。
2. 发布方、竞标工厂、中标工厂不需要提前绑定支付宝、微信或银行卡。
3. Server 不保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码、长期自动扣款授权或用户资金账户控制权。
4. 支付通道 raw payload 不是业务主真相。
5. 只有 Server 验签、查询确认或通道 verify success 后才能推进业务状态。
6. 支付通道限制只能作为 channel constraint，不得固化成永久业务真理。

## 12. Callback Truth

`PaymentCallbackEvent` 最小真相语义：

- `callbackEventId`
- `paymentOrderId`
- `channel`
- `merchantOrderId`
- `channelOrderId`
- `eventType`
- `verificationStatus`
- `applyStatus`
- `callbackPayloadHash`
- `receivedAt`
- `verifiedAt`
- `appliedAt`

Server truth rules：

1. 回调只进入 Server。
2. BFF 不接收支付通道回调。
3. Flutter 不接收支付通道回调。
4. 回调必须验签。
5. 回调必须幂等。
6. 重复回调不得重复推进业务状态。
7. 乱序回调必须 fail closed 或 no-op。
8. 回调不得直接改写项目、竞标、合同状态，必须通过 Server P0-Pay 规则映射。

## 13. Permission Truth

Server 必须裁决以下权限：

1. 当前 session 有效。
2. 当前 organization 有效。
3. 发布方是否可发布。
4. 发布方是否已认证。
5. 工厂是否可竞标 / 报价。
6. 当前用户是否属于任务发布方组织。
7. 当前用户是否属于竞标 / 报价工厂组织。
8. 当前 bid / quotation 是否属于 task。
9. 当前 contract confirmation 是否属于当前双方。
10. 当前 payment order 是否属于当前业务锚点。

权限失败必须 fail closed。

## 14. Derived vs Canonical Split

Canonical truth：

1. `TradeTask`。
2. `TradeTaskAuthenticity`。
3. `FixedPriceBid`。
4. `PlatformServiceFeeAuthorization`。
5. `InquiryQuoteTaskDeposit`。
6. `InquiryQuotation`。
7. `InquiryResultProcessing`。
8. `ContractConfirmation`。
9. `PlatformServiceFeeCharge`。
10. `PaymentOrder`。
11. `PaymentTransaction`。
12. `PaymentCallbackEvent`。
13. `audit_logs`。

Derived projection：

1. BFF `p0PaySummary`。
2. Flutter local state。
3. 消息楼资金状态展示。
4. 项目详情资金状态摘要。
5. `routeTarget`。
6. UI wording / status text。

Derived projection 不得：

1. 反向覆盖 Server canonical truth。
2. 产生资金状态。
3. 修改资金状态。
4. 裁定扣费。
5. 裁定争议。

## 15. Retained No-Go

Server truth 当前不打开：

1. 履约保证金。
2. 履约保证金冻结 / 释放 / 扣除。
3. 钱包。
4. 余额。
5. 金币。
6. 资金池。
7. 用户支付账户绑定。
8. 通用支付中心。
9. 通用账单中心。
10. 清分结算。
11. 发票 / 税务。
12. 财务后台。
13. AI 自动判责。
14. 平台自动扣保证金。
15. 律师团队资金控制。
16. 消息楼支付执行。

## 16. Stage Conclusion

当前阶段结论：

- `Go for L3 persistence / state machine / audit freeze authoring`。
- `No-Go for Server implementation`。
- `No-Go for BFF implementation`。
- `No-Go for Flutter implementation`。
- `No-Go for Computer Use integration`。
- `No-Go for release-prep`。
- `No-Go for production release`。

## 17. Formal Conclusion

P0-Pay Server truth 正式冻结为：

```text
Server owns all P0-Pay business truth, payment truth, callback truth, permission truth, and audit truth.
BFF, Flutter, message-building, profile payment status, and local cache are derived consumers only.
```

---
owner: Codex 总控
status: superseded
purpose: >
  Historical P0-Pay L2 contract package retained for audit and migration
  comparison only. This file no longer serves as the current platform pricing
  contracts owner after platform_pricing_contracts_master_v1.
layer: L2 Contracts
author_date_local: 2026-04-25
freeze_date_local: 2026-04-26
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# 展览平台任务发布与交易收费规则 P0-Pay Contracts Addendum V1.3

## Supersede Note

自 `2026-04-29` 起，本文件不再作为当前收费 L2 contracts 主文件使用。

当前唯一收费 L2 contracts 改为：

- [platform_pricing_contracts_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md)

本文件仅保留为历史 `P0-Pay` contracts 记录，用于：

1. 审计回溯
2. 差异对比
3. 下游 backend / BFF / Flutter 重写时的迁移参考

以下旧结论不再作为当前收费 contracts 真相继续指挥：

1. `trade-tasks` 作为当前唯一收费主路径
2. `询价报价单 200 元发单诚意金` 作为当前唯一 `200 元` 收费对象
3. `动态 estimatedFeeAmount + 固定 3%` 作为当前唯一服务费模型

## 1. Scope

本文件只冻结 `exhibition_trade_task_p0_pay` 的 `L2 app-facing contracts`。

本文件覆盖：

1. 明价竞标单发布 / 详情 / 竞标报名。
2. 明价竞标单平台服务费预授权。
3. 明价竞标单中标后合同确认与平台服务费正式扣取 handoff。
4. 询价报价单发布。
5. 询价报价单 200 元发单诚意金支付、状态、退回 / 扣除结果读回。
6. 询价报价单 5 个报价席位与结果处理。
7. 项目真实性材料与真实性声明。
8. 消息楼资金状态只读展示 handoff。
9. 支付通道订单级支付、预授权、退款、释放的 app-facing envelope。

本文件不覆盖：

1. `apps/**` 实现。
2. Server persistence / migration。
3. BFF implementation。
4. Flutter implementation。
5. 履约保证金冻结、释放、扣除、争议协商。
6. 平台钱包、余额、金币、资金池。
7. 支付账户绑定模块。
8. 清分结算、发票、财务后台。
9. 泛私信、群聊、全局未读治理。

## 2. Contract-layer Meaning

当前 contract family 的正式含义是：

- P0-Pay 交易任务最小 app-facing route family。
- Server-owned 支付订单 / 预授权 / 退款 / 释放状态的只读回显。
- Flutter 只通过 BFF 调用 `/api/app/*`。
- BFF 只做认证汇聚、请求整形、响应整形、可见性裁剪和轻幂等。
- Server 是业务状态、资金状态、回调状态、审计状态唯一真相。

当前 contract family 不得被解释成：

- 通用支付中心。
- 通用账单中心。
- 钱包 / 余额 / 金币能力。
- 履约保证金主线。
- 争议裁判台。
- 消息楼支付执行台。

## 3. Canonical App-facing Path Family

Flutter App canonical path 仍只允许在：

- `/api/app/*`

P0-Pay 当前唯一批准的新 app-facing path family 为：

| Path | Method | 定位 |
|---|---|---|
| `/api/app/exhibition/trade-tasks` | `POST` | 发布明价竞标单或询价报价单 |
| `/api/app/exhibition/trade-tasks/{taskId}` | `GET` | 交易任务详情与 P0-Pay 只读摘要 |
| `/api/app/exhibition/trade-tasks/{taskId}/authenticity-materials` | `POST` | 绑定已确认 FileAsset 为真实性材料 |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids` | `POST` | 明价竞标单提交报价与方案，进入待预授权 |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations` | `POST` | 创建平台服务费预授权订单 |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init` | `POST` | 拉起支付通道预授权 |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}` | `GET` | 读取平台服务费预授权结果 |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders` | `POST` | 创建 200 元发单诚意金支付订单 |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init` | `POST` | 拉起支付通道支付 |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}` | `GET` | 读取发单诚意金状态 |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-quotations` | `POST` | 询价报价单提交报价和方案 |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-result` | `POST` | 发布方选择、合规关闭或取消说明 |
| `/api/app/exhibition/trade-tasks/{taskId}/contract-confirmations` | `POST` | 中标后合同确认与最终成交金额确认 |
| `/api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary` | `GET` | P0-Pay 聚合只读状态 |

既有 route family 的关系：

- `POST /api/app/bid/submit` 继续保留为既有竞标提交命令，不被本文件删除。
- 本文件冻结的 `fixed-price-bids` 是 P0-Pay 明价竞标单的支付主线承接 route family。
- 进入实现前，L3/L4 必须评估是否复用既有 `bid/submit` 内部 carrier，或以 adapter 方式接入本 route family。
- 无论采用哪种实现，app-facing 语义必须保持本文件冻结的 P0-Pay 状态和错误边界。

当前不得创建：

1. bare `/api/app/payment/*`。
2. bare `/api/app/wallet/*`。
3. bare `/api/app/balance/*`。
4. bare `/api/app/settlement/*`。
5. bare `/api/app/invoice/*`。
6. bare `/api/app/guarantee-deposit/*`。
7. Flutter 直连 Server path。

## 4. TradeTask Create Contract

`POST /api/app/exhibition/trade-tasks`

Request 最小字段：

- `taskType`
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
- `authenticityMaterialFileAssetIds`
- `authenticityDeclarations`
- `idempotencyKey`

`taskType` enum：

- `fixed_price_bid`
- `inquiry_quote`

`authenticityDeclarations` 必须至少包含：

- `demandExistsConfirmed`
- `authorizationConfirmed`
- `noQuoteHarvestingConfirmed`
- `resultProcessingConfirmed`
- `creditImpactAcknowledged`

Response 最小字段：

- `taskId`
- `taskType`
- `taskStatus`
- `authenticityLevel`
- `publishGateStatus`
- `paymentRequirement`
- `nextAction`
- `updatedAt`

`paymentRequirement` 最小字段：

- `required`
- `requirementType`
- `amount`
- `currency`
- `reasonCode`

`requirementType` enum：

- `none`
- `inquiry_deposit_payment_required`
- `platform_service_fee_authorization_required`

Contract rules：

1. 明价竞标单发布本身不要求发布方缴费。
2. 询价报价单公开发布前必须完成 200 元发单诚意金。
3. 未认证主体只能保存草稿或进入低可信 / 审核状态。
4. `objectKey` 不得作为真实性材料真相。
5. 真实性材料必须引用 confirmed `FileAsset`。

## 5. TradeTask Detail Contract

`GET /api/app/exhibition/trade-tasks/{taskId}`

Response 最小字段：

- `taskId`
- `taskType`
- `publisherOrganization`
- `projectSummary`
- `authenticitySummary`
- `quoteSeatSummary`
- `p0PaySummary`
- `resultProcessingSummary`
- `messageHandoff`
- `contractHandoff`
- `updatedAt`

`p0PaySummary` 最小字段：

- `platformServiceFeeStatus`
- `platformServiceFeeEstimatedAmount`
- `platformServiceFeeFinalAmount`
- `inquiryDepositStatus`
- `inquiryDepositAmount`
- `paymentChannelSummary`
- `readOnly`

Contract rules：

1. `p0PaySummary.readOnly` 必须为 true。
2. 详情页不得通过本 response 触发支付执行。
3. 资金状态只来自 Server/BFF 聚合后的只读状态。

## 6. Authenticity Material Contract

`POST /api/app/exhibition/trade-tasks/{taskId}/authenticity-materials`

Request 最小字段：

- `fileAssetIds`
- `materialType`
- `idempotencyKey`

`materialType` enum：

- `rendering`
- `construction_drawing`
- `floor_plan`
- `booth_plan`
- `customer_requirement_screenshot`
- `customer_authorization_note`
- `tender_document`
- `venue_information`
- `organizer_information`
- `historical_project_photo`
- `other`

Response 最小字段：

- `taskId`
- `authenticityLevel`
- `materialCount`
- `updatedAt`

Contract rules：

1. 只接受 confirmed `FileAsset`。
2. 上传流程仍是 `init -> direct upload -> confirm`。
3. 本 path 只绑定业务材料，不生成 upload truth。

## 7. Fixed-price Bid Submit Contract

`POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`

Request 最小字段：

- `quoteAmount`
- `quoteValidUntil`
- `taxIncluded`
- `transportIncluded`
- `installationIncluded`
- `constructionPlan`
- `materialDescription`
- `craftDescription`
- `buildProcess`
- `deliveryMilestones`
- `riskNotes`
- `attachmentFileAssetIds`
- `platformServiceFeeRuleAgreement`
- `idempotencyKey`

`platformServiceFeeRuleAgreement` 最小字段：

- `ruleVersion`
- `ruleSnapshotHash`
- `agreedAtClient`
- `readConfirmed`
- `authorizationAwarenessConfirmed`
- `publisherBreachReleaseAwarenessConfirmed`

Response 最小字段：

- `bidId`
- `bidStatus`
- `platformServiceFeeRequirement`
- `nextAction`
- `updatedAt`

`platformServiceFeeRequirement` 最小字段：

- `feeRate`
- `quotedAmount`
- `estimatedFeeAmount`
- `currency`
- `authorizationRequired`
- `authorizationStatus`

Contract rules：

1. 提交报价后，未完成平台服务费预授权前不得进入正式报名成功态。
2. 平台服务费预授权不等于平台已收款。
3. 未中标必须自动释放预授权。
4. 中标后进入合同确认待扣。

## 8. Platform Service Fee Authorization Contracts

### 8.1 Create Authorization Order

`POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`

Request 最小字段：

- `expectedQuotedAmount`
- `expectedFeeRate`
- `expectedAuthorizationAmount`
- `currency`
- `idempotencyKey`

Response 最小字段：

- `authorizationId`
- `authorizationStatus`
- `estimatedFeeAmount`
- `currency`
- `channelCandidates`
- `expiresAt`
- `updatedAt`

### 8.2 Authorize-init

`POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`

Request 最小字段：

- `payChannel`
- `clientPlatform`
- `idempotencyKey`

`payChannel` enum：

- `alipay_candidate`
- `wechat_candidate`
- `other_candidate`

Response 最小字段：

- `authorizationInitStatus`
- `authorizationId`
- `paymentReferenceId`
- `channelActionType`
- `channelPayload`
- `callbackAwaiting`
- `expiresAt`
- `updatedAt`

`channelActionType` enum：

- `sdk_payload`
- `web_redirect`
- `qr_code`
- `unavailable`

### 8.3 Authorization Status

`GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`

Response 最小字段：

- `authorizationId`
- `authorizationStatus`
- `quotedAmount`
- `feeRate`
- `estimatedFeeAmount`
- `currency`
- `channelSummary`
- `failureReasonCode`
- `updatedAt`

`authorizationStatus` enum：

- `pending_authorization`
- `authorized`
- `authorization_released`
- `pending_contract_confirm`
- `charged`
- `refund_pending`
- `refunded`
- `breach_hold`
- `cancelled`
- `failed`

Contract rules：

1. `authorized` 只表示支付通道预授权成功。
2. `charged` 必须发生在合同确认生效之后。
3. 发布预算、口头估价、未确认报价区间不得成为收费真值。
4. 最终收费真值只能来自最终成交确认金额。

## 9. Inquiry Deposit Contracts

### 9.1 Create Deposit Order

`POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders`

Request 最小字段：

- `expectedAmount`
- `expectedCurrency`
- `ruleVersion`
- `ruleSnapshotHash`
- `idempotencyKey`

Contract fixed amount：

- `expectedAmount = 200`
- `expectedCurrency = CNY`

Response 最小字段：

- `depositOrderId`
- `depositStatus`
- `amount`
- `currency`
- `channelCandidates`
- `expiresAt`
- `updatedAt`

### 9.2 Pay-init

`POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init`

Request 最小字段：

- `payChannel`
- `clientPlatform`
- `idempotencyKey`

Response 最小字段：

- `paymentInitStatus`
- `depositOrderId`
- `paymentReferenceId`
- `channelActionType`
- `channelPayload`
- `callbackAwaiting`
- `expiresAt`
- `updatedAt`

### 9.3 Deposit Status

`GET /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}`

Response 最小字段：

- `depositOrderId`
- `depositStatus`
- `amount`
- `currency`
- `refundStatus`
- `deductionStatus`
- `deductionReason`
- `channelSummary`
- `updatedAt`

`depositStatus` enum：

- `pending_payment`
- `paid`
- `refund_pending`
- `refunded`
- `deducted`
- `dispute_hold`
- `cancelled`
- `failed`

Contract rules：

1. 发单诚意金名称不得写成押金、罚款、保证金或平台扣款。
2. 发布方合规处理后应退回。
3. 逾期不处理、恶意询价、虚假发布、绕单成立，可按规则扣除并记录信用。
4. 询价单不得向工厂收询价报价费。

## 10. Inquiry Quotation Contract

`POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-quotations`

Request 最小字段：

- `quotedAmount`
- `quoteValidUntil`
- `taxIncluded`
- `transportIncluded`
- `installationIncluded`
- `proposalSummary`
- `constructionPlan`
- `riskNotes`
- `attachmentFileAssetIds`
- `idempotencyKey`

Response 最小字段：

- `quotationId`
- `quotationStatus`
- `quoteSeatSummary`
- `updatedAt`

`quoteSeatSummary` 最小字段：

- `seatLimit`
- `seatUsed`
- `seatRemaining`
- `quoteEntryOpen`

Contract rules：

1. `seatLimit` P0 固定为 5。
2. 席位满后 `quoteEntryOpen = false`。
3. 工厂提交询价报价不支付平台报价费。

## 11. Inquiry Result Processing Contract

`POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-result`

Request 最小字段：

- `processingAction`
- `selectedQuotationId`
- `reasonCode`
- `reasonText`
- `idempotencyKey`

`processingAction` enum：

- `select_factory`
- `close_without_deal`
- `cancel_project`

Response 最小字段：

- `taskId`
- `processingStatus`
- `inquiryDepositStatus`
- `contractHandoff`
- `creditImpactSummary`
- `updatedAt`

Contract rules：

1. 报价截止后 48 小时内必须处理。
2. 超过 48 小时系统提醒。
3. 超过 72 小时标记异常。
4. 超过 7 天未处理，可扣发单诚意金并记录信用。
5. 合规处理后发单诚意金进入退回流程。

## 12. Contract Confirmation Contract

`POST /api/app/exhibition/trade-tasks/{taskId}/contract-confirmations`

Request 最小字段：

- `selectedBidId`
- `selectedQuotationId`
- `finalConfirmedAmount`
- `currency`
- `contractFileAssetIds`
- `confirmationRole`
- `platformServiceFeeRecalculationAwarenessConfirmed`
- `idempotencyKey`

`confirmationRole` enum：

- `publisher`
- `factory`

Response 最小字段：

- `contractConfirmationId`
- `contractStatus`
- `finalConfirmedAmount`
- `platformServiceFeeFinalAmount`
- `platformServiceFeeStatus`
- `nextAction`
- `updatedAt`

Contract rules：

1. 合同确认才是正式扣平台服务费节点。
2. 中标不等于立即成交。
3. 合同确认金额变化时，服务费按最终确认金额重新计算。
4. 平台服务费率 P0 固定为 3%。

## 13. P0-Pay Summary Contract

`GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

Response 最小字段：

- `taskId`
- `taskType`
- `platformServiceFee`
- `inquiryDeposit`
- `contractConfirmation`
- `messageDisplaySummary`
- `updatedAt`

`messageDisplaySummary` 最小字段：

- `displayAllowed`
- `readOnly`
- `statusTextKey`
- `routeTarget`

Contract rules：

1. `messageDisplaySummary.readOnly` 必须为 true。
2. 消息楼只能展示资金相关只读状态。
3. 消息楼不得产生、修改、裁定资金状态。

## 14. Payment Channel And Account-binding Contract Boundary

P0-Pay app-facing contract 必须写死：

1. 不要求发布方、竞标工厂、中标工厂提前绑定支付宝、微信或银行卡。
2. 每次支付或预授权都是订单级动作。
3. Flutter 获取 `channelPayload` 后跳转支付通道。
4. 支付通道回调只进入 Server。
5. Flutter 只读取状态，不持有回调真相。

Contract 不得包含：

1. 支付宝账号。
2. 微信账号。
3. 银行卡号。
4. 支付密码。
5. 短信验证码。
6. 长期自动扣款授权。
7. 用户资金账户控制权。

## 15. Error-family Freeze

P0-Pay 最小错误族：

- `AUTH_SESSION_INVALID`
- `ORGANIZATION_CERTIFICATION_REQUIRED`
- `TRADE_TASK_CREATE_REJECTED`
- `TRADE_TASK_NOT_FOUND`
- `TRADE_TASK_INVALID_STATE`
- `TRADE_TASK_AUTHENTICITY_MATERIAL_REQUIRED`
- `TRADE_TASK_AUTHENTICITY_DECLARATION_REQUIRED`
- `FIXED_PRICE_BID_CREATE_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_INIT_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE`
- `INQUIRY_DEPOSIT_ORDER_CREATE_REJECTED`
- `INQUIRY_DEPOSIT_PAY_INIT_REJECTED`
- `INQUIRY_DEPOSIT_RESULT_UNAVAILABLE`
- `INQUIRY_QUOTE_SEAT_FULL`
- `INQUIRY_QUOTATION_CREATE_REJECTED`
- `INQUIRY_RESULT_PROCESSING_REJECTED`
- `CONTRACT_CONFIRMATION_REJECTED`
- `P0_PAY_SUMMARY_UNAVAILABLE`
- `PAYMENT_CHANNEL_UNAVAILABLE`
- `PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- `IDEMPOTENCY_KEY_CONFLICT`

Contract rules：

1. unknown critical error 不得被 BFF 或 Flutter 转成伪成功。
2. 金额不一致、币种不一致、规则版本不一致必须 fail closed。
3. 支付通道能力不明确时，必须返回 controlled unavailable。

## 16. Retained No-Go

当前仍为 `No-Go`：

1. backend implementation。
2. BFF implementation。
3. Flutter implementation。
4. production release。
5. 履约保证金。
6. 钱包 / 余额 / 金币 / 资金池。
7. 账户绑定模块。
8. 通用支付中心。
9. 通用账单中心。
10. 清分结算。
11. 发票 / 税务。
12. 财务后台。
13. 消息楼支付执行。
14. 消息楼争议裁判。

## 17. Formal Conclusion

`exhibition_trade_task_p0_pay_contracts_addendum_v1_3` 正式冻结为 P0-Pay 的 `L2 app-facing contract family`。

当前结论：

- `Go for L2 contract review / freeze receipt`。
- `Go for L3 Server truth authoring` after L2 review passes。
- `No-Go for direct implementation`。
- `No-Go for integration`。
- `No-Go for release-prep`。
- `No-Go for production release`。

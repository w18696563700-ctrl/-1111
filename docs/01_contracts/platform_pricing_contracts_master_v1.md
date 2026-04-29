---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the unique L2 app-facing contract family for the current platform
  pricing master, rebaselining the charging flow around existing
  `project publish -> bid participation request -> bid submit` anchors while
  introducing only the minimum pricing-specific route families for
  `200 project authenticity sincerity money`, `4000 bid service-fee
  authorization quota`, deal confirmation, post-deal service-fee charge, and
  read-only pricing summary.
layer: L2 Contracts
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - docs/01_contracts/bid_participation_request_phase1_contracts_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# 《平台收费规则 L2 Contracts 母文件 V1》

## 0. 总结论

当前收费 L2 contracts 正式重写完成。

本轮正式选择：

- 不再沿用旧 `trade-task / inquiry-quote / fixed-price-bid / 3%` 作为当前收费 contracts 主骨架
- 直接挂在现有 `project publish -> bid participation request -> bid submit` 主链上
- 只把收费专属对象拆成最小独立 route family

当前更稳的方案：

- 复用现有 `project`、`bid_participation_request`、`bid/submit` 主锚点，只为收费新增最小 route family

当前更省成本的方案：

- 不重炸 `project create/save/submit/publish` 和 `bid/submit` 的主体 schema；优先通过前置 pricing gate 和 pricing-specific objects 接入

当前阶段最适合的方案：

- 先冻结 `200 元项目真实性诚意金`、`4000 元竞标服务费预授权额度`、`deal confirmation` 和 `pricing summary` 的 app-facing contracts

风险更大的方案：

- 继续沿用旧 `P0-Pay` contracts，同时在局部偷偷改成 `200 / 4000 / 阶梯费率 / 会员折扣`

本文件生效后：

1. [exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md) 不再作为当前收费 contracts 主文件
2. 当前收费 L2 只以本文件为准
3. 下一轮唯一动作变为 `L3 backend truth`

## 1. Scope

本文件只冻结 `当前平台收费规则` 的 `L2 app-facing contracts`。

本文件覆盖：

1. `project publish` 前后的收费 gate
2. `200 元项目真实性诚意金` 的订单、拉起支付、状态读回
3. `bid participation request approved` 之后的 `4000 元竞标服务费预授权额度`
4. `bid/submit` 的收费准入关系
5. `deal confirmation` 的双向确认、金额确认和成交成立语义
6. 成交后平台服务费计算结果与实扣结果读回
7. workbench / detail 可消费的只读 `pricing summary`

本文件不覆盖：

1. `apps/**` 实现
2. L3 persistence / migration
3. BFF implementation
4. Flutter implementation
5. 钱包 / 余额 / 金币 / 资金池
6. 通用支付中心 / 通用账单中心
7. 清分结算 / 发票 / 财务后台
8. 履约保证金
9. 会员直购支付 runtime
10. 线下转账 / 手工对账

## 2. Contract-layer Meaning

当前 contract package 的正式含义是：

1. `project` 仍是发布主锚点
2. `bid_participation_request` 仍是竞标准入锚点
3. `bid/submit` 仍是竞标提交锚点
4. 收费专属对象只承接：
   - `200 元项目真实性诚意金`
   - `4000 元竞标服务费预授权额度`
   - `deal confirmation`
   - `pricing summary`
5. Flutter 只通过 `BFF -> /api/app/*` 调用
6. Server 仍是状态、金额、回调、审计唯一真相

当前 contract package 不得被解释成：

1. 通用支付平台
2. 通用交易资金托管平台
3. 通用账单 / 清分 / 财务中心
4. 会员中心 execution mainline

## 3. Canonical Path Family

### 3.1 保留不重写的既有 canonical family

以下路径仍保留既有 canonical 地位，本轮不重开主体 schema：

1. `POST /api/app/project/create`
2. `POST /api/app/project/save`
3. `POST /api/app/project/submit`
4. `POST /api/app/project/publish`
5. `POST /api/app/project/withdraw`
6. `POST /api/app/project/bid-participation/request`
7. `GET /api/app/project/bid-participation/thread/detail`
8. `GET /api/app/my/projects/{projectId}/bid-participation/pending`
9. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/approve`
10. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/reject`
11. `POST /api/app/bid/submit`

### 3.2 本轮新增的收费专属 family

| Method | Path | 定位 |
|---|---|---|
| `GET` | `/api/app/project/{projectId}/pricing-summary` | 当前项目收费只读摘要 |
| `POST` | `/api/app/project/{projectId}/authenticity-sincerity/orders` | 创建 `200 元项目真实性诚意金` 订单 |
| `POST` | `/api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init` | 拉起 `200 元项目真实性诚意金` 支付 |
| `GET` | `/api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}` | 读取 `200 元项目真实性诚意金` 状态 |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations` | 创建 `4000 元竞标服务费预授权额度` 订单 |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init` | 拉起 `4000 元竞标服务费预授权额度` 冻结 |
| `GET` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}` | 读取 `4000 元竞标服务费预授权额度` 状态 |
| `POST` | `/api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release` | 主动解冻并退出本次竞标 |
| `POST` | `/api/app/project/{projectId}/deal-confirmations` | 创建或推进双向成交确认 |
| `GET` | `/api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}` | 读取成交确认与扣费结果 |

### 3.3 明确禁止新增的 family

当前禁止：

1. bare `/api/app/payment/*`
2. bare `/api/app/wallet/*`
3. bare `/api/app/billing/*`
4. bare `/api/app/settlement/*`
5. bare `/api/app/invoice/*`
6. bare `/api/app/deposit/*`
7. Flutter 直连 Server path

## 4. Pricing Summary Contract

`GET /api/app/project/{projectId}/pricing-summary`

最小 response 固定为：

- `projectId`
- `publisherPricing`
- `bidderPricing`
- `dealSummary`
- `updatedAt`
- `readOnly`

`publisherPricing` 最小字段：

- `authenticitySincerityRequired`
- `authenticitySincerityAmount`
- `authenticitySincerityStatus`
- `publishGateStatus`
- `formalResultProcessingRequired`
- `nextAction`

`bidderPricing` 最小字段：

- `bidParticipationRequestId`
- `authorizationRequired`
- `authorizationQuotaAmount`
- `authorizationStatus`
- `bidSubmissionEligible`
- `nextAction`

`dealSummary` 最小字段：

- `dealConfirmationId`
- `dealStatus`
- `selectedBidId`
- `finalConfirmedAmount`
- `platformServiceFeeAmount`
- `serviceFeeChargeStatus`

Contract rules：

1. `readOnly` 必须恒为 `true`
2. 本 response 只承接状态摘要，不执行支付、不执行冻结、不执行扣费
3. workbench / detail / message handoff 只消费本摘要，不本地计算收费真相

## 5. Project Authenticity Sincerity Order Contracts

### 5.1 Create Order

`POST /api/app/project/{projectId}/authenticity-sincerity/orders`

Request 最小字段：

- `expectedAmount`
- `expectedCurrency`
- `ruleVersion`
- `ruleSnapshotHash`
- `idempotencyKey`

固定规则：

- `expectedAmount = 200`
- `expectedCurrency = CNY`

Response 最小字段：

- `orderId`
- `orderStatus`
- `amount`
- `currency`
- `channelCandidates`
- `expiresAt`
- `updatedAt`

### 5.2 Pay-init

`POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`

Request 最小字段：

- `payChannel`
- `clientPlatform`
- `idempotencyKey`

Response 最小字段：

- `paymentInitStatus`
- `orderId`
- `paymentReferenceId`
- `channelActionType`
- `channelPayload`
- `callbackAwaiting`
- `expiresAt`
- `updatedAt`

### 5.3 Order Status

`GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}`

Response 最小字段：

- `orderId`
- `orderStatus`
- `amount`
- `currency`
- `refundStatus`
- `withholdStatus`
- `withholdReasonCode`
- `channelSummary`
- `updatedAt`

`orderStatus` enum：

- `pending_payment`
- `paid`
- `refund_pending`
- `refunded`
- `withheld`
- `cancelled`
- `failed`

Contract rules：

1. 正式名称必须是 `项目真实性诚意金`
2. 不得写成押金、罚款、履约保证金或平台服务费
3. 项目成交成立或合规正式撤回后，应进入原路退回流程
4. 恶意发布、虚假项目或长期不处理结果时，可进入 `withheld`

## 6. Project Publish Pricing Gate Override

当前 `POST /api/app/project/publish` path 继续保留。

但 pricing 语义新增硬门禁：

1. 若当前项目要求 `200 元项目真实性诚意金`，且状态不是 `paid`，则 `project/publish` 不得进入成功发布态
2. `project/publish` 不得偷偷代替 `authenticity-sincerity/orders` 自动创建收费订单
3. `project/publish` 失败时必须返回受控收费类错误，而不是伪成功

当前正式禁止：

1. 未付 `200` 仍成功 `publish`
2. publish 命令隐式完成代扣
3. publish 成功即视为 `200` 已消耗

## 7. Bid Participation Approval Pricing Override

当前 `bid_participation_request approve/reject` 路径继续保留。

但 `approved` 的收费语义正式改为：

1. `approved` 只表示竞标准入已通过
2. `approved` 不再自动等于“可直接进入 bid submit”
3. 若当前竞标方尚未完成 `4000 元竞标服务费预授权额度` 冻结，则 approved 后首个 CTA 必须指向 `bid-service-fee-authorization`
4. 只有 `authorizationStatus = frozen` 时，竞标方才获得 `bid_submit.open`

`GET /api/app/project/bid-participation/thread/detail` 当前允许的 pricing handoff 最小语义：

- `pricingGateRequired`
- `pricingGateType`
- `detailRouteTarget`

`pricingGateType` enum：

- `none`
- `bid_service_fee_authorization_required`

## 8. Bid Service-fee Authorization Contracts

### 8.1 Create Authorization

`POST /api/app/project/{projectId}/bid-service-fee-authorizations`

Request 最小字段：

- `bidParticipationRequestId`
- `expectedAmount`
- `expectedCurrency`
- `ruleVersion`
- `ruleSnapshotHash`
- `idempotencyKey`

固定规则：

- `expectedAmount = 4000`
- `expectedCurrency = CNY`

Response 最小字段：

- `authorizationId`
- `authorizationStatus`
- `authorizationQuotaAmount`
- `currency`
- `channelCandidates`
- `expiresAt`
- `updatedAt`

### 8.2 Freeze-init

`POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`

Request 最小字段：

- `payChannel`
- `clientPlatform`
- `idempotencyKey`

Response 最小字段：

- `freezeInitStatus`
- `authorizationId`
- `paymentReferenceId`
- `channelActionType`
- `channelPayload`
- `callbackAwaiting`
- `expiresAt`
- `updatedAt`

### 8.3 Authorization Status

`GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`

Response 最小字段：

- `authorizationId`
- `authorizationStatus`
- `authorizationQuotaAmount`
- `currency`
- `chargeStatus`
- `releaseStatus`
- `channelSummary`
- `updatedAt`

`authorizationStatus` enum：

- `pending_freeze`
- `frozen`
- `release_pending`
- `released`
- `charge_pending`
- `charged`
- `breach_hold`
- `cancelled`
- `failed`

### 8.4 Manual Release

`POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release`

Request 最小字段：

- `releaseReasonCode`
- `releaseReasonText`
- `idempotencyKey`

Response 最小字段：

- `authorizationId`
- `authorizationStatus`
- `bidSubmissionEligible`
- `updatedAt`

Contract rules：

1. 正式名称必须是 `竞标服务费预授权额度`
2. 不得写成报名费、竞标费、席位费、履约保证金或平台货款
3. 一个 `projectId + bidderOrganizationId` 同时只允许一个活跃授权对象
4. 主动解冻成功即视为主动放弃本次竞标
5. 解冻成功后当前项目的 `bidSubmissionEligible` 必须为 `false`

## 9. Bid Submit Pricing Gate Rule

`POST /api/app/bid/submit` 的主体字段仍保留既有 canonical shape。

但新增硬门禁：

1. 当前 actor 必须已有 `approved` 的 `bidParticipationRequest`
2. 当前 actor 必须已有同一 `projectId` 下状态为 `frozen` 的 `bidServiceFeeAuthorization`
3. 若缺任一前置条件，`bid/submit` 必须 fail closed

当前正式禁止：

1. 未冻结 `4000` 仍成功提交竞标
2. `bid/submit` 请求体自行传最终收费真相
3. Flutter 本地决定 `4000` 是否已完成冻结

## 10. Deal Confirmation Contracts

### 10.1 Create / Advance Confirmation

`POST /api/app/project/{projectId}/deal-confirmations`

Request 最小字段：

- `selectedBidId`
- `finalConfirmedAmount`
- `currency`
- `contractFileAssetIds`
- `confirmationRole`
- `idempotencyKey`

`confirmationRole` enum：

- `publisher`
- `factory`

Response 最小字段：

- `dealConfirmationId`
- `dealStatus`
- `selectedBidId`
- `finalConfirmedAmount`
- `platformServiceFeeCalculation`
- `serviceFeeChargeStatus`
- `updatedAt`

`platformServiceFeeCalculation` 最小字段：

- `ruleVersion`
- `baseFeeAmount`
- `membershipTierApplied`
- `membershipDiscountRate`
- `capAmount`
- `finalFeeAmount`

### 10.2 Deal Confirmation Detail

`GET /api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}`

Response 最小字段：

- `dealConfirmationId`
- `dealStatus`
- `selectedBidId`
- `publisherConfirmedAt`
- `factoryConfirmedAt`
- `finalConfirmedAmount`
- `platformServiceFeeCalculation`
- `serviceFeeChargeStatus`
- `publisherAuthenticitySincerityStatus`
- `updatedAt`

`dealStatus` enum：

- `pending_counterparty_confirm`
- `confirmed_deal`
- `cancelled`
- `failed`

Contract rules：

1. `confirmed_deal` 是当前唯一正式成交成立状态
2. 平台服务费只允许在 `confirmed_deal` 之后进入 `charge_pending -> charged`
3. `selectedBidId + contractFileAssetIds + finalConfirmedAmount + 双向确认` 缺一不可
4. 平台服务费从已冻结的 `4000 元竞标服务费预授权额度` 中扣取
5. 未扣部分必须进入释放流程

## 11. Error-family Freeze

当前 contract package 依赖并新增的最小错误族只允许包括：

1. `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
2. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED`
3. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND`
4. `PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED`
5. `PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE`
6. `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`
7. `BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED`
8. `BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND`
9. `BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED`
10. `BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED`
11. `BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE`
12. `DEAL_CONFIRMATION_INVALID`
13. `DEAL_CONFIRMATION_INVALID_STATE`
14. `DEAL_CONFIRMATION_COUNTERPARTY_PENDING`
15. `PRICING_RULE_VERSION_MISMATCH`
16. `AUTH_SESSION_INVALID`

unknown critical error code 不得被 BFF / Flutter 转成伪成功。

## 12. 当前最小闭环

本轮 contracts 的当前最小闭环正式写死为：

1. project create/save/submit 保持现状
2. publish 前完成 `200 元项目真实性诚意金`
3. 竞标参与审批通过后，先完成 `4000 元竞标服务费预授权额度`
4. 之后才允许 `bid/submit`
5. 达成唯一合作对象后，走 `deal-confirmations`
6. 双向确认后成交成立，并触发平台服务费扣取

## 13. 需要保留但暂不开通

当前 contracts 必须保留但暂不开通：

1. wallet / balance / coins
2. 通用 payment / billing center
3. settlement / invoice / tax / finance-admin
4. 履约保证金
5. 会员直购支付 runtime
6. 线下转账对账
7. 泛化非展览收费接线

## 14. 后续扩展位

后续扩展位正式保留：

1. 会员折扣更复杂规则
2. 后台人工 adjudication / appeal contracts
3. 多种成交对象扩展
4. 更完整的 billing / receipt / invoice contract family

## 15. Stage Conclusion

当前正式结论：

- `Go` for `L3 backend truth authoring`
- `No-Go` for direct implementation
- `No-Go` for cloud write
- `No-Go` for runtime enablement

当前唯一下一轮动作：

- 按本文件重写 `L3 backend truth`

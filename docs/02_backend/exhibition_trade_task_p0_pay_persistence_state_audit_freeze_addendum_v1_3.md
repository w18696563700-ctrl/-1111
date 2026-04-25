---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 persistence, state-machine, idempotency, callback, transaction,
  and audit boundaries for `exhibition_trade_task_p0_pay`, after Server truth
  ownership has been frozen and before BFF surface freeze, Flutter consumption
  freeze, backend implementation, integration, release-prep, or launch.
layer: L3 Backend
freeze_date_local: 2026-04-28
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/02_backend/audit_log_spec.md
  - docs/02_backend/db_schema.md
---

# 展览平台任务发布与交易收费规则 P0-Pay Persistence / State / Audit Freeze V1.3

## 1. Scope

本文件冻结：

1. P0-Pay 最小 canonical persistence family。
2. P0-Pay 状态机。
3. 支付订单状态机。
4. 支付通道回调状态机。
5. 幂等规则。
6. 事务边界。
7. 审计动作。
8. 隐私和敏感支付信息边界。

本文件不进入：

1. migration authoring。
2. `apps/server/**` 实现。
3. BFF surface freeze。
4. Flutter consumption freeze。
5. 支付通道 SDK 细节。
6. 云上部署。
7. Computer Use 联调。

## 2. Persistence Freeze Conclusion

P0-Pay persistence 正式冻结为：

- Server-owned。
- business-anchor first。
- payment-order first。
- callback-verification first。
- audit append-only。
- no wallet。
- no balance。
- no funds pool。
- no BFF truth。

实现时可按现有 repository 命名进行微调，但不得改变以下责任拆分。

## 3. Canonical Persistence Family

当前允许的最小 canonical persistence family：

| Persistence family | 责任 | 说明 |
|---|---|---|
| `trade_tasks` | 交易任务实例 | 可复用现有项目 / 交易任务 carrier，但必须保留 `taskType` |
| `trade_task_authenticity_materials` | 真实性材料绑定 | 只引用 confirmed `FileAsset` |
| `trade_task_authenticity_declarations` | 真实性声明快照 | 保存规则版本与快照 hash |
| `fixed_price_bids` | 明价竞标报价与方案 | 服务费预授权业务锚点 |
| `platform_service_fee_authorizations` | 平台服务费预授权 | 报名时预授权，未中标释放 |
| `inquiry_quote_deposits` | 询价发单诚意金 | 200 元支付 / 退回 / 扣除 |
| `inquiry_quotations` | 询价报价与席位占用 | P0 固定 5 席 |
| `inquiry_result_processings` | 询价结果处理 | 选择 / 关闭 / 取消说明 |
| `contract_confirmations` | 合同确认和最终金额 | 平台服务费实扣前置 |
| `platform_service_fee_charges` | 成交后平台服务费实扣 | 按最终成交确认金额 |
| `payment_orders` | 支付 / 预授权 / 退款 / 释放订单 | 所有资金动作统一订单锚点 |
| `payment_transactions` | 支付通道发起、查询和结果 | 保存通道引用与状态，不保存账户敏感信息 |
| `payment_callback_events` | 通道回调接收、验签、应用 | 幂等与乱序控制 |
| `audit_logs` | 业务审计 | append-only |

当前明确不允许的 persistence family：

1. `wallet_balances`。
2. `wallet_transactions`。
3. `coin_accounts`。
4. `fund_pool_entries`。
5. `settlement_entries`。
6. `clearing_batches`。
7. `invoice_profiles`。
8. `invoice_requests`。
9. `guarantee_deposit_freezes`。
10. `guarantee_deposit_disputes`。
11. BFF local payment table。
12. Flutter local truth table。

## 4. Minimum Field Freeze

### 4.1 `platform_service_fee_authorizations`

Minimum fields:

- `authorization_id`
- `task_id`
- `bid_id`
- `factory_organization_id`
- `quoted_amount`
- `fee_rate`
- `estimated_fee_amount`
- `currency`
- `payment_order_id`
- `status`
- `rule_version`
- `rule_snapshot_hash`
- `agreement_text_snapshot_hash`
- `agreed_at`
- `authorized_at`
- `released_at`
- `charged_at`
- `refunded_at`
- `created_at`
- `updated_at`

### 4.2 `inquiry_quote_deposits`

Minimum fields:

- `deposit_id`
- `task_id`
- `publisher_organization_id`
- `amount`
- `currency`
- `payment_order_id`
- `status`
- `rule_version`
- `rule_snapshot_hash`
- `paid_at`
- `refund_requested_at`
- `refunded_at`
- `deducted_at`
- `deduction_reason`
- `created_at`
- `updated_at`

### 4.3 `payment_orders`

Minimum fields:

- `payment_order_id`
- `business_type`
- `business_id`
- `payer_organization_id`
- `amount`
- `currency`
- `channel`
- `merchant_order_id`
- `channel_order_id`
- `status`
- `idempotency_key_hash`
- `expires_at`
- `created_at`
- `updated_at`

### 4.4 `payment_transactions`

Minimum fields:

- `payment_transaction_id`
- `payment_order_id`
- `channel`
- `merchant_order_id`
- `channel_order_id`
- `channel_action_type`
- `channel_reference`
- `transaction_status`
- `requested_amount`
- `confirmed_amount`
- `currency`
- `initiated_at`
- `confirmed_at`
- `failed_at`
- `failure_reason_code`

### 4.5 `payment_callback_events`

Minimum fields:

- `callback_event_id`
- `payment_order_id`
- `channel`
- `merchant_order_id`
- `channel_order_id`
- `provider_event_id`
- `event_type`
- `verification_status`
- `apply_status`
- `callback_payload_hash`
- `received_at`
- `verified_at`
- `applied_at`
- `rejected_reason_code`

## 5. State Machine Freeze

### 5.1 `TradeTask.status`

Allowed states:

- `draft`
- `published`
- `quoting`
- `bid_closed`
- `selected`
- `contract_pending`
- `contract_confirmed`
- `performing`
- `completed`
- `cancelled`
- `disputed`

P0-Pay 不得新增：

- `guarantee_freezing`
- `settlement_pending`
- `invoice_pending`
- `wallet_pending`

### 5.2 Platform Service Fee Authorization State

Allowed states:

- `not_required`
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
- `expired`

Allowed transitions:

```text
not_required -> pending_authorization
pending_authorization -> authorized
pending_authorization -> failed
pending_authorization -> expired
authorized -> authorization_released
authorized -> pending_contract_confirm
authorized -> breach_hold
pending_contract_confirm -> charged
pending_contract_confirm -> authorization_released
pending_contract_confirm -> breach_hold
charged -> refund_pending
refund_pending -> refunded
breach_hold -> authorization_released
breach_hold -> refund_pending
```

Forbidden transitions:

```text
pending_authorization -> charged
authorized -> charged without contract confirmation
authorization_released -> charged
failed -> charged
expired -> charged
```

### 5.3 Inquiry Deposit State

Allowed states:

- `pending_payment`
- `paid`
- `refund_pending`
- `refunded`
- `deducted`
- `dispute_hold`
- `cancelled`
- `failed`
- `expired`

Allowed transitions:

```text
pending_payment -> paid
pending_payment -> failed
pending_payment -> expired
paid -> refund_pending
refund_pending -> refunded
paid -> deducted
paid -> dispute_hold
dispute_hold -> refund_pending
dispute_hold -> deducted
```

Forbidden transitions:

```text
pending_payment -> refunded
failed -> paid
refunded -> deducted
deducted -> refunded without explicit correction audit
```

### 5.4 Payment Order State

Allowed states:

- `created`
- `pending_user_confirm`
- `succeeded`
- `failed`
- `cancelled`
- `closed`
- `release_pending`
- `released`
- `refund_pending`
- `refunded`
- `expired`

Allowed transitions:

```text
created -> pending_user_confirm
pending_user_confirm -> succeeded
pending_user_confirm -> failed
pending_user_confirm -> cancelled
pending_user_confirm -> expired
succeeded -> release_pending
release_pending -> released
succeeded -> refund_pending
refund_pending -> refunded
succeeded -> closed
```

### 5.5 Callback State

Allowed verification states:

- `received`
- `verified`
- `rejected`

Allowed apply states:

- `not_applied`
- `applied`
- `duplicate`
- `ignored_out_of_order`
- `apply_failed`

Callback rules:

1. `received` 不得推进业务状态。
2. 只有 `verified` 才能进入 apply。
3. 重复回调必须标记 `duplicate`。
4. 乱序回调必须 `ignored_out_of_order` 或 `apply_failed`。
5. 回调 apply 必须在 Server 事务内推进。

## 6. Idempotency Freeze

所有写命令必须携带 `idempotencyKey`，并由 Server 持久化裁决。

幂等键作用域：

| Command | Scope |
|---|---|
| `tradeTask.create` | `publisherOrganizationId + idempotencyKey` |
| `fixedPriceBid.create` | `taskId + factoryOrganizationId + idempotencyKey` |
| `serviceFeeAuthorization.create` | `taskId + bidId + factoryOrganizationId + idempotencyKey` |
| `serviceFeeAuthorization.authorizeInit` | `authorizationId + idempotencyKey` |
| `inquiryDepositOrder.create` | `taskId + publisherOrganizationId + idempotencyKey` |
| `inquiryDeposit.payInit` | `depositOrderId + idempotencyKey` |
| `inquiryQuotation.create` | `taskId + factoryOrganizationId + idempotencyKey` |
| `inquiryResult.process` | `taskId + publisherOrganizationId + idempotencyKey` |
| `contractConfirmation.create` | `taskId + organizationId + idempotencyKey` |

Uniqueness rules：

1. 同一 `taskId + bidId` 只能有一个当前有效平台服务费预授权。
2. 同一询价任务只能有一个当前有效发单诚意金支付链。
3. 同一 `contractConfirmationId` 只能有一个当前有效平台服务费扣取链。
4. 同一 `provider_event_id` 或 `channel + channel_order_id + event_type` 的回调只能应用一次。
5. 幂等冲突必须 fail closed，不能返回另一个业务对象的成功结果。

## 7. Transaction Boundary Freeze

必须在 Server 事务中完成：

1. 报价席位占用。
2. 平台服务费预授权订单创建。
3. 发单诚意金订单创建。
4. 合同确认与最终成交金额记录。
5. 回调验签后的状态应用。
6. 预授权释放状态推进。
7. 发单诚意金退款 / 扣除状态推进。
8. 平台服务费正式扣取状态推进。
9. audit log append。

不得拆成：

- BFF 先写状态、Server 后补真相。
- Flutter 本地先判成功、Server 后确认。
- 消息楼先展示已扣款、支付回调后补状态。

## 8. Payment Channel Boundary Freeze

Server 可保存：

- `channel`
- `merchant_order_id`
- `channel_order_id`
- `channel_reference`
- `channel_action_type`
- `transaction_status`
- `callback_payload_hash`
- `failure_reason_code`

Server 不得保存：

- 支付宝账号
- 微信账号
- 银行卡号
- 支付密码
- 短信验证码
- 长期自动扣款授权
- 用户资金账户控制权

支付通道 raw payload 处理：

1. 只作为验签、查证和审计材料。
2. 默认保存 hash 或脱敏快照。
3. 不得变成业务主真相。
4. 不得向 BFF / Flutter 原样透出。

## 9. Audit Freeze

最小 audit action family：

- `TradeTaskCreated`
- `TradeTaskAuthenticityMaterialBound`
- `TradeTaskAuthenticityDeclarationConfirmed`
- `FixedPriceBidSubmitted`
- `PlatformServiceFeeAuthorizationOrderCreated`
- `PaymentChannelInitIssued`
- `PaymentCallbackReceived`
- `PaymentCallbackVerified`
- `PaymentCallbackRejected`
- `PlatformServiceFeePreauthorizationAuthorized`
- `PlatformServiceFeePreauthorizationReleased`
- `PlatformServiceFeeAuthorizationMovedToContractPending`
- `ContractConfirmationSubmitted`
- `PlatformServiceFeeCharged`
- `PlatformServiceFeeRefundRequested`
- `PlatformServiceFeeRefunded`
- `InquiryDepositOrderCreated`
- `InquiryDepositPaid`
- `InquiryDepositRefundRequested`
- `InquiryDepositRefunded`
- `InquiryDepositDeducted`
- `InquiryQuotationSubmitted`
- `InquiryQuoteSeatOccupied`
- `InquiryResultProcessed`
- `P0PayStateTransitionBlocked`
- `PaymentStateApplyFailed`

Audit rules：

1. audit 必须 append-only。
2. 失败的权限校验不得写成功 audit。
3. 状态推进失败必须写失败 audit 或错误追踪事件。
4. BFF 不写业务 audit。
5. Flutter 不写业务 audit。

## 10. Release / Refund / Deduction Rules

### 10.1 未中标释放

Server 必须保证：

1. 未中标工厂 100% 自动释放平台服务费预授权。
2. 未中标不得收取平台服务费。
3. 释放失败进入 controlled failed / retry posture，不得伪装成功。

### 10.2 发布方毁约

Server 必须保证：

1. 释放或退回工厂预授权相关费用。
2. 标记项目发布方毁约。
3. 记录信用扣分候选。
4. 不得向工厂收取平台服务费。

### 10.3 工厂拒签

Server 必须保证：

1. 不得默认全额扣取平台服务费预授权。
2. 只能按竞标违约规则部分处理。
3. 处理上限必须遵守 V1.3 母资料。
4. 该处理不等同于平台服务费。

### 10.4 发单诚意金退回 / 扣除

Server 必须保证：

1. 合规处理后退回。
2. 逾期不处理、恶意询价、虚假发布、绕单成立才可扣除。
3. 扣除必须有原因、证据或平台处理记录。
4. 扣除不是履约保证金扣罚。

## 11. Derived Projection Boundary

允许派生：

1. BFF `p0PaySummary`。
2. 任务详情页支付状态摘要。
3. 消息楼只读资金状态。
4. route target。
5. UI status text key。

派生投影必须：

1. 从 Server canonical truth 读取。
2. 可重复计算。
3. 不反向覆盖 canonical truth。
4. 不保存资金状态真相。

## 12. Migration Authoring Guard

下一阶段如进入 migration authoring，必须遵守：

1. 每个新增 table 一事一责。
2. 支付订单、通道交易、回调事件不得混在同一表。
3. 业务侧 authorization/deposit/charge 不得混成通用 ledger。
4. `objectKey` 不得进入业务真相表。
5. 敏感支付账号字段不得出现。
6. 所有金额字段必须带 currency。
7. 所有回调应用必须可追溯到 audit。

## 13. Retained No-Go

当前继续 No-Go：

1. Server implementation。
2. BFF implementation。
3. Flutter implementation。
4. Computer Use 联调。
5. release-prep。
6. production release。
7. 履约保证金。
8. 钱包 / 余额 / 金币 / 资金池。
9. 通用支付中心。
10. 通用账单中心。
11. 清分结算。
12. 发票 / 税务。
13. 财务后台。

## 14. Stage Conclusion

当前阶段结论：

- `P0-Pay L3 persistence / state / audit freeze = 通过`。
- `Go for L4 BFF surface freeze authoring`。
- `No-Go for implementation`。
- `No-Go for integration`。
- `No-Go for release-prep`。
- `No-Go for production release`。

## 15. Formal Conclusion

P0-Pay backend persistence、状态机、幂等、回调和审计边界已冻结。

正式口径：

```text
All P0-Pay money movements are Server-owned order-level state transitions.
No wallet, no balance, no funds pool, no BFF payment truth, no Flutter payment truth.
```

---
owner: Codex 总控
status: frozen
layer: L2 Contracts
freeze_date_local: 2026-04-30
purpose: Freeze the contract boundary for controlled payment success callback, project sincerity paid readback, final service-fee charge, and read-only refund / settlement placeholders without allowing Flutter or BFF to own money truth.
inputs_canonical:
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/openapi.yaml
---

# 资金主线 L2 Contracts 冻结单

## 0. 总裁决

- 当前是否需要新增 Flutter-facing callback route：No
- 当前是否允许 BFF 接收支付通道 callback：No
- 当前是否允许 Flutter 传最终资金状态：No
- 当前是否允许 app-facing 读取支付成功和扣费结果：Yes, read-only

## 1. Contract Family

| Family | Path / Object | Owner | 本期裁决 |
|---|---|---|---|
| payment order | `PaymentOrder` | Server | Canonical |
| callback result | Server callback endpoint response | Server | Canonical, not app-facing |
| project sincerity status | `/api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}` | Server -> BFF | App-facing read-only |
| final charge | `platformServiceFeeCharge` / `dealSummary` | Server -> BFF | App-facing read-only |
| refund summary | `refundStatus` | Server -> BFF | Read-only placeholder |
| settlement summary | `settlementSummary` | Server future | Not opened in this package |

## 2. Server Callback Contract

Server callback endpoint:

```text
POST /server/exhibition/p0-pay/payment-callbacks/{paymentChannel}
```

Required request evidence:

- `x-p0-pay-signature`
- `merchantOrderNo`
- `channelOrderId`
- `providerEventId`
- `channelEventId`
- `eventType`
- `eventStatus`
- `amount`
- `currency`

Response minimum:

- `callbackEventId`
- `duplicate`
- `verificationStatus`
- `applyStatus`
- `rejectedReasonCode`
- `receivedAt`
- `processedAt`

Contract rules:

1. This endpoint is Server-facing only.
2. BFF must not expose this as app-facing.
3. Duplicate callback must return `duplicate=true` or `applyStatus=duplicate` without reapplying business state.
4. Signature failure must create rejected callback evidence and must not create transaction success.

## 3. Payment Order Fields

Minimum fields:

- `paymentOrderId`
- `businessType`
- `businessId`
- `taskId`
- `bidId`
- `payerOrganizationId`
- `payeeOrganizationId`
- `amount`
- `currency`
- `paymentChannel`
- `orderRole`
- `status`
- `merchantOrderNo`
- `channelOrderId`
- `idempotencyKeyHash`
- `expiresAt`
- `createdAt`
- `updatedAt`

Field owner:

- Server owns all fields.
- BFF may only expose selected fields through bounded read models.
- Flutter must never fabricate `orderId`, `merchantOrderNo`, `paid`, `charged`, `refunded`, or settlement result.

## 4. App-facing Readback Fields

### 4.1 Project Authenticity Sincerity Status

Existing app-facing route:

```text
GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}
```

Minimum response:

- `orderId`
- `orderStatus`
- `amount`
- `currency`
- `refundStatus`
- `withholdStatus`
- `withholdReasonCode`
- `channelSummary`
- `updatedAt`

### 4.2 Pricing Summary

Existing app-facing route:

```text
GET /api/app/project/{projectId}/pricing-summary
```

Minimum fields for this package:

- `publisherPricing.authenticitySincerityStatus`
- `publisherPricing.authenticitySincerityOrderId`
- `publisherPricing.authenticitySincerityAmount`
- `publisherPricing.nextAction`
- `dealSummary.dealStatus`
- `dealSummary.finalConfirmedAmount`
- `dealSummary.platformServiceFeeAmount`
- `dealSummary.serviceFeeChargeStatus`

### 4.3 Contract Confirmation / Final Charge

Final charge read model minimum:

- `contractConfirmationId`
- `contractStatus`
- `finalConfirmedAmount`
- `platformServiceFeeFinalAmount`
- `platformServiceFeeStatus`
- `platformServiceFeeCharge`
- `nextAction`
- `updatedAt`

`platformServiceFeeCharge` minimum:

- `finalConfirmedAmount`
- `feeRate`
- `feeRateLabel`
- `feeRateSource`
- `membershipTierSnapshot`
- `feeRateRuleVersion`
- `feeRateSnapshotHash`
- `baseFeeAmount`
- `membershipDiscountRate`
- `capAmount`
- `finalFeeAmount`
- `releasedRemainderAmount`
- `chargeStatus`

## 5. Error Codes

| Code | Meaning | App-facing copy rule |
|---|---|---|
| `P0_PAY_STATE_CONFLICT` | Current payment or charge state cannot accept this action | Must show Chinese action guidance |
| `P0_PAY_INVALID` | Payload, channel, callback, or rule input invalid | Must show Chinese validation guidance |
| `P0_PAY_PERMISSION_DENIED` | Current organization does not own the object | Must show permission message |
| `P0_PAY_RESOURCE_UNAVAILABLE` | Required order / auth / charge not found | Must show refresh or contact support |
| `PAYMENT_CALLBACK_SIGNATURE_INVALID` | Callback verification failed | Server audit only, not Flutter-facing |
| `PAYMENT_CALLBACK_DUPLICATE` | Duplicate callback | Server audit only, no user-facing error |

## 6. Explicit No-Go

This contracts addendum does not freeze:

1. bare `/api/app/payment/*`
2. bare `/api/app/refund/*`
3. bare `/api/app/settlement/*`
4. generic wallet or balance schema
5. provider settlement detail
6. invoice / tax / finance-admin fields

## 7. 下一轮唯一动作

进入 L3 Server truth 冻结，确认 callback 验签、幂等、状态推进、最终扣费和快照复用规则。

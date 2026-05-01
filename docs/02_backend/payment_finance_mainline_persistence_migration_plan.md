---
owner: Codex 总控
status: frozen
layer: L3 Persistence / Migration Plan
freeze_date_local: 2026-04-30
purpose: Confirm persistence coverage for controlled payment callback, paid readback, final charge, refund placeholder, and settlement placeholder without destructive migration.
inputs_canonical:
  - docs/02_backend/payment_finance_mainline_server_truth_addendum.md
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/p0_pay/entities/payment-order.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-transaction.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-callback-event.entity.ts
  - apps/server/src/modules/p0_pay/entities/platform-service-fee-charge.entity.ts
  - apps/server/src/modules/p0_pay/entities/inquiry-quote-deposit.entity.ts
---

# 资金主线 Persistence / Migration 设计与解锁单

## 0. 总裁决

- 是否需要新增 destructive migration：No
- 是否需要新增表：No
- 是否允许执行现有 P0-Pay migration：Yes, if target cloud lacks it
- 是否允许删除旧数据：No
- 是否允许进入 callback / charge 实现补证：Go

## 1. Existing Persistence Coverage

| Object | Existing table / entity | Coverage |
|---|---|---|
| payment order | `payment_orders` / `PaymentOrderEntity` | business anchor, amount, channel, order role, status, merchant order |
| transaction | `payment_transactions` / `PaymentTransactionEntity` | payment / authorization / refund / release / callback transaction evidence |
| callback event | `payment_callback_events` / `PaymentCallbackEventEntity` | verification, apply status, payload hash, idempotent event id |
| project sincerity | `inquiry_quote_deposits` / `InquiryQuoteDepositEntity` | 200 order, paid, refund placeholder, withheld placeholder |
| service-fee authorization | `platform_service_fee_authorizations` | locked fee snapshot, quota, charged/released/refunded fields |
| final charge | `platform_service_fee_charges` / `PlatformServiceFeeChargeEntity` | final amount, snapshot, charge status, released remainder |

## 2. Migration Rule

Current migration family:

- `p0PayMigrations`
- key: `20260504_p0_pay_payment_execution_truth`
- later additive statements for membership snapshot / platform pricing fields

Allowed migration behavior:

1. `CREATE TABLE IF NOT EXISTS`
2. `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
3. additive check-constraint refresh when needed

Forbidden migration behavior:

1. `DROP TABLE`
2. `DROP COLUMN`
3. destructive rename
4. data rewrite that changes paid / charged / refunded state

## 3. Old Data Compatibility

1. Existing `pending_payment` orders stay pending.
2. Existing `paid` sincerity orders stay paid.
3. Existing `charged` service-fee charge rows stay charged.
4. Legacy `legacy_fixed_default` snapshot remains visible as legacy, not recalculated.
5. Missing snapshot fields must be displayed as unknown / legacy, not guessed.

## 4. Rollback Plan

If runtime shows callback or charge mismatch:

1. Disable controlled callback runtime at gateway / route exposure level.
2. Keep read-only pricing summary available.
3. Do not delete callback event rows.
4. Do not rollback already-applied additive columns.
5. Revert application release to previous Server/BFF version if needed.

## 5. Implementation Unlock

Implementation unlock is limited to:

1. callback behavior tests / small fail-closed hardening
2. paid readback tests
3. final charge idempotency / failure tests

Refund and settlement implementation remains locked.

---
owner: Codex 总控
status: frozen
layer: L0 Charge Rule Freeze
freeze_date_local: 2026-04-30
purpose: Freeze contract final service-fee charge rules before implementation verification, especially locked snapshot reuse, idempotency, failure, and no settlement widening.
inputs_canonical:
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/02_backend/payment_finance_mainline_server_truth_addendum.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
---

# 合同确认最终扣费规则冻结单

## 0. 总裁决

- 是否允许合同确认后生成最终平台服务费 charge：Yes
- 是否允许重新读取会员等级：No
- 是否允许重复扣款：No
- 是否允许本期直接进入结算 / 发票：No

## 1. Charge Trigger

Charge trigger:

```text
publisher confirmed + factory confirmed + finalConfirmedAmount frozen = confirmed_deal
```

Only `confirmed_deal` can create `PlatformServiceFeeCharge`.

## 2. Amount Rule

Final fee calculation:

```text
finalFeeAmount = pricingPolicy(finalConfirmedAmount, locked authorization snapshot, authorizationQuotaAmount)
```

Rules:

1. `finalConfirmedAmount` comes from contract confirmation.
2. `feeRate / tier / rule snapshot` comes from original authorization.
3. Membership upgrade / downgrade / expiry after authorization does not affect this order.
4. Remaining authorization amount becomes `releasedRemainderAmount`.

## 3. Idempotency Rule

1. One contract confirmation can have at most one active charge.
2. Existing charge must be returned instead of creating a second charge.
3. Payment order idempotency must bind to charge / contract confirmation.
4. Repeated request must not create duplicate payment order or transaction.

## 4. Failure Rule

Fail closed when:

1. deal is not confirmed
2. authorization is missing
3. authorization has no payment channel
4. locked fee policy is unavailable
5. authorization snapshot is missing and cannot be safely interpreted

## 5. Settlement Boundary

`charged` means platform service fee charge record is created and marked by Server-controlled payment path.

It does not mean:

1. platform payout settlement has completed
2. provider clearing has completed
3. invoice has been issued
4. finance-admin reconciliation has completed

Those are future packages.

---
owner: Codex 总控
status: frozen
layer: L3 Server Truth
freeze_date_local: 2026-04-30
purpose: Freeze Server-owned truth for controlled payment callback success, duplicate and failure behavior, paid readback, contract final charge, idempotency, audit, and fail-closed rules.
inputs_canonical:
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/01_contracts/payment_finance_mainline_contracts_addendum.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
---

# 资金主线 L3 Server Truth 冻结单

## 0. 总裁决

- Server 是否唯一资金真相 owner：Yes
- Payment callback 是否只进 Server：Yes
- BFF / Flutter 是否可判断支付成功：No
- Contract final charge 是否必须复用 locked authorization snapshot：Yes
- Refund / settlement 是否本期实现：No

## 1. Callback Truth

Server callback rules:

1. Callback 必须验签。
2. Callback event 必须落库。
3. Duplicate callback 按 `paymentChannel + channelEventId` 幂等，不重复推进订单、交易或业务状态。
4. Signature rejected callback 只记录事件和 audit，不更新 payment order 为 succeeded。
5. Success callback 只允许从 `created / pending_user_confirm` 推进到 `succeeded`。
6. Failure callback 只允许从 `created / pending_user_confirm` 推进到 `failed`。
7. Out-of-order callback 必须 no-op 或 fail closed。
8. Callback 不得改写 feeRate、feeRateSource、membershipTierSnapshot、ruleVersion、snapshotHash。

## 2. Business Apply Truth

| businessType | success behavior | failure behavior |
|---|---|---|
| `project_authenticity_sincerity_payment` | sincerity order `pending_payment -> paid` | `pending_payment -> failed` |
| `platform_service_fee_authorization` | authorization `pending_authorization -> authorized` or `pending_freeze -> frozen` | pending status -> `failed` |
| `bid_service_fee_authorization_freeze` | same as authorization freeze | pending status -> `failed` |
| `platform_service_fee_charge` | charge `pending_charge / charge_pending -> charged` | pending charge -> `charge_failed` |

Project publish rule:

- `200 元项目真实性诚意金 paid` 不自动发布项目。
- Flutter 必须回到项目发布确认链路，由发布动作再次读取 Server gate。

## 3. Contract Final Charge Truth

Final charge rules:

1. Only confirmed deal can create final charge.
2. Charge uses current `ContractConfirmation.finalConfirmedAmount`.
3. Charge must copy locked authorization snapshot:
   - `feeRate`
   - `feeRateLabel`
   - `feeRateSource`
   - `membershipTierSnapshot`
   - `feeRateRuleVersion`
   - `feeRateSnapshotHash`
   - `feeCalculatedAt`
4. Contract confirmation must not reread current membership tier.
5. Existing charge for one contract confirmation must be returned idempotently.
6. Missing payment channel must fail closed.
7. Duplicate charge creation is forbidden.

## 4. Audit And Transaction Truth

Server must write:

- `PaymentOrder`
- `PaymentTransaction`
- `PaymentCallbackEvent`
- `PlatformServiceFeeCharge`
- `audit_logs` or equivalent audit event

Minimum audit actions:

- `payment_callback_verified`
- `payment_callback_rejected`
- `project_authenticity_sincerity_paid`
- `bid_service_fee_authorization_frozen`
- `platform_service_fee_charged`

## 5. Refund / Settlement Boundary

This Server truth freezes placeholders only:

1. `refund_pending / refunded` status may exist.
2. Release transaction for authorization may exist.
3. Provider refund API, provider settlement query, payout, invoice, tax, finance-admin are not part of this package.
4. Settlement status must not be shown as completed unless a later settlement package owns it.

## 6. 下一轮唯一动作

进入 persistence / migration design，确认现有表是否已承载本期字段；如已承载，不新增 migration。

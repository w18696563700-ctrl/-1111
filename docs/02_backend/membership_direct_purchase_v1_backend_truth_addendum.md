---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 backend truth family for `payment MVP / 会员直购`, including only the minimum Server-owned purchase-order, payment-transaction, refund-request, entitlement-materialization, and audit truth without unlocking BFF surface freeze, frontend surface freeze, implementation unlock, integration, or launch.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_backend_truth_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/02_backend/service_boundaries.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
  - docs/02_backend/payment_billing_v1_backend_truth_addendum.md
---

# `payment MVP / 会员直购` Backend Truth Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 会员直购`
  - execution-oriented `docs/02_backend` package
- 本文只冻结：
  - purchase-order truth
  - payment-transaction truth
  - refund-request truth
  - entitlement materialization truth boundary
  - audit ownership
- 本文当前不代表：
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime payment pass
  - launch approval

## B. Current Backend-truth Meaning

- 当前 backend-truth package 只服务于：
  - 会员直购最小执行闭环的 server-owned truth
  - payment transaction / callback / verify 的最小真值链
  - payment success -> entitlement materialization 的最小真值链
  - refund apply / refund result 的最小真值链
- 当前 backend-truth package 明确不服务于：
  - wallet
  - balance
  - invoice / tax full truth
  - settlement / clearing truth
  - finance-admin

## C. Truth Ownership Freeze

- `Server` 继续是以下 truth family 的唯一 owner：
  - membership purchase-offer source truth
  - membership purchase-order truth
  - membership payment-transaction truth
  - membership refund-request truth
  - entitlement materialization truth
  - audit truth
- 当前 package 的最小 owner split 冻结为：
  - `Server.membership` 持有：
    - SKU / entitlement / quota truth
    - entitlement materialization truth
  - `Server.payment_billing` 持有：
    - payment-init / callback / verify / payment reference truth
- `BFF` 与 Flutter 当前都不得持有：
  - 第二订单状态机
  - 第二支付真相
  - entitlement 生效真相

## D. Allowed Backend Carriers

- 当前 dedicated package 复用以下既有 carrier family：
  - `organizations`
  - `organization_members`
  - `organization_paid_memberships`
  - `organization_membership_quota_snapshots`
  - `audit_logs`
  - `config_entries`
- 当前 dedicated package 引入以下最小 dynamic carrier family：
  - `membership_purchase_orders`
  - `membership_payment_transactions`
  - `membership_refund_requests`
- 当前 round 明确不批准：
  - `billing_ledgers`
  - `invoice_profiles`
  - `settlement_entries`
  - `wallet_balances`
  - `manual_transfer_reconciliations`

## E. Purchase-offer Source Truth

- purchase-offer source truth 可继续由以下 server-owned family 派生：
  - `config_entries`
  - registered constant lookup tables
  - `organization_paid_memberships`
  - `organization_membership_quota_snapshots`
- 当前 source truth 至少要支持：
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
- 当前 hard rules：
  - front-end candidate commercial copy 不是 primary truth
  - long-term channel availability 不是 primary truth
  - offer source truth 不得被误写成 payment success truth

## F. Purchase-order Truth

- `membership_purchase_orders` 成为当前唯一 dedicated order truth carrier。
- 一条 row 代表：
  - 一个 organization-scoped 会员购买意图
  - 一个当前 order-state family
  - 一个当前 entitlement progression family
- 当前 minimum fields 必须支持：
  - `id`
  - `organization_id`
  - `created_by_actor_id`
  - `sku_code`
  - `purchase_intent_type`
  - `expected_amount`
  - `currency`
  - `channel_candidate`
  - `order_status`
  - `payment_status`
  - `entitlement_status`
  - `refund_status`
  - `idempotency_key`
  - `expires_at`
  - `updated_at`
- 当前 hard rules：
  - one idempotent create request 不得生成多条 current order truth
  - `paid` 不等于 entitlement 已生效
  - `active` 只能在 entitlement materialization 完成后成立

## G. Payment-transaction Truth

- `membership_payment_transactions` 成为当前唯一 dedicated payment-transaction truth carrier。
- 一条 row 代表：
  - 一个 membership purchase order 的 payment-init / callback / verify 真值链
- 当前 minimum fields 必须支持：
  - `id`
  - `membership_order_id`
  - `payment_reference_id`
  - `pay_channel`
  - `payment_init_status`
  - `callback_status`
  - `verify_result`
  - `channel_action_type`
  - `provider_trade_ref` optional
  - `callback_received_at` optional
  - `updated_at`
- 当前 hard rules：
  - provider raw payload 不是 primary truth
  - 前端支付弹窗完成态不是 primary truth
  - callback verify success 才能推进 `purchase order` 的 `paid` branch

## H. Entitlement Materialization Truth

- entitlement materialization truth 继续只允许写入既有 canonical carriers：
  - `organization_paid_memberships`
  - `organization_membership_quota_snapshots`
- 当前 hard rules：
  - entitlement materialization 不得写入 `membership_purchase_orders` 作为替代真相
  - `membership_purchase_orders.order_status = active` 的成立，必须依赖：
    - payment verify success
    - entitlement write success
  - 任何 current paid-membership cycle truth 仍然是 organization-scoped，而不是 actor-scoped

## I. Refund-request Truth

- `membership_refund_requests` 成为当前唯一 dedicated refund-request truth carrier。
- 一条 row 代表：
  - 一个 membership purchase order 的 refund apply / result 真值链
- 当前 minimum fields 必须支持：
  - `id`
  - `membership_order_id`
  - `refund_reason_code`
  - `refund_statement`
  - `refund_status`
  - `refund_amount`
  - `decision_summary_key` optional
  - `requested_by_actor_id`
  - `idempotency_key`
  - `updated_at`
- 当前 hard rules：
  - 无订单不得 materialize refund truth
  - 不得绕过 order truth 直接 materialize refund result
  - refund truth 不得伪装成 finance-admin 决策台 truth

## J. Audit Truth

- 当前 package 至少必须 audit：
  - membership order create
  - pay-init issue
  - callback verify result
  - entitlement materialization
  - refund apply
  - refund result materialization
- audit carrier 继续固定为：
  - `audit_logs`

## K. Retained No-Go

- 当前继续明确 `No-Go`：
  - wallet / balance / recharge / withdrawal truth
  - invoice / tax full truth
  - settlement / clearing truth
  - finance-admin truth
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## L. Formal Conclusion

- 当前正式结论如下：
  - `membership_direct_purchase_v1_backend_truth_addendum` 已冻结为 `payment MVP / 会员直购` 的第一份 execution-oriented `L3` backend truth family
  - 当前 package 只冻结最小 purchase-order / payment-transaction / refund-request / entitlement materialization / audit truth
  - 当前 package 不改写既有 `membership_entitlement_v1_backend_truth_addendum` 的 bounded read truth，也不授予 implementation unlock

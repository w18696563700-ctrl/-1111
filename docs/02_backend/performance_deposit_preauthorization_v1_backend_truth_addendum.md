---
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 backend truth family for `payment MVP / 履约保证金预授权`, including only the minimum Server-owned preauthorization-order, transaction, appeal, posture-linkage, and audit truth without unlocking BFF surface freeze, frontend surface freeze, implementation unlock, integration, or launch.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_backend_truth_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/performance_deposit_preauthorization_rules_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/01_contracts/performance_deposit_preauthorization_v1_contracts_addendum.md
  - docs/02_backend/service_boundaries.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
  - docs/02_backend/payment_billing_v1_backend_truth_addendum.md
---

# `payment MVP / 履约保证金预授权` Backend Truth Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 履约保证金预授权`
  - execution-oriented `docs/02_backend` package
- 本文只冻结：
  - preauthorization order truth
  - preauthorization transaction truth
  - appeal truth
  - posture-linkage truth boundary
  - audit ownership
- 本文当前不代表：
  - project 主链已接入保证金 execution
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime deposit freeze pass

## B. Current Backend-truth Meaning

- 当前 backend-truth package 只服务于：
  - 预授权冻结候选的 server-owned 最小真值链
  - freeze / release / deduction / appeal 结果真值链
  - 当前 bounded posture package 与 execution order truth 的分层边界
- 当前 backend-truth package 明确不服务于：
  - membership charging
  - wallet / balance
  - invoice / tax full truth
  - settlement / clearing truth
  - finance-admin
  - project 主链硬 gate 改写

## C. Truth Ownership Freeze

- `Server` 继续是以下 truth family 的唯一 owner：
  - deposit preauthorization current-offer source truth
  - deposit preauthorization order truth
  - deposit preauthorization transaction truth
  - deposit appeal truth
  - audit truth
- 当前 package 的最小 owner split 冻结为：
  - `Server.payment_billing` 持有：
    - freeze-init / callback / verify / payment reference truth
    - release / deduction result truth
  - `Server.trade_governance` 持有：
    - binding reference legality
    - deduction / appeal governance result truth
- `BFF` 与 Flutter 当前都不得持有：
  - 第二保证金状态机
  - 第二扣划真相
  - 责任归属真相

## D. Allowed Backend Carriers

- 当前 dedicated package 复用以下既有 carrier family：
  - `organizations`
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
  - `audit_logs`
  - `config_entries`
  - `file_assets`
  - `evidences`
- 当前 dedicated package 引入以下最小 dynamic carrier family：
  - `deposit_preauthorization_orders`
  - `deposit_preauthorization_transactions`
  - `deposit_preauthorization_appeals`
- 当前 round 明确不批准：
  - `deposit_penalty_ledgers`
  - `deposit_settlement_entries`
  - `invoice_profiles`
  - `wallet_balances`
  - `offline_transfer_deposit_records`

## E. Current-offer Source Truth

- current-offer source truth 可继续由以下 server-owned family 派生：
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
  - `config_entries`
  - registered constant lookup tables
- 当前 source truth 至少要支持：
  - `depositRequirementStatus`
  - `depositEligibilityStatus`
  - `depositTierCode`
  - `freezeAmount`
  - `currency`
  - `bindingReference`
  - `channelCandidates`
- 当前 hard rules：
  - current-offer truth 不是 project 主链 gate truth
  - current-offer truth 不得被误写成“当前项目已经依赖冻结成功”

## F. Preauthorization-order Truth

- `deposit_preauthorization_orders` 成为当前唯一 dedicated order truth carrier。
- 一条 row 代表：
  - 一个 organization-scoped 履约保证金预授权意图
  - 一个当前 order-state family
  - 一个当前 freeze / release / deduction / appeal progression family
- 当前 minimum fields 必须支持：
  - `id`
  - `organization_id`
  - `created_by_actor_id`
  - `binding_reference_family`
  - `binding_reference_id`
  - `expected_tier_code`
  - `freeze_amount`
  - `currency`
  - `channel_candidate`
  - `order_status`
  - `freeze_status`
  - `release_status`
  - `deduction_status`
  - `appeal_status`
  - `idempotency_key`
  - `expires_at`
  - `updated_at`
- 当前 hard rules：
  - one idempotent create request 不得生成多条 current order truth
  - 当前 order truth 不得被偷换成项目主链已过 gate 的证明
  - 当前 order truth 不得 materialize 为 generic deposit center truth

## G. Preauthorization-transaction Truth

- `deposit_preauthorization_transactions` 成为当前唯一 dedicated transaction truth carrier。
- 一条 row 代表：
  - 一个 preauthorization order 的 freeze-init / callback / verify 真值链
- 当前 minimum fields 必须支持：
  - `id`
  - `deposit_order_id`
  - `payment_reference_id`
  - `pay_channel`
  - `freeze_init_status`
  - `callback_status`
  - `verify_result`
  - `channel_action_type`
  - `provider_trade_ref` optional
  - `callback_received_at` optional
  - `updated_at`
- 当前 hard rules：
  - provider raw payload 不是 primary truth
  - 微信押金 candidate 当前仍不构成已放行实现真相
  - verify success 才能推进 order truth 的 `frozen` branch

## H. Appeal Truth

- `deposit_preauthorization_appeals` 成为当前唯一 dedicated appeal truth carrier。
- 一条 row 代表：
  - 一个 preauthorization order 的 appeal apply / review 真值链
- 当前 minimum fields 必须支持：
  - `id`
  - `deposit_order_id`
  - `appeal_reason_code`
  - `appeal_statement`
  - `appeal_status`
  - `requested_by_actor_id`
  - `idempotency_key`
  - `updated_at`
- appeal evidence 当前继续依附于：
  - `file_assets`
  - `evidences`
- 当前 hard rules：
  - 无 order truth 不得 materialize appeal truth
  - appeal truth 不得伪装成完整 admin adjudication console truth

## I. Posture-linkage Truth Boundary

- 既有 bounded posture truth 继续固定在：
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
- 当前 hard rules：
  - posture truth 不得被重写成 execution order truth
  - execution order truth 也不得回写伪装成当前 bounded posture truth
  - 后续若要做 derived read-model，只能由 Server 在下一层文书单独冻结

## J. Audit Truth

- 当前 package 至少必须 audit：
  - deposit order create
  - freeze-init issue
  - callback verify result
  - release / deduction result materialization
  - appeal apply
  - appeal review result materialization
- audit carrier 继续固定为：
  - `audit_logs`

## K. Retained No-Go

- 当前继续明确 `No-Go`：
  - generic deposit center truth
  - wallet / balance / offline transfer truth
  - settlement / clearing truth
  - invoice / tax truth
  - finance-admin truth
  - project 主链硬 gate rewrite
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## L. Formal Conclusion

- 当前正式结论如下：
  - `performance_deposit_preauthorization_v1_backend_truth_addendum` 已冻结为 `payment MVP / 履约保证金预授权` 的第一份 execution-oriented `L3` backend truth family
  - 当前 package 只冻结最小 preauthorization-order / transaction / appeal / posture-linkage / audit truth
  - 当前 package 不改写既有 `credit_deposit_transaction_guarantee_v1_backend_truth_addendum` 的 bounded posture truth，也不授予 implementation unlock

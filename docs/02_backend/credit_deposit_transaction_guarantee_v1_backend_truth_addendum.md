---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated backend truth, persistence carriers, derived private status-source rules, and dependency-reference ownership for `我的楼 V2.1 信用 / 保证金 / 交易保障` without widening into runtime funds execution, billing, settlement, governance-console detail, or implementation unlock.
layer: L3 Backend
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_contracts_judgment_addendum.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_backend_truth_judgment_addendum.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md
  - docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
---

# 我的楼 V2.1 信用 / 保证金 / 交易保障 Backend Truth Addendum

## A. Current Object

- This addendum applies only to the first dedicated `docs/02_backend` package for:
  - `我的楼 V2.1 信用 / 保证金 / 交易保障`
  - bounded credit-constraint status truth
  - bounded deposit posture truth
  - bounded transaction-guarantee posture truth
  - bounded private `status / explanation / handoff` source truth
  - bounded `V2.2` dependency reference truth
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `docs/03_bff` surface freeze
  - unlock `docs/04_frontend` surface freeze
  - approve runtime payment, billing, or settlement execution
  - approve dispute or governance-console runtime

## B. Current Backend-truth Meaning

- This backend-truth package freezes only:
  - `rule layer`
  - `status layer`
  - `explanation layer`
  - `handoff layer`
  - `dependency layer`
- This backend-truth package therefore freezes:
  - which dynamic carriers are canonical
  - which server-owned catalog-like truths may remain config-backed
  - how current private status / explanation / handoff is derived
  - how dependency references remain server-owned
- This addendum must not be read as:
  - approval for runtime funds execution
  - approval for payment / billing / settlement truth
  - approval for dispute adjudication truth
  - approval for governance-console truth
  - approval for implementation unlock

## C. Allowed Backend Truth Families

- `Server` remains the only truth owner for the following `V2.1` families:
  - credit-constraint status truth
  - deposit `requirement / eligibility / restriction / status` posture truth
  - transaction-guarantee `eligibility / restriction / handoff` posture truth
  - private `status / explanation / handoff` carrier truth
  - `V2.2` dependency truth reference
- Current package meaning:
  - those truths are bounded organization-scope trade-governance postures
  - those truths are not payment, billing, or settlement truths
  - those truths are not second identity or organization truths

## D. Allowed Backend Carriers

- This dedicated package reuses the following existing anchor family:
  - `organizations`
  - `organization_members`
  - `audit_logs`
  - `config_entries`
- This dedicated package introduces the following minimum dynamic carrier family:
  - `organization_credit_constraint_postures`
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
- Current carrier meaning is frozen as:
  - posture carriers
  - status carriers
  - explanation carriers
  - handoff carriers
  - dependency reference carriers
- Current round does not approve dedicated carriers for:
  - `deposit_funds_executions`
  - `deposit_penalty_executions`
  - `deposit_compensation_executions`
  - `deposit_refund_executions`
  - `billing_ledgers`
  - `settlement_entries`
  - `risk_score_snapshots`
  - `transaction_guarantee_cases`
  - `transaction_dispute_cases`
  - `admin_console_actions`

## E. Credit Constraint Truth

- `organization_credit_constraint_postures` becomes the only current dedicated credit-constraint truth carrier.
- One current effective row represents:
  - one organization-scoped trade constraint posture
  - one organization-scoped performance constraint posture
  - one current execution-availability posture
  - one current explanation and handoff posture
- Current minimum fields must support:
  - `organization_id`
  - `credit_constraint_status`
  - `performance_constraint_status`
  - `restriction_reason_code`
  - `advisory_reason_code`
  - `execution_availability_status`
  - `explanation_key`
  - `handoff_key`
  - `dependency_key` optional
  - `updated_at`
- Current hard rules:
  - one organization has at most one current effective credit-constraint posture row
  - credit-constraint truth is posture truth only in this round
  - no scoring-engine output may be stored as package truth in this carrier
  - no automatic risk execution may be stored as package truth in this carrier

## F. Deposit Requirement / Eligibility / Restriction / Status Truth

- `organization_deposit_postures` becomes the only current dedicated deposit-posture truth carrier.
- One current effective row represents:
  - one organization-scoped deposit requirement posture
  - one current eligibility posture
  - one current restriction posture
  - one current status posture
  - one current handoff and dependency posture
- Current minimum fields must support:
  - `organization_id`
  - `requirement_status`
  - `eligibility_status`
  - `restriction_status`
  - `deposit_posture_status`
  - `handoff_key`
  - `dependency_key` optional
  - `updated_at`
- Current hard rules:
  - this carrier stores posture only, not concrete funds movement
  - no concrete amount may be stored in this package
  - no amount formula may be stored in this package
  - no freeze / penalty / compensation / refund / settlement execution truth may be materialized in this carrier

## G. Transaction Guarantee Eligibility / Restriction / Handoff Truth

- `organization_transaction_guarantee_postures` becomes the only current dedicated transaction-guarantee truth carrier.
- One current effective row represents:
  - one organization-scoped guarantee eligibility posture
  - one current guarantee restriction posture
  - one current explanation posture
  - one current handoff posture
  - one current dependency posture
- Current minimum fields must support:
  - `organization_id`
  - `eligibility_status`
  - `restriction_status`
  - `explanation_key`
  - `handoff_key`
  - `dependency_key` optional
  - `updated_at`
- Current hard rules:
  - transaction-guarantee truth remains posture truth only
  - no dispute detail may be stored as package truth here
  - no admin adjudication operation truth may be stored as package truth here
  - no project or order execution ruling may be materialized through this carrier

## H. Private Status / Explanation / Handoff Carrier Truth

- The profile-side private status family remains a derived server-side read model and must not be backed by a second summary table.
- Current canonical inputs for the derived private carrier are:
  - current organization scope
  - current credit-constraint posture row
  - current deposit posture row
  - current transaction-guarantee posture row
  - server-owned explanation catalog
  - server-owned handoff mapping
  - server-owned dependency reference mapping
- Explanation, handoff, and dependency reference copy may remain server-owned catalog-like truth in either:
  - registered constant lookup tables
  - `config_entries`
- Current hard rules:
  - `我的信用与约束` is only a bounded entry direction reference
  - no second private summary table is approved in this round
  - no runtime final IA truth is approved in this round

## I. V2.0 Split Truth Rules

- `V2.0 paid membership` backend truth continues to solve only:
  - commercial entitlement truth
  - rate-band truth
  - quota truth
  - upgrade-guidance source truth
- `V2.1` backend truth continues to solve only:
  - trade constraint posture truth
  - performance constraint posture truth
  - deposit posture truth
  - transaction-guarantee posture truth
- Current hard rules:
  - `membershipTier` must not be reused as trade-eligibility truth
  - Package 1 `membershipStatus` must not be reused as deposit-paid truth
  - membership entitlement truth must not be reused as transaction-guarantee-active truth

## J. V2.2 Dependency Truth Rules

- All real funds actions remain marked only as:
  - `requires V2.2 payment/billing package dependency`
- Dependency reference truth may carry only:
  - dependency family key
  - dependency required flag
  - dependency explanation key
  - dependency handoff key
- This backend-truth package must not turn dependency truth into:
  - payment execution truth
  - billing execution truth
  - settlement execution truth
  - funds-movement truth

## K. Truth-owner Rules

- `Server` remains the only truth owner for all `V2.1` families in this package.
- `profile` remains:
  - entry owner only
  - not truth owner
- `BFF` must not own:
  - credit truth
  - deposit truth
  - transaction-guarantee truth
  - dependency reference truth
- Existing `blacklist / whitelist / permanent-ban` material may only be cited as:
  - constraint-reference material
  - governance-boundary material
  - not current `V2.1` package truth itself

## L. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a trade-operations console
  - a governance console
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `我的项目` remains the private project-asset and progression carrier.
- Public trade remains the carrier for trade objects and main trade progression.
- This package must not swallow:
  - `我的项目`
  - public trade mainline
  - admin governance

## M. Retained No-Go

- Current `No-Go` remains:
  - concrete amount truth
  - concrete penalty / compensation amount truth
  - actual funds freeze / refund / collection / settlement truth
  - billing / invoice / settlement truth
  - risk-scoring-engine truth
  - dispute-detail truth
  - admin console truth
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## N. Formal Conclusion

- `V2.1 信用 / 保证金 / 交易保障 backend truth freeze 已完成`
- `当前可进入 BFF-surface judgment`
- This addendum does not mean:
  - BFF ready
  - implementation ready
  - payment ready
  - launch ready

## O. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.1 信用 / 保证金 / 交易保障 BFF-surface judgment》`

---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated L2 contract family for `我的楼 V2.1 信用 / 保证金 / 交易保障`, including only the bounded app-facing status, explanation, handoff, and dependency contract families without widening into runtime funds execution, billing, governance-console detail, or implementation unlock.
layer: L2 Contracts
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
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md
  - docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
---

# 我的楼 V2.1 信用 / 保证金 / 交易保障 Contracts Addendum

## A. Current Object

- This addendum applies only to the first dedicated `L2` contract package for:
  - `我的楼 V2.1 信用 / 保证金 / 交易保障`
  - bounded private `status / explanation / handoff` visibility
  - bounded credit-constraint status projection
  - bounded deposit requirement / eligibility / restriction / status projection
  - bounded transaction-guarantee eligibility / restriction / handoff projection
- This addendum does not by itself:
  - unlock backend truth freeze
  - unlock BFF surface freeze
  - unlock frontend surface freeze
  - unlock implementation
  - freeze runtime payment, billing, or settlement execution
  - freeze dispute or governance-console operation contracts

## B. Current Contract-layer Meaning

- This contract package freezes only:
  - `rule layer`
  - `status layer`
  - `explanation layer`
  - `handoff layer`
  - `dependency layer`
- This contract package must not freeze:
  - runtime funds execution
  - runtime payment / billing / settlement
  - governance console detail
  - dispute adjudication detail
  - implementation unlock
- Flutter App paths remain under:
  - `/api/app/*`
- This contract package must not create:
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - bare `/deposit/*`
  - bare `/guarantee/*`
  - bare `/dispute/*`
- The minimum app-facing path family is frozen under:
  - `/api/app/profile/credit-and-constraints/*`
- Current round approves no write command for:
  - deposit payment
  - deposit refund
  - penalty execution
  - compensation execution
  - settlement execution
  - dispute submission or adjudication

## C. Allowed Contract Families

- Current bounded app-facing path matrix is frozen as:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- This contract package freezes the following object families only:
  - bounded private status summary contract
  - credit constraint status contract
  - deposit requirement / eligibility / restriction / status contract
  - transaction guarantee eligibility / restriction / handoff contract
  - `V2.2` dependency reference contract
- App-facing responses in this package must preserve:
  - clear separation between `creditConstraint`, `deposit`, `transactionGuarantee`, and `handoff`
  - clear separation between status, explanation, and dependency reference
  - explicit `blocked / limited / advisory / handoff-required` meaning where applicable
- This package must not overload:
  - `membershipStatus`
  - `certificationStatus`
  - organization role fields
  with `V2.1` credit / deposit / guarantee semantics.

## D. Credit Constraint Contract

- The credit-constraint contract family must at minimum carry fields for:
  - credit-constraint status
  - performance-constraint status
  - restriction status
  - advisory status
  - execution-availability status
  - rule explanation
  - handoff indication
- The credit-constraint contract may express only:
  - current constraint posture
  - current blocking reasons
  - current advisory reasons
  - current next-step direction
- The credit-constraint contract must not freeze:
  - scoring-engine contract
  - algorithm-weight contract
  - automatic risk-execution contract
  - external trade-flow orchestration contract

## E. Deposit Requirement / Eligibility / Restriction / Status Contract

- The deposit contract family must at minimum carry fields for:
  - requirement status
  - eligibility status
  - restriction status
  - current deposit posture status
  - handoff indication
  - dependency note
- The deposit contract may express only:
  - whether deposit is currently required as a posture
  - whether current eligibility is satisfied
  - whether current restriction blocks next-step progression
  - whether handoff to another capability family is required
- The deposit contract must not freeze:
  - concrete amount
  - amount tier
  - amount formula
  - funds-freeze execution field
  - penalty execution field
  - compensation execution field
  - refund execution field
  - settlement execution field

## F. Transaction Guarantee Eligibility / Restriction / Handoff Contract

- The transaction-guarantee contract family must at minimum carry fields for:
  - eligibility status
  - restriction status
  - explanation
  - handoff indication
  - dependency note
- The transaction-guarantee contract may express only:
  - current guarantee posture
  - current guarantee restriction
  - current rule explanation
  - current next-step direction
- The transaction-guarantee contract must not freeze:
  - dispute-detail contract
  - admin adjudication console contract
  - governance-operation contract
  - project or order execution-ruling contract

## G. Private Status / Explanation / Handoff Contract

- The bounded private entry-facing contract family may carry only:
  - status summary
  - explanation summary
  - primary handoff direction
  - dependency reference
- The current bounded entry-direction reference remains:
  - `我的信用与约束`
- This contract package must not freeze:
  - runtime final IA truth
  - second-dashboard payload
  - operations-console payload
  - full project-trade cockpit payload

## H. V2.0 Split Contract Rules

- `V2.0 paid membership` contract family continues to solve only:
  - commercial entitlements
  - rate band
  - quota
  - upgrade guidance
- `V2.1` contract family continues to solve only:
  - trade constraint posture
  - performance constraint posture
  - deposit posture
  - transaction-guarantee posture
- This contract package continues to forbid:
  - `membershipTier = trade eligibility`
  - `membershipStatus = deposit paid`
  - `membership entitlement = transaction guarantee active`

## I. V2.2 Dependency Contract Rules

- All real funds actions remain marked only as:
  - `requires V2.2 payment/billing package dependency`
- The dependency contract may carry only:
  - dependency required flag
  - dependency family key
  - dependency explanation
  - dependency handoff target
- This contract package must not turn dependency contract into:
  - payment execution contract
  - billing execution contract
  - settlement execution contract
  - funds-movement contract

## J. Truth-owner Contract Rules

- Entry owner may remain:
  - `我的楼 / profile`
- Truth owner does not automatically move to:
  - `profile`
- If future `信用 / 保证金 / 交易保障` truth exists, it must remain:
  - `Server`-owned by the corresponding business family
- `BFF` must not own:
  - credit truth
  - deposit truth
  - transaction-guarantee truth
- Existing `blacklist / whitelist / permanent-ban` material may only be cited as:
  - constraint-reference material
  - governance-boundary material
  - not current `V2.1` package truth itself

## K. Drift Guard

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

## L. Retained No-Go

- Current `No-Go` remains:
  - concrete amount contract
  - concrete penalty / compensation amount contract
  - actual funds freeze / refund / collection / settlement contract
  - billing / invoice / settlement contract
  - risk-scoring-engine contract
  - dispute-detail contract
  - admin console contract
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## M. Formal Conclusion

- `V2.1 信用 / 保证金 / 交易保障 contracts freeze 已完成`
- `当前可进入 backend-truth judgment`
- This addendum does not mean:
  - backend ready
  - implementation ready
  - payment ready
  - launch ready

## N. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.1 信用 / 保证金 / 交易保障 backend-truth judgment》`

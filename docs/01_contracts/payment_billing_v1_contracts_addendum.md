---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated L2 contract family for `我的楼 V2.2 支付 / 账单`, including only bounded payment-status, billing-reference, handoff, explanation, and dependency contracts without widening into payment execution, settlement, clearing, invoice or tax full systems, finance-admin detail, or implementation unlock.
layer: L2 Contracts
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_rules_freeze_judgment_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_contracts_judgment_addendum.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
---

# 我的楼 V2.2 支付 / 账单 Contracts Addendum

## A. Current Object

- This addendum applies only to the first dedicated `L2` contract package for:
  - `我的楼 V2.2 支付 / 账单`
  - bounded private `status / explanation / handoff / dependency-reference` visibility
  - bounded payment-status projection
  - bounded billing-reference projection
  - bounded payment handoff projection
- This addendum does not by itself:
  - unlock backend truth freeze
  - unlock BFF surface freeze
  - unlock frontend surface freeze
  - unlock implementation
  - freeze payment execution, settlement, clearing, or finance-admin contracts

## B. Current Contract-layer Meaning

- This contract package freezes only:
  - `rule layer`
  - `status layer`
  - `explanation layer`
  - `handoff layer`
  - `dependency layer`
- This contract package must not freeze:
  - payment execution
  - runtime payment / billing / settlement
  - clearing
  - tax / invoice full system
  - finance-admin detail
  - implementation unlock
- Flutter App paths remain under:
  - `/api/app/*`
- The minimum app-facing path family is frozen under:
  - `/api/app/profile/payment-and-billing-status/*`

## C. Allowed Contract Families

- Current bounded app-facing path matrix is frozen as:
  - `GET /api/app/profile/payment-and-billing-status/status`
  - `GET /api/app/profile/payment-and-billing-status/explanation`
  - `GET /api/app/profile/payment-and-billing-status/handoff`
- This contract package freezes the following object families only:
  - payment-status contract
  - billing-reference contract
  - payment handoff contract
  - payment / billing explanation contract
  - settlement / clearing / tax / finance-admin dependency contract
- App-facing responses in this package must preserve:
  - clear separation between `paymentStatus`, `billingReference`, `handoff`, and `dependency`
  - clear separation between status, explanation, and handoff
  - explicit `pending / unavailable / handoff-required / reference-visible / reference-unavailable` meaning where applicable

## D. Payment-status Contract

- The payment-status contract family must at minimum carry fields for:
  - `paymentStatus`
  - `paymentAvailabilityStatus`
  - `paymentHandoffKey`
  - `paymentExplanationKey`
  - `paymentDependencyKey`
  - `updatedAt`
- The payment-status contract may express only:
  - current payment-status boundary
  - current unavailable or pending posture
  - current next-step direction
  - current dependency-required meaning
- The payment-status contract must not freeze:
  - payment execution result
  - funds movement result
  - payment ledger detail
  - settlement result

## E. Billing-reference Contract

- The billing-reference contract family must at minimum carry fields for:
  - `billingReferenceStatus`
  - `billingReferenceCode`
  - `billingReferenceVisibilityStatus`
  - `billingExplanationKey`
  - `billingHandoffKey`
  - `billingDependencyKey`
  - `updatedAt`
- The billing-reference contract may express only:
  - whether billing reference currently exists
  - whether billing reference is currently visible
  - whether billing reference requires handoff to another family
- The billing-reference contract must not freeze:
  - full billing workflow
  - invoice workflow
  - tax-compliance workflow
  - settlement accounting workflow

## F. Payment Handoff Contract

- The payment handoff contract family must at minimum carry fields for:
  - `handoffStatus`
  - `handoffTargetFamily`
  - `handoffExplanationKey`
  - `dependencyRequired`
  - `updatedAt`
- The payment handoff contract may express only:
  - current handoff posture
  - current handoff target
  - why current package cannot continue locally
- The payment handoff contract must not freeze:
  - order orchestration contract
  - payment execution contract
  - finance backoffice operation flow

## G. Payment / Billing Explanation Contract

- The payment / billing explanation contract family may carry only:
  - `paymentExplanation`
  - `billingExplanation`
  - `dependencyExplanation`
  - `disclaimer`
- This explanation contract may express only:
  - current rule explanation
  - current status explanation
  - current handoff explanation
  - current dependency explanation
- This explanation contract must not freeze:
  - runtime price commitment
  - tax-compliance commitment
  - finance-admin decision flow

## H. Dependency Contract Rules

- All bigger finance scope remains marked only as:
  - `future dependency`
  - `strategic hold`
- The dependency contract family may carry only:
  - `dependencyRequired`
  - `dependencyFamilyKey`
  - `dependencyExplanationKey`
  - `dependencyHandoffKey`
- This package must not turn dependency contract into:
  - settlement execution contract
  - clearing execution contract
  - tax execution contract
  - finance-admin runtime contract

## I. Route Family Boundary

- The current route family is frozen as:
  - `/api/app/profile/payment-and-billing-status/*`
- This contract package must not create:
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - bare `/invoice/*`
- This route family must not drift into:
  - `messages`
  - `exhibition`
  - hidden building

## J. Truth-owner Contract Rules

- Entry owner may remain:
  - `我的楼 / profile`
- Truth owner does not automatically move to:
  - `profile`
  - `BFF`
- If future `payment / billing` truth exists, it must remain:
  - `Server`-owned by the corresponding business family
- This contract package must not treat:
  - `V2.1 dependency reference`
  - `payment pre-embed reserve`
  as current `V2.2` execution truth

## K. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a finance backoffice
  - a governance console
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `V2.2` must not swallow:
  - `我的项目`
  - public trade mainline
  - `V2.3` private operating-system regrouping

## L. Retained No-Go

- Current `No-Go` remains:
  - payment execution contract
  - settlement contract
  - clearing contract
  - invoice / tax full contract
  - finance-admin contract
  - dispute / admin governance contract
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## M. Formal Conclusion

- `V2.2 支付 / 账单 contracts freeze 已完成`
- `当前可进入 backend-truth judgment`
- This addendum does not mean:
  - backend ready
  - implementation ready
  - payment ready
  - launch ready

## N. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.2 支付 / 账单 backend-truth judgment》`

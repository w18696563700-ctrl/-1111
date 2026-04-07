---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated L3 backend truth family for `我的楼 V2.2 支付 / 账单`, including only bounded payment-status, billing-reference, handoff, explanation, and dependency truths without widening into payment execution, settlement, clearing, tax or invoice full systems, finance-admin detail, or implementation unlock.
layer: L3 Backend
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_v22_payment_billing_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_contracts_judgment_addendum.md
  - docs/01_contracts/payment_billing_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_backend_truth_judgment_addendum.md
---

# 我的楼 V2.2 支付 / 账单 Backend Truth Addendum

## A. Current Object

- This addendum applies only to the first dedicated `docs/02_backend` package for:
  - `我的楼 V2.2 支付 / 账单`
  - bounded payment-status truth
  - bounded billing-reference truth
  - bounded payment handoff truth
  - bounded payment / billing explanation truth
  - bounded dependency-reference truth
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock BFF surface freeze
  - unlock frontend surface freeze
  - unlock implementation
  - approve runtime payment execution, settlement, clearing, or finance-admin truth

## B. Current Backend-truth Meaning

- This backend-truth package freezes only:
  - `rule layer`
  - `status layer`
  - `reference layer`
  - `explanation layer`
  - `handoff layer`
  - `dependency layer`
- This backend-truth package must not freeze:
  - payment execution truth
  - settlement truth
  - clearing truth
  - tax / invoice full truth
  - finance-admin truth
  - implementation unlock

## C. Allowed Backend Truth Families

- Current package freezes only the following bounded truth families:
  - payment-status truth
  - billing-reference truth
  - payment handoff truth
  - payment / billing explanation truth
  - dependency-reference truth
- Current package must not freeze:
  - payment execution truth
  - settlement truth
  - clearing truth
  - finance backoffice truth
  - governance-console truth

## D. Allowed Backend Carriers

- Current backend carriers are frozen only as:
  - status carriers
  - reference carriers
  - explanation carriers
  - handoff carriers
  - dependency carriers
- Current backend carriers must not become:
  - funds execution carriers
  - payment ledger carriers
  - settlement carriers
  - clearing carriers
  - tax / invoice full carriers
  - finance-admin carriers

## E. Payment-status Truth

- The payment-status truth family must at minimum carry:
  - `payment_status_code`
  - `payment_availability_code`
  - `payment_handoff_key`
  - `payment_explanation_key`
  - `payment_dependency_key`
  - `updated_at`
- The payment-status truth may express only:
  - current status boundary
  - current unavailable or pending posture
  - current dependency-required posture
- The payment-status truth must not express:
  - payment execution success truth
  - funds movement result truth
  - ledger truth

## F. Billing-reference Truth

- The billing-reference truth family must at minimum carry:
  - `billing_reference_status_code`
  - `billing_reference_code`
  - `billing_reference_visibility_code`
  - `billing_explanation_key`
  - `billing_handoff_key`
  - `billing_dependency_key`
  - `updated_at`
- The billing-reference truth may express only:
  - reference existence
  - reference visibility
  - reference handoff requirement
- The billing-reference truth must not express:
  - settlement accounting truth
  - invoice workflow truth
  - tax workflow truth

## G. Payment Handoff Truth

- The payment handoff truth family must at minimum carry:
  - `handoff_status_code`
  - `handoff_target_family`
  - `handoff_explanation_key`
  - `dependency_required`
  - `updated_at`
- The payment handoff truth may express only:
  - current handoff posture
  - current bounded next-step target
  - why current package cannot continue locally
- The payment handoff truth must not express:
  - order orchestration truth
  - payment execution truth
  - finance-admin operation truth

## H. Payment / Billing Explanation Truth

- The explanation truth family may carry only:
  - `payment_explanation_key`
  - `billing_explanation_key`
  - `dependency_explanation_key`
  - `disclaimer_key`
- The explanation truth may express only:
  - rule explanation
  - status explanation
  - handoff explanation
  - dependency explanation
- The explanation truth must not express:
  - runtime price commitment truth
  - tax-compliance commitment truth
  - finance-admin decision truth

## I. Dependency-reference Truth

- All bigger finance scope remains marked only as:
  - `future dependency`
  - `strategic hold`
- The dependency-reference truth may carry only:
  - `dependency_required`
  - `dependency_family_key`
  - `dependency_explanation_key`
  - `dependency_handoff_key`
- This truth family must not turn into:
  - settlement execution truth
  - clearing execution truth
  - tax execution truth
  - finance-admin runtime truth

## J. V2.1 Split Truth Rules

- `V2.1` 继续只承接：
  - posture
  - status
  - explanation
  - handoff
  - dependency reference
- `V2.2` 继续只承接：
  - payment-status truth
  - billing-reference truth
  - payment handoff truth
  - payment / billing explanation truth
  - dependency-reference truth
- 当前继续明确禁止：
  - `V2.1 dependency reference = V2.2 execution truth`
  - `V2.1 deposit posture = V2.2 payment success`
  - `V2.1 guarantee posture = V2.2 billing settled`

## K. V2.3 Boundary / Dependency Truth Rules

- `V2.2` 当前不得吞并：
  - `V2.3` 私域操作系统整理
  - setting / profile regrouping
  - IA systematization truth
- `V2.3` 未来如果存在：
  - 也不得被误写成 payment / billing runtime truth
- 当前 truth 层只允许表达：
  - boundary split
  - dependency hold

## L. Truth-owner Rules

- Page owner or entry owner may remain:
  - `我的楼 / profile`
- Truth owner does not automatically move to:
  - `profile`
  - `BFF`
- If future `payment / billing` truth exists, it must remain:
  - `Server`-owned by the corresponding business family
- Existing `payment pre-embed reserve` must not be treated as:
  - current `V2.2` execution truth

## M. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a finance backoffice
  - a governance console
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `V2.2` must not swallow:
  - `我的项目`
  - public trade mainline
  - `V2.3` private operating-system regrouping

## N. Retained No-Go

- Current `No-Go` remains:
  - payment execution truth
  - settlement / clearing truth
  - invoice / tax full truth
  - finance backoffice truth
  - dispute / admin governance truth
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock
  - runtime implementation

## O. Formal Conclusion

- `V2.2 支付 / 账单 backend truth freeze 已完成`
- `当前可进入 BFF-surface judgment`
- This addendum does not mean:
  - BFF ready
  - implementation ready
  - payment ready
  - launch ready

## P. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.2 支付 / 账单 BFF-surface judgment》`

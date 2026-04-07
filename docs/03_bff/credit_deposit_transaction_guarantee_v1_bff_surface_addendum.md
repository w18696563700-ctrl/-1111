---
owner: 总控文书冻结
status: frozen
purpose: Freeze the BFF-side app-facing surface for `我的楼 V2.1 信用 / 保证金 / 交易保障` so the current package may expose only bounded read-only `status / explanation / handoff / dependency-reference` shaping under `profile`, without widening into payment, billing, settlement, dispute, admin-console, or implementation unlock.
layer: L3 BFF
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_contracts_judgment_addendum.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_backend_truth_judgment_addendum.md
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_bff_surface_judgment_addendum.md
---

# 我的楼 V2.1 信用 / 保证金 / 交易保障 BFF Surface Addendum

## A. Current Object

- This addendum applies only to the first dedicated `docs/03_bff` package for:
  - `我的楼 V2.1 信用 / 保证金 / 交易保障`
  - bounded private `status / explanation / handoff` shaping
  - bounded credit-constraint status shaping
  - bounded deposit posture shaping
  - bounded transaction-guarantee posture shaping
  - bounded `V2.2` dependency-reference shaping
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock frontend surface freeze
  - unlock implementation
  - approve runtime payment, billing, settlement, or funds execution
  - approve dispute-detail or admin-console surface

## B. Current BFF-surface Meaning

- This BFF-surface package freezes only:
  - read-only app-facing shaping layer
  - normalize layer
  - controlled error-family layer
  - explanation projection layer
  - handoff projection layer
  - dependency-reference projection layer
- `BFF` in this package may do only:
  - forward
  - normalize
  - shape
  - bounded profile summary projection
- `BFF` in this package must not own:
  - credit truth
  - deposit truth
  - transaction-guarantee truth
  - payment truth
  - billing truth
  - settlement truth
- This addendum must not be read as:
  - approval for runtime funds execution
  - approval for runtime payment / billing / settlement surface
  - approval for governance-console detail
  - approval for implementation unlock

## C. Allowed BFF Surface Families

- Current package freezes only the following bounded app-facing surface families:
  - private `status / explanation / handoff` shaping family
  - credit-constraint status shaping family
  - deposit `requirement / eligibility / restriction / status` shaping family
  - transaction-guarantee `eligibility / restriction / handoff` shaping family
  - `V2.2` dependency reference shaping family
- Current shell / profile side BFF surface may project only:
  - bounded private status summary
  - explanation projection
  - handoff projection
  - dependency reference projection
- Current package must not shape:
  - payment objects
  - billing objects
  - settlement objects
  - funds execution objects
  - dispute objects
  - admin console objects

## D. Allowed Route Family

- The current route family is frozen as:
  - `/api/app/profile/credit-and-constraints/*`
- The current read paths are frozen as:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- Current route rules:
  - only read paths are approved in this round
  - no write commands are approved in this round
  - no command-side execution handoff is approved in this round
- This addendum must not create:
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - bare `/deposit/*`
  - bare `/guarantee/*`
- This route family must not drift into:
  - `messages`
  - `exhibition`
  - hidden building

## E. Credit Constraint Shaping

- `GET /api/app/profile/credit-and-constraints/status` may shape only the minimum credit-constraint read model:
  - `creditConstraintStatus`
  - `performanceConstraintStatus`
  - `executionAvailabilityStatus`
  - `restrictionReasonCode`
  - `advisoryReasonCode`
  - `updatedAt`
- Current shaping rules:
  - values are app-facing normalized projections only
  - values must come from `Server`-owned posture truth only
  - no scoring-engine output may be projected as current package truth
  - no automatic risk-execution result may be projected as current package truth

## F. Deposit Requirement / Eligibility / Restriction / Status Shaping

- `GET /api/app/profile/credit-and-constraints/status` may shape only the minimum deposit read model:
  - `depositRequirementStatus`
  - `depositEligibilityStatus`
  - `depositRestrictionStatus`
  - `depositPostureStatus`
  - `depositHandoffKey`
  - `depositDependencyKey`
  - `updatedAt`
- Current shaping rules:
  - deposit shaping remains posture-only projection
  - no concrete amount may be projected in this package
  - no amount formula may be projected in this package
  - no freeze / penalty / compensation / refund / settlement execution field may be projected in this package

## G. Transaction Guarantee Eligibility / Restriction / Handoff Shaping

- `GET /api/app/profile/credit-and-constraints/status` and `GET /api/app/profile/credit-and-constraints/handoff` may shape only the minimum transaction-guarantee read model:
  - `transactionGuaranteeEligibilityStatus`
  - `transactionGuaranteeRestrictionStatus`
  - `transactionGuaranteeExplanationKey`
  - `transactionGuaranteeHandoffKey`
  - `transactionGuaranteeDependencyKey`
  - `updatedAt`
- Current shaping rules:
  - guarantee shaping remains posture-only projection
  - no dispute-detail payload may be shaped in this package
  - no admin adjudication operation may be shaped in this package
  - no project or order execution ruling may be shaped in this package

## H. Private Status / Explanation / Handoff Projection

- `GET /api/app/profile/credit-and-constraints/status` may project only the minimum bounded private summary:
  - `entryKey`
  - `summaryStatus`
  - `creditConstraintStatus`
  - `depositPostureStatus`
  - `transactionGuaranteeEligibilityStatus`
  - `updatedAt`
- `GET /api/app/profile/credit-and-constraints/explanation` may project only:
  - `creditExplanation`
  - `depositExplanation`
  - `transactionGuaranteeExplanation`
  - `dependencyExplanation`
  - `disclaimer`
- `GET /api/app/profile/credit-and-constraints/handoff` may project only:
  - `creditHandoff`
  - `depositHandoff`
  - `transactionGuaranteeHandoff`
  - `dependencyHandoff`
- Current hard rules:
  - `我的信用与约束` remains only a bounded entry direction reference
  - no runtime final IA truth is approved in this round
  - no second dashboard payload is approved in this round

## I. V2.2 Dependency Reference Shaping

- All real funds actions remain expressed only as:
  - `requires V2.2 payment/billing package dependency`
- Current dependency reference shaping may project only:
  - `dependencyFamilyKey`
  - `dependencyRequired`
  - `dependencyExplanationKey`
  - `dependencyHandoffKey`
- This BFF-surface package must not turn dependency reference shaping into:
  - payment execution shaping
  - billing execution shaping
  - settlement execution shaping
  - funds-movement shaping

## J. Controlled Error Family

- The current controlled error family for this package is frozen as:
  - `CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE`
  - `CREDIT_CONSTRAINT_STATUS_UNAVAILABLE`
  - `DEPOSIT_POSTURE_UNAVAILABLE`
  - `TRANSACTION_GUARANTEE_POSTURE_UNAVAILABLE`
  - `DEPENDENCY_REFERENCE_UNAVAILABLE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
- `BFF` may only:
  - normalize these failures
  - preserve their app-facing meaning
  - shape them into bounded unavailable or permission-insufficient output
- `BFF` must not:
  - hide route drift behind fake success
  - rewrite unavailable as fake funds-ready data
  - invent payment / billing / settlement success semantics

## K. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a trade-operations console
  - a governance console
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `我的项目` remains the private project-asset and progression carrier.
- Public trade remains the carrier for trade objects and main trade progression.
- `我的信用与约束` remains:
  - bounded entry direction only
  - not runtime final IA truth

## L. Retained No-Go

- Current `No-Go` remains:
  - concrete amount surface
  - payment / billing / settlement runtime surface
  - funds execution surface
  - dispute-detail surface
  - admin console surface
  - frontend surface freeze
  - implementation unlock
  - runtime implementation
- Current round also does not approve:
  - second-shell dashboard payload
  - payment / billing bare routes
  - governance-console route families

## M. Formal Conclusion

- `V2.1 信用 / 保证金 / 交易保障 BFF surface freeze 已完成`
- `当前可进入 frontend-surface judgment`
- This addendum does not mean:
  - frontend ready
  - implementation ready
  - payment ready
  - launch ready

## N. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.1 信用 / 保证金 / 交易保障 frontend-surface judgment》`

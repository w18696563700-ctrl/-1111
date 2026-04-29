---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated L3 BFF surface for `我的楼 V2.2 支付 / 账单`, including only bounded payment-status, billing-reference, explanation, handoff, and dependency-reference shaping without widening into payment execution, settlement, clearing, finance-admin, or implementation unlock.
layer: L3 BFF
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_v22_payment_billing_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_contracts_judgment_addendum.md
  - docs/01_contracts/payment_billing_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_backend_truth_judgment_addendum.md
  - docs/02_backend/payment_billing_v1_backend_truth_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bff_surface_judgment_addendum.md
---

## Pricing Mainline Override Note

本文件继续保留 `我的楼 V2.2 支付 / 账单` 的只读 `status / explanation / handoff / dependency-reference` BFF 边界。

但自 [platform_pricing_bff_surface_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/platform_pricing_bff_surface_master_v1.md) 生效后，本文件不得再被误读为当前展览收费执行主线的 `BFF` authority。

当前正式解释固定如下：

1. 本文件只承接 profile 读态 package
2. 本文件不是当前 `200 / 4000 / deal confirmation` 收费主线 owner
3. 当前平台收费执行主线的 `BFF` authority 仅以 `platform_pricing_bff_surface_master_v1.md` 为准

# 我的楼 V2.2 支付 / 账单 BFF Surface Addendum

## A. Current Object

- This addendum applies only to the first dedicated `docs/03_bff` package for:
  - `我的楼 V2.2 支付 / 账单`
  - bounded private `status / explanation / handoff / dependency-reference` shaping
  - bounded payment-status shaping
  - bounded billing-reference shaping
  - bounded payment handoff shaping
  - bounded payment / billing explanation shaping
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock frontend surface freeze
  - unlock implementation
  - approve runtime payment execution, settlement, clearing, or finance-admin surface

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
  - payment truth
  - billing truth
  - settlement truth
  - finance-admin truth
- This addendum must not be read as:
  - approval for runtime payment execution
  - approval for settlement or clearing surface
  - approval for finance-admin detail
  - approval for implementation unlock

## C. Allowed BFF Surface Families

- Current package freezes only the following bounded app-facing surface families:
  - private `status / explanation / handoff / dependency-reference` shaping family
  - payment-status shaping family
  - billing-reference shaping family
  - payment handoff shaping family
  - payment / billing explanation shaping family
- Current shell / profile side BFF surface may project only:
  - bounded private status summary
  - explanation projection
  - handoff projection
  - dependency reference projection

## D. Allowed Route Family

- The current route family is frozen as:
  - `/api/app/profile/payment-and-billing-status/*`
- The current read paths are frozen as:
  - `GET /api/app/profile/payment-and-billing-status/status`
  - `GET /api/app/profile/payment-and-billing-status/explanation`
  - `GET /api/app/profile/payment-and-billing-status/handoff`
- Current route rules:
  - only read paths are approved in this round
  - no write commands are approved in this round
  - no command-side execution handoff is approved in this round
- This addendum must not create:
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - bare `/invoice/*`
- This route family must not drift into:
  - `messages`
  - `exhibition`
  - hidden building

## E. Payment-status Shaping

- `GET /api/app/profile/payment-and-billing-status/status` may shape only the minimum payment-status read model:
  - `paymentStatus`
  - `paymentAvailabilityStatus`
  - `paymentHandoffKey`
  - `paymentExplanationKey`
  - `paymentDependencyKey`
  - `updatedAt`
- Current shaping rules:
  - values are app-facing normalized projections only
  - values must come from `Server`-owned boundary truth only
  - no payment execution success may be projected as current package truth
  - no funds movement result may be projected as current package truth

## F. Billing-reference Shaping

- `GET /api/app/profile/payment-and-billing-status/status` may shape only the minimum billing-reference read model:
  - `billingReferenceStatus`
  - `billingReferenceCode`
  - `billingReferenceVisibilityStatus`
  - `billingExplanationKey`
  - `billingHandoffKey`
  - `billingDependencyKey`
  - `updatedAt`
- Current shaping rules:
  - billing-reference shaping remains boundary-only projection
  - no settlement detail may be projected in this package
  - no invoice or tax full field may be projected in this package
  - no finance-admin field may be projected in this package

## G. Payment Handoff Shaping

- `GET /api/app/profile/payment-and-billing-status/handoff` may shape only the minimum payment handoff read model:
  - `handoffStatus`
  - `handoffTargetFamily`
  - `handoffExplanationKey`
  - `dependencyRequired`
  - `updatedAt`
- Current shaping rules:
  - handoff shaping remains bounded next-step projection
  - no order orchestration may be shaped in this package
  - no payment execution command may be shaped in this package
  - no finance-admin operation may be shaped in this package

## H. Private Status / Explanation / Handoff Projection

- `GET /api/app/profile/payment-and-billing-status/status` may project only the minimum bounded private summary:
  - `entryKey`
  - `summaryStatus`
  - `paymentStatus`
  - `billingReferenceStatus`
  - `updatedAt`
- `GET /api/app/profile/payment-and-billing-status/explanation` may project only:
  - `paymentExplanation`
  - `billingExplanation`
  - `dependencyExplanation`
  - `disclaimer`
- `GET /api/app/profile/payment-and-billing-status/handoff` may project only:
  - `paymentHandoff`
  - `billingHandoff`
  - `dependencyHandoff`
- Current hard rules:
  - `支付与账单状态 / 支付与账单处理` remains only a bounded entry direction reference
  - no runtime final IA truth is approved in this round
  - no second dashboard payload is approved in this round

## I. Dependency Reference Shaping

- All bigger finance scope remains expressed only as:
  - `future dependency`
  - `strategic hold`
- Current dependency reference shaping may project only:
  - `dependencyFamilyKey`
  - `dependencyRequired`
  - `dependencyExplanationKey`
  - `dependencyHandoffKey`
- This BFF-surface package must not turn dependency reference shaping into:
  - payment execution shaping
  - settlement execution shaping
  - clearing execution shaping
  - finance-admin execution shaping

## J. Controlled Error Family

- The current controlled error family for this package is frozen as:
  - `PAYMENT_AND_BILLING_STATUS_ROUTE_UNAVAILABLE`
  - `PAYMENT_STATUS_UNAVAILABLE`
  - `BILLING_REFERENCE_UNAVAILABLE`
  - `PAYMENT_HANDOFF_UNAVAILABLE`
  - `DEPENDENCY_REFERENCE_UNAVAILABLE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
- `BFF` may only:
  - normalize these failures
  - preserve their app-facing meaning
  - shape them into bounded unavailable or permission-insufficient output
- `BFF` must not:
  - hide route drift behind fake success
  - invent payment-ready or billing-ready semantics
  - rewrite dependency-required into funds-ready truth

## K. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a finance backoffice
  - a governance console
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `支付与账单状态 / 支付与账单处理` remains:
  - bounded entry direction only
  - not runtime final IA truth

## L. Retained No-Go

- Current `No-Go` remains:
  - payment execution truth / surface
  - settlement / clearing
  - invoice / tax full system
  - finance backoffice
  - dispute-detail surface
  - admin console surface
  - frontend surface freeze
  - implementation unlock
  - runtime implementation
- Current round also does not approve:
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - bare `/invoice/*`

## M. Formal Conclusion

- `V2.2 支付 / 账单 BFF surface freeze 已完成`
- `当前可进入 frontend-surface judgment`
- This addendum does not mean:
  - frontend ready
  - implementation ready
  - payment ready
  - launch ready

## N. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.2 支付 / 账单 frontend-surface judgment》`

---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation unlock that allows the current platform
  pricing rebaseline to enter future real implementation within the admitted
  `200 publish gate / 4000 bid gate / deal confirmation / message carry`
  corridor while preserving the five-building shell, the single-channel
  `Flutter -> BFF -> Server` architecture, and all retained non-goals outside
  the approved pricing scope.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_companion_patch_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - docs/00_ssot/platform_pricing_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/platform_pricing_runtime_drift_register_v1.md
  - docs/00_ssot/platform_pricing_rebaseline_gate_review_conclusion_addendum.md
---

# 《平台收费规则 implementation unlock addendum》

## Scope

- This addendum applies only to the current bounded object:
  - `平台收费重基线 implementation packages`
- It freezes only:
  - the current bounded implementation unlock decision
  - the passed / failed / retained veto gates for entering future
    implementation dispatch send
  - the currently approved implementation scope
  - the currently retained non-goals
- It does not by itself:
  - issue real implementation dispatch
  - approve direct code implementation in the current turn
  - approve cloud write
  - approve deploy / integration / release
  - approve runtime acceptance

## Current Active Object

- Current active bounded object:
  - `platform pricing rebaseline implementation packages`

## Passed Gates

- Current pricing master is frozen.
- Current `L2 contracts` master plus companion patch are frozen.
- Current `L3 backend truth` plus persistence / migration / audit companion
  truth are frozen.
- Current `L4 BFF surface` is frozen.
- Current `L5 Flutter consumption` is frozen.
- Current implementation unlock assessment is frozen.
- Current runtime drift register is frozen.
- Current Day 4 gate review conclusion is frozen.
- Current conclusion already admits:
  - `Go for implementation dispatch bundle authoring only`

## Failed Gates That Remain Non-blocking For This Unlock

- Current code implementation reality is still absent.
- Current ali-cloud runtime has not been revalidated against the new pricing
  mainline.
- Current result-verification receipt does not yet exist.
- Current dispatch-send stage gate has not yet been raised.

These failures remain non-blocking for this unlock because the current addendum
only decides whether the root guardrail may be narrowed for the current bounded
pricing object. It does not itself start execution.

## Retained Veto Gates

- no sixth shell building
- no new bottom tab
- `Flutter App` still may not call `Server` directly
- `BFF` must not own pricing truth or a second state machine
- `Server` remains the only pricing truth owner
- no bare `payment / wallet / billing / settlement / invoice` runtime opening
- no membership direct purchase runtime
- no performance deposit / guarantee deposit runtime
- no second `trade-task` family revived as current authority
- no dual-track live runtime where old `3% / estimatedFeeAmount / inquiry-deposit`
  and new `200 / 4000 / deal confirmation` both claim authority
- no cloud write, deploy, restart, rollback, integration run, or release in the
  current authoring round

## Phase 0 Guardrail Revision

- The root baseline Phase 0 rule of `no trading flow implementation` remains
  true by default.
- The current forum board remains an approved bounded exception.
- The current `messages interaction center and bidder carry` package remains an
  approved bounded exception.
- A third bounded exception is now approved for:
  - `platform pricing rebaseline implementation packages`
- The pricing-related blanket veto is revised from:
  - `payment / billing / settlement remain root non-goals`
- To:
  - `payment / billing / settlement remain root non-goals by default`
- The current bounded pricing exception applies only after the current pricing
  docs chain is frozen and only within the admitted implementation scope below.
- The exception scope is limited to:
  - `project publish` pricing gate for `200 元项目真实性诚意金`
  - `bid submit` pricing gate for `4000 元竞标服务费预授权额度`
  - bounded `deal confirmation` and `platform service fee charge` realization
  - bounded `message interaction pricing carry` supplement
  - the matching `Server`, `BFF`, and Flutter implementation needed to support
    the approved surfaces above

## Current Implementation Scope

- Current implementation is allowed for:
  - Server pricing kernel and additive migration:
    - `apps/server/src/modules/p0_pay/**`
    - `apps/server/src/core/migrations/migrations.ts`
  - Server publish / bid / exit minimum corridor:
    - `apps/server/src/modules/project/project-write.service.ts`
    - `apps/server/src/modules/bid/**`
    - `apps/server/src/modules/bid_participation_request/**`
    - `apps/server/src/modules/project/project-exit-governance.service.ts`
  - BFF pricing transport and normalization:
    - `apps/bff/src/routes/exhibition_p0_pay/**`
    - bounded `apps/bff/src/routes/project/**`
    - bounded `apps/bff/src/routes/bid_participation_request/**`
    - bounded `apps/bff/src/routes/bid/**`
  - Flutter pricing consumption:
    - `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
    - `apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart`
    - `apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart`
    - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
    - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
    - bounded `project detail` read-only summary consumption
  - bounded message carry supplement only after upstream pricing truth is cut:
    - `apps/server/src/modules/message_interaction/**`
    - `apps/bff/src/routes/message_interaction/**`
- Current implementation is not allowed for:
  - `apps/mobile/lib/features/profile/**payment_billing**`
  - `apps/bff/src/routes/profile/**payment-billing-status**`
  - `apps/server/src/modules/payment_billing/**`
  - `apps/server/src/modules/credit_constraints/**`
  - any new generic `payment-center / wallet / billing-center` page or route

## Current Explicit Non-goals

- No generic payment runtime platform
- No billing center write chain
- No settlement / invoice / finance-admin runtime
- No membership direct purchase runtime
- No guarantee / performance deposit runtime
- No `trade-task` legacy runtime continuation as current pricing mainline
- No second pricing state machine in `BFF` or Flutter
- No cloud validation claim
- No release readiness claim

## Formal Conclusion

- Current formal conclusion:
  - bounded implementation unlock for `platform pricing rebaseline
    implementation packages` is now allowed within the frozen current boundary
  - the old blanket Phase 0 payment/trading veto no longer blocks this current
    bounded pricing object
  - all retained veto items above remain active
- Current meaning:
  - bounded pricing implementation unlock only
- Current non-approved meaning:
  - no direct implementation in the current turn
  - no real implementation dispatch send yet
  - no cloud write
  - no deploy / integration / release

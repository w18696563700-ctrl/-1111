---
owner: Codex 总控
status: draft
purpose: Freeze the dedicated backend truth, persistence, archive gating, and audit/evidence linkage for contract archive and mandatory fulfillment continuity under the current order-bound truth system.
layer: L3 Backend
---

# 合同归档与履约强制入链规则 V1 Backend Truth Addendum

## 1. Scope
- This addendum applies only to the third dedicated `docs/02_backend` package for:
  - order-bound contract archive truth
  - contract confirmation and amendment truth
  - milestone continuity truth
  - inspection continuity truth
  - archive-dependent downstream gating truth
  - audit and file-evidence linkage
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `apps/bff` aggregation specs
  - freeze a daily-progress persistence family
  - freeze a final archive-confirm persistence family
  - freeze an archive-export persistence family
  - reopen dispute-resolution governance or penalty logic

## 2. Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md)
  - [contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md)
  - [contract_phase3_decision_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_phase3_decision_addendum.md)
  - [inspection_phase3_decision_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/inspection_phase3_decision_addendum.md)
  - [order_completed_upstream_execution_binding_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/order_completed_upstream_execution_binding_addendum.md)
  - [service_boundaries.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/service_boundaries.md)
  - [db_schema.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/db_schema.md)
  - [audit_log_spec.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/audit_log_spec.md)

## 3. Addendum Role
- Current `L0` and `L2` documents have already frozen:
  - the minimum app-facing path matrix
  - object-level lifecycle boundaries
  - current error-code families
  - current audit minimums
- This addendum upgrades that package into a dedicated backend-truth package for:
  - which existing tables remain the only current persistence carriers
  - which lifecycle states are release-relevant
  - how contract archive and fulfillment proof must bind to file truth
  - how downstream archive-dependent release must be derived
- This addendum must not be read as:
  - approval for a second fulfillment workflow model
  - approval for multi-version contract history
  - approval for daily-progress or final archive runtime

## 4. Current Truth Ownership Freeze
- `Server` remains the only truth owner for:
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - contract archive readiness
  - downstream release eligibility for `Rating` and `Dispute`
  - audit attribution and evidence linkage
- `BFF` may:
  - shape current order, contract, milestone, and inspection reads
  - forward command requests
  - return controlled unavailable and invalid-state responses
- `BFF` must not:
  - own contract version truth
  - own fulfillment continuity truth
  - own archive-ready truth
  - own order-complete derivation truth
- `Admin` remains a consumer only and is not itself a truth owner in this package.

## 5. Canonical Persistence Binding
- This dedicated package adopts the following existing table family as the only current canonical persistence family:
  - `orders`
  - `contracts`
  - `contract_clauses`
  - `milestones`
  - `inspections`
  - `change_orders`
  - `ratings`
  - `disputes`
  - `evidences`
  - `file_assets`
  - `audit_logs`
- Current round does not approve new dedicated tables for:
  - `contract_versions`
  - `contract_confirmations`
  - `daily_progress_logs`
  - `acceptance_archives`
  - `archive_exports`
  - `rectification_items`
- Product wording may still refer to:
  - contract version
  - contract confirmation
  - daily progress
  - acceptance archive
  - archive export
- But current relational truth must remain bound to the existing table family above until a later dedicated freeze adds anything more.

## 6. Contract Archive Truth Freeze
- Current contract archive truth remains order-bound and contract-bound.
- The only current canonical carrier for contract business truth is:
  - `contracts`
- The only current canonical carriers for contract file-backed proof are:
  - `evidences`
  - `file_assets`
- Current package meaning:
  - a contract may have current file-backed proof through the shared `Evidence -> FileAsset` chain
  - contract archive truth is not a second document-management subsystem
  - contract archive truth is not a raw URL, `objectKey`, or frontend-local file reference
- Current round explicitly forbids:
  - a parallel `contract_files` truth family
  - a parallel `contract_versions` truth family
  - storing contract file truth only in client payload history

## 7. Contract State Responsibility Freeze
- `contracts.state` remains the only current contract lifecycle field.
- Its current lifecycle meaning remains:
  - `draft`
  - `pending_confirm`
  - `active`
  - `amended`
  - `archived`
- `contracts.amend_count` remains the only currently frozen persistence counter for amendment ceiling enforcement.
- Current hard rules:
  - `pending_confirm` means fulfillment cannot rely on confirmed cooperation truth yet
  - `active` and `amended` are the only current fulfillment-eligible contract states
  - `archived` remains outside the current first-round app-facing main loop
  - a second amendment round must not be synthesized outside `contracts.amend_count`

## 8. Contract-before-fulfillment Rule
- Current backend release rule is:
  - order-bound fulfillment continuity must not outrun effective contract confirmation
- Current backend implication is:
  - `milestone` continuation and archive-dependent downstream release must treat `contracts.state in (active, amended)` as the current minimum confirmed cooperation baseline
  - `contracts.state in (draft, pending_confirm)` must block any interpretation that the fulfillment chain is already safely confirmed
- This package does not reopen:
  - contract history
  - contract list
  - contract provider callbacks
  - legal review workflow

## 9. Milestone Continuity Truth Freeze
- `milestones` remains the only current canonical fulfillment-step truth carrier.
- `Milestone` remains:
  - order-bound
  - auditable
  - the immediate upstream anchor for `Inspection`
- Current lifecycle meaning remains:
  - `pending_submission`
  - `submitted`
  - `completed`
- Current hard rules:
  - milestone submit must stay order-bound
  - milestone truth must not be replaced by off-platform verbal progress
  - milestone completion remains downstream of valid inspection passing under the current execution binding
- This package does not approve:
  - a second milestone approval console
  - a milestone history center
  - a separate milestone continuity table

## 10. Inspection Continuity Truth Freeze
- `inspections` remains the only current canonical acceptance-side truth carrier.
- One current effective `Inspection` truth remains milestone-bound under the already frozen object decision set.
- Current lifecycle meaning remains:
  - `draft`
  - `submitted`
  - `rectification_required`
  - `rechecked`
  - `passed`
  - `archived`
- Current persistence counters already frozen in `db_schema.md` remain authoritative:
  - `inspections.recheck_count`
  - `inspections.rectification_count`
- Current hard rules:
  - rectification and recheck remain single-round only
  - final pass or archive remains `Server` truth only
  - no frontend, `BFF`, or admin read model may infer pass or close without `Server` state truth

## 11. Inspection-to-milestone-to-order Binding Freeze
- The current upstream execution binding remains:
  - `Inspection.passed -> Milestone.completed -> Order.completed`
- The unique internal execution owner for the passing branch remains the `Inspection` module, as already frozen.
- Current package meaning:
  - `Milestone.completed` and `Order.completed` are derived downstream truths, not separate app-facing commands
  - a valid inspection pass must synchronously evaluate milestone and order completion derivation in the same `Server` truth flow
- Current package explicitly forbids:
  - `POST /api/app/milestone/complete`
  - `POST /api/app/order/complete`
  - a second downstream completion scheduler as substitute for the frozen execution binding

## 12. Archive-dependent Gating Truth Freeze
- Current V1 still uses the language of “archive-dependent release”, but the current backend truth package does not add a dedicated `archive_ready` field or table.
- Current archive-dependent release must therefore remain a derived `Server` decision from:
  - `Order` current state
  - `Contract` current state
  - `Milestone` current states
  - `Inspection` current state and current effective loop outcome
- Current hard rules:
  - route presence for `rating` or `dispute` never proves archive readiness
  - `BFF` and Flutter must not guess archive readiness
  - any release of rating or dispute continuation that depends on archive completeness remains `Server`-derived only

## 13. File And Evidence Linkage Freeze
- `file_assets` and `evidences` remain the only current file and proof carriers for this package.
- Current minimum allowed proof families in this package are:
  - contract-bound proof
  - milestone-bound proof
  - inspection-bound proof
- Current hard rules:
  - file proof must use shared upload `init -> direct upload -> confirm`
  - `objectKey` is never business truth
  - raw URL is never business truth
  - fulfillment proof must bind to a concrete business object
- This package does not approve:
  - a parallel contract-file subsystem
  - a parallel inspection-proof subsystem
  - a frontend-only archive file cache as truth

## 14. Explicit Gap Freeze
- The mother blueprint direction includes:
  - daily progress logs
  - final archive confirmation
  - archive export
- Current backend truth package freezes that those objects are:
  - directionally accepted
  - not yet dedicated persistence truth in the current repo
- Therefore no downstream agent may claim:
  - `daily_progress_logs` are already frozen
  - `acceptance_archives` are already frozen
  - `archive_exports` are already frozen
  - any current route family already guarantees those objects exist

## 15. Audit Increment Freeze
- This dedicated package adopts the following already-frozen audit family as must-audit truth:
  - `ContractConfirmed`
  - `ContractAmended`
  - `MilestoneSubmitted`
  - `InspectionSubmitted`
  - `InspectionRecheckSubmitted`
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - `OrderCompleted`
- Current package also freezes one negative rule:
  - there is no currently frozen audit action yet for daily progress, final archive confirm, or archive export generation
- Current hard rules:
  - invalid or repeated contract amend must not append duplicate `ContractAmended`
  - invalid or repeated inspection recheck must not append duplicate `InspectionRecheckSubmitted`
  - idempotent repeated passing decision must not append duplicate downstream completion audits

## 16. Explicit Non-goals
- No `contract_versions` truth package
- No `contract_confirmations` truth package
- No `daily_progress_logs` truth package
- No `acceptance_archives` truth package
- No `archive_exports` truth package
- No implementation unlock

## 17. Formal Conclusion
- Current formal conclusion:
  - `合同归档与履约强制入链规则 V1` now has a dedicated backend-truth package under `docs/02_backend`
  - current canonical truth stays bound to existing `orders / contracts / milestones / inspections / evidences / file_assets / audit_logs`
  - contract archive and fulfillment proof must reuse the shared file and evidence carriers
  - archive-dependent release remains a derived `Server` decision and does not become a duplicated persistence truth in this round
  - daily progress and final archive remain explicitly outside the current backend truth package
- Current stage meaning:
  - backend truth and persistence freeze only
  - no implementation unlock by this document alone

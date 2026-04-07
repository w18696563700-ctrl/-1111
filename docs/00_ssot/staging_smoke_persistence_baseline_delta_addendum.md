---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 persistence-truth delta exposed by the successful dedicated staging exhibition smoke round, including mandatory schema counters for repeatability and the formal classification of that smoke evidence.
layer: L0 SSOT
---

# staging smoke persistence baseline 增量补充单

## Scope
- This addendum applies only to the persistence-truth delta exposed by the
  successful dedicated staging exhibition write-chain smoke round.
- It freezes:
  - whether `contracts.amend_count`, `inspections.recheck_count`, and
    `inspections.rectification_count`, and
    `disputes.opened_by_organization_id` belong to the current formal backend
    persistence truth
  - their minimum owner, type, default, semantic role, and lifecycle boundary
  - whether they are mandatory baseline columns for fresh staging smoke
    repeatability
  - how the completed staging smoke round must be formally described
- It does not define implementation, migrations, release, cloud commands, or
  app-facing changes.
- It does not expand any business object semantic ceiling by itself.

## Canonical Decisions

### 1. Current formal verdict
- The successful dedicated staging exhibition smoke round is valid evidence that
  the current approved write chain can run in the dedicated staging corridor.
- That evidence is frozen as:
  - staging-only evidence
  - not live success
  - not release sign-off
  - not proof that the long-term persistence baseline was already complete
- The smoke round exposed a persistence-truth prerequisite gap:
  - `contracts.amend_count`
  - `inspections.recheck_count`
  - `inspections.rectification_count`
  - `disputes.opened_by_organization_id`
- Therefore the formal verdict is:
  - before this freeze, the smoke round proved runtime viability in staging but
    did not yet prove persistence-truth completeness
  - after this freeze, those three counters and the dispute ownership column
    are part of the current formal
    persistence baseline
  - the already completed smoke round remains staging-only evidence and must
    not be rewritten as live success

### 2. `contracts.amend_count`
- Formal owner:
  - `Contract`
- Formal persistence carrier:
  - `contracts.amend_count`
- Type:
  - `integer`
- Default:
  - `0`
- Minimum semantic role:
  - counts successful materialized amendment rounds on the current contract
    truth
  - supports enforcement of the current approved single-amendment ceiling
- Lifecycle boundary:
  - the column must exist at contract-row materialization time
  - it increments only on successful materialization of `ContractAmended`
  - invalid or rejected amendment attempts must not increment it
  - normal reads, replay, or smoke cleanup must not silently reset it

### 3. `inspections.recheck_count`
- Formal owner:
  - `Inspection`
- Formal persistence carrier:
  - `inspections.recheck_count`
- Type:
  - `integer`
- Default:
  - `0`
- Minimum semantic role:
  - counts successful materialized recheck rounds on the current inspection
    truth
  - supports enforcement of the current approved single-recheck ceiling
- Lifecycle boundary:
  - the column must exist at inspection-row materialization time
  - it increments only on successful materialization of
    `InspectionRecheckSubmitted`
  - invalid or rejected recheck attempts must not increment it
  - final close does not erase the recorded count

### 4. `inspections.rectification_count`
- Formal owner:
  - `Inspection`
- Formal persistence carrier:
  - `inspections.rectification_count`
- Type:
  - `integer`
- Default:
  - `0`
- Minimum semantic role:
  - counts successful materialized rectification-required branches on the
    current inspection truth
  - supports enforcement of the current approved single-rectification ceiling
- Lifecycle boundary:
  - the column must exist at inspection-row materialization time
  - it increments only when a controlled decision materializes the
    `rectification_required` branch
  - direct pass does not increment it
  - duplicate or invalid rectification decisions must not increment it

### 5. Current staging smoke repeatability baseline
- `disputes.opened_by_organization_id`
  - formal owner:
    - `Dispute`
  - formal persistence carrier:
    - `disputes.opened_by_organization_id`
  - type:
    - `uuid`
  - default:
    - `null`
  - minimum semantic role:
    - persists the opener organization scope for the current dispute truth
    - supports opener-side organization ownership checks on dispute actions
  - lifecycle boundary:
    - the column must exist at dispute-row materialization time
    - it must be populated only on successful materialization of
      `DisputeOpened`
    - it must remain stable after dispute materialization
    - failed or rejected dispute-open attempts must not materialize a
      conflicting persisted opener-organization value

### 6. Current staging smoke repeatability baseline
- These three counters and the dispute ownership column are frozen as mandatory
  baseline fields for fresh staging smoke repeatability under the current
  server runtime.
- A dedicated staging smoke DB is not baseline complete unless all four fields
  exist with their frozen type and default semantics.
- This requirement does not mean implementation must be changed in this round.
- It means future staging smoke or staging corridor rebuild must not treat the
  fields as optional or incidental runtime baggage.

### 7. Boundary with object addenda / backend schema truth / implementation
- `docs/02_backend/db_schema.md`
  - owns the formal backend persistence-carrier definition for these three
    counters and the dispute ownership column
- `docs/00_ssot/contract_phase3_decision_addendum.md`
  - continues to own the approved `Contract` workflow ceiling and audit
    semantics
  - does not need to be rewritten in this round because the new truth here is a
    persistence counter, not a broader workflow ceiling expansion
- `docs/00_ssot/inspection_phase3_decision_addendum.md`
  - continues to own the approved `Inspection` workflow ceiling and audit
    semantics
  - does not need to be rewritten in this round because the new truth here is a
    persistence counter, not a broader workflow ceiling expansion
- `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`
  - continues to own the current `Dispute` action boundary and opener-side
    organization rule
  - does not need to be rewritten in this round because the new truth here is a
    persistence ownership carrier, not a broader dispute workflow expansion
- `apps/**` and cloud runtime code
  - may already depend on these fields
  - but runtime dependency never substitutes for formal truth

## Non-goals
- No code change
- No migration script
- No release
- No `current` switch
- No service restart
- No new app-facing path
- No business-object semantic expansion
- No rewriting of staging smoke success into live success

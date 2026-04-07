---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 safety corridor for exhibition write-chain smoke, including actor and scope isolation, object non-reuse, cleanup and rollback discipline, runtime and database isolation, minimum allowed smoke corridor, and required evidence handoff, without turning it into an execution plan.
layer: L0 SSOT
---

# Exhibition 写链 smoke 安全 corridor 补充单

## Scope
- This addendum applies only to formal `L0 SSOT` truth for the exhibition
  write-chain smoke safety corridor.
- It freezes:
  - whether current shared live runtime and DB may be used for write-chain smoke
  - minimum isolation prerequisites for any later write-chain smoke round
  - dedicated smoke actor, tenant or organization, and object-scope semantics
  - non-reuse rule for historical objects
  - cleanup, recycle, rollback, and audit discipline
  - minimum allowed smoke corridor
  - minimum evidence handoff expected from cloud middle/backend work
  - minimum evidence baseline the result-verification agent may rely on
- It does not define implementation, cloud commands, release switching,
  service restart, or frontend changes.
- It does not add any new app-facing path, business object, or implementation
  unlock by itself.

## Canonical Decisions

### A. Exhibition 写链 smoke corridor 定义
- Exhibition write-chain smoke is frozen as:
  - one formally isolated
  - newly created
  - fully auditable
  - cleanup-governed
  cross-object verification corridor for the current approved exhibition
  write chain
- Its purpose is:
  - verify that the currently approved write-chain segments can create new
    downstream truth
  - verify that append-only audit is produced on the same fresh chain
  - verify that runtime and persistence evidence can be reconciled without
    reusing historical live business chains
- Current formal verdict:
  - the currently confirmed shared live DB `exhibition_app` is not an approved
    write-chain smoke target
  - a runtime selected by the cloud live `current` release symlink is not an
    approved write-chain smoke target
  - therefore the current shared live DB plus live `current` runtime
    combination is `No-Go` for exhibition write-chain smoke
- This `No-Go` does not mean the write chain is semantically disallowed.
- It means the current runtime and truth-isolation prerequisites are not yet
  satisfied for safe smoke execution.

### B. 允许 actor / tenant / object scope
- A later approved write-chain smoke round must use a dedicated smoke actor.
- The smoke actor rule is frozen as:
  - the actor identity must be dedicated to smoke use only
  - the actor identity must be explicitly attributable in auth or request
    context
  - smoke must not rely on implicit default actor resolution alone
  - smoke attribution must remain visible through append-only audit evidence
- Because the currently confirmed actor scope is header/default driven:
  - any approved smoke run must make actor scope explicit and auditable
  - default fallback may not be the only carrier of smoke identity
- A dedicated smoke organization scope is mandatory.
- `tenant` in this addendum means:
  - an already existing runtime tenant boundary, if one truly exists
  - not a newly invented product or truth model
- Therefore:
  - if no separately frozen tenant model exists, dedicated smoke organization
    scope is the minimum required isolation carrier
  - if a real tenant boundary already exists in runtime governance, the smoke
    organization must remain contained inside a dedicated smoke tenant boundary
    and may not share business chains with production-facing organizations
- A dedicated smoke object scope is mandatory.
- Dedicated smoke object scope means:
  - every business object in the smoke corridor is newly created inside the
    smoke actor and smoke organization scope
  - every object in the corridor is attributable to the same controlled smoke
    chain
  - no object from general live business traffic may enter the smoke chain as a
    reused anchor

### C. 禁止复用对象范围
- Historical object reuse is formally vetoed for exhibition write-chain smoke.
- The following objects must never be reused as smoke anchors:
  - existing `Project`
  - existing `Bid`
  - existing `Order`
  - existing `Contract`
  - existing `Milestone`
  - existing `Inspection`
  - existing `Rating`
  - existing `Dispute`
- The following chains must also never be reused:
  - any chain already used for acceptance
  - any chain already used for prior smoke
  - any live business chain owned by a non-smoke organization
  - any chain whose actor attribution cannot be proven as smoke-only
- If the chain includes file-backed actions, the smoke round must also avoid
  reusing historical live `Evidence` or `FileAsset` carriers as the primary
  proof of the new chain.
- Historical read-only lookup may still happen where the current product truth
  requires it.
- Historical write-anchor reuse remains prohibited.

### D. cleanup / recycle / rollback 规则
- Cleanup for smoke exists to restore operational cleanliness without destroying
  evidence.
- The minimum cleanup and recycle rule is frozen as:
  - business cleanup must be forward-governed, not truth-erasing
  - append-only audit rows must never be deleted or rewritten as smoke cleanup
  - smoke cleanup must preserve the ability to replay what happened
  - cleanup evidence itself must be attributable to the smoke chain
- The minimum recycle rule is:
  - a later smoke run must create a new chain again
  - historical smoke objects are not a reusable seed pool for acceptance
  - recycle means operational retirement or containment of smoke objects, not
    their business reuse
- The rollback rule is frozen as:
  - routine database rollback is not the normal cleanup path
  - shared live DB rollback is prohibited as a smoke cleanup mechanism
  - release rollback and `current` switching are not part of smoke cleanup
  - if a dedicated non-production smoke DB is later used, any DB reset remains
    subordinate to prior evidence capture and does not replace append-only audit
- Cleanup must be formally complete only when:
  - smoke objects are no longer mistaken for reusable business anchors
  - required audit evidence is preserved
  - any scoped containment or retirement result is itself evidence-backed

### E. runtime / DB / current 隔离要求
- The current runtime and database isolation rule is frozen as:
  - no exhibition write-chain smoke may run on the current shared live DB
    `exhibition_app`
  - no exhibition write-chain smoke may run against the runtime currently
    selected by live `current` symlinks
- The minimum allowed runtime target for a later approved smoke round is:
  - a dedicated non-production runtime candidate under the existing canonical
    environment partition
  - `staging` is the required target for acceptance-grade write-chain smoke
  - `dev` may support implementation-side smoke only and does not replace
    `staging` for acceptance or independent sign-off
- The minimum allowed DB target for a later approved smoke round is:
  - a dedicated smoke DB target that is not the shared live business DB
  - or an equivalently isolated dedicated logical DB namespace that does not
    serve live business truth
- Dedicated smoke actor and organization scope remain mandatory even when a
  dedicated smoke DB exists.
- Dedicated smoke object scope remains mandatory even when runtime and DB are
  isolated.
- Current formal implication:
  - the project does not currently permit exhibition write-chain smoke on the
    shared live DB and live `current` release pair
  - a later smoke round remains blocked until dedicated runtime, DB, actor,
    organization, object-pool, and cleanup evidence are all in place

### F. 最小允许 smoke corridor
- The minimum allowed smoke corridor is frozen as the current core write chain:
  1. `POST /api/app/project/create`
  2. `POST /api/app/bid/submit`
  3. `POST /api/app/order/create`
  4. `POST /api/app/contract/confirm`
  5. `POST /api/app/milestone/submit`
  6. `POST /api/app/inspection/submit`
- The minimum corridor starts from a newly created smoke `Project`.
- The minimum corridor ends when:
  - the new `Inspection` submit action succeeds on the fresh chain
  - required business truth is materialized
  - required append-only audit is present for the chain
- The following approved object actions remain outside the default minimum smoke
  corridor and require a separately approved extension round if they are to be
  exercised:
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- This default minimum smoke corridor is also the current first-release
  frontend happy-path baseline.
- Therefore, `inspection/recheck`, `rating/submit`, and `dispute/withdraw` are
  not current must-pass first-release happy-path actions even though their
  object-level truth may already be separately frozen.
- No later extension round may weaken the fresh-object and non-reuse rules
  frozen above.

### G. 对云端中后端 agent 的后续交付要求
- Before any later frontend pairing or result-verification round may exercise
  the write-chain smoke corridor, the cloud middle/backend side must provide at
  minimum:
  - active environment identity proving the target is not shared live `prod`
    smoke on live `current`
  - active release identity for `BFF` and `Server`
  - proof of runtime selection target
  - proof of dedicated smoke DB target identity
  - proof of dedicated smoke actor identity
  - proof of dedicated smoke organization scope
  - proof that actor scope is explicit and not default-only
  - proof that the new chain started from a fresh `Project`
  - created-object identity set for the smoke chain
  - append-only audit evidence for each required write step
  - cleanup or retirement evidence for the smoke object scope
- The cloud handoff must remain evidence-only.
- It does not authorize the cloud side to redefine truth in code, workspace
  notes, or ad hoc runbooks.

### H. 对结果校验 agent 的后续取证要求
- Before a later smoke run begins, the result-verification agent may rely on the
  following already frozen truth and evidence baselines:
  - `docs/00_ssot/gate_register_v1.md`
    - fresh `Project` start is mandatory
    - historical project or order reuse is vetoed
  - `docs/00_ssot/current_stage_mainline_blueprint_addendum.md`
    - current approved exhibition chain and minimum actions
  - `docs/00_ssot/release_environment_rollback_baseline_addendum.md`
    - environment partition
    - active release selection boundary
    - independent verification entry order
  - `docs/00_ssot/observability_backup_disaster_recovery_baseline_addendum.md`
    - release, runtime, persistence, audit, and observability evidence order
  - `docs/02_backend/audit_log_spec.md`
    - must-audit action set and append-only audit fields
  - `docs/01_contracts/openapi.yaml`
    - current approved canonical write paths and minimum request or response
      boundaries for the core chain
- For a later smoke round, the result-verification agent must at minimum obtain:
  - active environment and release evidence
  - DB target evidence
  - dedicated smoke actor and organization evidence
  - request and response evidence for each corridor step
  - business-truth row evidence for each newly created downstream object
  - append-only audit evidence for each required action
  - cleanup or retirement evidence for the smoke object scope
- No result-verification agent may infer smoke safety from runtime response
  alone without persistence and audit reconciliation.

## Non-goals
- No cloud implementation change
- No frontend change
- No service restart
- No release
- No `current` switch
- No new app-facing path
- No new business object
- No use of historical live chains as acceptable smoke inputs
- No implementation unlock by this addendum alone

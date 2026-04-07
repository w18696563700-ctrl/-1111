---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 baseline for observability, monitoring and alerting, trace and log correlation, backup and restore-drill scope, disaster-recovery boundary, and read-only evidence access without turning it into an implementation or operations manual.
layer: L0 SSOT
---

# 运行观测 / 备份 / 容灾基线补充单

## Scope
- This addendum applies only to formal L0 truth for:
  - canonical observation tree
  - monitoring and alerting baseline
  - trace and log correlation baseline
  - backup scope baseline
  - restore-drill baseline
  - disaster-recovery boundary
  - read-only evidence access boundary
- It does not define implementation, monitoring-platform configuration, alert
  scripts, backup commands, restore commands, disaster-recovery switch commands,
  or cloud execution steps.
- It does not add any app-facing path, response-envelope field, contract field,
  or implementation unlock by itself.

## Canonical Decisions

### 1. Canonical observation tree
- The canonical observation tree is frozen as the minimum formal evidence order
  for operational judgment:
  1. release and environment evidence
     - active environment identity
     - active release selection evidence
     - active config / flag / whitelist scope
  2. runtime health evidence
     - service health
     - canonical app-facing endpoint health
     - gateway or canonical-path stability
  3. persistence and audit evidence
     - business truth rows
     - append-only audit rows
     - file or evidence metadata truth when the chain includes file-backed
       objects
  4. observability signal evidence
     - logs
     - metrics
     - error aggregates
     - trace correlation
- Root-cause judgment, rollback judgment, or final sign-off may not skip the
  above order.
- Release evidence tells which candidate is active.
- Runtime evidence tells whether the candidate is alive and externally stable.
- Persistence and audit evidence tell whether the truth actually changed.
- Observability signal evidence tells where and why the failure propagated.
- Screenshot-only or cache-only judgment is never formal evidence.

### 2. Monitoring and alerting baseline
- The minimum first-release observability baseline is frozen as:
  - logs
  - metrics
  - errors
  - traces
- Monitoring and alerting must be sufficient to distinguish at minimum:
  - global outage vs scoped object failure
  - runtime unavailability vs truth divergence
  - exposure issue vs business-state issue
  - transient spike vs sustained regression
- The minimum alerting baseline must support:
  - service health awareness
  - canonical-path failure awareness
  - high-risk action failure awareness
  - repeated critical error-code awareness
  - unusual error concentration awareness on newly changed chains
- Monitoring and alerting remain evidence and control inputs.
- They do not replace:
  - business truth rows
  - append-only audit rows
  - release and environment evidence

### 3. Trace / log correlation baseline
- Trace and log correlation is frozen as a separate observability baseline and
  must not be confused with a later formal response-envelope specification.
- The current minimum correlation baseline is:
  - one request-level trace identity must be available for operational
    correlation
  - BFF-side and Server-side operational records must be correlatable by that
    identity
  - object investigation must also be supportable by object business identity,
    such as `objectNo` or `objectId`, where the object chain requires it
- The canonical investigation order is:
  1. start from alert or error aggregate
  2. locate request or chain correlation by trace identity
  3. correlate BFF and Server logs
  4. when the issue is object-specific, correlate object business identity to
     audit and truth evidence
- Trace and log records must remain operational evidence only.
- This addendum does not freeze a universal API response envelope, and it must
  not be read as doing so.

### 4. Backup scope baseline
- Backup exists to preserve the minimum truth needed to survive operational
  failure and support evidence-based recovery.
- The minimum backup scope is frozen as:
  - business-truth persistence
  - append-only audit persistence
  - object/file metadata truth needed to reconstruct business ownership and
    visibility
  - configuration truth required to restore approved exposure and risk posture
- Backup scope is about truth carriers and recovery evidence.
- It is not defined as:
  - every cache
  - every transient queue message
  - every derived projection artifact by default
- Cross-environment reuse of backup outputs is not normal operating behavior and
  must not be treated as an interchangeable truth shortcut.

### 5. Restore-drill baseline
- Production-grade backup without restore drill is not sufficient.
- The minimum restore-drill baseline is frozen as:
  - restore feasibility must be demonstrated on a non-production path
  - restored truth must be checkable through business evidence, not only by
    storage success signals
  - the drill must verify that business truth, audit truth, and required file
    metadata truth can still be correlated after restore
- A restore drill is not complete unless the following can still be judged:
  - what release and environment the evidence belongs to
  - what business truth exists
  - what audit trail exists
  - what file or evidence ownership still exists where applicable
- Restore drill is a truth-preservation and recoverability baseline, not a
  release sign-off shortcut.

### 6. Disaster-recovery boundary
- First release does not require cloud-vendor-grade high availability.
- It does require a minimum survival boundary for serious incidents.
- The current disaster-recovery boundary is frozen as:
  - rate limiting, circuit breaking, degradation, retry, fallback, backup, and
    rollback are valid resilience categories
  - the first operational objective is to keep the system controllably usable
  - the next objective is to preserve truth integrity and governance evidence
- Disaster recovery in this baseline means:
  - keep the system alive or safely degraded
  - prevent uncontrolled truth corruption
  - preserve recoverable evidence for later verification and repair
- Disaster recovery in this baseline does not mean:
  - automatic multi-region architecture by default
  - automatic failover implementation by default
  - platform-vendor-specific disaster scripts
  - unconditional zero-downtime promise

### 7. Read-only verification / evidence access boundary
- Operational verification and sign-off require controlled read-only evidence
  access.
- The minimum read-only evidence access boundary is frozen as:
  - active release identity must be readable
  - active runtime health evidence must be readable
  - necessary business truth rows must be readable
  - append-only audit evidence must be readable
  - necessary file or metadata truth must be readable where the object chain
    depends on it
- Read-only evidence access exists to support:
  - independent verification
  - root-cause investigation
  - rollback validation
  - restore-drill validation
- Read-only evidence access must not be reinterpreted as:
  - implementation privilege
  - write privilege
  - hidden authoring root
  - cloud-side truth authoring
- Operational evidence access remains subordinate to the formal truth hierarchy
  in `docs/**`.

## Non-goals
- No deployment implementation plan
- No monitoring-platform implementation
- No alert-rule script
- No backup command or restore command
- No disaster-recovery switch command
- No universal API response-envelope freeze
- No credential, domain, account, bucket, or database record
- No new `L2 Contracts`
- No new `L3 Backend / BFF / Frontend / Admin` truth
- No implementation unlock by this addendum alone

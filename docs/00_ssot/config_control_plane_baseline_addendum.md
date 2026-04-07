---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 baseline for config-control-plane model, governance semantics, scope semantics, value safety semantics, gray and whitelist relation, and refresh semantics without turning it into an implementation plan.
layer: L0 SSOT
---

# 配置中心基线补充单

## Scope
- This addendum applies only to formal L0 truth for:
  - canonical config item model
  - canonical scope model
  - owner, approver, change-reason, and approval-record baseline
  - default, safe, and rollback value rule
  - gray and whitelist relation
  - version, refresh, and effective-snapshot semantics
  - boundary with `docs/01_contracts/config_manifest.yaml`
- It does not define implementation, platform product selection, dynamic-refresh
  code, SDK, DTO, code generation, or cloud execution steps.
- It does not add any app-facing path, new environment name, or implementation
  unlock by itself.

## Canonical Decisions

### 1. Canonical config item model
- A config entry is frozen as a governed control-plane item, not as an ad hoc
  runtime knob.
- The minimum canonical config-item model is:
  - `key`
  - `family`
  - `valueType`
  - `scope`
  - `owner`
  - `changeReason`
  - `defaultValue`
  - `safeValue`
  - `rollbackValue`
  - `version`
  - `effectiveSnapshotRef`
- Their minimum meanings are:
  - `key`
    - the unique config identifier within the formal config-control plane
  - `family`
    - the controlled config family the key belongs to
  - `valueType`
    - the formal value kind required for review and validation
  - `scope`
    - the formal applicability range
  - `owner`
    - the accountable truth owner for the config item
  - `changeReason`
    - the explicit business or operational reason for the change
  - `defaultValue`
    - the baseline value when no narrower approved override applies
  - `safeValue`
    - the value accepted as the low-risk steady-state baseline
  - `rollbackValue`
    - the value used to restore the approved safe posture when rollback is
      required
  - `version`
    - the formal config-version identity of the item definition or approved
      value set
  - `effectiveSnapshotRef`
    - the formal reference to the effective config snapshot consumed by a given
      release or runtime candidate
- This baseline freezes the model only.
- Concrete current inventories remain outside this file.

### 2. Canonical scope model
- `scope` is frozen as a formal applicability boundary, not as a free-form note.
- The current minimum scope dimensions are:
  - environment scope
  - audience scope
  - capability or visibility scope
- Environment scope must stay inside the already frozen environment partition:
  - `local`
  - `dev`
  - `staging`
  - `prod`
- Audience scope may narrow applicability by approved whitelist or gray range.
- Capability or visibility scope may narrow applicability to:
  - building visibility
  - platform capability pre-embed
  - upload or risk-policy family
- Scope is allowed to narrow an approved config item.
- Scope must not invent:
  - a second tenant model
  - an unfrozen environment family
  - a hidden product path family

### 3. Owner / approval / change-reason baseline
- Every formal config item must have an accountable owner.
- Production-impacting config change must have an explicit approval trace.
- The minimum governance baseline is:
  - `owner` is mandatory
  - `changeReason` is mandatory
  - `approver` is mandatory for production-impacting change
  - `approvalRecord` is mandatory for production-impacting change
- Their minimum meanings are:
  - `owner`
    - who owns the config item's truth and safe posture
  - `approver`
    - who explicitly approved the effective change
  - `changeReason`
    - why the change exists and what risk or objective it serves
  - `approvalRecord`
    - the traceable evidence that the approval action happened
- In single-owner mode, owner and approver may be the same person, but the two
  roles may not be silently omitted.
- A config change without owner, reason, and approval trace is not a formally
  governed config change.

### 4. Default / safe / rollback value rule
- `defaultValue`, `safeValue`, and `rollbackValue` are related but not identical
  by default.
- Their formal relation is frozen as:
  - `defaultValue`
    - baseline value when no narrower override applies
  - `safeValue`
    - value accepted as the approved low-risk operating posture
  - `rollbackValue`
    - value selected to restore the approved safe posture quickly during a
      config rollback
- `safeValue` may equal `defaultValue`, but that is not automatically required.
- `rollbackValue` may equal `safeValue`, and should do so unless a separately
  justified formal truth says otherwise.
- High-risk config change is incomplete unless it has:
  - an explicit safe posture
  - an explicit rollback posture
- Config rollback must restore governed safety, not merely any previous random
  value.

### 5. Gray / whitelist relation
- Gray and whitelist are formal exposure-narrowing relations for config and
  flag effect, not alternate truth roots.
- Their relation to config control is frozen as:
  - config or flag defines the governed capability or visibility posture
  - gray narrows the exposure range of an already governed posture
  - whitelist narrows the eligible actor or organization set of an already
    governed posture
- Gray or whitelist may not legalize:
  - undefined semantics
  - an unfrozen path
  - an unapproved risky capability
- If a risky change must be contained, gray or whitelist reduction may happen
  before broader release rollback, following the release baseline.
- Gray and whitelist remain subordinate to:
  - the config item's safe posture
  - the config item's rollback posture

### 6. Version / refresh / effective snapshot semantics
- Config control-plane truth must be versioned.
- The minimum version and refresh semantics are frozen as:
  - every formal config item definition belongs to a versioned config truth
  - every effective runtime candidate must be attributable to an effective
    config snapshot
  - consumers may refresh only against an approved version or effective
    snapshot boundary
- Refresh semantics mean:
  - consumers detect or receive that the effective config version changed
  - consumers re-read the approved config truth boundary
  - consumers must not invent partial local truth outside the approved snapshot
- Effective snapshot semantics mean:
  - the active release candidate must be attributable to a specific approved
    config state
  - operational judgment must use the effective config version, not cache guess
    or screenshot memory
- This file freezes version and refresh semantics only.
- It does not freeze a specific polling, push, cache, or invalidation
  implementation.

### 7. Boundary with config_manifest / release baseline / implementation
- `docs/00_ssot/config_control_plane_baseline_addendum.md`
  - governs model and governance semantics
  - governs scope semantics
  - governs approval and rollback semantics
  - governs version and effective-snapshot semantics
- `docs/01_contracts/config_manifest.yaml`
  - governs the current formal flag inventory
  - governs the current owner/default/rollback list for frozen flag items
  - does not replace the higher-level config-control-plane governance model
- `docs/00_ssot/release_environment_rollback_baseline_addendum.md`
  - governs environment partition
  - governs release selection and rollback ordering
  - governs the relation between config rollback and broader release rollback
- `apps/**` and cloud workspaces
  - are implementation or runtime projection only
  - are not the authoring truth root for config-control-plane semantics

## Non-goals
- No implementation plan
- No config-platform product choice
- No dynamic refresh implementation
- No SDK or DTO generation rule
- No new app-facing path
- No new environment family
- No new tenant model
- No direct modification of `config_manifest.yaml` by this addendum alone
- No implementation unlock by this addendum alone

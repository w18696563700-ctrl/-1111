---
owner: Codex 总控
status: draft
purpose: Freeze the minimum L0 semantics for template family, rule family, snapshot-bearing instances, and historical immutability.
layer: L0 SSOT
---

# Template Rule Snapshot Baseline Addendum

## Scope
- This file freezes the formal `L0 SSOT` baseline for `Template`, `Rule`, and
  snapshot-bearing instance semantics only.
- It defines:
  - the minimum `Template` family
  - the minimum `Rule` family
  - which current instances are snapshot-bearing instances
  - when freeze must happen
  - what the minimum snapshot payload boundary is
  - why historical instances may not be rewritten by later template or rule changes
- It does not define implementation, database migration, table DDL, Admin UI
  implementation, or `Server` API shape.
- It does not add any app-facing path, new role family, or second snapshot truth.

## Canonical Template Family
- `Template` family is the controlled authoring family for reusable business form,
  checklist, clause, and evaluation structure.
- Minimum `Template` family members:
  - `Template`
  - `TemplateVersion`
  - `TemplateField`
  - controlled template-group refs used to keep industry and building-group
    assignment stable
- Minimum semantic rule:
  - `Template` identifies the long-lived template identity
  - `TemplateVersion` identifies a publishable immutable version of that template
  - `TemplateField` identifies the field-level structure carried by a specific
    template version
  - template-group refs identify where the template belongs, including hidden
    pre-embed groups that must exist before exposure
- Controlled actions on the family may produce new versions, but may not mutate
  already-frozen historical snapshots.

## Canonical Rule Family
- `Rule` family is the controlled authoring family for versioned constraints and
  assignment logic that govern how templates are selected and how a governed
  instance must be interpreted.
- Minimum `Rule` family members:
  - `TemplateRule`
  - `RuleVersion`
  - controlled rule-assignment refs that bind a rule version to an approved
    template version and assignment context
- Minimum semantic rule:
  - `TemplateRule` is the reusable rule identity
  - `RuleVersion` is the immutable versioned rule carrier
  - rule-assignment refs identify the approved assignment context such as industry,
    project type, risk tags, or equivalent controlled dispatch context already owned
    by `Server`
- A rule may evolve by publishing a new `RuleVersion`, but a later rule version may
  not rewrite the historical truth already frozen on an existing governed instance.

## Snapshot-bearing Instance Rule
- A snapshot-bearing instance is an already-materialized business instance whose
  downstream interpretation must remain historically replayable even after template
  or rule evolution.
- The current minimum snapshot-bearing instance set is:
  - `Project`
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `Rating`
  - `ChangeOrder`
  - `Dispute`
- Minimum semantic rule:
  - a snapshot-bearing instance must preserve the versioned template and rule
    context that existed when the instance was created or materially activated
  - downstream reads, review, acceptance, dispute handling, or audit replay must
    use the frozen snapshot context, not the latest template or rule
- Forbidden:
  - treating a future template publish as a historical-instance rewrite
  - consuming latest template truth as if it automatically replaced frozen
    historical context
  - maintaining a second snapshot truth outside `Server`

## Freeze Trigger Rule
- The default freeze trigger is instance creation.
- A snapshot-bearing instance must not leave its creation boundary without a frozen
  template-and-rule context.
- For split creation chains, the freeze must happen no later than the first
  persisted lifecycle entry that makes the instance consumable by downstream
  business logic.
- Minimum trigger rule by intent:
  - `Project`: freeze when the project instance is materialized
  - `Order` and `Contract`: freeze at creation/materialization time, not after
    downstream confirmation
  - `Milestone`, `Inspection`, `Rating`, `ChangeOrder`, `Dispute`: freeze when the
    governed instance is materialized into the active chain
- If an instance cannot be created with a valid snapshot context, that instance
  must not be advanced as if it were historically frozen.

## Minimum Snapshot Payload Boundary
- Every snapshot-bearing instance must carry the minimum frozen context through
  version refs or equivalent controlled frozen refs.
- Minimum payload boundary:
  - `templateVersionRef`
  - `ruleVersionRef`
  - `permissionSnapshotRef`, or an equivalent formally frozen permission-context ref
  - `inspectionContextSnapshotRef`, or an equivalent formally frozen acceptance or
    inspection-context ref when that instance participates in fulfillment or
    acceptance handling
- Equivalent semantics are allowed only when:
  - the ref is owned by `Server`
  - the ref is immutable for that historical instance
  - the ref is audit-replayable
- This file freezes the semantic boundary only. It does not force a single physical
  storage layout such as inline JSON versus normalized reference tables.

## Historical-instance Immutability Rule
- Once a snapshot-bearing instance is frozen, later `TemplateVersion` or
  `RuleVersion` changes may affect only newly created or newly materialized
  instances.
- Historical instances must remain bound to their original frozen refs or
  equivalent frozen snapshot semantics.
- Template governance may continue to move forward:
  - new draft versions may be authored
  - new versions may be published
  - assignment rules may move to new approved versions
- But those forward changes must not:
  - rewrite historical `Project`, `Order`, `Contract`, `Milestone`, `Inspection`,
    `Rating`, `ChangeOrder`, or `Dispute` instances
  - silently replace historical `permissionSnapshotRef`
  - silently replace historical `inspectionContextSnapshotRef`
  - reinterpret historical audit, review, dispute, or acceptance outcomes using the
    latest version instead of the frozen version

## Boundary with Admin / Gate / Schema / Implementation
- Boundary with `docs/05_admin/admin_governance_surface_matrix.md`:
  - `admin_governance_surface_matrix.md` freezes the `template_config` workbench
    surface and its controlled actions
  - this file freezes the upstream `L0` semantics for template family, rule family,
    freeze timing, and historical immutability
- Boundary with `docs/02_backend/db_schema.md`:
  - `db_schema.md` owns the current relational schema skeleton and physical-table
    boundary
  - this file owns the semantic object family and freeze rule only
- Boundary with `docs/00_ssot/lifecycle_state_machine.md`:
  - `lifecycle_state_machine.md` owns canonical object states
  - this file only freezes when snapshot context must already exist relative to
    instance creation or materialization
- Boundary with `docs/00_ssot/gate_register_v1.md`:
  - `gate_register_v1.md` owns veto enforcement and stage-gate rules
  - this file defines what counts as the minimum snapshot-bearing truth that the
    gate protects
- Boundary with implementation:
  - `apps/**` and `packages/**` remain non-truth layers
  - this file does not unlock implementation by itself

## Non-goals
- No implementation plan
- No database migration
- No table add/drop/change instruction
- No Admin page implementation
- No `Server` API implementation
- No new app-facing path
- No new `L2 Contracts`
- No new instance family outside the already-existing business object set
- No new role system
- No second snapshot truth

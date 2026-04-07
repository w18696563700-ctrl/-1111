---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 baseline for unified platform-capability families, namespace boundaries, member entitlement semantics, message capability semantics, payment pre-embed semantics, live-geo-map pre-embed semantics, risk-policy hooks, hidden pre-embed asset grouping, and boundaries with config truth, contracts, and implementation.
layer: L0 SSOT
---

# 平台能力统一收口基线补充单

## Scope
- This addendum applies only to formal `L0 SSOT` truth for:
  - canonical platform capability family map
  - capability namespace and family boundary
  - member quota and entitlement baseline
  - message template and message capability baseline
  - payment pre-embed baseline
  - `live / geo / map` pre-embed baseline
  - risk-threshold and policy-hook baseline
  - hidden pre-embed asset grouping and capability-scope relation
  - boundary with config truth, contracts truth, and implementation
- It does not define implementation, adapter wiring, payment transaction flow,
  membership-system implementation, message-center implementation, or cloud
  execution steps.
- It does not add any app-facing path, new contract field, new building, new
  provider truth root, or implementation unlock by itself.

## Canonical Decisions

### 1. Canonical capability family map
- Platform capability truth must stay unified.
- A platform capability family is a governed cross-object capability family,
  not a shell building, not a second business domain root, and not an ad hoc
  provider flag bucket.
- The current canonical capability family map is frozen as:

| Family | Canonical namespace root | Current posture | Minimum formal role |
|---|---|---|---|
| upload capability | `upload.*` | opened | controlled file-transfer capability for approved business objects only |
| message capability | `message.*` | opened with restrained surface | controlled message and instance-todo visibility capability only |
| membership entitlement | `membership.*` | opened at current consume boundary | entitlement and quota posture used by shell/profile consumption only |
| payment pre-embed | `payment.*` | pre-embed | provider-facing settlement and payment capability reserve only |
| live capability | `platform.live.*` | pre-embed | hidden platform capability name only |
| geo capability | `platform.geo.*` | pre-embed | hidden platform capability name only |
| map capability | `platform.map.*` | pre-embed | hidden platform capability name only |
| risk policy | `risk.*` | governance-reserved | threshold and policy-hook family for server-side risk control only |
| review governance capability | `review.*` | governance-reserved | controlled review and governance support capability only |

- The current posture meanings are frozen as:
  - `opened`
    - already allowed to appear through separately frozen current-stage truth
  - `opened with restrained surface`
    - visible only through the already frozen minimum consumer surface
  - `pre-embed`
    - truth may exist before runtime exposure or user-facing enablement
  - `governance-reserved`
    - formal capability family exists, but it is not an end-user feature family
- The family map above is the only current unified platform-capability family
  table at `L0`.
- A family may support multiple objects.
- A family must not become a second object state machine.

### 2. Capability namespace rule
- Capability namespace exists to prevent scattered second roots.
- The namespace rule is frozen as:
  - `building.*`
    - governs shell-building visibility only
    - does not define platform capability family
  - `platform.*`
    - governs platform-capability pre-embed or capability-level switches only
  - `upload.*`
    - governs upload capability family only
  - `message.*`
    - governs message capability family only
  - `membership.*`
    - governs member entitlement and quota family only
  - `payment.*`
    - governs payment pre-embed family only
  - `risk.*`
    - governs risk-threshold and policy-hook family only
  - `review.*`
    - governs governance review capability family only
- Provider names are implementation-side adapter labels unless they are already
  frozen in a narrower truth as a config key suffix.
- Therefore:
  - provider name is not a new capability family
  - provider name is not a new building
  - provider name is not a second capability root
- Hidden buildings remain:
  - `renovation`
  - `custom_furniture`
- They are building truths, not capability-family truths.

### 3. Member quota / entitlement baseline
- Member entitlement is frozen as a platform capability posture, not as a
  second membership product tree.
- The current minimum member-capability semantics are:
  - `membership entitlement`
    - the governed answer to what member-scoped capability posture currently
      applies to an eligible actor or organization
  - `member quota`
    - the governed answer to what quantitative limit currently applies within
      an approved entitlement posture
- Their minimum formal rule is:
  - entitlement may allow, narrow, or withhold capability exposure
  - quota may narrow volume or frequency within an already approved capability
    posture
  - neither entitlement nor quota may invent a new app-facing path or a second
    role system
- Current app-facing consumption remains limited to already frozen shell/profile
  projections such as:
  - `membershipStatus`
  - `membership`
- This file freezes the capability semantics only.
- It does not define a richer member-center workflow or entitlement UI.

### 4. Message template / message capability baseline
- Message capability is frozen as a platform capability family, not as a full
  message-center or chat-system truth.
- The current minimum message-capability semantics are:
  - `message capability`
    - controlled ability to deliver instance-todo visibility, notification
      visibility, and jump-target awareness through already approved surfaces
  - `message template`
    - governed reusable template asset that shapes message expression or
      notification wording without becoming a business-object truth root
- Message capability may:
  - surface approved instance anchors
  - surface approved action anchors
  - surface approved jump targets
- Message capability must not:
  - mutate business truth
  - create a second workflow truth
  - create a general-purpose message center
  - invent new app-facing path families
- Message templates remain subordinate to:
  - current object truth
  - current route truth
  - current config and policy truth

### 5. Payment pre-embed baseline
- Payment remains a pre-embedded platform capability family only.
- The current minimum payment semantics are:
  - payment capability truth may exist before runtime enablement
  - payment pre-embed may preserve provider-facing adapter slots, settlement
    posture placeholders, and approval gates
  - payment pre-embed does not by itself open:
    - user-facing payment pages
    - transaction paths
    - fund-pool semantics
    - settlement workflow semantics
- Payment pre-embed is frozen as a capability reserve.
- It is not frozen here as a business object family.

### 6. Live / geo / map pre-embed baseline
- `live / geo / map` are already frozen as platform capability names only.
- Their current minimum unified baseline is:
  - they are not buildings
  - they are feature-flagged off by default
  - they may exist in truth before implementation or enablement
  - they may surface only as normalized capability awareness after separate
    approval
- `platform.live.*`, `platform.geo.*`, and `platform.map.*` remain
  pre-embedded capability namespaces only.
- `platform.map.gaode.enabled` is currently a config-key projection only.
- It must not be interpreted as:
  - a second map truth root
  - a provider-governed business truth
  - a released end-user map workflow

### 7. Risk-threshold / policy-hook baseline
- Risk-threshold and policy-hook truth are frozen as a governed platform
  capability family.
- Their current minimum semantics are:
  - `risk threshold`
    - governed threshold used to narrow, block, escalate, or require additional
      governance handling
  - `policy hook`
    - governed decision hook that allows server-owned policy evaluation to run
      against an approved object, actor, or capability context
- Risk-threshold and policy-hook may:
  - narrow exposure
  - require review
  - require ticketing or escalation
  - block unsafe progression
- They must not:
  - create a second object truth
  - create a second audit truth
  - create a hidden state machine outside `Server`
  - legalize an unfrozen app-facing capability
- Risk-threshold and policy-hook remain subordinate to:
  - server-owned business truth
  - formal config-control truth
  - formal audit attribution

### 8. Hidden pre-embed asset grouping rule
- Hidden pre-embed asset grouping is frozen as a supporting organization rule,
  not as a second capability root.
- A hidden pre-embed asset group may group:
  - template assets
  - rule assets
  - message-template assets
  - entitlement assets
  - policy-hook assets
- Such grouping may serve:
  - hidden-building preparation
  - future capability preparation
  - scoped governance preparation
- Hidden pre-embed asset grouping must not:
  - redefine capability family
  - redefine building truth
  - redefine current visibility truth
  - imply that hidden or future capability is released
- Therefore:
  - hidden building grouping is not the same thing as capability family
  - capability family may support hidden-building preparation
  - asset grouping may exist before exposure without creating a second truth
    hierarchy

### 9. Boundary with config / contracts / implementation
- `docs/00_ssot/platform_capability_unified_baseline_addendum.md`
  - governs the unified capability-family map
  - governs namespace rule
  - governs member, message, payment, `live / geo / map`, and risk-policy
    baseline semantics
- `docs/00_ssot/config_control_plane_baseline_addendum.md`
  - governs config-item model, scope, approval, default/safe/rollback value,
    and refresh semantics
  - does not replace this file's capability-family unification role
- `docs/01_contracts/config_manifest.yaml`
  - governs current frozen config and flag inventory
  - governs current owners/defaults/rollbacks for listed items
  - does not replace this file's higher-level capability-family and namespace
    truth
- `docs/01_contracts/openapi.yaml`
  - governs current app-facing contract paths and payload surfaces
  - does not become the capability-family root
- `docs/03_bff/bff_routes.md`
  - governs current `BFF` shaping and app-facing capability-awareness boundary
  - does not become the authoring root for unified capability-family semantics
- `docs/00_ssot/template_rule_snapshot_baseline_addendum.md`
  - governs template, rule, and snapshot families and freeze semantics
  - does not replace the platform-capability family table frozen here
- `apps/**`, `packages/**`, `infra/**`, and cloud workspaces
  - are implementation or projection only
  - are not the authoring truth root for platform-capability semantics

## Non-goals
- No implementation plan
- No adapter implementation
- No payment-flow implementation
- No membership-system implementation
- No message-center implementation
- No new app-facing path
- No new `L2 Contracts`
- No new building
- No new provider truth root
- No second capability root
- No implementation unlock by this addendum alone

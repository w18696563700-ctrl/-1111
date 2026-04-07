---
owner: Codex 总控
status: submitted
purpose: Freeze the L0-only registration skeleton, boundary, and sync order for unified instance entry pre-embed before any L1/L2/L3 authoring or implementation unlock.
layer: L0 SSOT
---

# 统一实例入口注册能力预埋 L0 补充单

## Scope
- This addendum applies only to `L0` truth sync for unified instance entry registration pre-embed.
- It freezes the registration skeleton semantics only.
- It does not unlock `L1`, `L2`, `L3`, or implementation by itself.
- It does not define runtime storage, consumer rendering, or implementation wiring.

## Canonical Decision

### 1. 能力定义
- The only capability frozen by this addendum is:
  - `统一实例入口注册骨架`
- This capability represents only a minimum registration skeleton that can later align:
  - one app-facing canonical entry reference
  - one consumer-local entry key
- This capability is not:
  - a global navigation tree
  - a page layout metadata system
  - a message center
  - a workbench
  - a governance console
  - a control console
  - a new app-facing path design

### 2. 最小注册字段
- The minimum registration fields are:
  - `entryKey`
  - `objectType`
  - `actionKey`
  - `canonicalPath`
  - `requiredParams`
  - `consumerBuilding`
  - `localEntryKey`
  - `state`
- Field boundary:
  - `entryKey`
    - unique registration-row key inside the registration skeleton only
  - `objectType`
    - the registered business object family
  - `actionKey`
    - the registered instance action identifier
  - `canonicalPath`
    - the app-facing canonical entry reference, not a local page route name
  - `requiredParams`
    - the minimum parameter names required to consume the registered entry
  - `consumerBuilding`
    - the existing building allowed to consume this registration
  - `localEntryKey`
    - the consumer-local entry slot key, not app-facing truth
  - `state`
    - a registration-row field only; this addendum freezes the field presence, not a registration state machine

### 3. 第一批允许注册范围
- The first allowed registration batch is:
  - `contract.confirm`
  - `contract.amend`
  - `inspection.submit`
  - `rating.submit`
  - `dispute.open`
  - `dispute.withdraw`
- Corresponding first-batch object range is limited to:
  - `contract`
  - `inspection`
  - `rating`
  - `dispute`
- No other `actionKey` or `objectType` may be added to the first registration batch by this addendum alone.

### 4. `canonicalPath / localEntryKey` 边界
- `canonicalPath` boundary:
  - it is the app-facing canonical entry reference
  - it must not be reinterpreted as a local page route name
  - it must not be used by this addendum to define or expand the app-facing path inventory
- `localEntryKey` boundary:
  - it is a consumer-local entry key only
  - it must point only to an already-approved local entry slot inside a specific consumer building
  - it is not a second canonical path, not a deep-link truth layer, and not a global navigation registry
- Relationship boundary:
  - `canonicalPath` and `localEntryKey` must coexist in one registration row
  - neither field may overwrite or redefine the other
  - the concrete mapping rules are deferred to later `L1/L2/L3` sync and are not authored by this L0 addendum

### 5. Truth owner / consumer 高层边界
- `L0` owns only:
  - the existence of the registration skeleton
  - the minimum field boundary
  - the non-goal boundary
  - the sync-order boundary
- Later consumers may consume a projected registration view only after lower-layer truth is frozen.
- No consumer layer may become a second truth owner for this registration skeleton.
- No frontend, admin, BFF, or package projection may invent a parallel registration truth table or alternate registration semantics.

### 6. 非目标冻结
- Not a global navigation tree
- Not a page-layout metadata registry
- Not a message center
- Not a workbench
- Not a governance console
- Not a control console
- Not a new app-facing path design
- Not a full consumer-routing contract
- Not an implementation unlock
- Not a reopening of `Contract`, `Inspection`, `Rating`, or `Dispute`

### 7. 同步顺序冻结
- The sync order for this capability is frozen as:
  1. `L0`
     - capability semantics
     - minimum fields
     - boundary and non-goals
  2. `L1`
     - domain-level ownership and meaning, if required
  3. `L2`
     - contract-level field and canonical-path binding, if required
  4. `L3`
     - BFF / frontend consumer wording and projection boundary
- No later layer may skip ahead and retroactively redefine `L0`.

## Non-goals
- No runtime implementation
- No app-facing path addition
- No message-center semantics
- No workbench semantics
- No governance-console semantics
- No page-layout registry
- No consumer-specific rendering contract
- No local route-generation contract
- No implementation unlock by this document alone

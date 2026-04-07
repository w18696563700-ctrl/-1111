---
owner: Codex 总控
status: draft
purpose: Freeze the formal L0 baseline for release environment partitioning, release artifacts, switching units, rollback units, and post-release independent verification entry without turning it into an operations manual.
layer: L0 SSOT
---

# 发布 / 环境 / 回滚基线补充单

## Scope
- This addendum applies only to formal L0 truth for:
  - canonical environment partition
  - canonical release artifact set
  - active release selection and switching boundary
  - gray, whitelist, and flag rollback order
  - rollback matrix
  - post-release independent verification entry
- It does not define implementation, deployment, CI/CD, runtime commands, or
  cloud execution steps.
- It does not add any app-facing path, contract field, or implementation unlock
  by itself.

## Canonical Decisions

### 1. Canonical environment partition
- The canonical environment partition is frozen as:
  - `local`
  - `dev`
  - `staging`
  - `prod`
- No additional environment name is introduced by this baseline.
- Their minimum meanings are:
  - `local`
    - local authoring and local implementation verification only
  - `dev`
    - shared development and integration verification
  - `staging`
    - pre-production truth, release, and acceptance verification
  - `prod`
    - the only formal live serving environment
- Environment partition exists to guarantee:
  - development, integration, acceptance, and production do not pollute one
    another
  - configuration change is controllable
  - gray, whitelist, hidden-building, and feature-flag behavior can be verified
    safely before full production exposure
- Data, cache, and object/file truth carriers must not be treated as
  cross-environment interchangeable state.

### 2. Canonical release artifact set
- A formal release candidate is frozen as an auditable artifact set, not as a
  source workspace snapshot.
- The current canonical release artifact set is:
  - `Server` release artifact
  - `BFF` release artifact
  - approved configuration and flag snapshot
  - shipped static-resource bundle when the round includes one
  - release record that ties version identity, risk note, and rollback
    references together
- `docs/**` remain authoring truth prerequisites for release, but are not
  themselves runtime switching units.
- `packages/**` remain derived projection outputs and are not the release truth
  root.
- A release artifact must be identifiable as a specific candidate that can be
  selected, verified, and rolled back independently from unrelated artifacts.

### 3. Active release selection / switching boundary
- The active runtime release must be selected through release artifacts only,
  not through source working directories.
- The canonical active code selection boundary is:
  - `Server` active release selection
  - `BFF` active release selection
- The canonical active configuration selection boundary is:
  - approved config snapshot
  - approved feature-flag state
  - approved whitelist scope where applicable
- Therefore the formal switching unit is frozen as:
  - one runtime release artifact for `Server` or `BFF`
  - or one approved configuration / flag / whitelist scope set
- A switching action may change only the minimum affected unit.
- No switching action may redefine:
  - authoring truth
  - app-facing path semantics
  - business-object meaning

### 4. Gray / whitelist / flag rollback rule
- Gray, whitelist, and flag control are exposure-governance tools first, not
  substitutes for undefined semantics.
- New risky capability or new risky visibility may not jump directly to
  irreversible full exposure.
- The canonical containment order is frozen as:
  1. shrink exposure first
     - gray range reduction
     - whitelist reduction
     - flag rollback to the approved safe value
  2. if the issue is not safely contained by exposure control alone, roll back
     the affected config or code release unit
  3. after the stabilized active candidate is selected, enter independent
     verification before any final sign-off upgrade
- Feature flag rollback remains the first rollback path for:
  - visibility drift
  - hidden-building exposure drift
  - platform-capability exposure drift
  - other explicitly flag-governed risky entry exposure
- Gray or whitelist may narrow exposure, but may not be used to silently keep
  undefined semantics in production.

### 5. Rollback matrix
| Failure class | Preferred first containment | Canonical rollback unit | Frozen rule |
|---|---|---|---|
| Visibility or entry exposure drift | gray reduction, whitelist reduction, or flag rollback | one approved flag or whitelist scope set | exposure must be shrunk before larger rollback is chosen when semantics are otherwise stable |
| Platform capability exposure drift | flag rollback | one capability flag set | high-risk capability must return to its approved safe value before further expansion is considered |
| Config drift or risky threshold drift | config rollback | one approved config snapshot or scoped config set | every risky config path must have owner, safe value, and rollback value |
| `BFF` aggregation or response-shaping regression | `BFF` release rollback, optionally with matching config rollback | one `BFF` release artifact, plus its minimum required config set when needed | preserve canonical app-facing path stability and verify response truth again after rollback |
| `Server` business or state regression | `Server` release rollback, optionally with matching config rollback | one `Server` release artifact, plus its minimum required config set when needed | business truth and append-only audit must be re-verified after rollback |
| Static-resource regression when a static bundle is shipped | static bundle rollback | one shipped static-resource bundle | static rollback must not silently redefine backend truth or route truth |
| Cross-stack release regression | smallest combined rollback across affected units | the minimum combined set of `Server`, `BFF`, config, and static units actually involved | no unrelated object scope may be bundled into the rollback set |
| Data issue discovered after release | controlled mitigation and forward correction first | forward-fix / repair unit, not routine database rollback | database rollback is not the default release rollback path and must not be treated as the normal first response |

### 6. Post-release independent verification entry
- No release candidate may be finally signed off from implementation report
  alone.
- Post-release independent verification may begin only after:
  - the active release artifact selection is stabilized
  - the active config / flag / whitelist state is stabilized
  - the intended containment or rollback path for the candidate is no longer in
    flux
- The minimum independent verification entry must traverse the frozen
  observation order:
  1. active release and selection evidence
     - active release identity
     - active selection targets
     - active config / flag / whitelist scope
  2. runtime and canonical path evidence
     - health evidence
     - canonical app-facing endpoint evidence
  3. persistence and audit evidence
     - business truth evidence
     - append-only audit evidence
- If the independent verification channel is unavailable:
  - the candidate may remain `Submitted`
  - or `Pending independent verification`
  - but it may not be upgraded to `Passed`
- If the verification channel must be restored first, the recovery path is
  governed by:
  - `docs/00_ssot/independent_verification_channel_recovery_addendum.md`
- No new implementation work may be piggybacked into the post-release
  independent verification or recovery round.

## Non-goals
- No deployment implementation plan
- No CI/CD script
- No cloud command or shell procedure
- No `current` switching step-by-step manual
- No restart manual
- No credential, domain, secret, or account record
- No new `L2 Contracts`
- No new `L3 Backend / BFF / Frontend / Admin` truth
- No implementation unlock by this addendum alone

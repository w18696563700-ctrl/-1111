---
owner: Codex 总控
status: draft
purpose: Freeze the engineering-governance, testing, independent-verification, repository-hygiene, and release sign-off baseline before any later implementation round.
layer: L0 SSOT
---

# 工程治理 / 测试 / 目录收口 决策补充单

## Scope
- This addendum applies only to engineering governance, testing baseline,
  independent verification baseline, repository hygiene, and release sign-off
  discipline.
- It does not reopen any business object.
- It does not unlock any implementation by itself.
- It does not change any product contract, business state machine, or app-facing
  path.

## Canonical Decisions

### 1. 主工程观测树标准
- The canonical engineering observation tree is frozen as:
  1. `L0 truth`
     - stage objective
     - current object boundary
     - canonical contracts
     - audit and sign-off rules
  2. `L1 implementation projection`
     - local workspace code
     - cloud release code
     - active `current` symlink targets
  3. `L2 runtime health`
     - `systemctl` service status
     - canonical app-facing endpoint responses
     - Nginx canonical-path stability
  4. `L3 persistence and audit evidence`
     - business truth rows
     - append-only audit rows
- Any formal verification or sign-off must traverse the observation tree in
  that order.
- No sign-off may jump directly from implementation report to `Passed` without:
  - runtime evidence
  - persistence evidence
  - audit evidence

### 2. 测试层门禁与拆分预警
- The canonical test gate stack is frozen as:
  - `T0 truth sanity`
    - docs parse
    - YAML/OpenAPI parse
    - no truth drift before code
  - `T1 canonical path smoke`
    - app-facing request/response shape
    - canonical error-code boundary
  - `T2 fresh-chain acceptance`
    - start from a new `Project`
    - produce new downstream truth
    - verify state and audit transitions
  - `T3 Codex 总控独立复验`
    - independent cloud read
    - independent runtime probe
    - independent DB and audit check
- Split-warning rules are frozen as:
  - one handwritten acceptance or verification script should verify one primary
    object or one primary cross-object chain only
  - warning threshold:
    - handwritten test or verification file `>= 300` lines
  - forced split candidate:
    - handwritten test or verification file `>= 400` lines
  - warning threshold for a single handwritten verification method:
    - `>= 60` lines
  - forced split candidate for a single handwritten verification method:
    - `>= 90` lines
- Mechanical splitting that hides responsibility drift still fails review.
- One verification artifact may not simultaneously own:
  - contract shape assertions
  - object-state progression
  - audit reconciliation
  - release-environment repair logic

### 3. 独立复验基线
- The independent verification baseline is frozen as:
  - Codex 总控 must independently verify every final sign-off candidate on the
    cloud runtime
  - implementation self-report is evidence input only, not final proof
- Minimum independent verification capability must include:
  - read `current` symlink targets
  - read active release code files
  - read service status
  - hit canonical app-facing endpoints
  - query necessary business truth and append-only audit rows
- If the independent verification channel is unavailable:
  - the candidate status may be `Submitted` or `Pending independent verification`
  - it may not be upgraded to `Passed`
- If the independent verification channel is restored:
  - the required re-verification bundle must be run immediately
  - no new implementation work may be piggybacked into that recovery round

### 4. 目录职责与洁癖收口
- Directory responsibility closure is frozen as:
  - `docs/` stores formal truth only
  - `apps/**` stores implementation only
  - `packages/**` stores projection and tooling outputs only
  - `.tmp/`, `tmp/`, `cache/`, `.cache/`, `exports/`, `artifacts/`, and `logs/`
    remain non-truth only
- Formal reports used for sign-off must not be dropped into source directories.
- Prompt transcripts, cloud screenshots, ad hoc SQL notes, and copied evidence
  outputs must not be placed under:
  - `apps/**`
  - `packages/**`
  - `infra/**`
- Cloud workspaces remain read-only mirrors for truth and may not become a
  second authoring root.
- Release directories are runtime projection only and are not formal truth.

### 5. release 签收纪律
- The canonical release sign-off states are frozen as:
  - `Submitted`
  - `Pending independent verification`
  - `Blocked`
  - `Passed`
  - `Closed with evidence`
- Their minimum meanings are:
  - `Submitted`
    - implementation report returned
    - no final independent conclusion yet
  - `Pending independent verification`
    - no new blocker is confirmed
    - final sign-off waits for Codex control verification
  - `Blocked`
    - at least one required verification item failed
    - sign-off stops until a scoped correction round passes
  - `Passed`
    - all required verification items passed
    - no unresolved truth drift remains
  - `Closed with evidence`
    - the approved round is finished and recorded with evidence
- No release may be signed off as `Passed` if:
  - required independent verification was not completed
  - any veto finding is still open
  - runtime response and frozen truth still diverge
- Every final sign-off for a business round must record at minimum:
  - active release paths
  - runtime request evidence
  - business truth evidence
  - append-only audit evidence

## Non-goals
- No reopening of `Contract`
- No reopening of `Inspection`
- No reopening of `Rating`
- No reopening of `Dispute`
- No new app-facing path
- No implementation refactor by this addendum alone
- No infrastructure rewrite

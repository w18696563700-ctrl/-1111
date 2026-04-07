---
owner: Codex 总控
status: draft
purpose: Freeze how Codex control restores cloud independent verification capability and what must be re-verified immediately after the channel is restored.
layer: L0 SSOT
---

# 独立复验通道恢复单

## Scope
- This addendum applies only to Codex control's cloud independent verification
  channel.
- It governs only the historical residual independent-verification track for a
  previously submitted round whose final cloud re-verification could not yet be
  completed.
- It exists only to restore verification capability after the verification
  channel became unavailable.
- It does not unlock any implementation by itself.
- It does not change product semantics, app-facing paths, or business truth.
- It does not define the current active ranked item, the current unique
  mainline goal, or the current active stage.

## Canonical Decisions

### 1. Recovery target
- The recovery target is not "implementation success."
- The recovery target is only:
  - Codex control can independently read the active cloud release
  - Codex control can independently hit canonical app-facing endpoints
  - Codex control can independently query cloud truth and append-only audit
    evidence
- Until all three are restored, no pending implementation may be finally signed
  off as `Passed`.

### 2. Minimum restored verification capabilities
- The cloud independent verification channel is considered restored only when
  Codex control can independently complete all of the following:
  - read `current` release symlink targets for `Server` and `BFF`
  - read release code files under the active cloud release directories
  - execute canonical app-facing requests against the cloud runtime
  - query cloud persistence truth required for state and audit verification
- If any one of the above remains unavailable, the channel remains
  `not restored`.

### 3. Recovery boundary
- Restoring the verification channel is an infrastructure and control-plane
  recovery action only.
- It must not:
  - add any product path
  - change any contract or error-code truth
  - modify business implementation logic
  - serve as a hidden product or admin capability
- Recovery tooling or credentials are not product capability and must not become
  long-term product dependencies.

### 4. Historical residual pending object and status
- The historical residual pending object tracked by this addendum is:
  - `Contract Phase 3` minimum main-loop implementation
- Its historical residual status track remains:
  - `Contract Phase 3 最小修正：Submitted`
  - `Contract Phase 3 最小主闭环实现：Pending independent verification`
- This addendum does not redefine:
  - the current active ranked item
  - the current unique mainline goal
  - the current active stage
- Those three items remain defined only by:
  - `docs/00_ssot/next_stage_candidate_ranking_and_unique_goal.md`
- This status must not be upgraded to `Passed` before the restored channel is
  used to complete the required re-verification bundle below.

### 5. Mandatory immediate re-verification bundle after recovery
- Once the independent verification channel is restored, Codex control must
  immediately re-run all of the following on cloud:
  1. `confirm` request with missing `contractId`
  2. `amend` request with missing `contractId`
  3. `amended` contract receiving `amend` again
  4. success-chain sanity check remains valid
  5. no new app-facing path and no scope expansion
- No subset run is sufficient for final sign-off.

### 6. Pass criteria for the recovery follow-up verification
- Item 1 must prove:
  - `confirm` missing `contractId` no longer returns `202`
- Item 2 must prove:
  - `amend` missing `contractId` no longer returns `202`
- Item 3 must prove:
  - `amended -> amend again` returns `409 + CONTRACT_INVALID_STATE`
- Item 4 must prove:
  - at least one legal `confirm` still returns canonical success
  - at least one legal `amend` still returns canonical success
- Item 5 must prove:
  - no new app-facing path exists
  - no `Inspection / Rating / Dispute` changes were bundled
  - `Contract` scope did not expand beyond the minimum Phase 3 main loop

### 7. Controlled conclusion rule
- If the verification channel is restored but the five-item bundle is not yet
  completed, the only valid status remains:
  - `Pending independent verification`
- If any item in the five-item bundle fails, the valid status becomes:
  - `Blocked`
- Only after all five items pass under Codex control's independent verification
  may the pending `Contract Phase 3` implementation be registered as:
  - `Passed`
- This controlled conclusion rule applies only to the historical residual
  `Contract Phase 3` verification track.
- It must not be read as the definition of the current active mainline.

## Non-goals
- No current active-stage definition
- No ranked-item override
- No unique-goal override
- No Contract truth change
- No BFF truth change
- No Server business-logic change
- No reopening of `Inspection`
- No reopening of `Rating`
- No reopening of `Dispute`
- No new implementation unlock

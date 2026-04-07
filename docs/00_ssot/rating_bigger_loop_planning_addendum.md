---
owner: Codex 总控
status: draft
purpose: Freeze the planning-only boundary for Rating bigger-loop discussion after the minimum rating loop has already been closed.
layer: L0 SSOT
---

# Rating bigger-loop planning 补充单

## Scope
- This addendum applies only to `Rating bigger-loop planning`.
- The current active ranked item is:
  - `Rating bigger-loop planning`
- The current unique next-stage goal is:
  - `Rating bigger-loop planning`
- The current maximum allowed level remains:
  - `L0 SSOT planning truth`
- It is a planning-truth freeze only.
- It does not unlock implementation by itself.
- It does not reopen the already closed minimum `Rating` loop by itself.

## Canonical Decisions

### 1. Current closure baseline remains valid
- The already completed minimum `Rating` loop remains the current canonical
  closed baseline:
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
- This planning addendum must not be interpreted as saying that the minimum
  loop is incomplete.
- This planning addendum does not rewrite or downgrade any accepted minimum-loop
  truth already frozen in prior L0/L2/L3 rounds.

### 2. Allowed discussion range for bigger-loop planning
- Outside the minimum loop, the allowed `Rating bigger-loop` planning range is
  limited to whether a later round should discuss:
  - detail boundary only
  - history boundary only
  - list boundary only
  - review or moderation boundary only
  - richer scoring or feedback-model boundary only
  - downstream dispute-link boundary only
- In this round, these items are discussion scope only.
- None of them are approved implementation goals by default.

### 3. Current explicit non-goals
- This round does not approve:
  - reopening of `Contract`
  - reopening of `Inspection`
  - reopening of `Dispute`
  - rewrite of `rating/entry`
  - rewrite of `rating/submit`
  - rating detail implementation
  - rating history implementation
  - rating list implementation
  - review or moderation implementation
  - richer scoring-model implementation
  - downstream dispute-link implementation
- This round does not approve:
  - new app-facing path
  - rating schema freeze
  - BFF boundary freeze
  - frontend consumption freeze
  - backend execution plan
  - frontend execution plan
  - BFF execution plan
  - parallel multi-object planning bundle

### 4. Current maximum allowed level
- The maximum allowed level in this round is:
  - `L0 SSOT planning truth`
- This means the round may freeze only:
  - what `Rating bigger-loop planning` is allowed to discuss
  - what is still explicitly outside scope
  - what future gate path must be followed before any execution round
- This round may not freeze:
  - new `L2 Contracts`
  - new `L3 BFF truth`
  - new `L3 Frontend truth`
  - implementation prompts
  - implementation sequencing for `apps/**`

### 5. Future execution gate path
- If `Rating bigger-loop` is later proposed for execution, it must re-enter in
  this order:
  1. stage gate approval with one unique goal
  2. `L0` and `L1` truth clarification if semantics or ownership change
  3. `L2 Contracts` freeze if app-facing interfaces or contract truth change
  4. `L3` BFF and Frontend truth freeze for approved consumer boundaries
  5. implementation in `apps/**` only after upstream truth is frozen
  6. `packages/contracts/**` projection refresh only after upstream contract
     truth is frozen
  7. fresh-chain verification and independent verification before any stage
     closure
- No future execution round may skip directly from planning discussion to
  implementation.

## Non-goals
- No default approval of any bigger-loop capability
- No new product semantics by implication
- No new state machine
- No new contract field freeze
- No new path freeze
- No direct implementation unlock

---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum publish AI review gate, including final gate-decision materialization, draft retention on refusal, and controlled risk-governance handoff without opening a second publish truth.
layer: L3 Backend
---

# Forum Publish AI Review Gate Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum publish AI review gate`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the Server-side gate-ownership boundary
  - the minimum gate-decision materialization chain
  - the draft-retention rule on blocked publish
  - the minimum relation to existing forum governance truth carriers
- It does not by itself:
  - approve implementation completion
  - approve moderation console
  - approve image/video binary moderation completion
  - approve a second publish truth

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner of:
  - publish-eligibility truth
  - AI gate result truth
  - risk-decision truth
  - moderation / governance handoff truth
  - final public-visibility truth for forum post publish
- `BFF` and frontend remain non-owners of:
  - AI review truth
  - risk truth
  - moderation-case truth
  - final gate-decision truth

## Minimum Gate Materialization Chain
- The current minimum backend gate chain is frozen as:
  1. read the current Server-owned draft publish payload
  2. apply fixed hard-block rules
  3. apply sensitive-term / explicitly illegal-content hard-block rules
  4. invoke `DeepSeek` only as a model-assist layer when needed
  5. materialize the final gate decision inside `Server`
  6. continue publish or stop publish according to the materialized decision
- Model output is therefore:
  - signal input only
  - not final truth
  - not self-executing publish truth

## Current Text-only Review Boundary
- The current minimum backend review object is limited to:
  - title
  - body
  - topic / classification context
  - necessary publish metadata already in the existing publish boundary
- The current backend truth does not approve:
  - image binary moderation as completed
  - video binary moderation as completed
  - OCR moderation
  - ASR moderation
  - frame-by-frame moderation
- Any future media-content moderation must re-enter separately.

## Minimum Decision-category Semantics
- The current decision categories remain anchored to the existing governance
  baseline:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- Current backend meanings:
  - `clear`
    - publish may continue through the existing draft-to-post mainline
    - the draft may be consumed by the existing publish flow
    - the post may enter current public-visible truth
  - `supplement_required`
    - publish must not continue
    - the draft must remain retained and editable
    - the actor must retry only after modifying content
  - `restricted`
    - publish must not continue
    - the draft must remain retained under controlled non-public boundary
    - the current content must not pass unchanged through the same publish try
  - `ticket_required`
    - publish must not continue
    - the draft must remain retained and unconsumed
    - the case must hand off into controlled governance processing

## Draft Retention Rule
- When publish is blocked, `Server` must not:
  - consume the draft as published
  - create a fake public post
  - treat refusal as if the draft lifecycle had succeeded
- Minimum draft rule on refusal:
  - the draft remains the current authoring carrier
  - future retries still go through the same `publish` command
  - the current round does not create a second user-facing draft-review state
    machine

## Relation To Existing Governance Truth Carriers
- `ForumRiskFlag`
  - remains the forum-scoped risk signal carrier
  - may be materialized or updated only under `Server` control
- `ForumModerationCase`
  - remains the forum-specific moderation / governance handling carrier
  - may be opened only when the final Server decision requires controlled
    governance follow-up
- `ReviewTask` / governance ticket baseline
  - remains the escalated governance path when a case exceeds ordinary
    single-command handling
  - is the minimum baseline anchor for `ticket_required`
- This means:
  - `clear` does not require governance escalation
  - `supplement_required` and `restricted` may remain inside controlled forum
    risk handling without opening an end-user Admin workflow
  - `ticket_required` must be capable of handing off into the existing review /
    governance baseline without inventing a second governance truth

## Audit Attribution Boundary
- Every final gate decision must remain under append-only audit discipline.
- Minimum audit expectation:
  - the publish attempt has actor attribution
  - the final decision category is attributable
  - request and trace correlation remain preserved
  - governance handoff, when it occurs, remains attributable
- Named audit-action ownership remains governed by:
  - `docs/02_backend/audit_log_spec.md`
- This addendum does not mint a second audit system or a raw-model audit log.

## Current Explicit Non-goals
- No moderation console
- No human-review UI
- No second publish truth
- No image/video binary moderation completion
- No OCR / ASR / frame moderation completion
- No avatar upload truth
- No automatic location truth
- No direct publish without draft

## Formal Answers To Current Key Questions
- Why not pure `DeepSeek`?
  - because model output is not stable business truth, while `Server` must own publish eligibility, risk decisions, and governance handoff
- What happens when publish is blocked?
  - the draft remains retained and unconsumed; only `clear` may continue the current publish mainline
- What is the boundary between shared governance truth and forum-local truth?
  - `ForumRiskFlag` and `ForumModerationCase` remain forum-scoped carriers, while `ReviewTask` / governance ticket baseline remains the escalated cross-cutting governance path

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only owner of forum publish AI gate truth
  - final decision must be materialized by `Server`
  - the current minimum decision set is `clear / supplement_required / restricted / ticket_required`
  - blocked publish must retain the draft and prevent public visibility
  - existing governance carriers are reused rather than replaced

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - fixed hard-rule boundary
  - model-assist invocation boundary
  - final gate-decision materialization
  - draft retention on refusal

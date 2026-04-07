---
owner: Codex 总控
status: draft
purpose: Freeze the minimum L2 contract semantics for forum publish AI review gate without opening a second publish path, a second review protocol, or a media-binary moderation completion claim.
layer: L2 Contracts
---

# Forum Publish AI Review Gate Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum publish AI review gate`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the current publish-path rule
  - the current app-facing result-semantics boundary
  - the current review-input boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation
  - rewrite `openapi.yaml` as a final output freeze
  - approve release
  - approve closure

## Stage Gate Reminder
- Current active board:
  - `论坛模块`
- Current allowed entry:
  - `AI 审核 gate 的 L0/L2/L3 truth refinement`
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - do not mix in rich-media binary moderation completion
  - do not mix in moderation console
  - do not mix in avatar edit
  - do not mix in automatic location
  - do not mix in direct publish

## Canonical Publish Path Rule
- AI review gate must not create a second app-facing publish corridor.
- The current app-facing publish command remains only:
  - `POST /api/app/forum/publish`
- The current mainline remains:
  - `draft/save -> publish`
- This package does not approve:
  - `/api/app/forum/review/submit`
  - `/api/app/forum/moderation/*`
  - a frontend-only review-submit protocol
  - direct post publish without draft

## Current Publish Request Boundary
- The current publish request remains anchored to:
  - an existing `draftId`
- The current AI gate review input is derived only from the existing
  Server-owned draft and publish context:
  - title
  - body
  - selected topic / classification context
  - necessary publish metadata already inside the existing publish handoff
- This package does not freeze:
  - image/video binary review inputs
  - OCR / ASR / frame review inputs
  - location-truth inputs

## Current App-facing Result Semantics
- The existing publish path must be able to return only one of the following
  controlled semantic outcomes:
  - `clear` -> publish succeeds
  - `supplement_required` -> controlled failure, user must modify and retry
  - `restricted` -> controlled failure, current content may not publish as-is
  - `ticket_required` -> controlled governance handoff, no public publish
- This means the current publish contract must distinguish:
  - clear success
  - controlled refusal
  - controlled governance handoff
- These outcomes must stay within:
  - the same `POST /api/app/forum/publish` semantic family
- They must not become:
  - a second user-visible review workflow
  - a second publish path family

## Existing Error-code Boundary
- Existing malformed-request and invalid-state semantics remain owned by the
  current forum publish contract and error-code truth:
  - `FORUM_PUBLISH_INVALID`
  - `FORUM_PUBLISH_INVALID_STATE`
- AI gate outcomes are different from:
  - malformed request
  - invalid draft state
- Therefore a valid publish request that is blocked by the AI gate must not be
  disguised as:
  - a fake malformed-request error
  - a fake invalid-state error
- The field-level app-facing response implementation must stay inside the
  semantic boundary frozen by this addendum and must not reopen a second
  endpoint, a second review protocol, or a raw-model output surface.

## Draft Retention Rule
- When the result is non-`clear`:
  - the draft must not be consumed into a public post
  - the draft must remain inside the existing draft truth corridor
- Minimum current semantic expectation:
  - `supplement_required` keeps the draft editable
  - `restricted` keeps the draft retained under controlled non-public boundary
  - `ticket_required` keeps the draft retained while governance handoff occurs

## Current Explicit Non-goals
- No second publish endpoint
- No second review-submit protocol
- No media binary moderation completion
- No automatic location field
- No AI raw output exposure
- No moderation console path family
- No appeal / dispute workflow expansion
- No direct publish without draft

## Formal Answers To Current Key Questions
- Why keep AI review inside the existing publish path?
  - because the current publish contract is already frozen around `draft/save -> publish`, and opening another path would duplicate user-side publish semantics
- What is the boundary between controlled result semantics and final response fields?
  - this addendum freezes the semantic family that later field-level implementation must obey, without creating a second endpoint or a second review protocol
- What do the four categories mean in contract terms?
  - `clear` means accepted publish continuation, while the other three mean controlled non-public outcomes under the same publish command

## Formal Conclusion
- Current formal conclusion:
  - forum AI review gate does not open a second publish path
  - the only app-facing publish command remains `POST /api/app/forum/publish`
  - valid publish attempts may resolve to `clear / supplement_required / restricted / ticket_required`
  - text review is in-scope, media binary review is out-of-scope
  - non-`clear` outcomes must keep draft truth intact and must not be disguised
    as malformed-request or invalid-state errors
  - this addendum is the current L2 semantic freeze for later implementation

## Next Unique Action
- After this L2/L3 package is frozen, dispatch backend Agent first to
  materialize the publish-gate truth and controlled decision outputs under the
  existing publish command.

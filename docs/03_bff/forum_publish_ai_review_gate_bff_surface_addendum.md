---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum publish AI review gate so BFF can hand off publish, normalize controlled messages, and avoid becoming a second review owner or a raw-model output surface.
layer: L3 BFF
---

# Forum Publish AI Review Gate BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum publish AI review gate`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the allowed BFF responsibilities for the AI gate publish surface
  - the current controlled message-shaping boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve moderation console
  - approve media binary moderation completion

## BFF Responsibility Boundary
- For this package, `BFF` may do only:
  - publish handoff
  - Chinese error normalization
  - app-facing controlled message shaping
  - necessary auth consolidation
  - bounded visibility trimming already frozen upstream
- `BFF` must not own:
  - AI review truth
  - risk decision truth
  - moderation-case truth
  - prompt truth
  - policy truth

## Final-decision Consumption Rule
- `BFF` may consume only:
  - `Server`-materialized final gate decision
- `BFF` may shape only:
  - success continuation message
  - modification-required message
  - current-content-not-publishable message
  - controlled-governance-handoff message
- `BFF` must not expose:
  - raw model output
  - vendor-specific raw response text
  - internal prompt
  - internal risk-tag details not intended for ordinary users

## No Second Review State Machine
- `BFF` must not:
  - call the model and self-decide the final result
  - create a second audit or review state machine
  - create a second publish corridor
  - expose Admin moderation semantics to normal publish flows
- The only app-facing publish command remains:
  - the existing forum publish handoff

## Current Explicit Non-goals
- No moderation console
- No raw-model explanation surface
- No image/video binary moderation completion
- No avatar edit
- No automatic location
- No direct publish without draft
- No appeal / dispute workflow expansion

## Formal Answers To Current Key Questions
- Why can BFF not own the review result?
  - because `BFF` is only the app-facing aggregation and shaping layer, while `Server` is the only publish-eligibility and governance-truth owner
- Why must BFF not expose raw model output?
  - because user-facing publish semantics must stay controlled, Chinese, and bounded, not become a model-debug surface
- What is BFF allowed to return?
  - only controlled Chinese outcomes corresponding to `clear / supplement_required / restricted / ticket_required`

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may only hand off publish and shape the final `Server` decision into
    bounded user-facing Chinese messages
  - `BFF` may not own AI truth, risk truth, moderation-case truth, or prompt
    truth
  - `BFF` may not create a second review state machine or a raw-model output
    surface

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire:
  - publish handoff reuse
  - final-decision shaping
  - controlled Chinese outcome mapping

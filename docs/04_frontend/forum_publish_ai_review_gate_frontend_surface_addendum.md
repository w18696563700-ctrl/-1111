---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side publish-surface boundary for forum publish AI review gate so the client can continue using `draft/save -> publish` without becoming a second review-state-machine owner or exposing model internals.
layer: L3 Frontend
---

# Forum Publish AI Review Gate Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum publish AI review gate`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum publish-result surface
  - the minimum user-facing state semantics
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve media binary moderation completion
  - approve release
  - approve closure

## Current Publish-flow Rule
- Frontend must continue to use only:
  - `draft/save -> publish`
- Frontend must not expose:
  - a second `提交审核` button
  - a second publish path
  - a separate end-user moderation console
- The AI gate happens only after the user triggers:
  - publish on the existing draft-based flow

## Current User-facing Result Surface
- After publish is triggered, frontend may consume only the following bounded
  result meanings:
  - 发布成功
  - 需修改后再试
  - 当前内容暂不可发布
  - 已进入受控治理处理
- The client may map them into the existing controlled surface family such as:
  - success continuation
  - controlled prompt
  - controlled retry-after-edit prompt
  - controlled non-public unavailable prompt
- The client must not invent:
  - a second AI review progress state machine
  - a second moderation-state machine
  - a second publish lifecycle

## Draft Retention UX Boundary
- When the final decision is non-`clear`:
  - the user remains in the existing draft-based authoring corridor
  - the draft is not treated as published
  - future retry still goes through the same publish action after content
    change
- Frontend must not fake:
  - published success when the final decision is blocked
  - a new draft-review center page
  - a hidden Admin-style governance workflow page

## Forbidden Frontend Exposures
- Frontend must not show:
  - raw model output
  - prompt text
  - internal technical risk labels
  - raw vendor diagnostics
  - a second review-backoffice surface
- Current media binary moderation UI is not part of this package.

## Current Explicit Non-goals
- No image/video binary moderation result UI
- No moderation console UI
- No avatar edit
- No automatic location field
- No direct publish bypassing draft
- No appeal / dispute full workflow

## Formal Answers To Current Key Questions
- Why cannot frontend own a second review state machine?
  - because frontend consumes BFF-shaped results only and may not reinterpret governance truth into a second client-owned domain workflow
- What happens when publish is blocked?
  - the user keeps the current draft corridor and receives a bounded Chinese prompt rather than a fake success or raw technical failure
- Why is media binary moderation excluded here?
  - because this package freezes only the text-publish gate surface; media binary review needs its own separate truth re-entry

## Formal Conclusion
- Current formal conclusion:
  - frontend still follows `draft/save -> publish`
  - publish may end only in the bounded user-facing result family above
  - frontend must not expose raw model output, internal risk tags, or a second
    review-state machine
  - media binary moderation UI remains outside the current package

## Next Unique Action
- After backend and `BFF` truth land, dispatch frontend Agent third to
  implement the bounded publish-result surface above.

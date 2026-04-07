---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum content governance and report submission so BFF may hand off report commands and shape bounded Chinese results without becoming a second moderation owner.
layer: L3 BFF
---

# Forum Content Governance And Report BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum content governance and report minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the current BFF handoff role for report submission
  - the bounded Chinese shaping rule for forum governance outcomes
  - the explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve moderation console
  - approve messages-side harassment handling

## BFF Responsibility Boundary
- `BFF` may do only:
  - auth consolidation
  - report-submit handoff
  - bounded Chinese result shaping
  - visibility trimming already frozen upstream
- `BFF` must not own:
  - report-verdict truth
  - moderation-case truth
  - reporter-risk truth
  - malicious-report judgment truth
  - reviewer-routing truth

## Current Publish-governance Consumption Rule
- `BFF` continues to consume only:
  - the `Server`-materialized forum publish decision
- `BFF` may shape only the bounded existing family:
  - 发布成功
  - 需修改后再试
  - 当前内容暂不可发布
  - 已进入受控治理处理
- `BFF` must not expose:
  - raw risk tags
  - raw model output
  - moderator notes
  - Admin console semantics

## Current Report-submit Shaping Rule
- `BFF` may expose only:
  - `POST /api/app/forum/report/submit`
- `BFF` may shape only bounded ordinary-user outcomes such as:
  - 举报已提交
  - 已存在处理中举报
- `BFF` must not expose:
  - moderator assignment state
  - review queue state
  - reporter-side malicious-report scoring
  - governance ticket routing internals

## No Second Moderation State Machine
- `BFF` must not:
  - self-decide report verdicts
  - self-decide malicious-report guilt
  - create a second moderation or ticket state machine
  - expose a moderation-console route family to ordinary forum users

## Current Explicit Non-goals
- No moderation console
- No report queue for ordinary users
- No messages harassment path
- No DM block / mute / blacklist semantics
- No binary media moderation completion
- No second publish path

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may only hand off forum report submit and shape bounded Chinese
    outcomes for publish/report surfaces
  - `BFF` may not own report truth, malicious-report truth, moderation-case
    truth, or ticket-routing truth
  - `messages` harassment remains outside this package

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire:
  - report-submit handoff reuse
  - bounded report-submit message shaping
  - existing publish-governance result shaping continuity

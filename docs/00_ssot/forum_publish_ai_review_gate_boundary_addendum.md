---
owner: Codex 总控
status: draft
purpose: Freeze the minimum L0 boundary for forum publish AI review gate so later backend, BFF, and frontend execution may proceed without opening a second publish path, a second review state machine, or vendor-secret drift.
layer: L0 SSOT
---

# 论坛发布 AI 审核 gate 边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
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
  - do not mix in direct publish without draft
- This addendum freezes only:
  - the minimum boundary for `forum publish AI review gate`
  - the minimum supplier-selection rule
  - the minimum publish-gate decision semantics
  - the explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - approve image/video binary moderation as completed

## 2. Capability Package Name
- Current capability package name:
  - `forum publish AI review gate`
- This package belongs only to:
  - the forum publish command boundary
- It does not open:
  - a second user-side review path
  - a second app-facing publish corridor
  - a second forum review state machine

## 3. Publish Command-only Boundary
- The current forum publish mainline remains:
  - `draft/save -> publish`
- The AI review gate must happen only:
  - inside the controlled `publish` command boundary
- Therefore the current round does not approve:
  - a second `提交审核` path
  - a second forum review path family
  - a default `先发后审` public-visible strategy
- The minimum target is:
  - publish-time synchronous decision
  - `clear` continues the existing publish flow
  - non-`clear` stops public visibility under the same publish command

## 4. Supplier Selection And Secret Boundary
- The current intended model-assist supplier is:
  - `DeepSeek`
- Supplier selection may enter formal truth because it affects:
  - invocation boundary
  - vendor-dependency planning
  - later implementation dispatch order
- But the following must never enter `docs/**`, receipts, or logs:
  - raw API keys
  - raw secret values
  - runtime environment variables
  - deployment-only connection configuration
- Runtime env binding belongs to:
  - deployment and execution layer
- It does not belong to:
  - docs truth authoring

## 5. Minimum Gate Architecture
- The current minimum gate structure is frozen as:
  1. fixed hard-rule layer
  2. sensitive-term / explicitly illegal-content hard-block layer
  3. `DeepSeek` context-assist layer
  4. `Server` final materialized gate decision
- Therefore the current boundary is:
  - not pure rules
  - not pure model
  - not `BFF`-side judgment
  - not frontend-side judgment
- `Server` remains the only owner of:
  - review truth
  - risk truth
  - moderation truth
  - publish-eligibility truth

## 6. Current Review Object Boundary
- The current minimum AI review gate freezes only text-publish scope:
  - title
  - body
  - topic / classification context
  - necessary publish metadata already inside the publish handoff
- This round does not approve claiming that the following are complete:
  - image binary moderation
  - video binary moderation
  - OCR moderation
  - ASR moderation
  - frame-by-frame video moderation
- If future media moderation must be reopened, it must re-enter through:
  - a separate truth package
- The current rich-publish media package may coordinate only at the boundary:
  - it does not merge into this package

## 7. Minimum Decision Categories
- The minimum decision-category family must remain anchored to:
  - `docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md`
- The current publish-gate categories are:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- Current publish-gate meanings:
  - `clear`: publish may continue and content may enter public-visible state
  - `supplement_required`: publish may not continue, draft stays editable, user
    receives a controlled Simplified Chinese modification prompt
  - `restricted`: publish may not continue, current content may not pass as-is,
    user receives a controlled Simplified Chinese unavailable prompt
  - `ticket_required`: publish may not continue and the case must hand off into
    the controlled `Server` governance path
- This current boundary does not mean:
  - Admin moderation console is now approved
  - appeal / dispute full workflow is now approved

## 8. App-facing Simplicity Rule
- The current app-facing result family must stay user-simple.
- The minimum user-facing meanings remain only:
  - 发布成功
  - 需修改后再试
  - 当前内容暂不可发布
  - 已进入受控治理处理
- Frontend must not expose:
  - raw model output
  - prompt content
  - internal policy text
  - Admin console semantics
- `BFF` and frontend must not become:
  - a second review-state-machine owner
  - a second moderation-state-machine owner

## 9. Current Explicit Non-goals
- No implementation by this addendum
- No image/video binary moderation completion by this addendum
- No OCR / ASR / frame moderation completion by this addendum
- No moderation console by this addendum
- No appeal / dispute / human-review workflow expansion by this addendum
- No direct publish without draft
- No avatar edit
- No automatic location truth
- No author profile package in this round
- No full-site risk platform in this round

## 10. Formal Answers To Current Key Questions
- Why keep AI review inside `publish`?
  - because the current mainline is already frozen as `draft/save -> publish`,
    and opening a second review path would create a second user-side publish
    corridor and a second review-state machine
- Why use `fixed rules + model assist + Server final decision`?
  - because pure rules are too narrow, pure model output is not stable truth,
    and only `Server` may materialize publish-eligibility and governance
    outcomes
- Why freeze text only first?
  - because text publish already sits inside the current publish command, while
    image/video binary moderation still needs its own separate truth re-entry
- How can `DeepSeek` enter truth without leaking secrets?
  - only the supplier name and invocation role enter truth; keys and runtime
    env stay outside docs

## 11. Formal Conclusion
- Current formal conclusion:
  - `forum publish AI review gate` is now frozen as a minimum L0 boundary
  - the gate lives only inside `publish`
  - the gate uses `fixed hard rules + model assist + Server final decision`
  - the first approved review scope is text only
  - the result family is limited to `clear / supplement_required / restricted / ticket_required`
  - media binary moderation, moderation console, and direct publish remain
    outside the current package
- Current freeze type:
  - forum publish AI review gate boundary freeze only

## 12. Next Unique Action
- After this L0/L2/L3 package is frozen, the natural execution order is:
  1. backend Agent
  2. `BFF` Agent
  3. frontend Agent

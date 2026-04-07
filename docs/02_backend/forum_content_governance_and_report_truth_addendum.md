---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum content governance and report handling, including report materialization, malicious-report detection, and the reuse of existing risk and review-task carriers without opening a second moderation truth root.
layer: L3 Backend
---

# Forum Content Governance And Report Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum content governance and report minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the Server-owned rule boundary for forum content issues
  - the minimum report-submit materialization rule
  - the minimum malicious-report handling rule
  - the relation to existing governance carriers
- It does not by itself:
  - approve implementation completion
  - approve moderation console
  - approve messages-side harassment handling

## Server Ownership Stays Unchanged
- `Server` remains the only owner of:
  - content-governance judgment truth
  - report acceptance truth
  - reporter-side malicious-report judgment truth
  - final visibility-governance truth
- `BFF` and frontend remain non-owners of:
  - moderation-case truth
  - report-verdict truth
  - reviewer routing truth
  - reporter reputation truth

## Minimum Content-governance Rule Boundary
- The current minimum issue families are:
  - ad / solicitation
  - abuse / insult
  - flamebait / conflict incitement
  - spam / flood / repeated publish abuse
  - plagiarism / repost abuse
- The current minimum decision family remains:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- Minimum backend semantic rule:
  - curable content defects may stop at `supplement_required`
  - direct deny-level content may stop at `restricted`
  - repeated, severe, or cross-object governance cases may escalate to
    `ticket_required`

## Minimum Report Materialization Rule
- `ForumReport` remains the append-only report-submission truth for:
  - `ForumPost`
  - `ForumComment`
- Minimum report rule:
  - a report submission creates or reuses forum-governance clue truth
  - a report submission alone does not directly hide the target
  - target visibility may change only through controlled `Server` review
    decision
- Minimum duplicate rule:
  - equivalent active reports from the same actor against the same target must
    not fan out into unlimited parallel active truth rows
  - the current backend may treat an equivalent active report as idempotent
    accept-existing under the same target boundary

## Malicious-report Handling Rule
- Malicious reporting is a reporter-side governance issue.
- Minimum signal examples:
  - repeated false reports on the same target
  - retaliatory reporting pattern after interaction conflict
  - duplicate-report flooding
  - repeated unsupported reports across many targets without evidence
- Minimum materialization boundary:
  - reporter-side malicious-report suspicion may open `ForumRiskFlag`
  - severe or repeated malicious-report pattern may open `ForumModerationCase`
  - escalated malicious-report pattern may hand off into `ReviewTask`
- Forbidden meaning:
  - malicious-report suspicion may not auto-hide the reported target by itself

## Spam / Flood Boundary
- Spam in this package means both:
  - content repetition or low-value repeated content
  - suspicious publish-frequency pattern that occupies the forum surface
- Current backend truth meaning:
  - spam may be judged under the existing decision family
  - repeated or suspicious spam may escalate into `ticket_required`
  - later dedicated rate-limit / anti-abuse implementation may re-enter
    separately, but this package already freezes the governance meaning

## Relation To Existing Governance Carriers
- `ForumReport`
  - remains clue truth only
- `ForumRiskFlag`
  - remains forum-scoped risk signal truth
- `ForumModerationCase`
  - remains forum-scoped moderation / governance handling carrier
- `ReviewTask`
  - remains the cross-cutting escalation carrier when forum-local handling is
    no longer sufficient
- This means:
  - forum does not mint a second custom ticket object
  - forum reuses the current review-ticket governance baseline

## Audit Attribution Boundary
- The following remain must-audit:
  - `ForumReportSubmitted`
  - `ForumRiskFlagOpened`
  - `ForumModerationCaseOpened`
  - `ReviewTaskDecided`
- Every governance-side visibility or escalation action must retain:
  - actor attribution
  - request and trace correlation
  - object identity and reason attribution

## Current Explicit Non-goals
- No moderation console
- No user-side report queue
- No DM harassment handling
- No messages-side blacklist or mute truth
- No second moderation truth root
- No binary media moderation completion

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only owner of forum content-governance and report
    judgment truth
  - forum report submission is clue truth only and never auto-hides content by
    itself
  - malicious reporting is governed as reporter-side risk, not as a direct
    target takedown command
  - forum must reuse `ForumReport`, `ForumRiskFlag`, `ForumModerationCase`, and
    `ReviewTask` rather than inventing a second governance tree

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - report-submit materialization
  - duplicate-active-report idempotent handling
  - reporter-side malicious-report risk materialization

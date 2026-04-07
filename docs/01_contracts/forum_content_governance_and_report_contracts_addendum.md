---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract semantics for forum content governance and report submission without opening a second publish path, a moderation console path family, or a messages-side harassment package.
layer: L2 Contracts
---

# Forum Content Governance And Report Contracts Addendum

## Scope
- This addendum applies only to the minimum L2 contract refinement for:
  - `forum content governance and report minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the current publish-governance decision reuse rule
  - the minimum app-facing report-submit contract
  - the current report-reason boundary
  - the explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - approve moderation-console routes

## Stage Gate Reminder
- Current allowed entry:
  - `L2 / L3 truth refinement`
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - do not mix in DM harassment
  - do not mix in moderation console
  - do not mix in binary media moderation completion
  - do not create a second publish corridor

## Publish-governance Reuse Rule
- Forum content-governance still reuses the existing publish result family only:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- The only app-facing publish command remains:
  - `POST /api/app/forum/publish`
- This package does not create:
  - a second review-submit button
  - a second user-side moderation flow

## Minimum Report-submit Path
- The current minimum app-facing report path is frozen as:
  - `POST /api/app/forum/report/submit`
- Current minimum request body:
  - `targetType`
  - `targetId`
  - `reasonCode`
  - optional `reasonDetail`
- Current target scope:
  - `post`
  - `comment`
- This package does not approve:
  - report-list query for ordinary users
  - report-history center for ordinary users
  - moderator action routes in the app-facing family

## Minimum Report-reason Boundary
- The current minimum app-facing `reasonCode` allow-list is frozen as:
  - `ad_or_solicitation`
  - `abuse_or_insult`
  - `flamebait_or_conflict`
  - `spam_or_flood`
  - `plagiarism_or_repost`
  - `other`
- Current meaning:
  - ordinary reporters report target-content issues only
  - `malicious reporting` is not an ordinary-user reason code
  - malicious reporting stays a Server-side governance judgment on reporter
    behavior

## Minimum Report-submit Result Boundary
- The current minimum app-facing report-submit result family is:
  - new accepted report
  - equivalent active report already exists
- Minimum user-facing meanings remain only:
  - 举报已提交
  - 已存在处理中举报
- Current contract meaning:
  - duplicate-equivalent active report may be treated as bounded idempotent
    accept-existing
  - report submit does not imply immediate hide or takedown

## Current Error Boundary
- The current minimum package adds:
  - `FORUM_REPORT_INVALID`
- Current meaning:
  - malformed or incomplete report-submit input remains a Server-owned invalid
    request error
  - duplicate active report does not require a second forum-only duplicate error
    code in this round
  - target controlled-unavailable remains governed by existing forum visibility
    semantics

## Current Explicit Non-goals
- No moderation console route family
- No report-processing route family for ordinary users
- No DM harassment path
- No user-side blacklist / mute contract
- No appeal workflow contract
- No second publish path

## Formal Conclusion
- Current formal conclusion:
  - forum governance keeps using the existing publish decision family
  - ordinary users may submit bounded post/comment reports through
    `POST /api/app/forum/report/submit`
  - ordinary-user reason codes are limited to ad, abuse, flamebait, spam,
    plagiarism, and other
  - malicious reporting remains Server-side governance truth, not an app-facing
    report reason

## Next Unique Action
- After this L2/L3 package is frozen, dispatch backend Agent first to land the
  Server-owned report-submit and governance materialization semantics.

---
owner: Codex 总控
status: draft
purpose: Freeze domain lifecycle states and rollout sequencing boundaries.
layer: L1 Domain
---

# Lifecycle State Machine

## Project
- `draft -> pending_review -> published -> bidding_closed -> awarded -> converted_to_order -> archived`

## Bid
- `draft -> submitted -> shortlisted -> won | lost | invalid -> archived`

## Order
- `draft -> pending_confirm -> active -> completed | disputed -> archived`

## Contract
- `draft -> pending_confirm -> active -> amended -> archived`

## Milestone
- `pending_submission -> submitted -> completed`

## Inspection
- `draft -> submitted`
- first decision: `submitted -> passed | rectification_required`
- rectification resubmission: `rectification_required -> rechecked`
- final decision after recheck: `rechecked -> passed | archived`
- Phase 3 planning ceiling: at most one rectification round and at most one recheck round

## Current Approved Minimum Execution Subpaths
- `Milestone`
  - `pending_submission -> submitted -> completed`
- `Order`
  - `draft -> pending_confirm -> active -> completed`
- `Inspection` Branch C (`rechecked -> archived`) does not produce `MilestoneCompleted`
  and does not produce `OrderCompleted`.

## Rating
- `draft -> submitted -> visible | under_review -> archived`

## Dispute
- `opened -> negotiating -> platform_review -> resolved | escalated -> closed`

## ForumTopic
- `draft -> active -> archived`

## ForumPost
- creation branch: `pending_moderation -> published | hidden`
- moderation branch: `published -> hidden | archived`
- restore branch: `hidden -> published | archived`

## ForumComment
- creation branch: `pending_moderation -> published | hidden`
- moderation branch: `published -> hidden | archived`
- restore branch: `hidden -> published | archived`

## ForumBookmark
- `active -> removed`

## ForumFollow
- `active -> removed`

## ForumDraft
- `editing -> published_consumed | discarded`

## ForumReport
- `submitted -> accepted | rejected -> archived`

## ForumRiskFlag
- `open -> cleared | escalated -> archived`

## ForumModerationCase
- `open -> reviewing -> actioned -> closed`

## Delivery Policy
- M1 must run through `Project -> Bid -> Order -> Milestone`.
- V1 release gate must include `Contract`, `Inspection`, and `Rating/Dispute` entry states.

## Rules
- No client-side invention of state transitions.
- Snapshot-bearing instances freeze template and rule versions on creation.
- Forum moderation decisions may change only `ForumPost` and `ForumComment`
  visibility states and may not mutate transaction-domain truth.

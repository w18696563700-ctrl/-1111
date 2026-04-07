---
owner: Codex 总控
status: draft
purpose: Freeze audit coverage and append-only audit field requirements.
layer: L3 Backend
---

# Audit Log Spec

## Required Fields
- `id`
- `object_type`
- `object_id`
- `object_no`
- `action`
- `actor_id`
- `actor_role`
- `before_state`
- `after_state`
- `reason`
- `request_id`
- `trace_id`
- `occurred_at`

## Must-audit Actions
- `ProjectPublished`
- `BidSubmitted`
- `OrderActivated`
- `ContractConfirmed`
- `ContractAmended`
- `MilestoneSubmitted`
- `MilestoneCompleted`
- `InspectionSubmitted`
- `InspectionRecheckSubmitted`
- `InspectionDecisionChanged`
- `OrderCompleted`
- `RatingSubmitted`
- `DisputeOpened`
- `DisputeWithdrawn`
- `ForumTopicActivated`
- `ForumTopicArchived`
- `ForumDraftDiscarded`
- `ForumDraftPublishedConsumed`
- `ForumPostPublished`
- `ForumPostHidden`
- `ForumPostArchived`
- `ForumPostAttachmentBound`
- `ForumCommentPublished`
- `ForumCommentHidden`
- `ForumBookmarkAdded`
- `ForumBookmarkRemoved`
- `ForumFollowAdded`
- `ForumFollowRemoved`
- `ForumReportSubmitted`
- `ForumRiskFlagOpened`
- `ForumRiskFlagCleared`
- `ForumModerationCaseOpened`
- `ForumModerationCaseActioned`
- `ForumModerationCaseClosed`
- `ReviewTaskDecided`
- `FeatureFlagChanged`
- `UploadConfirmed`

## Phase 2.3 Entry-state Minimum Audit Subset
- `ContractConfirmed`
- `InspectionSubmitted`
- `RatingSubmitted`
- `DisputeOpened`

## Contract Phase 3 Minimum Audit Subset
- `ContractConfirmed`
- `ContractAmended`

## Contract Phase 3 Minimum Audit Semantics
- `ContractConfirmed`
  - before: `pending_confirm`
  - after: `active`
- `ContractAmended`
  - before: `active`
  - after: `amended`

## Order.completed Upstream Minimum Audit Subset
- `InspectionDecisionChanged` with the minimum passing transition `submitted -> passed`
- `MilestoneCompleted`
- `OrderCompleted`

## Order.completed Upstream Internal Execution Minimum Audit Semantics
- `InspectionDecisionChanged`
  - before: `submitted`
  - after: `passed`
- `MilestoneCompleted`
  - before: `submitted`
  - after: `completed`
- `OrderCompleted`
  - before: `active`
  - after: `completed`
- An idempotent repeated passing decision must not append duplicate rows for the
  same already-completed upstream chain.

## Inspection Phase 3 Minimum Audit Subset
- `InspectionSubmitted`
- `InspectionDecisionChanged`
- `InspectionRecheckSubmitted`
- `MilestoneCompleted`
- `OrderCompleted`

## Inspection Phase 3 Minimum Audit Semantics
- `InspectionSubmitted`
  - before: `draft`
  - after: `submitted`
- `InspectionDecisionChanged`
  - before: `submitted`
  - after: `passed`
- `InspectionDecisionChanged`
  - before: `submitted`
  - after: `rectification_required`
- `InspectionRecheckSubmitted`
  - before: `rectification_required`
  - after: `rechecked`
- `InspectionDecisionChanged`
  - before: `rechecked`
  - after: `passed`
- `InspectionDecisionChanged`
  - before: `rechecked`
  - after: `archived`

## Rating Next-stage Minimum Audit Subset
- `RatingSubmitted`

## Rating Next-stage Minimum Audit Semantics
- `RatingSubmitted`
  - before: `draft`
  - after: `submitted`
- Invalid submit attempts must not append duplicate or failed `RatingSubmitted`
  audit rows.

## Dispute Next-stage Minimum Audit Subset
- `DisputeOpened`
- `DisputeWithdrawn`

## Dispute Next-stage Minimum Audit Semantics
- `DisputeWithdrawn`
  - before: `opened`
  - after: `withdrawn`
- Invalid withdraw attempts must not append duplicate or failed
  `DisputeWithdrawn` audit rows.

## Phase 2.3 Rule
- Phase 2.3 freezes only the entry-state audit boundary for `Contract`, `Inspection`,
  `Rating`, and `Dispute`; it does not freeze the full downstream governance workflow.

## Rules
- Audit is append-only.
- High-risk actions without audit are release blockers.
- Admin actions and automated platform actions both require audit attribution.

## Forum Truth Baseline Audit Semantics
- `ForumTopicActivated`
  - before: `draft`
  - after: `active`
- `ForumTopicArchived`
  - before: `active`
  - after: `archived`
- `ForumDraftDiscarded`
  - before: `editing`
  - after: `discarded`
- `ForumDraftPublishedConsumed`
  - before: `editing`
  - after: `published_consumed`
- `ForumPostPublished`
  - before: `pending_moderation | hidden`
  - after: `published`
- `ForumPostHidden`
  - before: `pending_moderation | published`
  - after: `hidden`
- `ForumPostArchived`
  - before: `published | hidden`
  - after: `archived`
- `ForumPostAttachmentBound`
  - before: `published | hidden`
  - after: `published | hidden`
- `ForumCommentPublished`
  - before: `pending_moderation | hidden`
  - after: `published`
- `ForumCommentHidden`
  - before: `pending_moderation | published`
  - after: `hidden`
- `ForumBookmarkAdded`
  - before: `removed | null`
  - after: `active`
- `ForumBookmarkRemoved`
  - before: `active`
  - after: `removed`
- `ForumFollowAdded`
  - before: `removed | null`
  - after: `active`
- `ForumFollowRemoved`
  - before: `active`
  - after: `removed`
- `ForumReportSubmitted`
  - before: `null`
  - after: `submitted`
- `ForumRiskFlagOpened`
  - before: `null`
  - after: `open`
- `ForumRiskFlagCleared`
  - before: `open | escalated`
  - after: `cleared`
- `ForumModerationCaseOpened`
  - before: `null`
  - after: `open`
- `ForumModerationCaseActioned`
  - before: `reviewing`
  - after: `actioned`
- `ForumModerationCaseClosed`
  - before: `actioned`
  - after: `closed`

---
owner: Codex 总控
status: draft
purpose: Freeze the first formal truth baseline for the forum content domain, persistence units, moderation boundary, and file truth reuse rules.
layer: L0 SSOT
---

# Forum Domain Truth Baseline Addendum

## Scope
- This addendum freezes forum content truth only.
- It does not add a new shell building.
- It does not freeze any app-facing `forum/*` canonical path in this round.
- It does not turn forum into a trading-domain extension.
- It does not allow forum actions to mutate `Project`, `Bid`, `Order`,
  `Contract`, `Milestone`, `Inspection`, `Rating`, or `Dispute` truth.

## Position In The Product Model
- The forum domain is a platform content domain owned by `Server`.
- The forum domain may later be consumed from existing visible buildings only
  after separate contract freeze.
- `BFF`, Flutter App, and Admin may not invent forum states, moderation
  semantics, or attachment truth.

## Formal Domain Objects
| Object | Purpose |
|---|---|
| `ForumTopic` | forum taxonomy and posting container |
| `ForumPost` | primary published content truth |
| `ForumComment` | post-bound discussion reply truth |
| `ForumBookmark` | actor-bound saved-post truth |
| `ForumFollow` | actor-bound topic follow truth |
| `ForumDraft` | author-owned content draft truth for `post` or `comment` |
| `ForumModerationCase` | controlled review case for forum governance actions |
| `ForumReport` | user-submitted content report truth |
| `ForumRiskFlag` | system or moderator risk signal truth |

## Explicit Non-goals
- No transaction handoff or workflow continuation.
- No order-bound rights, delivery evidence, or dispute escalation reuse.
- No feed ranking, recommendation, search relevance, or ad system truth.
- No chat, station inbox, or IM truth under the forum namespace.
- No app-facing moderation console, report queue, or governance dashboard in
  this round.

## Canonical Content Boundary
- `ForumTopic` is taxonomy truth only. It does not carry trading or contract
  meaning.
- `ForumPost` and `ForumComment` are visible content truth only.
- `ForumBookmark` and `ForumFollow` are member preference truth only.
- `ForumDraft` is authoring scratch truth only and is not visible content.
- `ForumModerationCase`, `ForumReport`, and `ForumRiskFlag` are governance
  truth and must not be reused as ranking or recommendation signals without a
  later separate truth freeze.

## Attachment Truth Boundary
- Forum attachment capability is limited to `ForumPost` in this round.
- The upload flow remains `init -> direct upload -> confirm`.
- `FileAsset` remains the file truth carrier.
- `objectKey` remains storage location only and is never business truth.
- The forum attachment binding table is `forum_post_attachments`.
- `Evidence` is not reused for forum content attachments because forum
  attachments are not workflow proof truth.
- The initial formal baseline binds attachments only to an existing
  materialized `ForumPost`.
- Any later draft-stage attachment flow requires a separate truth freeze and
  must still keep `FileAsset` as the file truth carrier.

## Persistence Baseline Draft

### `forum_topics`
- purpose:
  - platform-managed topic container
- required columns:
  - `id`
  - `topic_no`
  - `slug`
  - `title`
  - `description`
  - `state`
  - `sort_order`
  - `created_by`
  - `updated_by`
  - `created_at`
  - `updated_at`
  - `archived_at`
- required indexes:
  - unique `slug`
  - unique `topic_no`
  - `state, sort_order, created_at desc`

### `forum_posts`
- purpose:
  - primary visible content truth
- required columns:
  - `id`
  - `post_no`
  - `topic_id`
  - `author_actor_id`
  - `author_organization_id`
  - `title`
  - `body`
  - `state`
  - `comment_count`
  - `last_moderation_case_id`
  - `published_at`
  - `hidden_at`
  - `created_at`
  - `updated_at`
  - `archived_at`
- required indexes:
  - unique `post_no`
  - `topic_id, state, published_at desc`
  - `author_actor_id, created_at desc`
  - `last_moderation_case_id`

### `forum_post_attachments`
- purpose:
  - bind existing `FileAsset` truth to an existing `ForumPost`
- required columns:
  - `id`
  - `post_id`
  - `file_asset_id`
  - `sort_order`
  - `bound_by`
  - `created_at`
- required indexes:
  - unique `file_asset_id`
  - `post_id, sort_order, created_at`

### `forum_comments`
- purpose:
  - post-bound comment truth
- required columns:
  - `id`
  - `comment_no`
  - `post_id`
  - `parent_comment_id`
  - `author_actor_id`
  - `author_organization_id`
  - `body`
  - `state`
  - `last_moderation_case_id`
  - `published_at`
  - `hidden_at`
  - `created_at`
  - `updated_at`
  - `archived_at`
- required indexes:
  - unique `comment_no`
  - `post_id, state, created_at asc`
  - `parent_comment_id, state, created_at asc`
  - `author_actor_id, created_at desc`

### `forum_bookmarks`
- purpose:
  - actor-bound saved-post truth
- required columns:
  - `id`
  - `actor_id`
  - `organization_id`
  - `post_id`
  - `state`
  - `created_at`
  - `removed_at`
- required indexes:
  - unique `actor_id, post_id`
  - `post_id, state, created_at desc`

### `forum_follows`
- purpose:
  - actor-bound topic follow truth
- required columns:
  - `id`
  - `actor_id`
  - `organization_id`
  - `topic_id`
  - `state`
  - `created_at`
  - `removed_at`
- required indexes:
  - unique `actor_id, topic_id`
  - `topic_id, state, created_at desc`

### `forum_drafts`
- purpose:
  - author-owned draft truth for `post` or `comment`
- required columns:
  - `id`
  - `draft_no`
  - `draft_type`
  - `owner_actor_id`
  - `owner_organization_id`
  - `topic_id`
  - `target_post_id`
  - `parent_comment_id`
  - `title`
  - `body`
  - `state`
  - `created_at`
  - `updated_at`
  - `consumed_at`
  - `discarded_at`
- required indexes:
  - unique `draft_no`
  - `owner_actor_id, draft_type, state, updated_at desc`
  - `topic_id, state, updated_at desc`

### `forum_reports`
- purpose:
  - user-submitted report truth for `ForumPost` or `ForumComment`
- required columns:
  - `id`
  - `report_no`
  - `target_type`
  - `target_id`
  - `reporter_actor_id`
  - `reporter_organization_id`
  - `reason_code`
  - `reason_detail`
  - `state`
  - `moderation_case_id`
  - `created_at`
  - `decided_at`
  - `archived_at`
- required indexes:
  - unique `report_no`
  - `target_type, target_id, state, created_at desc`
  - `reporter_actor_id, created_at desc`
  - `moderation_case_id`

### `forum_risk_flags`
- purpose:
  - system or moderator risk signal truth for `ForumPost` or `ForumComment`
- required columns:
  - `id`
  - `flag_no`
  - `target_type`
  - `target_id`
  - `source_type`
  - `rule_code`
  - `severity`
  - `state`
  - `moderation_case_id`
  - `created_at`
  - `resolved_at`
  - `archived_at`
- required indexes:
  - unique `flag_no`
  - `target_type, target_id, state, created_at desc`
  - `state, severity, created_at desc`
  - `moderation_case_id`

### `forum_moderation_cases`
- purpose:
  - controlled governance truth for content review and disposition
- required columns:
  - `id`
  - `case_no`
  - `target_type`
  - `target_id`
  - `trigger_type`
  - `state`
  - `decision`
  - `opened_by`
  - `assigned_to`
  - `decided_by`
  - `opened_at`
  - `decided_at`
  - `closed_at`
- required indexes:
  - unique `case_no`
  - `target_type, target_id, state`
  - `state, opened_at asc`
  - `assigned_to, state, opened_at asc`

## Planned Migration Units
1. `20260327_forum_truth_baseline_core`
   - create `forum_topics`
   - create `forum_posts`
   - create `forum_post_attachments`
   - create `forum_comments`
   - create `forum_bookmarks`
   - create `forum_follows`
   - create `forum_drafts`
2. `20260327_forum_truth_baseline_governance`
   - create `forum_reports`
   - create `forum_risk_flags`
   - create `forum_moderation_cases`
   - add cross-reference indexes for governance lookup

## Audit Baseline
- The following actions are formal forum audit events:
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

## Execution Boundary
- This addendum freezes domain truth only.
- No `BFF` route, Flutter page, Admin console surface, or cloud release switch is
  approved by this addendum alone.
- Implementation may begin only after the stage gate explicitly accepts this
  truth input.

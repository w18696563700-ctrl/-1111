---
owner: Codex 总控
status: draft
purpose: Freeze relational storage boundaries and reserved schema areas, including geo and live pre-embeds.
layer: L3 Backend
---

# DB Schema Skeleton

## Core Tables
- `organizations`
- `organization_members`
- `organization_paid_memberships`
- `organization_membership_quota_snapshots`
- `projects`
- `project_attachments`
- `bids`
- `bid_versions`
- `orders`
- `contracts`
- `contract_clauses`
- `milestones`
- `evidences`
- `file_assets`
- `inspections`
- `change_orders`
- `ratings`
- `disputes`
- `review_tasks`
- `audit_logs`
- `forum_topics`
- `forum_posts`
- `forum_post_attachments`
- `forum_comments`
- `forum_bookmarks`
- `forum_follows`
- `forum_drafts`
- `forum_reports`
- `forum_risk_flags`
- `forum_moderation_cases`
- `feature_flags`
- `config_entries`

## Current write-chain persistence counters and ownership columns

### Membership current-cycle truth
- `organization_paid_memberships`
  - owner: `PaidMembershipCycle`
  - semantic role:
    - current organization-scoped paid-membership cycle truth only
    - carrier for current tier posture and current effective/expires window
  - minimum boundary:
    - not a payment order table
    - not a billing ledger
    - not a guarantee table
    - not a second organization-membership table

### Membership quota summary truth
- `organization_membership_quota_snapshots`
  - owner: `PaidMembershipQuotaSnapshot`
  - semantic role:
    - current organization-scoped quota summary truth only
    - carrier for minimum quota value and next refresh posture
  - minimum boundary:
    - not a rich consumption workflow ledger
    - not a billing or payment counter
    - not a guarantee amount carrier

### Contract persistence counters
- `contracts.amend_count`
  - owner: `Contract`
  - type: `integer`
  - default: `0`
  - semantic role:
    - the persisted amendment counter for the current approved single-amendment
      `Contract` ceiling
    - used to distinguish fresh amendable truth from already-amended truth
  - lifecycle boundary:
    - the column must exist when the `Contract` truth row is materialized
    - it increments only on successful materialization of the approved
      `ContractAmended` transition
    - invalid or rejected amend attempts must not increment it
    - it must not be recomputed from ad hoc runtime guess or cleared by normal
      staging-smoke cleanup

### Inspection persistence counters
- `inspections.recheck_count`
  - owner: `Inspection`
  - type: `integer`
  - default: `0`
  - semantic role:
    - the persisted recheck-round counter for the current approved
      single-recheck `Inspection` ceiling
    - used to distinguish a fresh recheck-eligible truth from a truth that has
      already consumed its one approved recheck round
  - lifecycle boundary:
    - the column must exist when the `Inspection` truth row is materialized
    - it increments only on successful materialization of
      `InspectionRecheckSubmitted`
    - invalid or rejected recheck attempts must not increment it
    - it persists with the inspection truth after final close
- `inspections.rectification_count`
  - owner: `Inspection`
  - type: `integer`
  - default: `0`
  - semantic role:
    - the persisted rectification-round counter for the current approved
      single-rectification `Inspection` ceiling
    - used to distinguish a fresh submitted inspection from one that has
      already consumed its one approved rectification branch
  - lifecycle boundary:
    - the column must exist when the `Inspection` truth row is materialized
    - it increments only when a controlled inspection decision materializes the
      `rectification_required` branch
    - direct-pass or archived-final-close branches must not increment it
    - duplicate or invalid rectification decisions must not increment it

### Dispute persistence ownership column
- `disputes.opened_by_organization_id`
  - owner: `Dispute`
  - type: `uuid`
  - default: `null`
  - semantic role:
    - the persisted opener-organization carrier for the current dispute truth
    - used to enforce opener-side organization ownership constraints on
      downstream dispute actions such as withdraw
    - used to keep dispute truth ownership reconcilable with permission and
      audit evidence
  - lifecycle boundary:
    - the column must exist when the `Dispute` truth row is materialized
    - it must be populated from the opener organization scope when
      `DisputeOpened` is successfully materialized
    - it must remain stable after dispute materialization and must not be
      rewritten by normal reads, staging-smoke cleanup, or later governance
      reads
    - invalid or rejected dispute-open attempts must not materialize a
      conflicting persisted opener-organization value

## Current staging smoke baseline requirement
- `contracts.amend_count`, `inspections.recheck_count`, and
  `inspections.rectification_count`, and
  `disputes.opened_by_organization_id` are part of the current formal backend
  persistence truth.
- For the current server runtime, these four persistence fields are mandatory
  baseline columns for repeatable fresh staging smoke on the approved
  exhibition write chain and current dispute ownership constraint.
- A fresh staging smoke DB that lacks any of these fields is not baseline
  complete for the current approved write-chain runtime.
- This section freezes persistence truth only.
- It does not require implementation changes by itself.

## File Truth Tables
- `file_assets`
- `evidences`

## Forum Truth Tables
- `forum_topics`
- `forum_posts`
- `forum_post_attachments`
- `forum_comments`
- `forum_bookmarks`
- `forum_follows`
- `forum_drafts`
- `forum_reports`
- `forum_risk_flags`
- `forum_moderation_cases`

### Forum attachment truth
- `forum_post_attachments`
  - owner: `ForumPost`
  - relation:
    - binds one existing `FileAsset` truth row to one existing `ForumPost`
    - `file_asset_id` must be unique at the binding-table layer
  - lifecycle boundary:
    - forum attachments must keep the three-step upload flow
    - `objectKey` remains storage location only
    - `Evidence` is not the forum attachment truth carrier in the current forum
      baseline

### Forum governance truth
- `forum_reports`
  - owner: `ForumReport`
  - semantic role:
    - append-only report submission truth for `ForumPost` or `ForumComment`
- `forum_risk_flags`
  - owner: `ForumRiskFlag`
  - semantic role:
    - controlled risk signal truth for forum governance only
- `forum_moderation_cases`
  - owner: `ForumModerationCase`
  - semantic role:
    - moderation decision carrier for forum content visibility governance

## Geo Pre-embed Tables
- `location_snapshots`
- `location_bindings`

Required geo columns:
- `lat`
- `lng`
- `coord_system`
- `provider`
- `address_snapshot`
- `poi_id`
- `city_code`
- `district_code`

## Live Pre-embed Tables
- `live_providers`
- `live_rooms`
- `live_bindings`
- `live_sessions`
- `live_events`
- `live_replay_assets`

## Policy
- PostgreSQL is the only relational truth store.
- Migrations are forward-only by default.
- Audit-bearing records must keep stable identifiers and trace references.

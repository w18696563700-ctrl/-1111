---
owner: Codex 总控
status: draft
purpose: Freeze the dedicated backend truth, persistence, derived governance summary, and audit/evidence linkage for whitelist, penalty, blacklist, permanent-ban, and appeal governance under the current App truth system.
layer: L3 Backend
---

# 黑白名单与永久封禁规则 V1 Backend Truth Addendum

## 1. Scope
- This addendum applies only to the fourth dedicated `docs/02_backend` package for:
  - governance penalty truth
  - whitelist-membership truth
  - permanent-ban truth
  - appeal-case truth
  - derived governance summary truth
  - audit and evidence linkage
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `apps/bff` aggregation specs
  - create a second permission truth
  - create a second identity or organization truth
  - approve a public blacklist or whitelist directory
  - approve a user-side governance history center

## 2. Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md)
  - [blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
  - [service_boundaries.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/service_boundaries.md)
  - [db_schema.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/db_schema.md)
  - [audit_log_spec.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/audit_log_spec.md)

## 3. Addendum Role
- Current `L0` and `L2` documents have already frozen:
  - governance overlay semantics
  - app-facing governance-summary and appeal-submit paths
  - admin-side penalty, whitelist, permanent-ban, and appeal action paths
  - minimum status families
- This addendum upgrades that package into a dedicated backend-truth package for:
  - which new tables are actually approved
  - which status fields remain distinct
  - how profile-side governance summary is derived
  - how governance evidence and audit must bind to current truth
- This addendum must not be read as:
  - approval for a second role system
  - approval for a second organization lifecycle
  - approval for a trust-score engine
  - approval for full linked-subject ban-network truth

## 4. Current Truth Ownership Freeze
- `Server` remains the only truth owner for:
  - governance penalty truth
  - whitelist-membership truth
  - permanent-ban truth
  - appeal-case truth
  - derived governance summary truth
  - governance-side evidence linkage
  - governance-side audit attribution
- `BFF` may:
  - shape profile-side governance summary
  - shape blocked-state copy
  - return controlled unavailable and invalid-state responses
- `BFF` must not:
  - own penalty lifecycle
  - own whitelist lifecycle
  - own permanent-ban lifecycle
  - own appeal decision truth
  - own a second governance-status store
- `Admin` consumes `Server` Admin APIs directly.
- `Admin` is not itself a truth owner.

## 5. Canonical Persistence Binding
- This dedicated package adopts the following current persistence family as the only approved governance-overlay truth family:
  - existing identity and organization anchors:
    - `organizations`
    - `organization_members`
  - existing governance and trace carriers:
    - `review_tasks`
    - `audit_logs`
    - `security_events`
  - existing file and evidence carriers:
    - `file_assets`
    - `evidences`
  - four new governance-overlay carriers:
    - `governance_penalties`
    - `governance_appeal_cases`
    - `governance_whitelist_memberships`
    - `governance_permanent_bans`
- Current round does not approve dedicated tables for:
  - `trust_levels`
  - `trust_snapshots`
  - `ban_relations`
  - `governance_status_snapshots`
  - `penalty_history_views`
  - `appeal_chat_threads`
  - `public_blacklist_directory`
  - `public_whitelist_directory`

## 6. Overlay-not-truth Rule
- Penalty, whitelist, blacklist, permanent ban, and appeal remain governance overlays only.
- They must not replace:
  - `roleKeys`
  - `certificationStatus`
  - `organizations.status`
  - `organization_members.member_status`
- Current hard rules:
  - whitelist never grants a forbidden action by itself
  - blacklist never becomes a shortcut replacement for organization disablement
  - permanent ban never becomes a shortcut replacement for organization closure truth
  - governance summary is derived, not a second identity or permission truth

## 7. Subject-scope Freeze
- The current minimal governance subject family remains aligned to the frozen contract:
  - `organization`
  - `organization_member`
- Current package meaning:
  - governance penalties may target one organization or one organization membership
  - permanent-ban applies to the same bounded subject family only
  - whitelist applies to organization only
- Current round explicitly does not approve:
  - user-only governance subjects outside membership scope
  - device-only ban truth
  - payment-marker ban truth
  - linked-subject network expansion

## 8. Governance Penalty Truth Freeze
- `governance_penalties` becomes the only current dedicated penalty truth carrier.
- Minimum columns that must exist before implementation:
  - `id`
  - `subject_type`
  - `subject_id`
  - `penalty_type`
  - `status`
  - `reason_code`
  - `reason_summary`
  - `effective_from`
  - `effective_until`
  - `source_review_task_id`
  - `source_object_type`
  - `source_object_id`
  - `created_by`
  - `created_at`
  - `lifted_at`
  - `updated_at`
- Minimum `penalty_type` family remains aligned to the frozen contract:
  - `warning`
  - `watchlist`
  - `restrict_publish`
  - `restrict_bid`
  - `blacklist`
- Minimum `status` family remains aligned to the frozen contract:
  - `active`
  - `lifted`
  - `expired`
- Current hard rules:
  - one current penalty row records one operator-governed decision
  - `watchlist` is implemented through penalty truth, not a second watchlist table
  - `blacklist` is implemented through penalty truth, not a second blacklist table
  - passive expiry must not rewrite identity or organization truth

## 9. Whitelist-membership Truth Freeze
- `governance_whitelist_memberships` becomes the only current whitelist truth carrier.
- Minimum columns that must exist before implementation:
  - `id`
  - `organization_id`
  - `status`
  - `reason_summary`
  - `effective_from`
  - `effective_until`
  - `created_by`
  - `created_at`
  - `revoked_at`
  - `updated_at`
- Current whitelist-membership status family is:
  - `active`
  - `revoked`
  - `expired`
- Current hard rules:
  - whitelist applies to organization only in this round
  - at most one current active whitelist membership may exist per organization
  - whitelist may affect exposure summary only
  - whitelist must not override active severe restriction or permanent ban

## 10. Permanent-ban Truth Freeze
- `governance_permanent_bans` becomes the only current permanent-ban truth carrier.
- Minimum columns that must exist before implementation:
  - `id`
  - `subject_type`
  - `subject_id`
  - `reason_code`
  - `reason_summary`
  - `source_review_task_id`
  - `source_object_type`
  - `source_object_id`
  - `created_by`
  - `created_at`
- Current package meaning:
  - one active permanent-ban row means the subject is permanently banned for the current approved bounded scope
  - permanent ban is append-only governed truth in this round
- Current round explicitly does not approve:
  - public permanent-ban browse surface
  - normal revoke workflow for permanent ban
  - linked-subject propagation truth through `ban_relations`
- If exceptional error-correction reversal is ever needed, it requires a later dedicated freeze and must not be improvised here.

## 11. Appeal-case Truth Freeze
- `governance_appeal_cases` becomes the only current dedicated appeal truth carrier.
- Current minimal appeal scope is:
  - appeals against `governance_penalties` only
- Current round does not approve:
  - permanent-ban appeals
  - public appeal chat
  - multi-round appeal workflow
- Minimum columns that must exist before implementation:
  - `id`
  - `penalty_id`
  - `status`
  - `reason`
  - `decision`
  - `decision_note`
  - `submitted_by`
  - `submitted_at`
  - `decided_by`
  - `decided_at`
  - `created_at`
  - `updated_at`
- Minimum `status` family remains aligned to the frozen contract:
  - `submitted`
  - `under_review`
  - `upheld`
  - `modified`
  - `revoked`
  - `closed`
- Current hard rules:
  - one active unresolved appeal may exist per penalty at a time
  - appeal detail is append-only governance truth, not frontend-local text
  - appeal decision may modify or revoke penalty effect only through controlled `Server` truth mutation

## 12. Derived Governance-summary Freeze
- `GET /api/app/profile/governance/status` remains a derived read model and must not be backed by a second summary table.
- Current canonical inputs for the derived summary are:
  - current organization scope
  - current actor organization membership
  - current active penalties that apply to the current subject set
  - current active whitelist membership for the current organization
  - current permanent-ban rows that apply to the current subject set
  - current unresolved appeal rows bound to the current effective penalty
- Current precedence for `governanceStatus` is:
  1. `permanently_banned`
  2. `blacklisted`
  3. `restricted`
  4. `watchlisted`
  5. `normal`
- Current derivation rule is:
  - `permanently_banned` if an active permanent-ban row applies
  - `blacklisted` if no permanent-ban applies and an active `blacklist` penalty applies
  - `restricted` if no stronger overlay applies and an active `restrict_publish` or `restrict_bid` penalty applies
  - `watchlisted` if no stronger overlay applies and an active `watchlist` penalty applies
  - `normal` otherwise
- `whitelistStatus` is derived independently from `governance_whitelist_memberships`.
- `appealEntryState` is derived from:
  - whether there is a current effective penalty
  - whether that penalty is appealable in current policy
  - whether there is already one active unresolved appeal

## 13. Permission-consumption Freeze
- Governance overlays may affect action release for:
  - project publish
  - bid submit
  - comment
  - message
  - contract upload
  - milestone submit
  - inspection submit or recheck
- But the effect must be consumed through controlled `Server` eligibility checks only.
- Current hard rules:
  - `permission_matrix.md` remains the baseline role and object-permission truth
  - governance overlays may narrow effective eligibility
  - governance overlays must not widen effective eligibility beyond role and certification truth

## 14. Review, Risk, And Source-link Freeze
- Penalty and permanent-ban decisions may be anchored to:
  - `review_tasks`
  - current business object refs
  - current evidence refs
  - current risk signals already materialized by `security_events`
- Current package meaning:
  - governance overlays may be downstream of review or report adjudication
  - governance overlays do not replace `ReviewTask`
  - governance overlays do not create a second ticket system
- `source_review_task_id`, `source_object_type`, and `source_object_id` remain the minimum source-link carriers in this package.

## 15. Evidence And File Linkage Freeze
- `evidences` and `file_assets` remain the only current evidence carriers for this package.
- Current minimal evidence rule is:
  - penalty, appeal, and permanent-ban detail may project `evidenceFileAssetIds`
  - those file ids must resolve through the current `Evidence -> FileAsset` chain
- Current round explicitly forbids:
  - raw URL as penalty or appeal evidence truth
  - `objectKey` as business truth
  - a separate `governance_evidence_links` table
  - Admin-memory-only evidence handling

## 16. Audit Increment Freeze
- This dedicated package freezes the following must-audit actions:
  - `GovernancePenaltyApplied`
  - `GovernanceAppealSubmitted`
  - `GovernanceAppealDecided`
  - `GovernanceWhitelistGranted`
  - `GovernanceWhitelistRevoked`
  - `GovernancePermanentBanApplied`
- Current semantics are:
  - penalty apply appends only on successful materialization of a penalty row
  - appeal submit appends only on successful materialization of an appeal row
  - appeal decision appends only on valid state transition
  - whitelist grant and revoke append only on valid state transition
  - permanent-ban apply appends only on successful materialization of a permanent-ban row
- Current round does not yet freeze a dedicated audit action for passive penalty expiry.

## 17. Explicit Non-goals
- No `trust_levels` truth package
- No `trust_snapshots` truth package
- No `ban_relations` truth package
- No public blacklist or whitelist directory
- No user-side penalty or appeal history center
- No permanent-ban appeal workflow
- No implementation unlock

## 18. Formal Conclusion
- Current formal conclusion:
  - `黑白名单与永久封禁规则 V1` now has a dedicated backend-truth package under `docs/02_backend`
  - current governance-overlay truth is frozen to four dedicated carriers:
    `governance_penalties`, `governance_appeal_cases`,
    `governance_whitelist_memberships`, and `governance_permanent_bans`
  - profile-side governance summary remains a `Server`-derived read model, not a second persisted summary truth
  - whitelist, blacklist, permanent-ban, penalty, and appeal remain overlays and do not replace current identity, organization, role, certification, or permission truth
- Current stage meaning:
  - backend truth and persistence freeze only
  - no implementation unlock by this document alone

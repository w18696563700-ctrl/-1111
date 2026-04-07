---
owner: Codex 总控
status: draft
purpose: Freeze the first dedicated L2 contract family for governance-status summary, appeal submit, admin-side penalty handling, whitelist management, and permanent-ban action under the current App truth system.
layer: L2 Contracts
---

# 黑白名单与永久封禁规则 V1 Contracts Addendum

## Scope
- This addendum applies only to the first dedicated `L2` contract package for:
  - profile-side governance status summary
  - profile-side appeal submit
  - admin-side penalty list and detail
  - admin-side appeal list, detail, and decision
  - admin-side whitelist grant and revoke
  - admin-side permanent-ban apply
- This addendum does not by itself:
  - unlock implementation
  - create a second permission truth
  - create a second identity or organization truth
  - approve a user-side penalty history center
  - approve a full user-side appeal center
  - approve a public blacklist or whitelist directory

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Canonical Path-family Rule
- App-facing governance summary and appeal entry remain under:
  - `/api/app/profile/*`
- Admin-side governance actions remain under:
  - `/server/admin/*`
- This package freezes the current minimal path family as:
  - `GET /api/app/profile/governance/status`
  - `POST /api/app/profile/governance/appeals`
  - `GET /server/admin/governance/penalties`
  - `GET /server/admin/governance/penalties/{penaltyId}`
  - `POST /server/admin/governance/penalties`
  - `GET /server/admin/governance/appeals`
  - `GET /server/admin/governance/appeals/{appealCaseId}`
  - `POST /server/admin/governance/appeals/{appealCaseId}/decide`
  - `POST /server/admin/governance/whitelist-memberships`
  - `POST /server/admin/governance/whitelist-memberships/{whitelistMembershipId}/revoke`
  - `POST /server/admin/governance/permanent-bans`
- This package explicitly forbids:
  - bare `/risk/*`
  - bare `/penalty/*`
  - bare `/appeal/*`
  - bare `/ban/*`
  - bare `/whitelist/*`

## Contract Role
- This package freezes transport and read-model semantics only.
- `Server` remains the only owner of:
  - penalty truth
  - whitelist-membership truth
  - permanent-ban truth
  - appeal-case truth
  - governance overlay state consumed by current permission and visibility rules
- `BFF` may shape:
  - profile-side governance summary
  - controlled blocked-state copy
- `BFF` must not own:
  - penalty lifecycle
  - whitelist lifecycle
  - permanent-ban lifecycle
  - appeal decision truth

## App-facing Boundary
- `GET /api/app/profile/governance/status` is the only current user-side read
  summary in this package.
- `POST /api/app/profile/governance/appeals` is the only current user-side
  write action in this package.
- This package does not approve:
  - user-side governance history list
  - user-side appeal list or detail
  - user-side blacklist detail center
  - user-side whitelist dashboard

## Governance Summary Boundary
- Current profile-side governance status summary must carry at minimum:
  - `organizationId`
  - `governanceStatus`
  - `whitelistStatus`
  - `appealEntryState`
  - optional `currentPenalty`
- `currentPenalty` must stay bounded to:
  - `penaltyId`
  - `penaltyType`
  - `status`
  - `effectiveFrom`
  - `effectiveUntil`
  - `reasonSummary`
  - `appealAllowed`
- This package does not approve:
  - full penalty history
  - full trust score
  - hidden permission bypass fields

## Appeal Submit Boundary
- Current minimum appeal-submit request must carry:
  - `penaltyId`
  - `reason`
  - optional `evidenceFileAssetIds`
- Current minimum appeal-submit response must carry:
  - `appealCaseId`
  - `penaltyId`
  - `status`
  - `traceId`
- This package does not approve:
  - user-side appeal review result list
  - user-side appeal chat or negotiation loop

## Admin Penalty Boundary
- `GET /server/admin/governance/penalties` must return:
  - `items`
  - `pagination`
- One penalty list item must carry at minimum:
  - `penaltyId`
  - `subjectType`
  - `subjectId`
  - `penaltyType`
  - `status`
  - `effectiveFrom`
  - `effectiveUntil`
- `GET /server/admin/governance/penalties/{penaltyId}` must carry at minimum:
  - `penaltyId`
  - `subjectType`
  - `subjectId`
  - `penaltyType`
  - `status`
  - `reasonCode`
  - `reasonSummary`
  - `evidenceFileAssetIds`
  - `effectiveFrom`
  - `effectiveUntil`
  - `createdAt`
  - `createdBy`
- `POST /server/admin/governance/penalties` must carry at minimum:
  - `subjectType`
  - `subjectId`
  - `penaltyType`
  - `reasonCode`
  - optional `reasonSummary`
  - optional `effectiveUntil`
  - optional `evidenceFileAssetIds`

## Admin Appeal Boundary
- `GET /server/admin/governance/appeals` must return:
  - `items`
  - `pagination`
- One appeal list item must carry at minimum:
  - `appealCaseId`
  - `penaltyId`
  - `status`
  - `submittedAt`
- `GET /server/admin/governance/appeals/{appealCaseId}` must carry at minimum:
  - `appealCaseId`
  - `penaltyId`
  - `status`
  - `reason`
  - `evidenceFileAssetIds`
  - `submittedAt`
  - `decidedAt`
  - `decisionNote`
- `POST /server/admin/governance/appeals/{appealCaseId}/decide` must carry:
  - `decision`
  - optional `decisionNote`

## Whitelist And Permanent-ban Boundary
- `POST /server/admin/governance/whitelist-memberships` must carry:
  - `organizationId`
  - optional `reasonSummary`
  - optional `effectiveUntil`
- `POST /server/admin/governance/whitelist-memberships/{whitelistMembershipId}/revoke`
  must carry:
  - optional `reasonSummary`
- `POST /server/admin/governance/permanent-bans` must carry:
  - `subjectType`
  - `subjectId`
  - `reasonCode`
  - optional `reasonSummary`
  - optional `evidenceFileAssetIds`
- This package does not approve:
  - a public whitelist or blacklist browse surface
  - a user-side permanent-ban detail page

## Status-family Boundary
- Current governance-status family is frozen as:
  - `normal`
  - `watchlisted`
  - `restricted`
  - `blacklisted`
  - `permanently_banned`
- Current whitelist-status family is frozen as:
  - `none`
  - `active`
- Current penalty-status family is frozen as:
  - `active`
  - `lifted`
  - `expired`
- Current appeal-entry-state family is frozen as:
  - `not_available`
  - `available`
  - `pending`
- Current appeal-status family is frozen as:
  - `submitted`
  - `under_review`
  - `upheld`
  - `modified`
  - `revoked`
  - `closed`

## Truth-preservation Rule
- Governance overlays in this package must not replace:
  - `roleKeys`
  - `certificationStatus`
  - organization active or disabled truth
  - membership active or disabled truth
- Whitelist must never bypass `permission_matrix.md`.
- Permanent ban must not become a hidden substitute for organization-state
  disablement.

## Error-family Rule
- This package introduces the current minimum `GOVERNANCE` error family only:
  - `GOVERNANCE_STATUS_UNAVAILABLE`
  - `GOVERNANCE_APPEAL_SUBMIT_INVALID`
  - `GOVERNANCE_PENALTY_RESOURCE_UNAVAILABLE`
  - `GOVERNANCE_PENALTY_APPLY_INVALID`
  - `GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE`
  - `GOVERNANCE_APPEAL_DECIDE_INVALID`
  - `GOVERNANCE_WHITELIST_GRANT_INVALID`
  - `GOVERNANCE_WHITELIST_REVOKE_INVALID`
  - `GOVERNANCE_PERMANENT_BAN_INVALID`
  - `GOVERNANCE_INVALID_STATE`

## Current Non-goals
- No full user-side governance center
- No user-side penalty history center
- No user-side appeal history center
- No public blacklist or whitelist browse surface
- No automatic permission bypass through whitelist
- No implementation unlock by this document alone

## Formal Conclusion
- Current formal conclusion:
  - the first dedicated `黑白名单与永久封禁规则 V1` contract family is now frozen
    as `profile` summary plus minimal admin governance actions
  - blacklist, whitelist, permanent-ban, penalty, and appeal remain governance
    overlays, not replacements for current identity or permission truth
- Current stage meaning:
  - `L2 contracts freeze` only
  - no implementation unlock by this addendum alone

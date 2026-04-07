---
owner: Codex 总控
status: draft
purpose: Freeze the four-document governance direction into the current App truth system, so future contracts and implementation can proceed without inventing a second identity, permission, or route system.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 App 对齐冻结版 V1

## 1. Scope
- This file freezes the App-aligned baseline for the following governance set:
  - account and enterprise certification
  - fake-project report and adjudication
  - contract archive and mandatory fulfillment chain
  - whitelist / blacklist / permanent ban / appeal
- This file applies only to the current repo and current App stack.
- This file does not by itself:
  - approve implementation
  - modify OpenAPI directly
  - override already accepted current-board release or implementation gates

## 2. Alignment Basis
- This file is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
  - [exhibition_home_ordered_marketplace_unified_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 3. Non-negotiable App-truth Rules
- `organization` remains the only current organization business truth.
- `organization_members` remains the current organization membership truth.
- `roleKeys` remains the only current app-facing role-key carrier.
- `certificationStatus` remains the current qualification-release truth field.
- `permission_matrix.md` remains the only current formal permission baseline.
- App-facing paths must remain inside `/api/app/*`.
- Admin-facing paths must remain inside `/server/admin/*`.
- `BFF` remains aggregation only; it must not own governance truth or a second
  state machine.
- File truth remains:
  - upload `init`
  - direct upload
  - upload `confirm`
  - `FileAsset` as truth

## 4. Conflict Priority
- If this file conflicts with the current already-frozen publish-board corridor
  for active implementation, the current accepted board freeze wins.
- Therefore this file:
  - sets governance direction
  - constrains later contracts
  - does not reopen current implementation rounds by itself

## 5. Building Responsibilities In Current App Terms
- `exhibition`
  - owns project display and current transaction action entry surfaces
  - hosts publish, bid, contract, milestone, inspection, rating, and dispute
    continuation pages
  - hosts action guards only, not identity truth
- `messages`
  - may host notices, reminders, and object-linked communication continuation
  - does not own transaction truth, penalty truth, or report-case truth
- `profile`
  - remains the only current main entry for:
    - login
    - organization handoff
    - certification state
    - session center
    - later eligibility, risk, and appeal summary surfaces

## 6. Governance Labels Versus Current Truth
- Product-side governance labels may still be used in copy or documentation:
  - visitor
  - enterprise-certified actor
  - high-trust enterprise
- But current formal truth may only rely on:
  - shell blocking state
  - `organizationId`
  - `membershipStatus`
  - `certificationStatus`
  - `roleKeys`
  - object scope
- Explicit freeze:
  - `U0/U1/U2/U3` must not become formal backend role keys in the current App
    round
  - a separate “real-name user tier” must not be invented as a second truth
    layer before formal identity truth is frozen

## 7. Current Formal Action Gates
- Publish project:
  - current actor identity present
  - organization scope present
  - allowed buyer-side role from `roleKeys`
  - `certificationStatus = approved`
- Submit bid:
  - current actor identity present
  - organization scope present
  - allowed supplier-side role from `roleKeys`
  - `certificationStatus = approved`
- Confirm contract:
  - current actor identity present
  - organization scope present
  - role and object scope allowed by current order-side truth
- Submit milestone / inspection / recheck:
  - current actor identity present
  - object scope allowed
- Open dispute:
  - current actor identity present
  - organization scope belongs to the current instance side

## 8. Certification Document Alignment Freeze
- The certification-governance document must align to current truth as follows:
  - organization creation, join, switch, and membership remain profile-domain
    truth
  - organization certification remains the current certification truth owner
  - certification release to transaction actions is controlled through
    `certificationStatus`
- Current frozen profile family must remain the main base:
  - `GET /api/app/profile/index`
  - `POST /api/app/profile/organization/create`
  - `POST /api/app/profile/organization/join-by-code`
  - `POST /api/app/profile/organization/switch`
  - `GET /api/app/profile/organization/mine`
  - `GET /api/app/profile/organization/members`
  - `POST /api/app/profile/certification/submit`
  - `GET /api/app/profile/certification/current`
  - `POST /api/app/profile/certification/resubmit`
- This document set must not create:
  - bare `/auth/*` for Flutter
  - bare `/orgs/*`
  - bare `/me/*`
  - a second enterprise certification truth

## 9. Fake-project Report Document Alignment Freeze
- Report and adjudication must be object-linked only.
- Allowed primary target objects in the current App direction are:
  - project
  - organization profile
  - bid
  - contract
  - inspection / acceptance object
  - dispute-adjacent object where applicable
- Current freeze ruling:
  - the report/adjudication family is directionally approved
  - but it is not yet a frozen current contract family in `openapi.yaml`
- Therefore the next contract package for this document must:
  - stay inside `/api/app/*`
  - stay inside `/server/admin/*`
  - bind reports to current transaction objects
  - avoid inventing a second case-truth owner outside `Server`

## 10. Contract Archive And Fulfillment Document Alignment Freeze
- This governance document must layer onto the already-existing exhibition
  transaction object chain.
- It must reuse the current current-route families already present in the App:
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `POST /api/app/bid/submit`
  - `GET /api/app/order/detail`
  - `POST /api/app/order/create`
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- It must not create:
  - a second contract truth outside the order/contract object chain
  - a second attachment truth outside `FileAsset`
  - a second fulfillment state machine in `BFF` or Flutter

## 11. Risk, Ban, And Appeal Document Alignment Freeze
- Risk, penalty, ban, whitelist, and appeal must be treated as governance
  overlays on top of the current actor and organization truth.
- They must not replace:
  - `roleKeys`
  - `certificationStatus`
  - object-scope permission judgement
- Current aligned direction is:
  - profile-side summary and explanation entry
  - server-admin-side review, penalty, and appeal action
- Current explicit freeze:
  - no permanent-ban state may become a fake replacement for disabled
    `organization` or `membership` truth
  - no whitelist tag may become a permission bypass over
    `permission_matrix.md`

## 12. Admin Alignment Freeze
- Admin remains `Server`-admin only.
- Governance admin workbenches must stay under `/server/admin/*`.
- Existing review family already frozen for organization review remains a
  baseline example:
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
- Later governance admin route packages may extend under `/server/admin/*`
  only after separate contract freeze.

## 13. Profile-building Expansion Freeze
- The mother blueprint wants `我的` to become:
  - account center
  - certification center
  - enterprise center
  - qualification center
  - risk and penalty center
  - rules and agreement center
- Current App-aligned ruling:
  - this direction is accepted
  - but only login, organization handoff, certification current, company view,
    and session center are already concretely present
  - risk center, appeal center, and rules center must not be marked as already
    implemented

## 14. Current Explicit Non-goals
- No second identity truth beside current organization-centered baseline
- No second app-facing role family beside current `roleKeys`
- No bare non-`/api/app/*` Flutter route family
- No bare non-`/server/admin/*` admin route family
- No local Flutter final permission judgement
- No `BFF`-owned governance state machine
- No direct claim that the four-document product target is already implemented

## 15. Next Freeze Order
1. Freeze certification-governance contracts aligned to current profile truth
2. Freeze report/adjudication contracts aligned to current exhibition objects
3. Freeze contract archive and fulfillment governance contracts on top of the
   existing transaction family
4. Freeze risk, penalty, whitelist, blacklist, and appeal contracts aligned to
   current organization and admin truth

## 16. Conclusion
- The four-document governance direction is accepted only in this aligned form.
- Downstream work must use:
  - current `organization` truth
  - current `roleKeys`
  - current `certificationStatus`
  - current `permission_matrix.md`
  - current `/api/app/*` family
  - current `/server/admin/*` family
- Any downstream package that renames those truths or opens a second route
  system fails this freeze directly.

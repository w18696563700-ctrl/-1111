---
owner: Codex 总控
status: draft
purpose: Freeze the first dedicated L2 contract family for fake-project report intake, temporary restriction consumption, and admin-side adjudication handling under the current App truth system.
layer: L2 Contracts
---

# 假项目举报与裁决规则 V1 Contracts Addendum

## Scope
- This addendum applies only to the first dedicated `L2` contract package for:
  - fake-project report submit
  - fake-project report admin queue and detail
  - explanation request
  - adjudication decision
  - governance-ticket escalation
- This addendum does not by itself:
  - unlock implementation
  - reopen dispute detail, history, resolution, or appeal families
  - approve a public report center
  - approve a user-side report-history center
  - define downstream penalty, blacklist, whitelist, or permanent-ban contracts

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md)
  - [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
  - [dispute_entry_minimal_governance_action_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md)
  - [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Canonical Path-family Rule
- Reporter-side app-facing path must stay inside:
  - `/api/app/*`
- Admin-side adjudication path must stay inside:
  - `/server/admin/*`
- This package freezes the current minimal path family as:
  - `POST /api/app/exhibition/report/submit`
  - `GET /server/admin/exhibition/report-cases`
  - `GET /server/admin/exhibition/report-cases/{reportCaseId}`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/request-explanation`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/decide`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/escalate`
- This package explicitly forbids:
  - bare `/report/*`
  - bare `/governance/*`
  - bare `/adjudication/*`
  - reusing `POST /api/app/dispute/open` as fake-project report intake

## Current Contract Role
- This package freezes the transport contract only.
- `Server` remains the only owner of:
  - report-case truth
  - review-task truth
  - governance-ticket truth
  - adjudication outcome truth
  - temporary restriction truth
- `BFF` may later shape:
  - accepted submit acknowledgment
  - blocked-state copy
  - controlled unavailable responses
- `BFF` must not own:
  - report-case lifecycle
  - adjudication state machine
  - temporary restriction truth

## App-facing Minimum Path
- The only app-facing fake-project report path in this round is:
  - `POST /api/app/exhibition/report/submit`
- Current minimum request body is:
  - `targetType`
  - `targetId`
  - `reasonCode`
  - optional `reasonDetail`
  - optional `evidenceFileAssetIds`
- Current target scope is bounded to:
  - `project`
  - `project_profile`
  - `bid`
  - `contract`
  - `inspection`
- This package does not approve:
  - user-side report list
  - user-side report detail
  - user-side report history
  - user-side adjudication dashboard

## Admin Path Matrix
- Current admin fake-project report path family is:
  - `GET /server/admin/exhibition/report-cases`
  - `GET /server/admin/exhibition/report-cases/{reportCaseId}`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/request-explanation`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/decide`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/escalate`
- Current admin path meaning is bounded to:
  - queue consumption
  - detail read
  - explanation request
  - adjudication decision
  - governance-ticket escalation
- This package does not approve:
  - admin appeal routes
  - admin blacklist routes
  - admin permanent-ban routes

## Reason-code Freeze
- The current minimum app-facing `reasonCode` allow-list is frozen as:
  - `fabricated_project`
  - `unauthorized_project_material`
  - `false_budget_or_schedule`
  - `fake_organization_or_contact`
  - `fraudulent_collection_attempt`
  - `other`
- Current meaning:
  - ordinary reporters report suspicious project-authenticity or fraud-adjacent
    transaction issues only
  - malicious reporting remains `Server`-side governance truth, not an
    app-facing reason code

## Submit Result Boundary
- The current minimum app-facing submit result family is:
  - new accepted report case
  - equivalent active report case already exists
- Minimum response fields are:
  - `reportCaseId`
  - `targetType`
  - `targetId`
  - `status`
  - `acceptMode`
  - `traceId`
- Current app-facing accepted meanings remain only:
  - 举报已提交
  - 已存在处理中举报
- Report submit does not imply:
  - immediate hide
  - immediate penalty
  - adjudication completed

## Admin Queue Boundary
- The current minimum admin queue query fields are:
  - `page`
  - `pageSize`
  - `status`
  - `targetType`
  - `keyword`
- The current minimum admin queue response must return:
  - `items`
  - `pagination`
- One queue item must carry at minimum:
  - `reportCaseId`
  - `targetType`
  - `targetId`
  - `reasonCode`
  - `status`
  - `submittedAt`
  - `temporaryRestrictionState`

## Admin Detail Boundary
- The current minimum admin detail must carry:
  - `reportCaseId`
  - `targetType`
  - `targetId`
  - `targetTitle`
  - `reasonCode`
  - `reasonDetail`
  - `status`
  - `temporaryRestrictionState`
  - `reviewTaskId`
  - `governanceTicketId`
  - `reporter.actorId`
  - `reporter.organizationId`
  - `evidenceFileAssetIds`
  - `submittedAt`
  - `explanationRequestedAt`
  - `explanationReceivedAt`
  - `adjudicationResult`
  - `decidedAt`
  - `decisionNote`
- This package accepts nullable fields for values not yet materialized at the
  current processing step.

## Admin Action Boundary
- `request-explanation` request must carry:
  - `question`
  - optional `dueAt`
- `decide` request must carry:
  - `adjudicationResult`
  - optional `decisionNote`
- `escalate` request must carry:
  - `reason`
- All three admin-side action paths may return only:
  - `ActionAckResponse`

## Status And Result Boundary
- The current minimum report-case status family is frozen as:
  - `submitted`
  - `under_review`
  - `explanation_requested`
  - `escalated`
  - `decided`
  - `closed`
- The current minimum adjudication-result family is frozen as:
  - `not_established`
  - `partially_established`
  - `materially_established`
- The current minimum temporary-restriction family is frozen as:
  - `not_applied`
  - `active`
  - `lifted`

## Error Boundary
- This package adds the following minimum review error family:
  - `REVIEW_REPORT_INVALID`
  - `REVIEW_REPORT_RESOURCE_UNAVAILABLE`
  - `REVIEW_REPORT_INVALID_STATE`
  - `REVIEW_REPORT_REQUEST_EXPLANATION_INVALID`
  - `REVIEW_REPORT_DECIDE_INVALID`
  - `REVIEW_REPORT_ESCALATE_INVALID`
- Current meaning:
  - malformed or incomplete report-submit input remains a `Server` invalid
    request error
  - duplicate-equivalent active report may be accepted idempotently and does not
    require a dedicated duplicate code in this round
  - hidden or absent target or report-case remains controlled unavailable, not
    fake success

## Current Non-goals
- No public anonymous report path
- No user-side report-history center
- No report-processing dashboard for ordinary users
- No appeal workflow contract
- No blacklist or penalty contract
- No reopening of dispute detail, list, escalate, resolve, or history families

## Formal Conclusion
- Current formal conclusion:
  - ordinary actors may submit bounded fake-project reports only through
    `POST /api/app/exhibition/report/submit`
  - admin-side fake-project governance stays under
    `/server/admin/exhibition/report-cases/*`
  - report intake, adjudication, and escalation remain `Server`-owned
    governance truth
- Current stage meaning:
  - `L2 contracts freeze` only
  - no implementation unlock by this document alone

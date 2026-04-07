---
owner: Codex 总控
status: draft
purpose: Freeze the App-aligned governance rules for fake-project reporting, temporary risk restriction, review-task handoff, adjudication discipline, and closure semantics, without inventing a second dispute truth or a second governance ticket system.
layer: L0 SSOT
---

# 假项目举报与裁决规则 V1 App 对齐冻结稿

## 1. Scope
- This file applies only to the current V1 governance package for:
  - fake-project reporting
  - report intake eligibility
  - report-to-review-task or governance-ticket handoff
  - temporary risk restriction before final adjudication
  - adjudication result semantics
  - notice, audit, and closure requirements
- This file does not by itself:
  - implement a full report center
  - freeze exact app-facing report route payloads
  - reopen dispute detail, history, escalation, or resolution families
  - define penalty, blacklist, whitelist, or appeal in full
  - approve implementation or release

## 2. Alignment Basis
- This file is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
  - [dispute_entry_minimal_governance_action_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md)
  - [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 3. Current Formal Truth Boundary
- `Server` remains the only truth owner for:
  - project truth
  - project visibility or restriction truth
  - review task truth
  - governance ticket truth
  - risk classification truth
  - adjudication outcome truth
  - audit attribution truth
- `BFF` may:
  - normalize auth and object context
  - shape read-side blocked-state copy
  - shape accepted report-submit acknowledgement after formal contract freeze
- `BFF` must not:
  - own report-case truth
  - own adjudication truth
  - own project freeze truth
  - own a second risk state machine
- `Flutter App` may:
  - expose later report entry
  - display current restricted or unavailable state
  - hand off to controlled report submission once frozen in contracts
- `Flutter App` must not:
  - locally hide a project as a final governance decision
  - locally adjudicate fake-project claims
  - confuse dispute action with report action

## 4. One-line Goal
- The fake-project governance goal is:
  - an eligible actor reports a concrete suspicious project or transaction object
  - `Server` materializes controlled review or governance handling
  - high-risk cases may trigger immediate stop-loss restriction
  - adjudication closes with evidence, audit, and notice

## 5. Core Identity And Eligibility Ruling
- Current report eligibility must stay inside the current App truth system.
- This means any future fake-project report path must derive reporter legitimacy
  from:
  - actor identity present
  - current session valid
  - current object scope where required
  - organization scope where the object is transaction-side bound
- This document explicitly does not freeze:
  - a separate person-real-name report gate
  - anonymous public reporting as the default V1 path
- Current aligned restriction:
  - fake-project reporting in V1 should be tied to authenticated actors only
  - where the report target is an instance-bound trade object, the actor must
    also satisfy the current scope truth

## 6. Report Object Boundary
- A fake-project report must always bind to a concrete target object.
- Allowed primary target objects in the current App direction are:
  - project
  - organization-facing project profile projection
  - bid object
  - contract object
  - inspection or acceptance-side object
- Explicitly forbidden:
  - free-floating text complaint with no target anchor
  - a general public “governance mailbox” with no object binding
  - a second dispute object created by report submission

## 7. Relationship With Dispute Truth
- `Dispute` and fake-project report are not the same thing.
- Current `Dispute` truth remains:
  - order-bound
  - object-scoped
  - app-facing only for `open` and the currently planned `withdraw`
- Therefore this document freezes:
  - fake-project reporting must not be implemented by overloading
    `POST /api/app/dispute/open`
  - dispute state must not become the report-case truth
  - report adjudication must not silently reopen dispute detail, resolution,
    escalation, or history families

## 8. Relationship With ReviewTask And Governance Ticket Truth
- Report intake must reuse the already-frozen governance semantics:
  - `ReviewTask`
  - risk classification
  - governance ticket lifecycle
- This means:
  - ordinary report intake may materialize a `ReviewTask`
  - high-severity or cross-object contradiction may escalate into governance
    ticket truth
- This document explicitly forbids:
  - a second ticket store in Admin
  - a second review-case truth outside the controlled `Server` governance path
  - bypassing the review-to-ticket handoff discipline already frozen in
    [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)

## 9. Current Report Intake Semantics
- Current report intake semantics for this V1 rule set are:
  - target object must exist
  - report reason must be bounded
  - explanation text must be bounded
  - evidence refs must be allowed where the chosen reason requires support
  - duplicated equivalent active reports may be handled through bounded
    idempotent acceptance after later contract freeze
- Current allowed high-level reason families may include:
  - fake or fabricated project
  - unauthorized project material or drawing source
  - false budget or false location / schedule statement
  - fake organization or fake contact relation
  - fraudulent collection attempt under project pretext
- This file does not yet freeze:
  - the exact reason-code enum
  - the exact request schema
  - the exact app-facing endpoint name

## 10. Temporary Risk Restriction Rule
- Temporary restriction is a stop-loss action, not a final conviction.
- Once a fake-project report reaches a high-risk threshold under `Server`
  governance handling, `Server` may apply one or more controlled restrictions:
  - remove project from public display
  - stop new bid-entry continuation
  - stop new paid or gated project-side actions
  - preserve current evidence snapshot refs
- Controlled restriction must remain:
  - `Server`-owned
  - auditable
  - reversible after adjudication
- `Flutter App` and `BFF` may only consume the resulting restricted state.

## 11. Adjudication Result Families
- The current adjudication result family is frozen conceptually as:
  - not established
  - partially established
  - materially established
- Their semantic effect is:
  - not established
    - remove temporary restriction where applicable
    - close governance handling with audit
  - partially established
    - maintain or convert controlled restriction into remediation handling
    - preserve recorded governance outcome
  - materially established
    - keep hard restriction on the current target
    - hand off to downstream penalty handling if later frozen
    - preserve full evidence and audit chain
- This document does not yet freeze:
  - the penalty matrix
  - blacklist decision flow
  - permanent-ban decision flow

## 12. Evidence-chain Rule
- Fake-project reporting must follow the current evidence-chain discipline.
- Minimum required evidence discipline:
  - target object ref
  - actor ref
  - time
  - reason
  - current object snapshot ref where materialized
  - file or evidence refs where provided
- Evidence truth must continue to use:
  - `FileAsset`
  - existing object refs
  - current audit attribution rules
- This document explicitly forbids:
  - raw URL as evidence truth
  - `BFF`-local evidence-only truth
  - Admin-side manual-only case memory

## 13. Current Admin Handling Boundary
- Admin handling remains `Server`-admin only.
- Current formal admin route truth is still limited in this area:
  - exact fake-project report admin routes are not yet frozen
  - later governance review routes must remain under `/server/admin/*`
- This document accepts in direction the following admin workbench capabilities:
  - report queue
  - evidence viewer
  - review-task decision panel
  - ticket escalation view
  - adjudication record
  - notice and audit viewer
- But this document explicitly does not claim:
  - those Admin surfaces already exist
  - those Admin routes are already frozen in OpenAPI

## 14. App-facing Route Boundary
- Any future app-facing fake-project report route family must stay inside
  `/api/app/*`.
- Current freeze does not allow:
  - bare `/report/*`
  - bare `/governance/*`
  - bare `/adjudication/*`
- The route family may later be added only through separate contract freeze.
- Current route-family alignment rule:
  - if the report targets exhibition transaction objects, the app-facing route
    must remain aligned to the exhibition-side product family
  - it must not hijack the forum report family

## 15. Relationship With Current Publish And Trade Corridors
- This document must not expand the current publish board by itself.
- This means:
  - it does not reopen bid/order/contract implementation rounds
  - it does not override the current publish minimum-success corridor
  - it does not automatically unlock downstream dispute governance expansion
- If any interpretation conflicts with an active board freeze, the active board
  freeze wins.

## 16. Notice And Closure Rule
- Fake-project handling must produce controlled notice semantics for:
  - reporter-side intake acknowledgement after contract freeze
  - reported-side explanation request where applicable
  - adjudication result communication where applicable
- This document does not yet freeze:
  - exact notice templates
  - exact message-center payloads
- Closure condition for the current rule set is:
  - governance handling reaches terminal review or ticket closure
  - audit attribution exists
  - the target object restriction state is consistent with the adjudication
    outcome

## 17. Audit Requirements
- The following actions must remain auditable:
  - report intake acceptance
  - temporary restriction applied
  - explanation requested
  - explanation received
  - adjudication decided
  - restriction lifted or maintained
- Invalid report attempts must not be written as successful adjudication actions.
- High-risk restriction without audit attribution is a release blocker.

## 18. Explicit Non-goals
- No public anonymous report center
- No second dispute truth
- No dispute detail/history/escalation reopen
- No second review or ticket truth
- No full penalty workflow in this document
- No full blacklist or appeal workflow in this document
- No exact OpenAPI route freeze in this document
- No implementation unlock by this file alone

## 19. Acceptance Gate For This Rule Set
- Any future fake-project report must bind to a concrete target object.
- High-risk fake-project handling must be able to apply one-step temporary
  restriction through `Server` truth.
- Report handling must end in review-task or governance-ticket closure with
  audit attribution.
- App-facing consumption must distinguish:
  - report/review governance restriction
  - dispute action restriction
  - route absence

## 20. Next Single Action
- The next single action after this freeze is:
  - freeze the L2 contract package for fake-project report submission and
    adjudication consumption under current `/api/app/*` and `/server/admin/*`
    boundaries only

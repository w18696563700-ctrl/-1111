---
owner: Codex 总控
status: draft
purpose: Freeze the App-aligned governance rules for contract archive, contract confirmation release, fulfillment-chain continuity, inspection alignment, and archive gating, while staying inside the current order / contract / milestone / inspection truth families.
layer: L0 SSOT
---

# 合同归档与履约强制入链规则 V1 App 对齐冻结稿

## 1. Scope
- This file applies only to the current V1 governance package for:
  - contract archive entry semantics
  - contract confirmation release
  - fulfillment-chain mandatory continuity
  - milestone and inspection alignment
  - archive gating before downstream closure actions
- This file does not by itself:
  - approve implementation
  - freeze exact new route payloads for missing fulfillment artifacts
  - reopen contract history, signing-provider integration, or legal-review loops
  - reopen inspection history or multi-round console capability
  - define penalty or dispute-resolution governance

## 2. Alignment Basis
- This file is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)
  - [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
  - [lifecycle_state_machine.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/lifecycle_state_machine.md)
  - [inspection_phase3_lifecycle_alignment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/inspection_phase3_lifecycle_alignment_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 3. Current Formal Truth Boundary
- `Server` remains the only truth owner for:
  - order truth
  - contract truth
  - milestone truth
  - inspection truth
  - archive gating truth
  - final eligibility for downstream rating and dispute continuation
- `BFF` may:
  - shape read-side contract, milestone, and inspection payloads
  - forward command requests
  - normalize controlled unavailable responses
- `BFF` must not:
  - own contract version truth
  - own fulfillment state-machine truth
  - own archive-complete truth
- `Flutter App` may:
  - host contract detail / confirm / amend
  - host milestone list / submit
  - host inspection detail / submit / recheck
  - display current blocked-state explanation
- `Flutter App` must not:
  - infer archive completion locally
  - treat route presence as full fulfillment capability
  - create a local fulfillment or archive workflow model

## 4. One-line Goal
- The current governance goal is:
  - once a project becomes an order-side cooperation,
  - contract truth must be confirmed before entering real fulfillment progress,
  - milestone and inspection objects must remain on-platform,
  - and later archive-dependent actions must not outrun archive readiness.

## 5. Current Formal Object Family
- Current aligned object family remains:
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `AuditLog`
  - `FileAsset`
- This document accepts in direction, but does not yet freeze as formal route
  contracts:
  - daily progress log object
  - acceptance archive object
  - archive export object
- Therefore:
  - current formal truth already exists for contract / milestone / inspection
  - daily-progress and final archive still require later contract freeze

## 6. Current Lifecycle Alignment
- Current top-level lifecycle truth remains:
  - `Order`
    - `draft -> pending_confirm -> active -> completed | disputed -> archived`
  - `Contract`
    - `draft -> pending_confirm -> active -> amended -> archived`
  - `Milestone`
    - `pending_submission -> submitted -> completed`
  - `Inspection`
    - `draft -> submitted`
    - `submitted -> passed | rectification_required`
    - `rectification_required -> rechecked`
    - `rechecked -> passed | archived`
- This document must not create:
  - a second lifecycle truth for those objects
  - a second fulfillment workflow model in `BFF` or Flutter

## 7. Current Formal Route Family
- The current app-facing transaction route family already present in the App and
  contracts includes:
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
- Critical alignment ruling:
  - the route family listed above is cited for App-truth alignment only
  - it does not by itself unlock the whole downstream implementation round
  - if a current active board freeze is narrower, the active board freeze wins

## 8. Contract Entry Rule
- Contract entry remains order-bound.
- Current formal contract read and command semantics remain:
  - `contract/detail` is the minimum read projection
  - `contract/confirm` is the minimum confirmation command
  - `contract/amend` is the minimum amendment handoff
- Current explicit non-approval:
  - no contract history route
  - no contract list route
  - no electronic-sign provider callback
  - no full clause editor
  - no legal review console in this rule set

## 9. Contract Archive Meaning In Current App Terms
- In current App-aligned V1 terms, “contract archive” does not mean:
  - a full digital-sign product
  - a public contract-history center
  - a second document-management subsystem
- Current accepted meaning is:
  - contract truth exists under order scope
  - contract file references remain bound to current file truth
  - both sides confirm the current contract state through the existing workflow
  - downstream fulfillment actions must not outrun that confirmation state

## 10. File Truth Rule
- Contract and fulfillment evidence files must continue to use:
  - upload `init`
  - direct upload
  - upload `confirm`
  - `FileAsset` as truth
- `objectKey` remains storage location only.
- This document explicitly forbids:
  - raw URL as contract truth
  - a local Flutter-only contract-file carrier
  - a parallel evidence-file subsystem outside shared upload truth

## 11. Mandatory Contract-before-fulfillment Rule
- Current aligned release rule is:
  - contract confirmation must precede fulfillment continuation that depends on
    a confirmed cooperation baseline
- In current App terms, this means:
  - milestone and inspection continuation may not reinterpret missing or
    unavailable contract truth as acceptable completion
  - later archive-dependent actions must not be released if the contract-side
    workflow is still unavailable or inconsistent
- This document does not yet freeze:
  - the exact Boolean or derived field name for “archive-ready”
  - the exact denial error-code family for every downstream action

## 12. Milestone Continuity Rule
- Milestone continuity remains part of the current on-platform fulfillment chain.
- Current formal semantics remain:
  - `milestone/list` is the minimum read carrier
  - `milestone/submit` is the minimum submit carrier
- Current explicit non-approval:
  - no milestone history center
  - no second milestone continuation model
  - no milestone-only approval console
- This document adds one governance interpretation:
  - milestone submission must remain attributable to a real order-bound
    fulfillment object
  - milestone submissions must remain auditable and object-linked

## 13. Inspection Continuity Rule
- Inspection remains the current minimum acceptance-side self-workflow.
- Current formal semantics remain:
  - `inspection/detail` is the minimum read projection
  - `inspection/submit` is the minimum command
  - `inspection/recheck` is the minimum recheck command, but still outside the
    first-release frontend happy-path bundle
- Current explicit non-approval:
  - no inspection history center
  - no inspection governance console
  - no multi-round expansion beyond the current minimum loop
- This document adds one governance interpretation:
  - an inspection outcome is part of the mandatory on-platform fulfillment
    evidence chain
  - it must not be replaced by off-platform verbal acceptance

## 14. Daily-progress And Archive Gap Freeze
- The mother blueprint expects:
  - daily progress logs
  - final archive
  - archive export
- Current repo truth does not yet freeze those as app-facing contract families.
- Therefore this document freezes the gap explicitly:
  - daily-progress is directionally accepted
  - archive-confirm is directionally accepted
  - archive-export is directionally accepted
  - none of those are yet frozen app-facing paths in the current repo
- Downstream agents must not:
  - claim daily-progress is already contract-frozen
  - claim final archive is already implemented
  - invent bare non-`/api/app/*` families to compensate

## 15. Downstream Release Gating Rule
- Later downstream actions such as rating and dispute closure handling must not
  outrun the fulfillment-chain archive boundary.
- In current App-aligned terms, this means:
  - route presence for `rating` or `dispute` does not mean archive conditions
    are already satisfied
  - `Server` must remain final gate owner for any archive-dependent release
    decision
- This document does not yet freeze:
  - the exact archive prerequisite matrix for every downstream action
  - the exact route-by-route denial responses

## 16. Current Admin Boundary
- Admin remains `Server`-admin only.
- This document accepts in direction, but does not yet freeze exact admin route
  families for:
  - contract archive review
  - fulfillment archive review
  - final archive export
- Any such admin route family must later remain inside `/server/admin/*`.
- This document does not claim those workbenches already exist.

## 17. Relationship With Current Publish Board
- This document must not be misread as a publish-board expansion order.
- It does not by itself:
  - reopen the current publish implementation round
  - approve bid/order/contract/fulfillment implementation bundling in one round
  - override the current publish minimum-success corridor
- If this document conflicts with an active board freeze, the active board
  freeze wins directly.

## 18. Audit Requirements
- The following actions must remain auditable:
  - contract confirmation
  - contract amendment
  - milestone submission
  - inspection submission
  - inspection recheck
  - later archive confirmation when formally frozen
- Audit attribution must preserve:
  - object anchor
  - actor
  - time
  - before and after state where applicable
- `BFF` acknowledgements do not replace `Server` audit truth.

## 19. Explicit Non-goals
- No full e-sign integration in this document
- No contract history/list in this document
- No daily-progress route freeze in this document
- No archive-export route freeze in this document
- No second fulfillment workflow model
- No client-side archive-complete judgement
- No implementation unlock by this document alone

## 20. Acceptance Gate For This Rule Set
- Contract, milestone, and inspection semantics must remain inside the current
  order-bound truth family.
- File truth for contract and fulfillment evidence must remain shared upload
  truth plus `FileAsset`.
- Route-family citation must not be interpreted as automatic implementation
  unlock.
- Daily-progress and final archive must remain explicitly marked as “direction
  accepted but contract not yet frozen”.
- Downstream archive-dependent release decisions must remain `Server`-owned.

## 21. Next Single Action
- The next single action after this freeze is:
  - freeze the L2 contract package for contract archive semantics and the first
    formally accepted fulfillment archive additions, while keeping them inside
    the current `/api/app/*` and `/server/admin/*` boundaries

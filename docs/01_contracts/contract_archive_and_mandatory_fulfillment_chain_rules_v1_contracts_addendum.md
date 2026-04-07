---
owner: Codex 总控
status: draft
purpose: Freeze the first dedicated L2 contract family for contract archive entry, contract confirmation, milestone continuity, inspection continuity, and downstream archive-dependent gating under the current order-bound truth system.
layer: L2 Contracts
---

# 合同归档与履约强制入链规则 V1 Contracts Addendum

## Scope
- This addendum applies only to the first dedicated `L2` contract package for:
  - order-side continuation into contract entry
  - contract detail, confirm, and amend
  - milestone list and submit
  - inspection detail, submit, and recheck
  - downstream rating and dispute entry gating alignment
- This addendum does not by itself:
  - unlock implementation
  - freeze daily-progress routes
  - freeze final archive-confirm routes
  - freeze archive-export routes
  - freeze admin archive-review routes
  - reopen contract history, inspection history, or full governance console

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md)
  - [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
  - [lifecycle_state_machine.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/lifecycle_state_machine.md)
  - [inspection_phase3_lifecycle_alignment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/inspection_phase3_lifecycle_alignment_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Canonical Path-family Rule
- Current app-facing path family remains under:
  - `/api/app/*`
- This package freezes the following current path matrix only:
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
- This package explicitly forbids:
  - bare `/contract/*`
  - bare `/milestone/*`
  - bare `/inspection/*`
  - bare `/archive/*`
  - bare `/daily-progress/*`

## Contract Role
- This package freezes transport and read-model semantics only.
- `Server` remains the only owner of:
  - order truth
  - contract truth
  - milestone truth
  - inspection truth
  - archive-dependent release truth
- `BFF` may shape current read-side aggregation only.
- `BFF` must not own:
  - contract version truth
  - milestone workflow truth
  - inspection workflow truth
  - archive-ready truth

## Current Path Responsibilities
- `order/detail` remains:
  - the current order read carrier
  - the controlled local continuation anchor into already frozen downstream
    entries
- `order/create` remains:
  - the minimum order-activation command
- `contract/detail`, `contract/confirm`, and `contract/amend` remain:
  - the minimum contract-entry workflow family
- `milestone/list` and `milestone/submit` remain:
  - the minimum fulfillment continuation family
- `inspection/detail`, `inspection/submit`, and `inspection/recheck` remain:
  - the minimum acceptance-side continuation family
- `rating` and `dispute` remain:
  - downstream gated families that must not outrun the archive boundary

## Contract Entry Boundary
- `GET /api/app/contract/detail` freezes only:
  - `contractId`
  - `orderId`
  - `state`
  - `summary`
- `POST /api/app/contract/confirm` freezes only:
  - minimum request with `contractId`
  - minimum accepted response with `contractId`, `orderId`, `state`, `summary`
- `POST /api/app/contract/amend` freezes only:
  - minimum request with `contractId`, `amendmentSummary`
  - minimum accepted response with `contractId`, `orderId`, `state`, `summary`
- This package does not approve:
  - contract history
  - clause editor
  - legal review loop
  - electronic-sign provider integration

## Fulfillment Continuity Boundary
- `GET /api/app/milestone/list` freezes:
  - `items[]` only
- `POST /api/app/milestone/submit` freezes:
  - minimum request from the current page
  - minimum accepted response carrying `milestoneId` only
- `GET /api/app/inspection/detail` freezes:
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
- `POST /api/app/inspection/submit` and `POST /api/app/inspection/recheck`
  freeze:
  - minimum request
  - minimum accepted response carrying `inspectionId`, `milestoneId`, `state`,
    `summary`

## Daily-progress And Final Archive Gap
- The current mother blueprint direction includes:
  - daily progress logs
  - final archive confirmation
  - archive export
- This package explicitly freezes that those items are:
  - directionally accepted
  - not yet part of the current `L2` contract family
- Therefore no agent may claim:
  - daily-progress app-facing route is frozen
  - final archive-confirm route is frozen
  - archive-export route is frozen

## File Truth Rule
- Contract and fulfillment evidence files must keep using:
  - upload `init`
  - direct upload
  - upload `confirm`
  - `FileAsset` as truth
- This package does not approve:
  - raw URL as contract truth
  - `objectKey` as business truth
  - a parallel contract-file subsystem

## Error-code Binding Rule
- The current minimum contract-family error binding is:
  - `CONTRACT_ENTRY_UNAVAILABLE`
  - `CONTRACT_CONFIRM_INVALID`
  - `CONTRACT_INVALID_STATE`
  - `CONTRACT_AMEND_INVALID`
  - `CONTRACT_AMEND_LIMIT_REACHED`
  - `MILESTONE_SUBMIT_INVALID`
  - `MILESTONE_INVALID_STATE`
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_SUBMIT_INVALID`
  - `INSPECTION_INVALID_STATE`
  - `INSPECTION_RECHECK_INVALID`
  - `INSPECTION_RECHECK_LIMIT_REACHED`
  - `RATING_ENTRY_UNAVAILABLE`
  - `DISPUTE_INVALID_STATE`
- `openapi.yaml` must bind these codes explicitly in route descriptions where the
  current path semantics depend on them.

## Archive-dependent Gating Rule
- Current downstream gating meaning is:
  - route presence for `rating` or `dispute` does not imply archive conditions
    are already satisfied
  - `Server` remains final owner of any archive-dependent release decision
- This package does not yet freeze:
  - a route-by-route archive prerequisite matrix
  - a dedicated archive-ready field family

## Admin Boundary
- Admin remains `Server`-admin only.
- This package accepts in direction, but does not freeze exact admin route
  families for:
  - contract archive review
  - fulfillment archive review
  - final archive export
- Therefore this package is still app-facing-centric for the current round.

## Current Non-goals
- No daily-progress route freeze
- No archive-confirm route freeze
- No archive-export route freeze
- No admin archive-review route freeze
- No contract history or list
- No inspection history or console
- No second fulfillment workflow model
- No implementation unlock by this document alone

## Formal Conclusion
- Current formal conclusion:
  - the first dedicated `合同归档与履约强制入链规则 V1` contract family is now
    frozen against the current order-bound path matrix
  - daily-progress and final archive remain explicitly outside the current
    contract family
  - downstream rating and dispute paths remain gated continuations, not proof of
    archive completion
- Current stage meaning:
  - `L2 contracts freeze` only
  - no implementation unlock by this addendum alone

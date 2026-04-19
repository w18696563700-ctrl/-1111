---
owner: Codex 总控
status: frozen
purpose: Freeze the owner appendix for the V1.0 revised enterprise display field-alignment execution package.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts
---

# Enterprise Display Field Alignment V1 Revision Owner Appendix

## 1. Owner Table

| Field family | Canonical owner | Notes |
|---|---|---|
| published public summary | `enterprise_listing` public projection | list/detail shared owner |
| certification identity truth | `organization certification` + listing snapshots | enterprise name / region / verification labels are constrained by certification truth |
| workbench editable basic fields | `listing` before publish, `published change snapshot.basic` after publish | workbench is an edit carrier |
| board profile | board-specific profile entities before publish, `published change snapshot.boardProfile` after publish | board-type specific |
| primary contact | `enterprise_contact` / `published change snapshot.primaryContact` | public visibility controlled |
| cases | `enterprise_case` / `published change snapshot.cases` | case media remains case-owned |
| enterprise media asset lookup | `asset registry / file asset` | file asset ids are truth carriers; URLs are projections |
| review / audit / readiness | review-audit chain + workbench-only read-model | internal only, not public detail/list |

## 2. Current Runtime Notes

- `workbench` currently reads:
  - listing
  - certification
  - cases
  - primary contact
  - readiness
- `published change` currently exposes:
  - `liveSnapshot`
  - `currentChangeRequest`
  - `basic`
  - `boardProfile`
  - `primaryContact`
  - `cases`
- `public list/detail` currently read from the published listing side only.

## 3. Owner Anti-drift Rule

- Presenter shaping may project truth, but may not become truth owner.
- BFF may carry or trim fields, but may not re-own field meaning.
- Flutter may arrange fields, but may not compensate for owner confusion with silent fallbacks.

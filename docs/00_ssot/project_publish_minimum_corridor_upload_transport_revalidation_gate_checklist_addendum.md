---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for rerunning the upload sub-chain only after Server-side upload transport source repair has passed local build and test validation.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_blocker_ruling_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_repair_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_receipt.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊上传子链重验证轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / upload sub-chain revalidation round`
- This stage applies only to:
  - development host `47.108.180.198`
  - controlled Server deploy / restart for the repaired upload transport source
  - rerun of:
    - `POST /api/app/file/upload/init`
    - direct upload `PUT`
    - `POST /api/app/file/upload/confirm`
  - one negative-path validation:
    - failed or skipped PUT must keep `confirm` in controlled failure
- This stage does not reopen:
  - project create/detail logic
  - BFF source changes
  - Flutter source changes
  - auth / shell / workbench boards
  - release

## 2. Passed Gates

- Current source-repair gate:
  - passed conditionally
  - Server upload transport source repair has local build success
  - transport repair test suite has `3 passed / 0 failed`
- Current scope-isolation gate:
  - passed
  - only the upload sub-chain requires rerun
- Current ownership gate:
  - passed
  - the source repair is Server-only and does not require BFF or Flutter changes

## 3. Stage-local Guard Conditions

- This round may deploy only the repaired Server runtime.
- This round must not change BFF release.
- This round must validate only the upload sub-chain.
- This round must prove both:
  - positive path:
    - upload init -> real PUT -> confirm succeeds
  - negative path:
    - skipped or failed PUT -> confirm fails
- This round must record the actual public upload endpoint used.
- This round must not write secrets into docs or chat.

## 4. Failed Gates

- Corridor closeout gate:
  - still failed until upload sub-chain positive and negative paths are both
    proven on development runtime

## 5. Veto Gates

- No veto gate blocks this exact upload sub-chain revalidation round, provided:
  - it remains development-stage only
  - it stays inside upload sub-chain scope
  - it does not expand into release or unrelated boards

## 6. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / upload sub-chain revalidation round`
  - `No-Go` for corridor closeout
  - `No-Go` for release
  - `No-Go` for board expansion

## 7. Next Unique Action

- The next single action is:
  - issue the formal development-stage upload sub-chain rerun dispatch to the
    integration / release role, limited to the repaired Server runtime and the
    upload sub-chain only

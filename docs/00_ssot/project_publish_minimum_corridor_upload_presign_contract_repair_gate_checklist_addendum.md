---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for a narrow Server-only repair round that fixes the presigned-URL and returned-upload-headers contract mismatch.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_presign_contract_blocker_ruling_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_receipt.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊 presign 契约修复轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / Server upload presign-contract repair round`
- This stage applies only to:
  - Server upload direct-upload contract generation
  - Server upload confirm-side transport truth strategy, only as needed to stay
    consistent with the repaired signed-upload contract
  - minimal test additions that lock the signed-header contract
- This stage does not apply to:
  - BFF changes
  - Flutter changes
  - corridor expansion
  - release

## 2. Passed Gates

- Current scope-isolation gate:
  - passed
  - the remaining blocker is narrowed to one Server contract defect
- Current ownership gate:
  - passed
  - the defect sits in Server upload contract generation and verification

## 3. Stage-local Guard Conditions

- This round must stay Server-only.
- This round must repair the exact contract mismatch between:
  - generated signed URL
  - returned upload headers
- This round must add a regression test that would have caught the current live
  failure.
- This round must not reopen unrelated upload topology work unless strictly
  required by the contract fix.

## 4. Failed Gates

- Corridor closeout gate:
  - still failed
  - positive upload path is not yet proven end to end

## 5. Veto Gates

- No veto gate blocks this exact narrow Server repair round, provided:
  - it remains inside upload presign-contract scope
  - it does not expand into release or unrelated boards

## 6. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / Server upload presign-contract repair round`
  - `No-Go` for corridor closeout
  - `No-Go` for BFF / Flutter work
  - `No-Go` for release

## 7. Next Unique Action

- The next single action is:
  - issue a Server-only repair dispatch for presigned-URL and returned-header
    contract consistency, then rerun upload sub-chain validation on the same
    development runtime

---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for a narrow Server-only upload transport repair round inside the project publish minimum corridor mainline.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_blocker_ruling_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊上传 transport 修复轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / Server upload transport repair round`
- This stage applies only to:
  - `apps/server/src/modules/upload/**`
  - `apps/server/src/core/runtime-config.service.ts`
  - `apps/server/package.json`
  - development-stage Server runtime config required for upload transport only
- This stage does not apply to:
  - `apps/bff/**`
  - `apps/mobile/**`
  - formal auth
  - shell
  - workbench
  - corridor expansion

## 2. Passed Gates

- Current mainline containment gate:
  - passed
  - the blocker is inside the current minimum corridor
- Current ownership gate:
  - passed
  - the failing logic currently sits in Server upload truth generation and
    Server upload confirm truth
- Current frontend/BFF freeze gate:
  - passed
  - no new BFF or Flutter changes are required before transport truth is fixed

## 3. Stage-local Guard Conditions

- This round must stay Server-only.
- This round must repair both:
  - reachable and authorized direct-upload generation
  - confirm-side transport-truth verification
- This round may add the minimum dependency support required for S3-compatible
  signed PUT generation and object existence verification.
- This round may update development-stage runtime config for upload transport
  only.
- This round must not touch unrelated route families.

## 4. Allowed Runtime Work

- Allowed after implementation in the same round or the next immediate
  validation step:
  - controlled development-stage Server build
  - controlled development-stage Server deploy / restart
  - rerun of upload sub-chain validation only
- Not allowed:
  - production release
  - corridor expansion
  - unrelated infrastructure redesign

## 5. Failed Gates

- Corridor closeout gate:
  - failed
  - direct upload remains mandatory and is not yet closed

## 6. Veto Gates

- No veto gate blocks this exact narrow Server transport-repair round, provided:
  - the work stays inside upload truth
  - `confirm` truth is repaired together with direct-upload generation
  - no new unrelated board is opened

## 7. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / Server upload transport repair round`
  - `No-Go` for BFF round
  - `No-Go` for Flutter round
  - `No-Go` for corridor closeout
  - `No-Go` for release

## 8. Next Unique Action

- The next single action is:
  - issue a Server-only repair dispatch for direct-upload host/signing
    generation plus confirm transport-truth verification

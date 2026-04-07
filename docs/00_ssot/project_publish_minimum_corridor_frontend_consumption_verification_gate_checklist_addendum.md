---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for the project publish minimum-corridor frontend consumption verification round only, after backend and BFF source implementation have been completed.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_bff_implementation_receipt.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊前端消费核对轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / 前端消费核对轮`
- This stage applies only to:
  - source-level verification of current Flutter consumption for:
    - `/exhibition/projects/create`
    - `POST /api/app/project/create`
    - `GET /api/app/project/detail`
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
  - zero-delta confirmation if the existing frontend is already aligned
  - minimal frontend patch only if a concrete source-level mismatch is proven
- This stage does not unlock:
  - broad frontend redesign
  - new route family
  - hidden building changes
  - BFF changes
  - backend changes
  - integration verification
  - deployment
  - release

## 2. Gate Basis

- Current gate basis is frozen against:
  - `AGENTS.md`
  - `docs/00_ssot/gate_register_v1.md`
  - `docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md`
  - `docs/00_ssot/project_publish_minimum_corridor_bff_implementation_receipt.md`
  - `docs/01_contracts/openapi.yaml`

## 3. Passed Gates

- Current backend-truth gate:
  - passed
  - source-level backend truth for the four frozen internal paths exists
- Current BFF-mapping gate:
  - passed
  - source-level BFF corridor mapping now exists
- Current canonical-path gate:
  - passed for current touch-set
  - frontend canonical paths remain `/api/app/*`
- Current architecture-boundary gate:
  - passed
  - Flutter App still talks to BFF only
- Current stage-control gate:
  - passed
  - this round is verification-first, not expansion-first

## 4. Stage-local Guard Conditions

- Frontend must first try to prove `zero-delta already aligned`.
- Only when a concrete mismatch is shown may a minimal patch be applied.
- Any patch must stay inside current minimum corridor touch-set.
- No new route family may be introduced.
- No direct-to-Server path may be introduced.
- No fake success may be introduced to mask backend or BFF gaps.
- Existing over-line files may not be expanded casually; if a minimal fix is
  required, prefer the smallest possible delta and record the touch-set.

## 5. Failed Gates

- Current integration gate:
  - failed for this stage on purpose
  - runtime acceptance is not included
- Current deployment gate:
  - failed for this stage on purpose
- Current release gate:
  - failed for this stage on purpose

## 6. Veto Gates

- No current veto gate blocks a frontend verification-first round for this
  minimum corridor.
- Global unresolved blockers remain vetoes for:
  - integration acceptance
  - deployment
  - release

## 7. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / 前端消费核对轮`
  - `No-Go` for broad frontend implementation expansion
  - `No-Go` for integration verification
  - `No-Go` for deployment
  - `No-Go` for release

## 8. Next Unique Action

- The next single action is:
  - issue the frontend verification-first dispatch for the project publish
    minimum corridor

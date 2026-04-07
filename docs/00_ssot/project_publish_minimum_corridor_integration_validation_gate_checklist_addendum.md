---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for the project publish minimum-corridor development-stage integration validation round only, after source-level implementation pack signoff has conditionally passed.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/development_stage_cloud_host_override_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_source_implementation_validation_signoff.md
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_bff_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_frontend_consumption_receipt.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊联调验证轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / development-stage integration validation round`
- This stage applies only to:
  - development host `47.108.180.198`
  - local tunnel `8080 -> 80`
  - controlled dev-stage migration execution for:
    - `20260402_project_publish_minimum_corridor_truth`
  - controlled dev-stage build / deploy / process restart for:
    - `Server`
    - `BFF`
  - runtime validation for the minimum corridor only:
    - `POST /api/app/project/create`
    - `GET /api/app/project/detail?projectId=...`
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
    - `/exhibition/projects/create` continuation evidence
- This stage does not unlock:
  - staging
  - production release
  - admin remediation
  - bid / order / contract / milestone / inspection / rating / dispute
  - unrelated forum / enterprise_hub work

## 2. Gate Basis

- Current gate basis is frozen against:
  - `AGENTS.md`
  - `docs/00_ssot/gate_register_v1.md`
  - `docs/00_ssot/development_stage_cloud_host_override_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_source_implementation_validation_signoff.md`
  - `docs/01_contracts/openapi.yaml`

## 3. Passed Gates

- Current source-implementation signoff gate:
  - passed conditionally
  - source-level implementation pack has been independently signed off as
    `有条件通过`
  - result-verification explicitly allows entry into a restricted integration
    validation round
- Current truth-order gate:
  - passed
  - L0 truth and L2 contracts were frozen before implementation and signoff
- Current development-runtime gate:
  - passed
  - `47.108.180.198` and `8080 -> 80` remain the approved development runtime
    baseline
- Current architecture-boundary gate:
  - passed
  - Flutter App still validates through BFF only
  - BFF still validates through Server only
- Current corridor-scope gate:
  - passed
  - current validation object remains the minimum publish corridor only

## 4. Stage-local Guard Conditions

- All runtime actions in this stage must target development runtime only.
- This stage may execute only the one new migration key required by the current
  minimum corridor:
  - `20260402_project_publish_minimum_corridor_truth`
- This stage may deploy only the minimum affected dev units:
  - `Server`
  - `BFF`
- This stage must validate only on the approved active chain:
  - `80 -> 3000/3001`
  - `systemd + /srv/releases/**`
- Evidence from:
  - `pm2`
  - `3100/3101`
  - `127.0.0.1:18080`
  must not be used as the acceptance chain.
- Any failure must be recorded with rollback-ready evidence; this stage does not
  authorize silent ad hoc fixes outside the minimum corridor.

## 5. Failed Gates

- Current release gate:
  - failed for this stage on purpose
  - this round is development-stage integration only
- Current production-readiness gate:
  - failed for this stage on purpose
  - no production sign-off is included

## 6. Veto Gates

- No current veto gate blocks this exact development-stage integration
  validation round, provided all stage-local guard conditions are obeyed.
- The unresolved global blockers remain vetoes for:
  - release sign-off
  - production deployment
  - unrelated board expansion

## 7. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / development-stage integration validation round`
  - `No-Go` for production release
  - `No-Go` for corridor expansion
  - `No-Go` for unrelated board work

## 8. Next Unique Action

- The next single action is:
  - issue the formal integration-validation dispatch to the release /
    integration role for the current minimum publish corridor only

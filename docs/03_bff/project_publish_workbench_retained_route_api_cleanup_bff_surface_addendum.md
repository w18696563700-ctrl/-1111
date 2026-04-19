---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF-side removal of the obsolete exhibition private workbench
  summary route after the compatibility shell is no longer a valid app-facing
  consumer.
layer: L4 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_retained_route_api_cleanup_contract_addendum.md
  - docs/02_backend/project_publish_workbench_retained_route_api_cleanup_backend_truth_addendum.md
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/routes.module.ts
---

# 《发布项目工作台 Retained Route + API Cleanup BFF Surface Freeze》

## 1. BFF Conclusion

- `BFF` 当前正式删除：
  - `GET /api/app/exhibition/workbench`
  - `routes/exhibition_workbench/**`
- `BFF` 当前不再维护：
  - workbench summary normalization
  - workbench summary error-envelope family
  - workbench compatibility transport trimming

## 2. Remaining App-facing Surface

- Flutter App 当前继续通过 `BFF` 读取：
  - `shell/context`
  - `project/*`
  - `my/projects*`
  - current downstream trade corridor paths

## 3. Explicit Non-goals

- 本轮不影响：
  - enterprise-hub workbench BFF family
  - profile / forum / file / auth unrelated surface

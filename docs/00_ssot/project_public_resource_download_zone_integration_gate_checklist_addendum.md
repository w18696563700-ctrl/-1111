---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the stage gate checklist for the public resource download zone
  development-stage integration validation round only, after the rerun result
  verification has passed.
layer: L0 SSOT
freeze_date_local: 2026-04-14
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_public_resource_download_zone_result_verification_rerun_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_frontend_execution_receipt_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《公共资源下载区联动发布前门禁核查表》

## 1. Scope

- 当前阶段对象：
  - `公共资源下载区 / development-stage integration validation round`
- 本阶段只适用于：
  - active local isolated runtime
    - `http://127.0.0.1:3201`
    - `http://127.0.0.1:3301`
  - current Flutter local consumption proof
  - bounded owner-facing `我的项目详情` verification
  - shared file-access download reuse verification
- 本阶段不解锁：
  - `release-prep`
  - production release
  - admin remediation
  - workbench expansion
  - public detail expansion
  - unrelated board work

## 2. Passed Gates

- 当前 result-verification rerun gate：
  - passed
  - rerun review conclusion 已正式给出 `PASS`
- 当前 truth-order gate：
  - passed
  - L0/L2/L3/L4/L5 冻结均先于实现与回执
- 当前 runtime-alignment gate：
  - passed
  - active `3301` / `3201` 当前均已与已签收实现对齐
- 当前 architecture-boundary gate：
  - passed
  - Flutter 仍只经 BFF
  - BFF 仍只经 Server
- 当前 corridor-scope gate：
  - passed
  - 当前对象仍只限 `公共资源下载区`

## 3. Stage-local Guard Conditions

- 所有 runtime 动作必须只面向当前 active local isolated runtime。
- 本阶段只允许验证：
  - `GET /server/projects/public-resources`
  - `GET /api/app/project/public-resources`
  - `GET /api/app/file/access?fileAssetId=...&mode=download`
  - `我的项目详情` 内的 zone placement
- 本阶段不得把以下当成 acceptance chain：
  - fake/demo transport
  - workbench summary
  - public `项目展示详情`
- 任一失败都必须保留 rollback-ready 证据；本阶段不授权静默修补。

## 4. Failed Gates

- 当前 release gate：
  - failed on purpose
  - 本轮是 integration validation only
- 当前 production-readiness gate：
  - failed on purpose
  - no production sign-off is included

## 5. Veto Gates

- 不得把当前对象扩成：
  - owner-private 文书区改造
  - Admin 公共资源治理扩面
  - workbench 入口恢复
  - public detail 资源中心
- unresolved global blockers 仍然阻断：
  - release sign-off
  - production deployment
  - unrelated board expansion

## 6. Stage Go / No-Go

- Stage decision：
  - `Go` for `公共资源下载区 / development-stage integration validation round`
  - `No-Go` for `release-prep`
  - `No-Go` for production release
  - `No-Go` for scope expansion

## 7. Next Unique Action

- 下一步唯一动作：
  - 向联调负责人发出《公共资源下载区联动验证口令》

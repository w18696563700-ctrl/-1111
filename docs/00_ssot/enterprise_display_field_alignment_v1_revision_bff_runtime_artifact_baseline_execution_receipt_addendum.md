---
owner: Codex 总控
status: frozen
purpose: Record the execution receipt for the child ticket that repaired the BFF runtime artifact baseline required by enterprise display field alignment V1 revision.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_bff_runtime_artifact_baseline_stage_gate_checklist_addendum.md
  - docs/03_bff/enterprise_display_field_alignment_v1_revision_bff_runtime_artifact_baseline_addendum.md
---

# Enterprise Display Field Alignment V1 Revision BFF Runtime Artifact Baseline Execution Receipt

## 1. 现状

- Gate 4 首次 runtime release 已失败并完成 rollback。
- 已确认根因不在业务字段逻辑，而在 BFF runtime artifact 结构：
  - `dist/apps/bff/src/shared/contracts.js`
  - 依赖 `dist/packages/contracts/src/generated/*`

## 2. 冻结边界

- 本子单只修：
  - BFF runtime artifact / generated contracts release baseline
- 不动：
  - enterprise display 字段语义
  - public list/detail 业务逻辑
  - workbench/change/public truth 口径

## 3. 实施结果

- 已正式冻结 BFF runtime artifact baseline：
  - release 不得只复制 `apps/bff` 子树
  - release 必须保留 release root 下的 `dist/packages/contracts/src/generated/**`
- 已按修复后的基线准备新 BFF release root：
  - 复制整个 active release root
  - 在保留 `packages/contracts` 的前提下只覆盖 bounded runtime files

## 4. 证据

- active BFF runtime 可运行的 artifact 中存在：
  - `dist/packages/contracts/src/generated/app-api.types.js`
  - `dist/packages/contracts/src/generated/error-codes.js`
- 首次失败的新 artifact 中缺失的正是该 subtree。

## 5. 下一步

- 允许在修复后的 baseline 上重做 Gate 4 runtime release retry。

---
owner: Codex 总控
status: frozen
purpose: Record the successful Gate 4 runtime release retry for enterprise display field alignment V1 revision after the BFF runtime artifact baseline was repaired.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_bff_runtime_artifact_baseline_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_execution_receipt_addendum.md
---

# Enterprise Display Field Alignment V1 Revision Gate4 Runtime Release Retry Execution Receipt

## 1. 现状

- retry 前 active 指针为：
  - `SERVER_PREV=/srv/releases/server/20260417223848-enterprise-display-continuation-auto-review-v1`
  - `BFF_PREV=/srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`
- retry 目标 release 为：
  - `SERVER_R2=/srv/releases/server/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2`
  - `BFF_R2=/srv/releases/bff/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2/apps/bff`

## 2. 冻结边界

- retry 仍只围绕已冻结范围发布：
  - public list
  - public detail
  - change-preview carrying
  - media semantics projection
- 未引入本单外改动。

## 3. 实施结果

- BFF release 已改为复制整个 active release root，再保留 `packages/contracts` runtime subtree。
- 新 server / BFF artifact 都已在远端完成 bounded build / test。
- 已切换：
  - `/srv/apps/server/current -> SERVER_R2`
  - `/srv/apps/bff/current -> BFF_R2`
- 已重启：
  - `exhibition-server`
  - `exhibition-bff`

## 4. 运行态证据

- 当前 active 指针：
  - `server -> /srv/releases/server/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2`
  - `bff -> /srv/releases/bff/20260418071709-enterprise-display-field-alignment-v1-runtime-release-r2/apps/bff`
- `systemctl is-active exhibition-server = active`
- `systemctl is-active exhibition-bff = active`

## 5. 回退预案

- rollback target 仍明确存在：
  - `SERVER_PREV`
  - `BFF_PREV`
- rollback path 已在 Gate 4 首次失败时被真实执行并验证过，可继续作为当前 release 的回退口径。

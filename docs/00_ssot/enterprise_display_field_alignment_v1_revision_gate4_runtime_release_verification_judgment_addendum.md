---
owner: Codex 总控
status: frozen
purpose: Record the Gate 4 runtime verification judgment after the enterprise display field-alignment V1.0 revision release attempt failed smoke and was rolled back.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_gate_checklist_addendum.md
  - .tmp/enterprise_display_execution/05_evidence/round_02_verification_summary.md
---

# Enterprise Display Field Alignment V1 Revision Gate4 Runtime Verification Judgment

## Findings

### blocker

- Gate 4 runtime release `failed`.
- 失败原因不是 public projection 逻辑本身，而是 `BFF runtime artifact baseline` 不成立。
- 新 release 中 BFF 运行入口实际加载的 dist subtree 仍要求：
  - `../../../../packages/contracts/src/generated/app-api.types`
  但该路径在当前 artifact runtime 结构里不存在，导致 BFF 启动失败并触发 `502`。

### non-blocking risk

- server bounded artifact 本身通过了 build 与 targeted test。
- field-alignment 代码范围没有出现 scope 外漂移。
- 回滚后 live 已恢复。

### observation

- 本轮 rollback 动作有效：
  - `Server current` 恢复到 `20260417223848-enterprise-display-continuation-auto-review-v1`
  - `BFF current` 恢复到 `20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`
  - `company public list` 恢复 `HTTP 200`

## Runtime Evidence

- failed smoke：
  - `company / factory / supplier public list -> 502`
- failure log：
  - `journalctl -u exhibition-bff`
  - `Cannot find module '../../../../packages/contracts/src/generated/app-api.types'`
- rollback recovery：
  - `systemctl is-active exhibition-server = active`
  - `systemctl is-active exhibition-bff = active`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1 -> 200`

## Docs Evidence

- release gate：
  - `docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_gate_checklist_addendum.md`
- release receipt：
  - `docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_execution_receipt_addendum.md`

## Verification Results

- Gate 4 runtime release：
  - `Fail`
- rollback execution：
  - `Pass`
- rollback recovery：
  - `Pass`
- current ticket close condition：
  - `Not met`

## Verdict

- 当前正式结论为：
  - `Gate 4 failed and rolled back`
  - `live recovered`
  - `ticket not closable`
- 下一步不得继续盲发同类 release。
- 必须先单开并冻结：
  - `BFF runtime artifact / generated contracts release baseline`

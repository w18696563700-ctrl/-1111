---
owner: Codex 总控
status: frozen
purpose: Record the runtime verification judgment for the BFF-only enterprise display case upload-init scope fix after bounded release execution on the active development runtime.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-21
inputs_canonical:
  - docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_gate_checklist_addendum.md
---

# 《enterprise display case upload-init scope fix BFF runtime verification judgment》

## Findings

- blocker
  - `authenticated positive upload smoke` 仍未完成，因此当前不能写成“线上案例上传正向已实测通过”。
- non-blocking risk
  - Flutter 端 `caseCoverFileAssetId / caseMediaFileAssetIds` 英文 fallback 的本地汉化不在本轮 release scope 内；若用户继续命中其他未覆盖失败链，客户端仍可能显示旧英文。
- observation
  - `BFF` active runtime 已切到新的 bounded release artifact，且运行态源码已包含 `enterprise_display` command-header forwarding。

## Runtime Evidence

- active BFF symlink：
  - `/srv/apps/bff/current -> /srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`
- service status：
  - `systemctl is-active exhibition-bff = active`
- app-facing smoke：
  - `POST /api/app/file/upload/init`
    - `401 AUTH_SESSION_INVALID`
    - 说明 route 在线，auth gate 正常返回，未见 `404` / `502` startup regression

## Docs Evidence

- `docs/03_bff/enterprise_display_case_upload_init_scope_fix_bff_surface_addendum.md`
- `docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_gate_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_execution_receipt_addendum.md`

## Verification Results

- `BFF` bounded release artifact build：通过
- `file-enterprise-display-upload-init.test.cjs`：通过
- active runtime switch：通过
- service restart / active：通过
- unauthenticated route smoke：通过
- authenticated positive case upload smoke：未完成

## Verdict

- `bounded BFF runtime release pass`
- `strict full closure not granted`
- 当前可正式写成：
  - enterprise display case upload-init 组织作用域修复已进入 active runtime
- 当前不可正式写成：
  - 用户态案例图片正向上传已在 live runtime 由真实登录态 smoke 证明
  - Flutter 英文 fallback 已同步完成线上发布

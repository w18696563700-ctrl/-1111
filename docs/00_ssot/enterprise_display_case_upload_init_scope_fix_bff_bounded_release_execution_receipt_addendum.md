---
owner: Codex 总控
status: frozen
purpose: Record the bounded release execution receipt for the BFF-only enterprise display case upload-init scope fix after the new release artifact was prepared, built, tested, switched, restarted, and smoke-checked on the active development runtime.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-20
inputs_canonical:
  - docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_gate_checklist_addendum.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/03_bff/enterprise_display_case_upload_init_scope_fix_bff_surface_addendum.md
---

# 《enterprise display case upload-init scope fix BFF bounded release execution receipt》

## 1. 现状

- release 前 active BFF runtime 指针为：
  - `BFF_PREV=/srv/releases/bff/20260417211631-enterprise-display-trust-repair/apps/bff`
- 本轮目标 release artifact 为：
  - `BFF_NEW=/srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`

## 2. 冻结边界

- 本轮只做：
  - `BFF` release artifact preparation
  - minimal source patch
  - targeted build
  - targeted test
  - current switch
  - restart
  - bounded smoke
- 本轮不做：
  - `Server` deploy
  - Flutter release
  - auth whitelist / debug session unlock

## 3. 派工对象

- `总控` 直接执行受限 BFF release procedure
- 未再拆新的施工角色

## 4. 实施结果

- 已基于当前 active BFF release 复制出新 artifact：
  - `/srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`
- 已在新 artifact 内只覆盖本轮最小写集合：
  - `src/routes/file/file.service.ts`
  - `test/file-enterprise-display-upload-init.test.cjs`
- 已在新 artifact 内执行：
  - `pnpm build`
  - `node --test test/file-enterprise-display-upload-init.test.cjs`
- 已将 current 指针切换到新 release 并重启：
  - `ln -sfn /srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff /srv/apps/bff/current`
  - `systemctl restart exhibition-bff`

## 5. 运行态证据

- 切换后 current 指针为：
  - `/srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`
- service 状态：
  - `systemctl is-active exhibition-bff = active`
- active source 核验：
  - active runtime `file.service.ts` 已包含：
    - `command.businessType === "enterprise_display"`
    - `buildCommandHeaders(headers)`
- post-release smoke：
  - `POST /api/app/file/upload/init`
    - `401 AUTH_SESSION_INVALID`
    - 证明 app-facing upload-init route 在线，且当前未登录分支为受控 auth gate，而非 `404` / 启动失败

## 6. 文档证据

- BFF scope freeze：
  - `docs/03_bff/enterprise_display_case_upload_init_scope_fix_bff_surface_addendum.md`
- release gate 文书：
  - `docs/00_ssot/enterprise_display_case_upload_init_scope_fix_bff_bounded_release_gate_checklist_addendum.md`
- deploy / rollback baseline：
  - `docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md`

## 7. 风险与 blocker

- 当前仍缺 authenticated positive upload smoke：
  - 没有可复用的正式 app session 可用于在线正向上传企业展示案例图片
- Flutter 端对英文 fallback 的本地汉化未进入本轮 release scope：
  - 该部分仍不应被写成“已在线消失”

## 8. 下一步

- 进入独立校验结论轮。
- 正式判断：
  - 本轮是否达到 `bounded BFF runtime release pass`
  - 是否还能写成 `strict full closure`

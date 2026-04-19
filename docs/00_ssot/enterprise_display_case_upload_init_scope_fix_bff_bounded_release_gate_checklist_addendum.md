---
owner: Codex 总控
status: frozen
purpose: Record the bounded release gate checklist for the BFF-only enterprise display case upload-init scope fix.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-19
inputs_canonical:
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/03_bff/enterprise_display_case_upload_init_scope_fix_bff_surface_addendum.md
  - apps/bff/src/routes/file/file.service.ts
  - apps/bff/test/file-enterprise-display-upload-init.test.cjs
---

# 《enterprise display case upload-init scope fix BFF bounded release gate checklist》

## 1. 本轮目标

- 将 `enterprise_display` 图片上传初始化遗漏组织作用域的 `BFF` 传输修复切入 active runtime。

## 2. 非目标

- 不做 `Server` 代码改动
- 不做 Flutter 发布
- 不做 schema / migration
- 不做认证白名单或 debug session 解锁

## 3. passed gates

- 当前主链 deploy / rollback procedure baseline 已正式冻结。
- 本轮 release scope 已收敛为 `BFF file upload transport only`。
- 本地最小写集合已明确：
  - `apps/bff/src/routes/file/file.service.ts`
  - `apps/bff/test/file-enterprise-display-upload-init.test.cjs`
- 本地 targeted build/test 已可执行，用于证明：
  - `enterprise_display` upload init 走 command headers

## 4. failed gates

- 当前仍缺 authenticated positive smoke：
  - 没有可复用的受控 app session 可用于在线正向上传案例图片。

## 5. veto gates

- 对 `bounded BFF release`：
  - 无未通过 veto gate
- 对 `strict full closure before runtime smoke`：
  - 仍有一项保留风险：
    - authenticated positive smoke 暂不能自动完成

## 6. Go / No-Go

- 对 `BFF bounded release`：
  - `Go`
- 对 `strict full closure before post-release verification`：
  - `No-Go`

## 7. Formal Conclusion

- 当前允许进入：
  - `BFF release artifact preparation`
  - `build`
  - `targeted test`
  - `current switch`
  - `restart`
  - `bounded smoke`
- 当前不允许直接宣布：
  - Flutter 端英文 fallback 已在线消失
  - authenticated positive upload smoke 已通过

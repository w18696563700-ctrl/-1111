---
owner: Codex 总控
status: frozen
purpose: Record the bounded release execution receipt for enterprise display trust repair after the new server and BFF release artifacts were built, switched, restarted, and smoke-checked on the active development runtime.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round16_bounded_release_gate_checklist_addendum.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
---

# 《enterprise display trust repair round 17 bounded release execution receipt》

## 1. 现状

- release 前 active runtime 指针为：
  - `SERVER_PREV=/srv/releases/server/20260417040450-enterprise-stage2-card-album`
  - `BFF_PREV=/srv/releases/bff/20260417040450-enterprise-stage2-card-album/apps/bff`
- 本轮目标 release artifact 为：
  - `SERVER_NEW=/srv/releases/server/20260417211631-enterprise-display-trust-repair`
  - `BFF_NEW=/srv/releases/bff/20260417211631-enterprise-display-trust-repair/apps/bff`

## 2. 冻结边界

- 本轮只做：
  - release artifact preparation
  - build
  - targeted test
  - current switch
  - restart
  - smoke
- 本轮不做：
  - migration
  - env rewrite
  - auth whitelist capability unlock

## 3. 派工对象

- `总控` 直接执行受限 release procedure
- 未再拆独立施工角色

## 4. 实施结果

- 已基于 current release 复制出新 artifact：
  - `server`
  - `bff`
- 已覆盖本轮最小写集合：
  - `Server`:
    - `enterprise-hub-write.service.ts`
    - `enterprise-hub-truth.controller.ts`
    - `enterprise-hub-workbench.query.service.ts`
    - `enterprise-hub-location.service.ts`
    - `enterprise-hub.presenter.ts`
    - `enterprise-hub-workbench.presenter.ts`
    - `enterprise-hub-published-change-app.service.ts`
    - `enterprise-hub-published-change-snapshot.service.ts`
    - `enterprise-hub-published-change-support.service.ts`
    - `enterprise-hub-region-lookup.ts`
    - `enterprise-hub-region-lookup.generated.ts`
  - `BFF`:
    - `app-enterprise-hub.controller.ts`
    - `enterprise-hub.controller.ts`
    - `enterprise-hub.read-model.ts`
    - `enterprise-hub.service.ts`
- 已在新 artifact 内执行：
  - `cd /srv/releases/server/20260417211631-enterprise-display-trust-repair && pnpm build`
  - `node --test test/enterprise-hub-location-display-truth.test.cjs test/enterprise-hub-submit-chain-drift-repair.test.cjs test/enterprise-hub-workbench-closure.test.cjs test/enterprise-hub-workbench-scope-chain.test.cjs test/enterprise-hub-public-read-closure.test.cjs test/enterprise-hub-published-change-governance.test.cjs`
  - `cd /srv/releases/bff/20260417211631-enterprise-display-trust-repair/apps/bff && pnpm build`
  - `node --test test/enterprise-hub-application-transport.test.cjs test/enterprise-hub-update-basic-contact-transport.test.cjs test/enterprise-hub-list-query-transport.test.cjs`
- 已将 current 指针切换到新 release 并重启：
  - `ln -sfn /srv/releases/server/20260417211631-enterprise-display-trust-repair /srv/apps/server/current`
  - `systemctl restart exhibition-server`
  - `ln -sfn /srv/releases/bff/20260417211631-enterprise-display-trust-repair/apps/bff /srv/apps/bff/current`
  - `systemctl restart exhibition-bff`

## 5. 运行态证据

- 切换后 current 指针为：
  - `/srv/releases/server/20260417211631-enterprise-display-trust-repair`
  - `/srv/releases/bff/20260417211631-enterprise-display-trust-repair/apps/bff`
- service 状态：
  - `systemctl is-active exhibition-server = active`
  - `systemctl is-active exhibition-bff = active`
- post-release smoke：
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1`
    - `200`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell`
    - `401 AUTH_SESSION_INVALID`
    - 证明 route 已在线且非 `404`
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=company`
    - `401 AUTH_SESSION_INVALID`
    - 证明 workbench auth gate 在线且非 `404`

## 6. 文档证据

- release gate 文书：
  - `docs/00_ssot/enterprise_display_trust_repair_round16_bounded_release_gate_checklist_addendum.md`
- deploy / rollback baseline：
  - `docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md`

## 7. 风险与 blocker

- 当前仍缺：
  - authenticated positive smoke
- 原因不是 route 不在线，而是当前运行环境未开放可复用的 whitelist test session gate，且本轮没有正规可审计的 auth carrier。
- 云端现有 release/workspace 仍存在：
  - `._*` 垃圾文件
  - dirty workspace
  但未阻断本轮 bounded release。

## 8. 下一步

- 进入独立校验结论轮。
- 正式判断：
  - 本轮是否达到 `bounded runtime release pass`
  - 是否还能写成 `strict full closure`

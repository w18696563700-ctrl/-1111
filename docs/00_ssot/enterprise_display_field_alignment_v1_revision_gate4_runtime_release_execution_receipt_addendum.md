---
owner: Codex 总控
status: frozen
purpose: Record the Gate 4 bounded runtime-release execution receipt for enterprise display field-alignment V1.0 revision, including failed smoke and immediate rollback.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_gate_checklist_addendum.md
  - .tmp/enterprise_display_execution/05_evidence/round_02_verification_summary.md
---

# Enterprise Display Field Alignment V1 Revision Gate4 Runtime Release Execution Receipt

## 1. 现状

- release 前 active 指针为：
  - `SERVER_PREV=/srv/releases/server/20260417223848-enterprise-display-continuation-auto-review-v1`
  - `BFF_PREV=/srv/releases/bff/20260417214856-enterprise-display-case-upload-scope-fix/apps/bff`

## 2. 冻结边界

- 本轮只做：
  - 新 release artifact 准备
  - 最小写集合覆盖
  - server artifact build / targeted test
  - bounded current switch
  - live smoke
  - 失败即 rollback
- 本轮不做：
  - Admin / auth / infra baseline 改造
  - Flutter 二进制发版
  - 非 enterprise display scope 的顺手改动

## 3. 派工对象

- 总控主线程执行 cloud write
- 只读子线程执行 release preflight 与 rollback 后复核

## 4. 实施结果

- 已基于 active current 复制出新 artifact：
  - `SERVER_NEW=/srv/releases/server/20260418070054-enterprise-display-field-alignment-v1-runtime-release`
  - `BFF_NEW=/srv/releases/bff/20260418070054-enterprise-display-field-alignment-v1-runtime-release/apps/bff`
- 已仅覆盖本轮最小写集合：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
  - `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
  - local-built BFF runtime dist carrying subtree for enterprise-hub read-model projection
- server artifact 验证结果：
  - `pnpm build` PASS
  - `node --test test/enterprise-hub-public-read-closure.test.cjs` PASS
- BFF artifact 运行结构问题：
  - artifact 内无法直接做 source build
  - 尝试补齐 local-built runtime subtree 后，service 启动仍失败

## 5. 运行态证据

- 发布尝试后：
  - `exhibition-server = active`
  - `exhibition-bff = crash-loop`
- 首轮 live smoke：
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=3 -> 502`
  - `factory -> 502`
  - `supplier -> 502`
- BFF journal 关键失败点：
  - `Cannot find module '../../../../packages/contracts/src/generated/app-api.types'`
  - require stack 起点：
    - `/srv/releases/bff/20260418070054-enterprise-display-field-alignment-v1-runtime-release/apps/bff/dist/apps/bff/src/shared/contracts.js`
- 按 Gate 4 规则已立即 rollback：
  - `ln -sfn $SERVER_PREV /srv/apps/server/current`
  - `ln -sfn $BFF_PREV /srv/apps/bff/current`
  - `systemctl restart exhibition-server`
  - `systemctl restart exhibition-bff`
- rollback 后：
  - `exhibition-server = active`
  - `exhibition-bff = active`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1 -> 200`

## 6. 文档证据

- Gate 4 checklist：
  - `docs/00_ssot/enterprise_display_field_alignment_v1_revision_gate4_runtime_release_gate_checklist_addendum.md`

## 7. 风险与 blocker

- 本轮未能完成 Gate 4 发布通过。
- blocker 已明确收敛为：
  - `BFF release artifact baseline` 不稳定
  - 当前 artifact/runtime 对 `packages/contracts` 生成依赖路径存在结构耦合

## 8. 下一步

- 本轮不允许关单。
- 下一子单应单独收口：
  - `BFF runtime artifact / build baseline repair`
  - 明确 source build、dist carrying、generated contracts 的正式发布基线

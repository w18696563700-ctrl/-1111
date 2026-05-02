---
owner: Codex 总控
status: frozen
purpose: Record the independent verification judgment for round-12 after cloud ensure-shell implementation evidence and local Flutter verification were both rechecked.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-12
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round10_location_display_name_truth_source_ruling_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round11_logo_only_implementation_admission_judgment_addendum.md
  - docs/01_contracts/enterprise_display_trust_repair_round11_logo_only_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_trust_repair_round11_logo_only_bff_surface_scope_addendum.md
---

# 《enterprise display trust repair round 12 independent verification judgment》

## Findings

- blocker:
  - 当前只能证明 `cloud git workspace` 中的 `Logo-only shell/application split` 已存在代码与测试证据，仍不能证明 `live runtime` 已完成 deploy、restart、HTTP smoke 或 DB truth 验证。
  - 当前本地工作区与云端实现存在正式漂移：
    - 本地 `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
      里还没有 `POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell`
    - 本地 `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
      里也还没有 `POST /server/exhibition/enterprise-hub/enterprises/ensure-shell`
    - 但云端 `/srv/git/exhibition-infra-monorepo` 已存在该 route 与对应 service
  - `province/city display-name truth source` 仍未进入实现轮。round-10 已冻结它必须先补 `server-owned truth source`，本轮没有关闭该 blocker。
- non-blocking risk:
  - 云端 `/srv/git/exhibition-infra-monorepo` 相关文件仍处于 dirty worktree：
    - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
    - `apps/bff/src/routes/enterprise_hub/enterprise-hub-shell.service.ts`
    - `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
    - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
    - 若未进一步归档或清理，后续线程仍有 anti-revert 风险。
  - 本地 Flutter 为完成独立校验新增了 test-only hook / loader override，当前验证未发现业务行为漂移，但这些入口必须继续保持 test-only，不得被误当作正式 runtime 能力。
- observation:
  - 云端 `BFF` 已存在独立 `EnterpriseHubShellService`，而不是继续把 `ensure-shell` 偷绑到 `createApplication`。
  - 云端 `Server` 已存在 `ensureShell()` + `ensureOwnedListingShell()`，并且 `enterprise-hub-logo-only-shell.test.cjs` 已明确覆盖：
    - `ensureShell` 只创建 listing shell，不创建 application / contact
    - `createApplication` 在 applicant fields 提供后才写 application / contact truth
  - 本地 Flutter 保存链现在稳定走：
    - `ensure-shell`
    - `updateBasic`
    不再要求先触发 `createApplication`
  - 本地三组 Flutter 最小回归全部通过。

## Runtime Evidence

- 云端只读核验 workspace：
  - `/srv/git/exhibition-infra-monorepo`
- 云端只读代码证据：
  - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
    - 存在 `POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub-shell.service.ts`
    - 独立负责 `ensure-shell` transport 与错误整形
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`
    - 存在 `POST /server/exhibition/enterprise-hub/enterprises/ensure-shell`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
    - 存在 `ensureShell()` 与 `ensureOwnedListingShell()`
  - `apps/server/test/enterprise-hub-logo-only-shell.test.cjs`
    - 覆盖 shell 与 application 的 carrier 分离
- 云端只读执行通过：
  - `pnpm --dir apps/bff build`
  - `node apps/bff/test/enterprise-hub-update-basic-contact-transport.test.cjs`
  - `node apps/bff/test/enterprise-hub-list-query-transport.test.cjs`
  - `pnpm --dir apps/server build`
  - `node apps/server/test/enterprise-hub-logo-only-shell.test.cjs`
  - `node apps/server/test/enterprise-hub-workbench-closure.test.cjs`
  - `node apps/server/test/enterprise-hub-certification-sync.test.cjs`
  - `node apps/server/test/enterprise-hub-submit-chain-drift-repair.test.cjs`
- 本地执行通过：
  - `flutter test test/enterprise_hub_routes_test.dart`
  - `flutter test test/enterprise_hub_trust_repair_stage1_test.dart`
  - `flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart`
- 本轮未执行：
  - deploy
  - rollback
  - service restart
  - live HTTP smoke
  - DB query truth verification

## Docs Evidence

- `Logo-only` 的 carrier boundary 已在 round-9 冻结：
  - `docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md`
- `province/city display-name truth source` 的真源约束已在 round-10 冻结：
  - `docs/00_ssot/enterprise_display_trust_repair_round10_location_display_name_truth_source_ruling_addendum.md`
- round-11 已正式要求 app-facing contract 采用独立 `ensure-shell`：
  - `docs/01_contracts/enterprise_display_trust_repair_round11_logo_only_contract_freeze_addendum.md`
  - `docs/03_bff/enterprise_display_trust_repair_round11_logo_only_bff_surface_scope_addendum.md`

## Verification Results

- `Logo-only shell/application carrier split`
  - `cloud code + targeted test = pass`
- `BFF ensure-shell transport`
  - `cloud code = pass`
- `Server ensure-shell truth write`
  - `cloud code + targeted test = pass`
- `local Flutter save basic -> ensure-shell -> updateBasic`
  - `pass`
- `local Flutter trust-repair regression`
  - `pass`
- `local workspace 与 cloud implementation 对齐`
  - `fail / drift still exists`
- `province/city display-name truth source`
  - `not implemented / still blocker`
- `live runtime closure`
  - `not verified`

## Verdict

- `部分通过，不可结案。`
- 当前允许的结论：
  - round-12 的 `Logo-only ensure-shell` 方向在云端代码与 targeted tests 上已成立
  - 本地 Flutter 保存链与最小回归已成立
- 当前不允许的结论：
  - 问题已全闭环
  - live runtime 已生效
  - integration release 可放行
  - 本地仓库已与云端实现一致

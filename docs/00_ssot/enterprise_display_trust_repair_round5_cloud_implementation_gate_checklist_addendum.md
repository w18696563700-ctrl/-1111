---
owner: Codex 总控
status: frozen
purpose: Submit the round-5 stage gate checklist for bounded cloud BFF and Server implementation after the deploy and rollback procedure baseline was frozen.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-05
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_cloud_git_worktree_drift_note_addendum.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round4_local_frontend_verification_judgment_addendum.md
---

# 《enterprise display trust repair round 5 cloud implementation gate checklist》

## 1. Stage Objective

- 当前 round-5 目标固定为：
  - 开启 bounded cloud `BFF / Server` 实施轮
  - 只处理不需要新增 app-facing contract 的 residual cloud blockers
  - 保持 deploy / rollback / release 与实现分离

## 2. Passed Gates

- passed gates:
  - 真源门禁
    - docs-only baseline 与 gate checklist 已冻结
  - 云上运行门禁
    - current mainline host / release / symlink / service 已核验
    - deploy / rollback procedure baseline 已冻结
  - 阶段控制门禁
    - bounded object 已冻结
    - local frontend stage-1 已独立验证通过
  - implementation workspace existence gate
    - `/srv/git/exhibition-infra-monorepo` 已存在
    - 当前分支已可见

## 3. Failed Gates

- failed gates:
  - contract-extension gate
    - `Logo-only` 真正从联系人前置中解耦，当前仍不属于“现有合同内小修”
  - integration-release gate
    - 本轮不 author release / deploy sign-off
  - independent full-chain verification gate
    - 当前还未进入结果校验轮

## 4. Veto Gates

- veto gates:
  - 不得在 `/srv/apps/bff/current` 或 `/srv/apps/server/current` 直接改源码
  - 不得执行 release / deploy / rollback / integration
  - 不得覆盖 cloud git root 里的未知 enterprise_hub 既有改动
  - 不得把 `Logo-only` carrier 解耦偷渡成未冻结 contract 扩写
  - 不得把 founded-time filter 混入当前 round-5

## 5. Whether The Next Stage Is Allowed

- whether the next stage is allowed:
  - `Allowed with bounded scope`

## 6. Allowed Scope

- 当前 round-5 允许进入的实施范围：
  - `apps/server/src/modules/enterprise_hub/**`
  - `apps/server/src/core/runtime-config.service.ts`
  - `apps/bff/src/routes/enterprise_hub/**`
  - 必要的对应测试
- 当前 round-5 不允许：
  - `docs/01_contracts` 新 contract 扩写
  - founded-time filter
  - integration release

## 7. Next Unique Action

- 下一唯一动作：
  - 先读 cloud git root 里的当前 enterprise_hub dirty files
  - 拆出 `Server` 与 `BFF` 的最小写集合
  - 只对“不扩合同”的 residual items 开始实施

---
owner: Codex 总控
status: frozen
purpose: Record the current cloud git worktree drift for the enterprise-display trust-repair round before any cloud-side BFF or Server implementation is admitted.
layer: L0 SSOT
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/current_active_runtime_and_formal_host_drift_note_addendum.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
---

# 《enterprise display trust repair cloud git worktree 漂移说明》

## 1. Drift Fact

- 当前云端 implementation workspace 已确认存在：
  - `/srv/git/exhibition-infra-monorepo`
- 当前分支已确认：
  - `feature/trading-im-round-a`
- 当前 cloud git worktree 不是干净状态：
  - `apps/bff/src/routes/enterprise_hub/**` 存在已修改文件
  - `apps/server/src/modules/enterprise_hub/**` 存在已修改文件
  - 还存在一组 `._*` AppleDouble 风格的异常文件

## 2. Impact

- 这不是 release runtime 漂移，而是 implementation workspace 漂移。
- 该漂移直接影响：
  - BFF cloud implementation
  - Server cloud implementation
  - anti-revert 风险判断

## 3. Anti-revert Rule

- 进入 cloud implementation round 后必须遵守：
  - 不得 `git reset --hard`
  - 不得 `git checkout --`
  - 不得覆盖未读懂的既有 enterprise_hub 改动
  - 不得把 `._*` 异常文件当成 truth source
- 当前实现线程必须：
  - 先读当前 dirty files
  - 再做最小增量修改
  - 在回执里区分：
    - 既有云端改动
    - 本轮新增云端改动

## 4. Formal Conclusion

- cloud implementation workspace 漂移已正式记录。
- 该漂移不自动等于 `No-Go`。
- 但它强制要求：
  - read-first
  - no-revert
  - bounded ownership

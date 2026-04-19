---
owner: Codex 总控
status: frozen
purpose: Correct the overly broad round-2 no-go scope for enterprise-display trust repair, preserving the cloud-write block while re-affirming the already-frozen bounded local frontend stage-1 implementation path.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-03
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_stage1_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_and_public_list_trust_repair_stage1_frontend_surface_addendum.md
  - docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round2_no_go_judgment_addendum.md
---

# 《enterprise display trust repair round 3 scope correction and partial unlock》

## 1. Correction Trigger

- `round 2 no-go judgment` correctly blocked:
  - cloud write
  - deploy / rollback
  - integration release
- 但该文书把 `implementation unlock` 也一并写成了统一 `No-Go`，这与当前已生效的：
  - `enterprise_display_workbench_and_public_list_trust_repair_stage1_gate_checklist_addendum.md`
  - `enterprise_display_workbench_and_public_list_trust_repair_stage1_frontend_surface_addendum.md`
  形成了范围冲突。
- 上述 stage-1 文书已经正式冻结：
  - bounded object
  - allowed directories
  - stage-1 frontend repair surface
  - `Allowed` 的本地前端实施门禁

## 2. Scope Correction Rule

- 自本纠偏单生效起：
  - `round 2 no-go judgment` 继续有效的部分，只限于：
    - `No-Go for cloud write`
    - `No-Go for deploy / rollback / restart authorization`
    - `No-Go for integration release`
    - `No-Go for any cloud-side Backend / BFF implementation mutation`
- 自本纠偏单生效起：
  - `round 2 no-go judgment` 不再被解释为：
    - 撤销已冻结的 `stage-1 local frontend implementation`
    - 撤销已冻结的 `docs-only + local Flutter repair` 范围

## 3. Current Stage Decision

- 当前正式裁决调整为：
  - `Go for bounded local frontend stage-1 implementation`
  - `Go for docs-only freeze and local verification preparation`
  - `No-Go for cloud mutation`
  - `No-Go for Backend implementation on cloud`
  - `No-Go for BFF implementation on cloud`
  - `No-Go for integration release`

## 4. Allowed Scope After Correction

- 当前允许实施的目录仍固定为：
  - `docs/**`
  - `apps/mobile/lib/features/exhibition/**`
  - `apps/mobile/lib/core/location/**`
  - `apps/mobile/test/**`
- 当前允许进入的角色为：
  - 总控
  - 总控文书冻结
  - 前端 Agent（仅本地）
  - 结果校验 Agent（本地验证优先）
- 当前待命角色继续为：
  - 后端 Agent（仅云端）
  - BFF Agent（仅云端）
  - 联调发布 Agent

## 5. Stage-1 Repair Slice Still In Scope

- 当前可进入本地实施的 stage-1 repair slice 仍限于：
  - workbench truth-derived 阻断解释修复
  - Logo-only 维护路径修复
  - 地址解析失败态与 asset failure 受控兜底
  - company 公域列表 `logoUrl` 呈现
  - company 公域列表城市筛选可用性修复或受控禁用
- 当前仍不允许偷渡：
  - founded-time filter
  - 新 query contract
  - 云端 provider/config 修复伪装成前端已完成

## 6. Residual Blockers That Stay Active

- 下列 blocker 继续成立，且不因本纠偏单被解除：
  - `BFF_DEPLOY_CMD` 未冻结
  - `SERVER_DEPLOY_CMD` 未冻结
  - `BFF_ROLLBACK_CMD` 未冻结
  - `SERVER_ROLLBACK_CMD` 未冻结
  - current mainline cloud mutation baseline 未形成单一正式口径
- 因此：
  - 本地前端修复完成后，也不得直接口头宣称“全链完成”
  - 任何需要云端实现或云端发布的项，仍需单独门禁重判

## 7. Formal Conclusion

- `enterprise display trust repair round 3 scope correction`
  - `frozen`
- `bounded local frontend stage-1 implementation`
  - `Go`
- `cloud mutation / deploy / rollback / integration release`
  - `No-Go`

本纠偏单只做一件事：

- 把 `cloud execution blocker` 与 `local frontend stage-1 implementation` 正式拆开
- 避免后续线程继续用错误的 blanket `implementation No-Go` 阻断已获准的本地前端修复

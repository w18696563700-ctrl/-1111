---
owner: Codex 总控
status: frozen
purpose: Provide the corrective backend execution prompt for ED-2 after verification found the workbench case requirement drifted out of both readiness and submit truth.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_ed2_backend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/test/enterprise-hub-workbench-closure.test.cjs
---

# 《enterprise display full closure ED-2 backend corrective prompt R2》

## 1. 当前唯一任务

- 你现在继续是：
  - `enterprise display full closure mainline`
  - `ED-2 backend execution owner`
- 你的唯一任务不是重做 ED-2。
- 你的唯一任务是：
  - 修正 `case` 在 workbench truth 中的漂移
  - 让 `readiness.submitReady` 与 `submitApplication` 都重新符合冻结真源

## 2. 当前 blocker

- verifier 已确认以下两处和冻结真源冲突：
  1. `enterprise-hub-workbench.query.service.ts`
     - 当前 `readiness.hasCase` 已计算
     - 但 `submitReady` 没把 `hasCase` 算进去
     - `blockers` 里也没有“至少已有 1 个案例”的缺项提示
  2. `enterprise-hub-write.service.ts`
     - 当前 `submitApplication()` 不再校验 case minimum
     - 这意味着用户可能在没有 case 的情况下进入 submit
- 这与冻结真源直接冲突：
  - `enterprise_display_workbench_v1_truth_freeze_addendum.md` 已明确：
    - `至少已有 1 个案例`
    - 才能视为 submit-ready

## 3. 这次只允许改什么

- 只允许修改：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - 与这两处校验直接相关的最小测试文件
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - ED-1 已通过的 organization/profile 真值修复
  - ED-2 其他已经成立的 basic/profile/case 回读能力

## 4. 你必须完成

1. 让 `readiness.submitReady` 必须包含：
   - `hasCase = true`
2. 让 `readiness.blockers` 在没有 case 时必须出现稳定缺项提示。
3. 恢复或补上 `submitApplication()` 对 case minimum 的真实校验。
4. 保证以下两条链口径一致：
   - workbench `readiness.submitReady`
   - submit write gate
5. 补定向测试，至少覆盖：
   - 无 case 时 `submitReady = false`
   - 无 case 时 blockers 包含案例缺项
   - 无 case 时 submit 被 Server 拒绝
   - 有 case 时不因 case gate 被错误拦截

## 5. 你必须遵守

1. 不得只修 `submitReady`，不修 submit write gate。
2. 不得只修 submit write gate，不修 workbench `readiness/blockers`。
3. 不得把 case requirement 转嫁成前端本地规则。
4. 不得放宽成“case 可选”。
5. 不得顺手扩到 `application status`、`admin review/publish`、`public list/detail`。

## 6. 完成标准

- 结果必须证明：
  - workbench 的 `hasCase / submitReady / blockers` 与冻结真源一致
  - submit write gate 与 workbench readiness 一致
  - 没有 case 时，用户既看不到假 ready，也不能成功 submit

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. 为什么之前发生 case gate 漂移
  3. 现在如何保证 read/write 两条链一致
  4. 新增或更新的测试结果
  5. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `verification 中`
- 当前下一步唯一动作：
  - 发出本 R2 corrective prompt 给 `后端`
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - 已确认 case requirement 当前在 read/write 两侧同时漂移

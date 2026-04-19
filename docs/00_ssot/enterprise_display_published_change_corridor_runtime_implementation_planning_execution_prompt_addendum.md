---
owner: Codex 总控
status: active
purpose: Freeze the execution prompt for runtime implementation planning of the enterprise display published-change corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
---

# 《enterprise display published change corridor runtime implementation planning execution prompt》

## 1. 执行角色

- 文书冻结执行 / Runtime planning owner

## 2. 唯一目标

你这轮只负责把 `published change corridor` 的 runtime implementation 拆成可执行 package 顺序。

当前唯一目标固定为：

1. 冻结 runtime package 分解
2. 冻结 package 之间的依赖顺序与门禁
3. 冻结每个 package 的 owner、范围、非目标、验证点

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_admin_governance_contract_freeze_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_result_verification_conclusion_addendum.md)
4. [enterprise_display_published_change_corridor_runtime_implementation_planning_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_stage_gate_checklist_addendum.md)

## 4. 只允许修改的范围

- `docs/00_ssot/**`
- 与本轮 planning 直接相关的最小 `docs/01_contracts/**`

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不直接发 implementation prompt
- 不把 planning 写成 unlock
- 不跳过 `Server / Admin` 治理主链先发 app-facing 包

## 6. 你必须完成

1. package 分解
- 至少拆清：
  - `Server governance truth package`
  - `Admin review/apply surface package`
  - `BFF published-corridor surface package`
  - `Flutter published-change workbench package`

2. 依赖顺序
- 必须明确：
  - 哪个 package 必须先过
  - 哪个 package 必须等待上游验收结论

3. 每包边界
- 每个 package 都必须写：
  - owner
  - 允许修改范围
  - 禁止事项
  - 最低验证要求

4. veto gate
- 必须明确：
  - 哪些包在什么条件下仍然 `No-Go`
  - 什么时候才能从 planning 进入 dispatch

## 7. 完成标准

结果必须证明：

1. runtime implementation 已经有可执行分包顺序
2. 不会出现 `Flutter / BFF` 先跑、`Server / Admin` 后补的倒挂
3. 下一轮可以按 package dispatch，而不是继续口头推进

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把本轮 planning 写成已完成

## 8. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. package 顺序清单
  2. 每包 owner 与修改范围
  3. 每包 veto gate
  4. 当前是否允许进入第一包 dispatch

## 9. 输出禁令

- 不要写“应该可以”
- 不要把 planning 伪装成 unlock
- 不要省略 package 依赖关系
- 不要让 app-facing runtime 早于治理真相层
- 只给真实 planning、真实门禁、真实下一步顺序

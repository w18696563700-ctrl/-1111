---
owner: Codex 总控
status: active
purpose: Freeze the execution prompt for the admin-governance contract bundle of the enterprise display published-change corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_stage_gate_checklist_addendum.md
---

# 《enterprise display published change corridor admin-governance contract freeze execution prompt》

## 1. 执行角色

- 文书冻结执行 / Contracts owner

## 2. 唯一目标

你这轮只负责冻结 `published change corridor` 的 Admin / 治理承接 contract。

当前唯一目标固定为：

1. 明确 `change request` 在 Admin 侧的 review / revision / approve / reject / apply canonical contract family
2. 明确 app-facing `changes/current` 与 Admin 治理承接面的状态对应关系
3. 在 runtime implementation 前，把 published corridor 的治理闭环 contract owner 写死

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_admin_governance_contract_freeze_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_stage_gate_checklist_addendum.md)
4. [docs/01_contracts/openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 4. 只允许修改的范围

- `docs/01_contracts/**`
- 与本轮最小 contract freeze 直接相关的最小 `docs/00_ssot/**`

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不直接进入 `openapi` runtime patch，除非结论已经冻结成唯一 canonical family
- 不把 review / apply 逻辑口头化，不落 formal contract owner
- 不发明第二条 published-edit 治理主链

## 6. 你必须冻结的内容

1. Admin / 治理 canonical path family
- 至少明确：
  - review queue read
  - review detail read
  - approve
  - reject / return for revision
  - apply to live listing

2. 状态流转 contract
- 至少明确：
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
  - `applied`
- 并写清：
  - 哪些状态由 app-facing `submit` 触发
  - 哪些状态由 Admin action 触发

3. app-facing 与 Admin-facing 的对接规则
- 必须明确：
  - `GET /changes/current/status` 如何映射到 Admin review 状态
  - `apply` 后 live listing 怎样更新
  - `revision_required` 如何回到用户侧继续修改

4. 禁止语义
- 必须明确禁止：
  - 已发布修改绕过治理直接进 live listing
  - `approve` 与 `apply` 混成同一步
  - Admin review 没有 formal carrier 只靠口头约定

## 7. 完成标准

结果必须证明：

1. published corridor 不再只有 app-facing 半套 contract
2. review / apply / reject / revision 已有正式治理 contract owner
3. 下一步 runtime implementation 能按 contract-first 顺序进入

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把本轮 contract freeze 写成已完成

## 8. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 新增冻结的 Admin / 治理 contract family 清单
  3. change status 流转说明
  4. app-facing 与 Admin-facing 对接说明
  5. 当前是否允许进入 runtime implementation planning

## 9. 输出禁令

- 不要写“应该可以”
- 不要把 Admin 承接继续留给后端实现时再猜
- 不要把 `approve` 与 `apply` 混写
- 不要借机直接发 runtime 包
- 只给真实 contract freeze、真实剩余风险、真实下一步门禁

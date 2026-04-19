---
owner: Codex 总控
status: frozen
purpose: Record the formal round-6 admission judgment after the cloud deploy and rollback baseline was corrected from a single-command expectation to a verified procedure baseline.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-06
inputs_canonical:
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_cloud_git_worktree_drift_note_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round5_cloud_implementation_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_workbench_and_public_list_trust_repair_bounded_object_ruling_addendum.md
---

# 《enterprise display trust repair round 6 cloud implementation 准入裁决》

## 1. Judgment Scope

- 本裁决只判断：
  - 当前 enterprise display trust repair 是否允许进入受限云端 `BFF / Server` 实施轮
- 本裁决不判断：
  - integration release 是否放行
  - full-chain verification 是否已完成
  - founded-time filter 是否开启

## 2. Findings

- blocker:
  - `Logo-only` 真正从联系人姓名 / 手机号前置中解耦，仍不能按“现有合同内小修”直接放入当前轮次；如要完成，需单独冻结 contract / truth 变更。
- non-blocking risk:
  - cloud git root 仍是 dirty worktree，且与 enterprise_hub 关键文件重叠。
  - 当前 `exhibition-bff` 的实际启动口径依赖 systemd drop-in override，应继续按运行态为准，不得回退到基础 unit 原值。
- observation:
  - deploy / rollback 的单一命令基线并不存在，但 procedure baseline 已完成 formal freeze。
  - 当前 No-Go 已不再适用于“所有云端实施”；它只继续适用于 release / deploy / rollback / full-chain verification。

## 3. Formal Judgment

- 当前 round-6 正式裁决为：
  - `Allowed with bounded scope`
- 当前允许进入：
  - cloud `Server` residual implementation
  - cloud `BFF` residual implementation
  - 仅限不扩 app-facing contract 的修复项
- 当前仍不允许进入：
  - deploy
  - rollback
  - release sign-off
  - integration release
  - full-chain final verification

## 4. Allowed Residual Object

- 当前 round-6 允许处理：
  - 企业工作台 truth 同步与展示补齐
  - 位置解析 provider / config / error-path 的受控修复
  - 列表 / workbench read model 对已存在 server truth 的消费对齐
  - 更精确的保存 / 提交失败分型，但不得偷渡新增 contract 字段
- 当前 round-6 不允许处理：
  - `Logo-only` carrier 解耦
  - founded-time filter
  - 新 query / 新 contract surface

## 5. Mandatory Anti-revert Rule

- 进入 round-6 前必须先读 cloud git root 中已有 dirty enterprise_hub 改动。
- 不得：
  - `git reset --hard`
  - `git checkout --`
  - 覆盖未读懂的既有 enterprise_hub 改动
  - 把 `._*` AppleDouble 异常文件当成 truth source
- 本轮每个施工回执必须区分：
  - 既有云端改动
  - 本轮新增云端改动

## 6. Next Stage Order

1. 先只读读取 cloud git root 中 `Server` 和 `BFF` 的当前 dirty diff。
2. 拆出最小 `Server` 写集合与最小 `BFF` 写集合。
3. 先做 `Server` truth / error-path 修复，再做 `BFF` mapping / consumption 修复。
4. 完成后再进入独立校验准入判断。

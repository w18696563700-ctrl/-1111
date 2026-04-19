---
owner: Codex 总控
status: active
purpose: Freeze the execution prompt for Package A readonly inventory so enterprise-display three-board independence can freeze the exact historical case/media repair candidate set before any live data write is attempted.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
---

# 《enterprise display three-board independence Package A readonly inventory execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display / three-board independence`
- 子阶段：
  - `Stage C / Server data repair`
- 当前包：
  - `Package A / readonly inventory`

## 2. 唯一目标

- 你这轮只负责冻结候选集。
- 你这轮只允许做三件事：
  1. 跑 `Q1-Q7`
  2. 按 carrier 分类候选行
  3. 写 inventory receipt

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md`
- `docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md`
- `apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql`

## 4. 只允许修改的范围

- 只允许写：
  - `docs/00_ssot/**`
- 只允许执行：
  - approved readonly SQL audit
- 不得修改：
  - `apps/server/src/**`
  - `apps/server/scripts/**`
  - 任何 live database row

## 5. 禁止事项

- 不执行任何 `UPDATE / DELETE / INSERT`
- 不执行任何 `COMMIT`
- 不凭页面现象猜归属
- 不凭 URL / `objectKey` 反推真值
- 不把 `Q5` 观察项自动塞进主修候选集
- 不把 runtime 已兼容的 board-specific case `fileKind` 自动记成脏数据

## 6. 你必须完成

### 6.1 候选集冻结

- 必须跑完整 `Q1-Q7`。
- 必须额外注意：
  - `Q4` 的旧查询只把 `enterprise_case_media` 视为合法值
  - inventory 解释时必须同时承认 runtime 兼容集合中的：
    - `enterprise_company_case_media`
    - `enterprise_factory_case_media`
    - `enterprise_supplier_case_media`
- 必须把结果拆成：
  - `case ownership drift`
  - `case media drift`
  - `draft_cases snapshot drift`
  - `ref rebuild required`
  - `out-of-scope observation`

### 6.2 每条候选行的最小画像

- 对每条候选行至少写清：
  - source table
  - row id
  - current enterprise / board
  - target enterprise / board
  - 为什么不能靠 runtime 自动自愈
  - 是否需要联动 `enterprise_media_asset_ref`

### 6.3 repair admission 结论

- 必须明确回答：
  - 哪些候选行可以进入 `Package B`
  - 哪些候选行继续 `No-Go`
  - 哪些问题只是观察项，不应进入当前轮

## 7. 完成标准

- 输出必须让总控可以据此决定：
  - `Package B` 是否升为 executable
- 若任一候选行仍需要猜测归属：
  - 该候选行必须保留 `No-Go`

## 8. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 执行环境与只读前提
  2. `Q1-Q7` 结果摘要
  3. 候选行清单与分类
  4. 每条候选行的 target truth 判断
  5. `Package B` 准入建议
  6. 继续 veto 的对象

## 9. 输出禁令

- 不要给 repair SQL
- 不要开始改数据
- 不要把 inventory 写成验证通过
- 只给真实候选集与真实准入建议

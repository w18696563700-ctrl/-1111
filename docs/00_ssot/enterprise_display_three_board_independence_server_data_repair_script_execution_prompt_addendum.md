---
owner: Codex 总控
status: active
purpose: Freeze the execution prompt for Package B bounded repair script so enterprise-display three-board independence may repair only the inventory-confirmed historical rows after Package A receipt passes.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_template.sql
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
  - apps/server/src/modules/enterprise_hub/enterprise-hub-media-truth.service.ts
---

# 《enterprise display three-board independence Package B bounded repair script execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display / three-board independence`
- 子阶段：
  - `Stage C / Server data repair`
- 当前包：
  - `Package B / bounded repair script`

## 2. 前置条件

- 本 prompt 只有在以下条件同时成立时才可执行：
  - `Package A` receipt 已落盘
  - 总控已明确把 `Package B` 从 authored 状态升为 executable
- 若没有上述两项：
  - 当前 prompt 仅可阅读，不得执行

## 3. 唯一目标

- 你这轮只负责修正 `Package A` 已冻结的候选行。
- 你这轮只允许解决四件事：
  1. `enterprise_case` ownership drift
  2. `draft_cases` snapshot drift
  3. `file_asset` business binding drift
  4. `enterprise_media_asset_ref` rebuild

## 4. 强制阅读

- `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md`
- `docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_receipt_addendum.md`
- `apps/server/scripts/enterprise_hub_case_media_repair_template.sql`
- `apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql`

## 5. 只允许修改的范围

- `apps/server/scripts/**`
- `docs/00_ssot/**`
- 如确有必要的最小辅助测试：
  - `apps/server/test/**`
- 不允许修改：
  - `apps/server/src/**`
  - `apps/bff/**`
  - `apps/mobile/**`

## 6. 禁止事项

- 不做无界全量 backfill
- 不用 migration 代替本轮 data repair
- 不修改 schema
- 不借 API 迁移 case ownership
- 不用 URL / `objectKey` 反写 truth
- 不修 inventory 未确认的行
- 不把 generic `enterprise_case_media` 默认改写成 board-specific `fileKind`

## 7. 你必须完成

### 7.1 concrete repair script

- 必须从 template 复制出 concrete script。
- concrete script 必须显式写出：
  - 目标行 ID
  - 目标 enterprise / board
  - repair 前置判断
  - rollback 方式

### 7.2 四层同步

- 若修 `enterprise_case`：
  - 必须同步检查 `draft_cases`
  - 必须同步检查相关 `file_asset`
  - 必须同步重建 `enterprise_media_asset_ref`
- 若修 `file_asset`：
  - 必须说明为何不需要改 case row
  - 必须说明目标 `file_kind` 是否仍落在 runtime 兼容集合内
- 若修 `draft_cases`：
  - 必须保证 live truth 已先归位

### 7.3 dry-run first

- 必须先给出 `BEGIN ... ROLLBACK` dry-run 版本。
- 若总控未追加 commit 放行：
  - 不得改成 `COMMIT`

## 8. 完成标准

- repair script 必须是行级、可回滚、可审计的。
- 任一 repair 若仍需猜测归属：
  - 必须剔除，不得强修。

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_script_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. concrete script 文件清单
  2. 每个目标行的 repair 理由
  3. dry-run 结果
  4. 是否已获得 commit 放行
  5. 对 `enterprise_media_asset_ref` 的处理
  6. 当前剩余未修项

## 10. 输出禁令

- 不要越过 `Package A`
- 不要直接默认 `COMMIT`
- 不要把 script authoring 写成 repair 完成
- 只给真实脚本、真实 dry-run、真实剩余风险

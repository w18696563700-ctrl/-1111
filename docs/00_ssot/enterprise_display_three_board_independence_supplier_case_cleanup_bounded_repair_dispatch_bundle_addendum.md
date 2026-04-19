---
owner: Codex 总控
status: active
purpose: Freeze the bounded dispatch bundle for deleting the current invalid supplier case under enterprise-display three-board independence, ensuring the repair touches only case truth and verification surfaces.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_supplier_case_cleanup_bounded_repair_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_receipt_addendum.md
---

# 《enterprise display three-board independence supplier case cleanup bounded repair dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 删除当前非法 supplier case 的 live business truth
  - 让该 case 不再出现在 public read 与 SQL truth 中

## B. 当前轮明确非目标

- 不删除 `profile/business_license` 文件本体
- 不删除 organization 级 profile truth
- 不修改 `enterprise_application`
- 不修改 `enterprise_listing`
- 不修改 company / factory 任何对象
- 不新增 schema / path family / state machine

## C. 当前轮 package split

### C1. Package 1 | Cleanup repair

- 允许写：
  - `apps/server/scripts/**`
  - `docs/00_ssot/**`
- 只允许动作：
  - 删除当前 `enterprise_case` 主记录
  - 删除该 case 的专属 case ref

### C2. Package 2 | Verification

- 只允许动作：
  - 复跑 supplier 定向 SQL
  - 检查 public case 路由
  - 检查 supplier detail cases 状态

## D. 当前轮验收底线

- `enterprise_case` 中不再存在：
  - `5ffda6ac-e379-4ff9-85fc-720beb2a7161`
- `public-cases/5ffda6ac-e379-4ff9-85fc-720beb2a7161` 不再可读
- supplier detail 不再展示该案例
- `file_asset.id = 9399d036-aca4-4331-b15f-0c6ede2e8df9` 仍保留为 profile truth

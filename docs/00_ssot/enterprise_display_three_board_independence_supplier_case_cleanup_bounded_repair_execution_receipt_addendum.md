---
owner: Codex 总控
status: active
purpose: Record the bounded repair receipt for deleting the current invalid supplier case under enterprise-display three-board independence.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_supplier_case_cleanup_bounded_repair_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_supplier_case_cleanup_bounded_repair_dispatch_bundle_addendum.md
  - apps/server/scripts/enterprise_hub_supplier_invalid_case_cleanup_20260419.sql
---

# 《enterprise display three-board independence supplier case cleanup bounded repair execution receipt》

## 1. 当前目标对象

- `case_id = 5ffda6ac-e379-4ff9-85fc-720beb2a7161`
- `enterprise_id = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
- `board_type = supplier`

## 2. 允许删除的 truth carrier

- `enterprise_case` 当前主记录
- `enterprise_media_asset_ref` 中该 case 专属 ref

## 3. 明确不删除的对象

- `file_asset.id = 9399d036-aca4-4331-b15f-0c6ede2e8df9`
- 任何 `profile/business_license` 资产
- `enterprise_application`
- `enterprise_listing`

## 4. 执行留证

- dry-run：
  - 已执行
  - 结果：
    - `DELETE 0` on `enterprise_media_asset_ref`
    - `DELETE 1` on `enterprise_case`
    - `supplier_case_remaining = 0`
    - `supplier_case_ref_remaining = 0`
    - `file_asset.id = 9399d036-aca4-4331-b15f-0c6ede2e8df9` 仍存在，且仍是 `profile/business_license`
    - `ROLLBACK`
- commit：
  - 已执行
  - 执行方式：
    - 使用同一份脚本，将末行 `ROLLBACK` 临时替换为 `COMMIT` 后送入云端 `psql`
  - 结果：
    - `DELETE 0` on `enterprise_media_asset_ref`
    - `DELETE 1` on `enterprise_case`
    - `supplier_case_remaining = 0`
    - `supplier_case_ref_remaining = 0`
    - `COMMIT`
- verification：
  - 已执行
  - 关键结果：
    - `enterprise_case` 中该 case 已不存在
    - `enterprise_media_asset_ref` 中该 case 专属 ref 仍为 `0`
    - `Q4_AFTER = 0`
    - public case route 返回 `404`
    - supplier detail：`casesState = empty`，`caseCount = 0`

## 5. 当前结论

- 当前删除型 bounded repair 已完成。
- 当前已确认：
  - 非法 supplier case live truth 已清除
  - 共享 `business_license` 文件本体未被误删
  - 删除范围没有扩散到 company / factory / listing / application

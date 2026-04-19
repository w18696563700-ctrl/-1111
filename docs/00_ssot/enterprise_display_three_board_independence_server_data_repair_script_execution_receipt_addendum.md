---
owner: Codex 总控
status: active
purpose: Record the Package B bounded repair-script execution receipt for enterprise-display three-board independence after the candidate set was narrowed to historical live case ref backfill only and a production dry-run completed with rollback.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_script_execution_prompt_addendum.md
  - apps/server/scripts/enterprise_hub_three_board_case_ref_backfill_20260419.sql
  - apps/server/src/modules/enterprise_hub/enterprise-hub-media-truth.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-media-asset-ref.entity.ts
---

# 《enterprise display three-board independence Package B bounded repair script execution receipt》

## 1. concrete script 文件清单

- `apps/server/scripts/enterprise_hub_three_board_case_ref_backfill_20260419.sql`

## 2. 当前真实 scope

- 当前 `Package B` 只覆盖：
  - company approved live case ref rebuild
  - factory approved live case ref rebuild
- 当前明确不覆盖：
  - company draft snapshot `caseImageUrlMap`
    - 原因：当前 read-path 会 `hydrateSnapshotMedia()`，该字段是派生展示字段，不是 canonical truth
  - supplier invalid case media
    - 原因：target asset 不可安全推定
  - listing basic refs
  - factory showcase refs

## 3. 每个目标行的 repair 理由

### 3.1 company live case

- target case：
  - `a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64`
- enterprise：
  - `e2a016f4-0b6a-497d-902c-409413858ca9`
- repair 理由：
  - live case cover/media 资产合法
  - `enterprise_media_asset_ref` 当前为 `0`
  - target truth 可由当前 live row 无歧义重建
- 预期 ref：
  - `case_cover x 1`
  - `case_media x 2`

### 3.2 factory live case

- target case：
  - `e3940909-b9ec-4f21-a150-7d34dafce31c`
- enterprise：
  - `a9b46040-956e-44fd-8e35-e3c533687e27`
- repair 理由：
  - live case cover/media 资产合法
  - `enterprise_media_asset_ref` 当前为 `0`
  - target truth 可由当前 live row 无歧义重建
- 预期 ref：
  - `case_cover x 1`
  - `case_media x 1`

## 4. dry-run 结果

- 执行方式：
  - 将本地脚本通过 `ssh + psql -f -` 只读/受控方式送入云端
  - 脚本末尾保留 `ROLLBACK`
- dry-run 输出：
  - `BEGIN`
  - `DELETE 0`
  - `INSERT 0 3`
  - `INSERT 0 2`
  - 预期 `5` 条 ref 查询结果全部出现
  - `ROLLBACK`
- 结论：
  - 当前脚本语义正确
  - 当前目标行集合正确
  - 当前没有误删历史 ref

## 5. 是否已获得 commit 放行

- 当前状态：
  - `Yes`
- commit 触发依据：
  - 总控已收到明确继续指令
  - 候选集未发生漂移
  - dry-run 已通过
- 当前已执行：
  - 将同一脚本的最终 `ROLLBACK` 替换为 `COMMIT`
  - 对 Candidate B/C 完成真实写库

## 6. 对 `enterprise_media_asset_ref` 的处理

- 当前脚本会先按两条 target case 的 `owner_id` 定点删除旧 ref。
- 然后只插入：
  - company live case 的 `3` 条 ref
  - factory live case 的 `2` 条 ref
- 当前不会碰：
  - supplier case refs
  - listing basic refs
  - factory showcase refs
- 当前真实 commit 结果：
  - company case 写入 `3` 条 ref
  - factory case 写入 `2` 条 ref
  - 合计 `5` 条 ref

## 7. 当前剩余未修项

- supplier approved live case：
  - `5ffda6ac-e379-4ff9-85fc-720beb2a7161`
  - 仍绑定 `profile/business_license`
  - 继续 `No-Go`
- company draft snapshot 缺 `caseImageUrlMap`：
  - 继续作为 observation 保留
  - 当前不进入 bounded SQL repair
- 三条 listing 的非 case ref backfill：
  - 当前不进入本轮

## 8. 当前结论

- `Package B` 现在已经具备以下条件：
  - Candidate B/C 的真实 commit 已完成
  - commit 风险边界清楚
  - dry-run 与 commit 两套证据都已留存
- 截至本回执落盘：
  - `Package C` 已可进入验证
  - 但最终闭环仍受 Candidate D 与 observation-only Candidate A 约束

## 9. Formal Conclusion

- 当前 `Package B` 结论固定为：
  - `commit passed for Candidate B/C`
  - `Candidate A stays observation-only`
  - `Candidate D stays No-Go`
- 下一步若继续推进，只应是：
  - 执行 `Package C` verification

---
owner: Codex 总控
status: active
purpose: Record the Package A readonly inventory execution receipt for enterprise-display three-board independence after Q1-Q7 and targeted readonly HTTP/SQL follow-up froze the current historical case/media candidate set.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_inventory_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
---

# 《enterprise display three-board independence Package A readonly inventory execution receipt》

## 1. 执行环境与只读前提

- 执行时间：
  - `2026-04-19`
- 执行位置：
  - 本地总控通过 `ssh root@47.108.180.198` 进入云主机只读执行
- 运行环境确认：
  - `exhibition-server` 当前使用：
    - `/srv/apps/server/.env`
  - 当前数据库：
    - `POSTGRES_DB = exhibition_app`
- 只读前提：
  - 只执行 `SELECT`
  - 只执行 `curl GET`
  - 不执行任何 `UPDATE / DELETE / INSERT`
  - 不执行任何 `COMMIT`
  - 不修改 `apps/server/src/**`

## 2. `Q1-Q7` 结果摘要

### 2.1 Q1｜listing / application / case 总览

- 结果：
  - `5` 条 listing
- 关键事实：
  - 目标组织 `e6bf4567-016e-45f9-9420-9c950237690e` 下三条 published+visible listing 仍存在：
    - `company = e2a016f4-0b6a-497d-902c-409413858ca9`
    - `factory = a9b46040-956e-44fd-8e35-e3c533687e27`
    - `supplier = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
  - 三条 listing 当前各有 `1` 条 same-board case。
  - `company` 最新 application 为 `submitted`。
  - `factory` 最新 application 为 `submitted`。
  - `supplier` 最新 application 为 `approved`。

### 2.2 Q2｜硬串板块 case

- 结果：
  - `0` 行
- 结论：
  - 当前线上不存在 `enterprise_case.board_type != enterprise_listing.primary_board_type` 的硬串板块 case。

### 2.3 Q3｜已影响公开面的硬串板块 case

- 结果：
  - `0` 行
- 结论：
  - 当前线上不存在已影响公开面的 hard board mismatch。

### 2.4 Q4｜case 图片真值异常

- 结果：
  - `2` 行
- 命中对象：
  - 同一条 `supplier` approved live case：
    - `case_id = 5ffda6ac-e379-4ff9-85fc-720beb2a7161`
    - `enterprise_id = c0576f5c-854c-4b78-9f93-6d57e55d8b47`
    - `title = supplier 样本案例`
- 异常资产：
  - `file_asset_id = 9399d036-aca4-4331-b15f-0c6ede2e8df9`
  - `business_type = profile`
  - `business_id = e6bf4567-016e-45f9-9420-9c950237690e`
  - `file_kind = business_license`
  - `mime_type = image/jpeg`
- 解释：
  - `Q4` 的旧查询只把 `enterprise_case_media` 视为合法 `file_kind`，本身存在兼容边界。
  - 但本次命中的不是 board-specific `fileKind` 假阳性，而是真异常：
    - 资产属于 `profile/business_license`
    - 不是 enterprise-display case 媒体
    - 也不是 runtime 已兼容的 board-specific case `fileKind`

### 2.5 Q5｜listing album / factory showcase 图片真值

- 结果：
  - `0` 行
- 结论：
  - 当前未发现 listing album / factory showcase truth 异常。
- 当前裁决：
  - `Q5` 继续只作为观察项，不进入当前轮主修范围。

### 2.6 Q6｜draft_cases 错板块快照

- 结果：
  - `0` 行
- 结论：
  - 当前线上不存在 `draft_cases` 中的错板块快照。

### 2.7 Q7 equivalent｜draft_cases 缺少 `caseImageUrlMap`

- 原脚本情况：
  - 原 `Q7` 在云端 PostgreSQL 13 上无法直接执行：
    - `jsonb_object_length(jsonb) does not exist`
- 等价补跑结果：
  - `1` 行
- 命中对象：
  - `change_request_id = 14955150-f6a2-403d-a430-fcde49a3b113`
  - `enterprise_id = e2a016f4-0b6a-497d-902c-409413858ca9`
  - `board_type = company`
  - `change_status = submitted`
  - `case_id = a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64`
- 解释：
  - 当前缺的是 `caseImageUrlMap` 这个派生展示字段。
  - 该字段不是 canonical truth，不足以单独构成 bounded SQL repair 准入依据。

## 3. 追加只读核查

### 3.1 三条 live case 的当前真值

- `company` live case：
  - `case_id = a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64`
  - `case_status = approved`
  - cover / media 资产全部合法：
    - `business_type = enterprise_display`
    - `business_id = e2a016f4-0b6a-497d-902c-409413858ca9`
    - `file_kind = enterprise_case_media`
- `factory` live case：
  - `case_id = e3940909-b9ec-4f21-a150-7d34dafce31c`
  - `case_status = approved`
  - cover / media 资产全部合法：
    - `business_type = enterprise_display`
    - `business_id = a9b46040-956e-44fd-8e35-e3c533687e27`
    - `file_kind = enterprise_case_media`
- `supplier` live case：
  - `case_id = 5ffda6ac-e379-4ff9-85fc-720beb2a7161`
  - `case_status = approved`
  - cover / media 资产全部非法：
    - 仍是 `profile/business_license`
    - 当前不存在可无歧义推定的合法 enterprise-display case asset

### 3.2 `enterprise_media_asset_ref` 当前现状

- 当前查询结果：
  - `company` case refs 已存在 `3` 条
  - `factory` case refs 已存在 `2` 条
  - `supplier` case refs 不存在
- 结论：
  - `company / factory` 的 case ref rebuild 不是当前待修项，而是已存在的历史运行态事实。
  - 当前不得再把它们重新列为 `Package B` 候选。

### 3.3 当前 public read 表现

- `factory` public detail：
  - 可正常读取，标题为：
    - `重庆海川展览工厂`
- `factory` public case：
  - `caseImageUrlMap` 正常返回 enterprise-display case URL
- `supplier` public case：
  - 当前仍直接返回 `profile/business_license` URL
- 结论：
  - `supplier` 异常不仅存在于 SQL truth 层，也已经体现在公开读面。

## 4. 候选行清单与分类

### 4.1 Candidate A｜supplier live case media drift

- `candidate_id`：
  - `candidate-supplier-case-5ffda6ac-e379-4ff9-85fc-720beb2a7161`
- `drift_class`：
  - `No-Go candidate`
- `trigger_reason`：
  - `Q4 = 2`
  - live case cover/media 都指向 `profile/business_license`
  - public read 仍会直接泄漏该 URL
- `required_action`：
  - 当前不得进入 `Package B`
  - 需要运营 / 人工补素材或业务决策先明确 target asset
  - 不允许靠 SQL 猜测应绑定哪张 enterprise-display 图片

### 4.2 Candidate B｜company submitted snapshot 派生字段残留

- `candidate_id`：
  - `candidate-company-snapshot-14955150-f6a2-403d-a430-fcde49a3b113`
- `drift_class`：
  - `observation only`
- `trigger_reason`：
  - `Q7 equivalent = 1`
  - 缺失字段是 `caseImageUrlMap`
  - live case canonical truth 仍合法
- `required_action`：
  - 当前不进入 `Package B`
  - 保持 observation-only
  - 若后续要修，应走 read-side hydration 或单独 snapshot corridor 讨论，不应在本轮直接修库

### 4.3 Non-candidate｜company / factory case refs

- `candidate_id`：
  - `non-candidate-company-factory-case-refs`
- `drift_class`：
  - `observation only`
- `trigger_reason`：
  - 当前数据库内：
    - `company` 已有 `3` 条 case refs
    - `factory` 已有 `2` 条 case refs
  - 说明这两条对象的 ref rebuild 已经发生在当前 inventory 之前
- `required_action`：
  - 当前不作为 `Package B` 候选
  - 当前也不采信未跟踪 receipt 作为 formal gate evidence
  - 这里只把现状当作 live readonly fact 记录

## 5. `Package B` 准入建议

- 当前结论：
  - `No-Go for Package B`
- 原因：
  - 当前不存在新的、可安全确定 target truth 的 bounded script 对象。
  - `company / factory` refs 已经存在，不应重复执行 ref backfill。
  - `supplier` case media drift 无法安全推定目标素材。
  - `company` snapshot 缺的是派生字段，不是 canonical truth。

## 6. 继续 veto 的对象

- `supplier` approved live case：
  - `5ffda6ac-e379-4ff9-85fc-720beb2a7161`
  - 继续 `No-Go`
- `company` submitted snapshot `caseImageUrlMap`：
  - 保持 observation-only
- `listing album / factory showcase`：
  - 继续 out-of-scope
- 仓库中现有未跟踪 `Package B / Package C` receipts：
  - 当前不作为 formal gate evidence 使用
  - 原因是其证据链与当前 gate/dispatch 约束不完全一致

## 7. Formal Conclusion

- 当前 `Package A readonly inventory` 的 formal conclusion 固定为：
  - 候选集已冻结
  - 当前没有新的 `Package B` 可执行对象
  - 本轮 data-repair 主线到此停在 inventory
- 若继续推进当前对象，下一步只可能是：
  - 针对 `supplier` invalid case 先做业务决策 / 人工补素材
  - 或单独讨论 read-side / snapshot residue，不应直接再开 bounded SQL repair

-- enterprise_hub_case_media_repair_template.sql
-- 修复模板。默认只给出事务骨架和判定顺序，不直接写入生产。
-- 生产执行前，必须先跑 readonly audit，并导出候选集进行人工确认。

BEGIN;

-- Step 1. 冻结候选集
-- 建议先将 enterprise_hub_case_media_repair_readonly_audit.sql 的结果导出到临时表或审计文件。

-- Step 2. 判定修复类型
-- A. enterprise_case.enterprise_id 错挂
-- B. enterprise_case.board_type 写错
-- C. enterprise_change_request.draft_cases 快照保留旧值
-- D. file_asset.business_id / file_kind 仍指向旧 enterprise truth

-- Step 3. enterprise_case 修复样板
-- 下面模板不要直接全库执行，只对人工确认后的 case_id 集合执行。

-- 3A. 仅当确认 case 应归属到同组织下另一条 listing 时，修 enterprise_id
-- UPDATE enterprise_case
-- SET enterprise_id = :target_enterprise_id,
--     updated_at = NOW()
-- WHERE id = :case_id;

-- 3B. 仅当确认 case 的归属 listing 正确，但 board_type 写错时，修 board_type
-- UPDATE enterprise_case
-- SET board_type = :target_board_type,
--     updated_at = NOW()
-- WHERE id = :case_id;

-- Step 4. enterprise_change_request.draft_cases 修复样板
-- 注意：live truth 必须先修，再修 draft_cases，否则旧快照会继续反污染 live。
--
-- 推荐做法：
-- 1) 先 select 出目标 change_request
-- 2) 在应用层或安全脚本里重建 draft_cases JSON
-- 3) 再 update draft_cases

-- 示例骨架：
-- UPDATE enterprise_change_request
-- SET draft_cases = :rebuilt_draft_cases::jsonb,
--     updated_at = NOW()
-- WHERE id = :change_request_id;

-- Step 5. file_asset 修复样板
-- 仅当 case 已归位且确认为企业展示图片真值仍指向旧 business_id 时执行。

-- UPDATE file_asset
-- SET business_id = :target_enterprise_id
-- WHERE id = :file_asset_id
--   AND business_type = 'enterprise_display'
--   AND file_kind = 'enterprise_case_media';

-- Step 6. 修复后强制复核
-- 必须重新运行：
-- - enterprise_hub_case_media_repair_readonly_audit.sql 的 Q2 / Q3 / Q4 / Q6 / Q7
-- 预期：
-- - Q2 / Q3 / Q4 / Q6 / Q7 返回 0 行

ROLLBACK;

-- 说明：
-- 默认保留 ROLLBACK，防止误执行。
-- 真正生产修复时，应复制本模板，替换成明确 case_id / enterprise_id / change_request_id，
-- 并在人工复核后将最后一行改为 COMMIT。

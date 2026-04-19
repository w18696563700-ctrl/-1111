-- enterprise_hub_case_media_repair_readonly_audit.sql
-- 只读核查脚本。用于生产取证，不执行任何写操作。

-- Q1. listing / latest application / case count 总览
SELECT
  l.id AS enterprise_id,
  l.organization_id,
  l.primary_board_type,
  l.enterprise_status,
  l.display_status,
  a.id AS latest_application_id,
  a.apply_board_type,
  a.application_status,
  cc.total_case_count,
  cc.same_board_case_count
FROM enterprise_listing l
LEFT JOIN LATERAL (
  SELECT a1.id, a1.apply_board_type, a1.application_status, a1.reviewed_at
  FROM enterprise_application a1
  WHERE a1.enterprise_id = l.id
  ORDER BY a1.created_at DESC, a1.updated_at DESC
  LIMIT 1
) a ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) AS total_case_count,
    COUNT(*) FILTER (WHERE c.board_type = l.primary_board_type) AS same_board_case_count
  FROM enterprise_case c
  WHERE c.enterprise_id = l.id
) cc ON TRUE
WHERE l.primary_board_type IN ('company', 'factory', 'supplier')
ORDER BY l.organization_id, l.primary_board_type, l.id;

-- Q2. case.board_type 与 listing.primary_board_type 不一致的硬串板块 case
SELECT
  c.id AS case_id,
  c.enterprise_id AS current_enterprise_id,
  src.organization_id,
  src.primary_board_type AS listing_board_type,
  c.board_type AS case_board_type,
  c.case_status,
  c.title,
  dst.id AS candidate_target_enterprise_id,
  dst.primary_board_type AS candidate_target_board_type
FROM enterprise_case c
JOIN enterprise_listing src
  ON src.id = c.enterprise_id
LEFT JOIN enterprise_listing dst
  ON dst.organization_id = src.organization_id
 AND dst.primary_board_type = c.board_type
WHERE c.board_type <> src.primary_board_type
ORDER BY src.organization_id, c.enterprise_id, c.created_at;

-- Q3. 已对公开面造成影响的脏 case
SELECT
  c.id AS case_id,
  c.enterprise_id,
  c.board_type,
  l.primary_board_type,
  c.case_status,
  l.enterprise_status,
  l.display_status,
  c.title
FROM enterprise_case c
JOIN enterprise_listing l
  ON l.id = c.enterprise_id
WHERE c.board_type <> l.primary_board_type
  AND (
    c.case_status = 'approved'
    OR (l.enterprise_status = 'published' AND l.display_status = 'visible')
  )
ORDER BY l.organization_id, c.updated_at DESC;

-- Q4. case 图片真值核查
WITH case_files AS (
  SELECT
    c.id AS case_id,
    c.enterprise_id,
    c.board_type,
    'cover' AS image_role,
    c.case_cover_file_asset_id AS file_asset_id
  FROM enterprise_case c
  UNION ALL
  SELECT
    c.id AS case_id,
    c.enterprise_id,
    c.board_type,
    'media' AS image_role,
    x.file_asset_id
  FROM enterprise_case c
  CROSS JOIN LATERAL jsonb_array_elements_text(
    COALESCE(c.case_media_file_asset_ids, '[]'::jsonb)
  ) AS x(file_asset_id)
)
SELECT
  cf.case_id,
  cf.enterprise_id,
  cf.board_type,
  cf.image_role,
  cf.file_asset_id,
  fa.business_type,
  fa.business_id,
  fa.file_kind,
  fa.mime_type
FROM case_files cf
LEFT JOIN file_asset fa
  ON fa.id = cf.file_asset_id
WHERE fa.id IS NULL
   OR fa.business_type <> 'enterprise_display'
   OR fa.business_id <> cf.enterprise_id
   OR fa.file_kind <> 'enterprise_case_media'
   OR fa.mime_type NOT LIKE 'image/%'
ORDER BY cf.enterprise_id, cf.case_id, cf.image_role;

-- Q5. listing album / factory showcase 图片真值核查
WITH listing_album AS (
  SELECT
    l.id AS enterprise_id,
    l.primary_board_type,
    'album' AS image_role,
    x.file_asset_id
  FROM enterprise_listing l
  CROSS JOIN LATERAL jsonb_array_elements_text(
    COALESCE(l.album_image_file_asset_ids, '[]'::jsonb)
  ) AS x(file_asset_id)
),
factory_showcase AS (
  SELECT
    f.enterprise_id,
    'factory' AS primary_board_type,
    'showcase' AS image_role,
    x.file_asset_id
  FROM enterprise_profile_factory f
  CROSS JOIN LATERAL jsonb_array_elements_text(
    COALESCE(f.showcase_image_file_asset_ids, '[]'::jsonb)
  ) AS x(file_asset_id)
),
all_refs AS (
  SELECT * FROM listing_album
  UNION ALL
  SELECT * FROM factory_showcase
)
SELECT
  r.enterprise_id,
  r.primary_board_type,
  r.image_role,
  r.file_asset_id,
  fa.business_type,
  fa.business_id,
  fa.file_kind,
  fa.mime_type
FROM all_refs r
LEFT JOIN file_asset fa
  ON fa.id = r.file_asset_id
WHERE fa.id IS NULL
   OR fa.business_type <> 'enterprise_display'
   OR fa.business_id <> r.enterprise_id
   OR (r.image_role = 'album' AND fa.file_kind <> 'enterprise_album')
   OR (r.image_role = 'showcase' AND fa.file_kind <> 'enterprise_factory_showcase')
   OR fa.mime_type NOT LIKE 'image/%'
ORDER BY r.enterprise_id, r.image_role;

-- Q6. published-change 快照里是否保留错板块 case
SELECT
  r.id AS change_request_id,
  r.enterprise_id,
  r.board_type AS request_board_type,
  d.case_id,
  d.case_board_type
FROM enterprise_change_request r
CROSS JOIN LATERAL (
  SELECT
    item ->> 'caseId' AS case_id,
    item ->> 'boardType' AS case_board_type
  FROM jsonb_array_elements(COALESCE(r.draft_cases, '[]'::jsonb)) AS item
) d
WHERE COALESCE(d.case_board_type, '') <> r.board_type
ORDER BY r.enterprise_id, r.created_at DESC;

-- Q7. published-change 快照里是否缺少 caseImageUrlMap
SELECT
  r.id AS change_request_id,
  r.enterprise_id,
  r.board_type,
  r.change_status,
  item ->> 'caseId' AS case_id,
  item ->> 'title' AS title,
  item ->> 'caseStatus' AS case_status
FROM enterprise_change_request r
CROSS JOIN LATERAL jsonb_array_elements(COALESCE(r.draft_cases, '[]'::jsonb)) AS item
WHERE COALESCE(jsonb_typeof(item -> 'caseImageUrlMap'), 'null') <> 'object'
   OR jsonb_object_length(COALESCE(item -> 'caseImageUrlMap', '{}'::jsonb)) = 0
ORDER BY r.updated_at DESC, r.enterprise_id;

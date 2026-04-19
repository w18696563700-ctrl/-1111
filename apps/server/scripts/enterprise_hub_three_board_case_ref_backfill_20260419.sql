-- enterprise_hub_three_board_case_ref_backfill_20260419.sql
-- Package B dry-run script for historical live case ref backfill only.
-- Scope:
--   - company approved live case a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64
--   - factory approved live case e3940909-b9ec-4f21-a150-7d34dafce31c
-- Non-scope:
--   - supplier invalid case media
--   - listing basic refs
--   - factory showcase refs
--   - any schema change

BEGIN;

-- Step 1. Remove stale refs for the two target live cases only.
DELETE FROM enterprise_media_asset_ref
WHERE owner_type = 'enterprise_case'
  AND owner_id IN (
    'a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64',
    'e3940909-b9ec-4f21-a150-7d34dafce31c'
  );

-- Step 2. Backfill company live case refs.
INSERT INTO enterprise_media_asset_ref (
  id,
  enterprise_id,
  owner_type,
  owner_id,
  media_role,
  file_asset_id,
  sort_order
)
VALUES
  (
    gen_random_uuid()::varchar,
    'e2a016f4-0b6a-497d-902c-409413858ca9',
    'enterprise_case',
    'a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64',
    'case_cover',
    'e5817abf-6ea1-4409-9c61-0ca32c8728d4',
    NULL
  ),
  (
    gen_random_uuid()::varchar,
    'e2a016f4-0b6a-497d-902c-409413858ca9',
    'enterprise_case',
    'a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64',
    'case_media',
    'e5817abf-6ea1-4409-9c61-0ca32c8728d4',
    0
  ),
  (
    gen_random_uuid()::varchar,
    'e2a016f4-0b6a-497d-902c-409413858ca9',
    'enterprise_case',
    'a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64',
    'case_media',
    'f074747f-ab37-4746-9ee8-0c654ee1905d',
    1
  );

-- Step 3. Backfill factory live case refs.
INSERT INTO enterprise_media_asset_ref (
  id,
  enterprise_id,
  owner_type,
  owner_id,
  media_role,
  file_asset_id,
  sort_order
)
VALUES
  (
    gen_random_uuid()::varchar,
    'a9b46040-956e-44fd-8e35-e3c533687e27',
    'enterprise_case',
    'e3940909-b9ec-4f21-a150-7d34dafce31c',
    'case_cover',
    'b9293a66-401b-4791-96db-071fcc39151c',
    NULL
  ),
  (
    gen_random_uuid()::varchar,
    'a9b46040-956e-44fd-8e35-e3c533687e27',
    'enterprise_case',
    'e3940909-b9ec-4f21-a150-7d34dafce31c',
    'case_media',
    'b9293a66-401b-4791-96db-071fcc39151c',
    0
  );

-- Step 4. Show the expected post-repair refs before rollback.
SELECT
  enterprise_id,
  owner_type,
  owner_id,
  media_role,
  file_asset_id,
  sort_order
FROM enterprise_media_asset_ref
WHERE owner_type = 'enterprise_case'
  AND owner_id IN (
    'a6729c3f-2dc8-40c0-9d5a-76c5f0d59c64',
    'e3940909-b9ec-4f21-a150-7d34dafce31c'
  )
ORDER BY enterprise_id, owner_id, media_role, sort_order;

ROLLBACK;

-- To promote this script beyond dry-run:
-- 1. Keep the target case set unchanged unless a new inventory receipt is approved.
-- 2. Re-run the post-script verification queries.
-- 3. Replace only the final ROLLBACK with COMMIT after explicit total-control grant.

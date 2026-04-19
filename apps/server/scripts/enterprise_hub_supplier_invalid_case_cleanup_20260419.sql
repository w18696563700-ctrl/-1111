-- enterprise_hub_supplier_invalid_case_cleanup_20260419.sql
-- Bounded cleanup for the single invalid supplier live case only.
-- Scope:
--   - delete enterprise_case row 5ffda6ac-e379-4ff9-85fc-720beb2a7161
--   - clear enterprise_case refs for the same case if any exist
-- Non-scope:
--   - delete profile/business_license file_asset 9399d036-aca4-4331-b15f-0c6ede2e8df9
--   - mutate enterprise_application
--   - mutate enterprise_listing
--   - mutate company/factory objects

BEGIN;

DELETE FROM enterprise_media_asset_ref
WHERE owner_type = 'enterprise_case'
  AND owner_id = '5ffda6ac-e379-4ff9-85fc-720beb2a7161';

DELETE FROM enterprise_case
WHERE id = '5ffda6ac-e379-4ff9-85fc-720beb2a7161'
  AND enterprise_id = 'c0576f5c-854c-4b78-9f93-6d57e55d8b47'
  AND board_type = 'supplier';

SELECT
  COUNT(*) AS supplier_case_remaining
FROM enterprise_case
WHERE id = '5ffda6ac-e379-4ff9-85fc-720beb2a7161';

SELECT
  COUNT(*) AS supplier_case_ref_remaining
FROM enterprise_media_asset_ref
WHERE owner_type = 'enterprise_case'
  AND owner_id = '5ffda6ac-e379-4ff9-85fc-720beb2a7161';

SELECT
  id,
  business_type,
  business_id,
  file_kind
FROM file_asset
WHERE id = '9399d036-aca4-4331-b15f-0c6ede2e8df9';

ROLLBACK;

-- To commit:
--   replace the final ROLLBACK with COMMIT after explicit total-control execution.

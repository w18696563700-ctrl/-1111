const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildProfileIndexProjection,
  buildShellContextProjection
} = require('../dist/modules/private_operating_system_reorganization/private-operating-system-reorganization.catalog.js');

test('profile index projection exposes the bounded regrouping summary only', () => {
  const projection = buildProfileIndexProjection();

  assert.equal(projection.regroupingKey, 'my_building_compact_current_user_hub');
  assert.equal(projection.entryOrderKey, 'my_building_compact_hub_first_level');
  assert.equal(projection.corridorVisibilityStatus, 'visible');
  assert.equal(projection.groupingExplanationKey, 'my_building_bounded_private_regrouping');
  assert.ok(projection.updatedAt instanceof Date);
});

test('shell context projection preserves family order and strategic hold dependency', () => {
  const projection = buildShellContextProjection();

  assert.deepEqual(projection.visibleFamilyKeys, [
    'my_company',
    'certification_membership_status',
    'my_projects',
    'my_forum',
    'settings'
  ]);
  assert.deepEqual(
    projection.familyPresence.map((item) => item.familyKey),
    projection.visibleFamilyKeys
  );
  assert.equal(
    projection.familyPresence[projection.familyPresence.length - 1].familyVisibilityReasonKey,
    'bottom_most_first_level_entry_preserved'
  );
  assert.equal(projection.dependencyReference.dependencyRequired, true);
  assert.equal(
    projection.dependencyReference.dependencyFamilyKey,
    'future_cross_building_shell_rewrite'
  );
  assert.equal(
    projection.dependencyReference.dependencyHandoffKey,
    'strategic_hold_current_private_operating_system_boundary'
  );
});

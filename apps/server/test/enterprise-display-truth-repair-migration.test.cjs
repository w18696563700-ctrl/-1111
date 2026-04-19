const test = require('node:test');
const assert = require('node:assert/strict');

function applyDeterministicRepair(candidates) {
  const grouped = new Map();

  for (const candidate of candidates) {
    if (
      !candidate.provinceCode ||
      !candidate.cityCode ||
      candidate.provinceCode === '000000' ||
      candidate.cityCode === '000000'
    ) {
      continue;
    }
    const current = grouped.get(candidate.organizationId) ?? new Set();
    current.add(`${candidate.provinceCode}|${candidate.cityCode}`);
    grouped.set(candidate.organizationId, current);
  }

  const repaired = new Map();
  for (const [organizationId, pairs] of grouped.entries()) {
    if (pairs.size !== 1) {
      continue;
    }
    const [pair] = [...pairs];
    const [provinceCode, cityCode] = pair.split('|');
    repaired.set(organizationId, { provinceCode, cityCode });
  }
  return repaired;
}

test('enterprise display truth repair migration only backfills organizations with one distinct valid registered-location candidate', () => {
  const {
    enterpriseDisplayTruthRepairMigrations,
    serverMigrations,
  } = require('../dist/core/migrations/migrations.js');

  const migration = enterpriseDisplayTruthRepairMigrations.find(
    (item) => item.key === '20260410_enterprise_display_org_and_cert_truth_repair',
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.equal(migration.statements.length, 3);

  const repairStatement = migration.statements[2];
  assert.match(repairStatement, /GROUP BY organization_id/);
  assert.match(
    repairStatement,
    /HAVING COUNT\(DISTINCT province_code \|\| '\|' \|\| city_code\) = 1/,
  );
  assert.match(repairStatement, /candidate_rows/);
  assert.match(repairStatement, /valid_candidates/);
});

test('enterprise display truth repair skips conflicting organizations and backfills only a single valid candidate', () => {
  const repaired = applyDeterministicRepair([
    {
      organizationId: 'org-single',
      provinceCode: '510000',
      cityCode: '510100',
    },
    {
      organizationId: 'org-single',
      provinceCode: '510000',
      cityCode: '510100',
    },
    {
      organizationId: 'org-conflict',
      provinceCode: '510000',
      cityCode: '510100',
    },
    {
      organizationId: 'org-conflict',
      provinceCode: '310000',
      cityCode: '310100',
    },
    {
      organizationId: 'org-placeholder',
      provinceCode: '000000',
      cityCode: '000000',
    },
  ]);

  assert.deepEqual(repaired.get('org-single'), {
    provinceCode: '510000',
    cityCode: '510100',
  });
  assert.equal(repaired.has('org-conflict'), false);
  assert.equal(repaired.has('org-placeholder'), false);
});

test('enterprise display truth repair includes the dedicated album column migration with a new key', () => {
  const {
    enterpriseDisplayTruthRepairMigrations,
    serverMigrations,
  } = require('../dist/core/migrations/migrations.js');

  const migration = enterpriseDisplayTruthRepairMigrations.find(
    (item) => item.key === '20260417_enterprise_display_album_truth_backfill',
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.equal(migration.statements.length, 1);
  assert.match(migration.statements[0], /album_image_file_asset_ids/);
  assert.match(migration.statements[0], /ALTER TABLE enterprise_listing/);
});

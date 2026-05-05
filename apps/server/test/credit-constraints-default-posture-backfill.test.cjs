const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildReceipt,
  maskOrganizationRef,
  parseArgs,
  summarizeCandidates,
} = require('../scripts/credit-constraints-default-posture-backfill.cjs');

test('backfill script defaults to dry-run and requires explicit execute flag', () => {
  const options = parseArgs([]);

  assert.equal(options.execute, false);
  assert.equal(options.limit, 500);
  assert.match(options.runId, /^credit-constraints-default-posture-backfill-/);
});

test('backfill script parses explicit execute flag and run id', () => {
  const options = parseArgs(['--execute', '--limit=25', '--run-id=manual-run']);

  assert.equal(options.execute, true);
  assert.equal(options.limit, 25);
  assert.equal(options.runId, 'manual-run');
});

test('backfill dry-run summary masks organization refs and counts missing families', () => {
  const rows = [
    {
      organization_id: 'bdfb4523-1111-2222-3333-444444444444',
      missing_credit: true,
      missing_deposit: true,
      missing_transaction_guarantee: true,
    },
    {
      organization_id: 'e6bf4567-1111-2222-3333-444444444444',
      missing_credit: false,
      missing_deposit: true,
      missing_transaction_guarantee: false,
    },
  ];

  const summary = summarizeCandidates(rows);

  assert.equal(maskOrganizationRef(rows[0].organization_id), 'bdfb4523...');
  assert.equal(summary.candidateOrganizationCount, 2);
  assert.equal(summary.missingPostureFamilyCount, 4);
  assert.deepEqual(summary.wouldInsertByFamily, {
    credit: 1,
    deposit: 2,
    transaction_guarantee: 1,
  });
  assert.deepEqual(summary.candidates[0], {
    maskedOrganizationRef: 'bdfb4523...',
    missingFamilies: ['credit', 'deposit', 'transaction_guarantee'],
  });
});

test('backfill receipt is safe to paste and marks dry-run as noWrite', () => {
  const receipt = buildReceipt({
    rows: [{
      organization_id: 'bdfb4523-1111-2222-3333-444444444444',
      missing_credit: true,
      missing_deposit: false,
      missing_transaction_guarantee: true,
    }],
    options: { runId: 'receipt-run' },
    noWrite: true,
  });

  const text = JSON.stringify(receipt);
  assert.equal(receipt.noWrite, true);
  assert.equal(receipt.candidateOrganizationCount, 1);
  assert.equal(receipt.missingPostureFamilyCount, 2);
  assert.equal(text.includes('bdfb4523-1111'), false);
  assert.equal(text.includes('password'), false);
  assert.match(receipt.executeCommandPreview, /--execute --run-id=receipt-run/);
});

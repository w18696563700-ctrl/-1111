const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

class FakeRepository {
  constructor(initialRows = []) {
    this.rows = new Map();
    this.saved = [];
    for (const row of initialRows) {
      this.rows.set(this.resolveKey(row), { ...row });
    }
  }

  async findOneBy(where) {
    if (where.id) {
      return this.rows.get(where.id) ?? null;
    }
    if (where.organizationId) {
      for (const row of this.rows.values()) {
        if (row.organizationId === where.organizationId) {
          return row;
        }
      }
    }
    return null;
  }

  async findOne() {
    return this.rows.values().next().value ?? null;
  }

  async count(whereInput = {}) {
    const where = whereInput.where ?? whereInput;
    let total = 0;
    for (const row of this.rows.values()) {
      const matched = Object.entries(where).every(([key, value]) => row[key] === value);
      if (matched) {
        total += 1;
      }
    }
    return total;
  }

  create(value) {
    return { ...value };
  }

  async save(value) {
    const row = { ...value };
    this.rows.set(this.resolveKey(row), row);
    this.saved.push(row);
    return row;
  }

  resolveKey(row) {
    return row.id ?? row.organizationId;
  }
}

function buildService({
  creditRows = [],
  depositRows = [],
  guaranteeRows = [],
  organizationRows = [{ id: 'org-1', status: 'active' }],
  certificationRows = [{ organizationId: 'org-1', certificationStatus: 'approved' }],
  memberRows = [{ organizationId: 'org-1', memberStatus: 'active' }],
} = {}) {
  const { CreditConstraintsPostureInitializationService } = require('../dist/modules/credit_constraints/credit-constraints-posture-initialization.service.js');
  const repositories = {
    credit: new FakeRepository(creditRows),
    deposit: new FakeRepository(depositRows),
    guarantee: new FakeRepository(guaranteeRows),
    organization: new FakeRepository(organizationRows),
    certification: new FakeRepository(certificationRows),
    member: new FakeRepository(memberRows),
  };
  return {
    repositories,
    service: new CreditConstraintsPostureInitializationService(
      repositories.credit,
      repositories.deposit,
      repositories.guarantee,
      repositories.organization,
      repositories.certification,
      repositories.member,
    ),
  };
}

test('default posture initialization creates all three missing posture rows', async () => {
  const { service, repositories } = buildService();

  const result = await service.ensureDefaultPosturesForApprovedOrganization('org-1');

  assert.deepEqual(result, {
    eligible: true,
    organizationId: 'org-1',
    createdFamilies: ['credit', 'deposit', 'transaction_guarantee'],
    existingFamilies: [],
  });
  assert.equal(repositories.credit.saved.length, 1);
  assert.equal(repositories.deposit.saved.length, 1);
  assert.equal(repositories.guarantee.saved.length, 1);
  assert.equal(repositories.credit.saved[0].creditConstraintStatus, 'clear');
  assert.equal(repositories.credit.saved[0].performanceConstraintStatus, 'clear');
  assert.equal(repositories.credit.saved[0].executionAvailabilityStatus, 'available');
  assert.equal(repositories.credit.saved[0].dependencyKey, 'v22_payment_billing_required');
  assert.equal(repositories.deposit.saved[0].requirementStatus, 'required');
  assert.equal(repositories.deposit.saved[0].eligibilityStatus, 'eligible');
  assert.equal(repositories.deposit.saved[0].restrictionStatus, 'clear');
  assert.equal(repositories.deposit.saved[0].depositPostureStatus, 'handoff_required');
  assert.equal(repositories.deposit.saved[0].dependencyKey, 'v22_payment_billing_required');
  assert.equal(repositories.guarantee.saved[0].eligibilityStatus, 'eligible');
  assert.equal(repositories.guarantee.saved[0].restrictionStatus, 'clear');
  assert.equal(repositories.guarantee.saved[0].dependencyKey, 'v22_payment_billing_required');
});

test('default posture initialization does not overwrite existing posture rows', async () => {
  const { service, repositories } = buildService({
    creditRows: [{
      id: 'credit-existing',
      organizationId: 'org-1',
      creditConstraintStatus: 'constrained',
    }],
    depositRows: [{
      id: 'deposit-existing',
      organizationId: 'org-1',
      depositPostureStatus: 'restricted',
    }],
    guaranteeRows: [{
      id: 'guarantee-existing',
      organizationId: 'org-1',
      eligibilityStatus: 'not_eligible',
    }],
  });

  const result = await service.ensureDefaultPosturesForApprovedOrganization('org-1');

  assert.deepEqual(result, {
    eligible: true,
    organizationId: 'org-1',
    createdFamilies: [],
    existingFamilies: ['credit', 'deposit', 'transaction_guarantee'],
  });
  assert.equal(repositories.credit.saved.length, 0);
  assert.equal(repositories.deposit.saved.length, 0);
  assert.equal(repositories.guarantee.saved.length, 0);
  assert.equal(
    (await repositories.credit.findOneBy({ organizationId: 'org-1' })).creditConstraintStatus,
    'constrained',
  );
});

test('default posture initialization only creates missing posture family', async () => {
  const { service, repositories } = buildService({
    creditRows: [{ id: 'credit-existing', organizationId: 'org-1' }],
    guaranteeRows: [{ id: 'guarantee-existing', organizationId: 'org-1' }],
  });

  const result = await service.ensureDefaultPosturesForApprovedOrganization('org-1');

  assert.deepEqual(result, {
    eligible: true,
    organizationId: 'org-1',
    createdFamilies: ['deposit'],
    existingFamilies: ['credit', 'transaction_guarantee'],
  });
  assert.equal(repositories.credit.saved.length, 0);
  assert.equal(repositories.deposit.saved.length, 1);
  assert.equal(repositories.guarantee.saved.length, 0);
});

test('default posture initialization skips organizations without approved certification', async () => {
  const { service, repositories } = buildService({
    certificationRows: [{ organizationId: 'org-1', certificationStatus: 'pending_review' }],
  });

  const result = await service.ensureDefaultPosturesForApprovedOrganization('org-1');

  assert.deepEqual(result, {
    eligible: false,
    organizationId: 'org-1',
    createdFamilies: [],
    existingFamilies: [],
    skippedReason: 'certification_not_approved',
  });
  assert.equal(repositories.credit.saved.length, 0);
  assert.equal(repositories.deposit.saved.length, 0);
  assert.equal(repositories.guarantee.saved.length, 0);
});

test('approved certification submit and resubmit paths both invoke posture initialization', () => {
  const sourcePath = path.resolve(
    __dirname,
    '../src/modules/profile/profile-certification-write.service.ts',
  );
  const source = fs.readFileSync(sourcePath, 'utf8');
  const calls = source.match(/ensureDefaultPosturesForApprovedOrganization/g) ?? [];

  assert.equal(calls.length, 2);
  assert.match(source, /certification\.certificationStatus === "approved"/);
});

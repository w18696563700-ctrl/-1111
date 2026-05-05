#!/usr/bin/env node
const { randomUUID } = require('node:crypto');
const { Client } = require('pg');

const SCRIPT_NAME = 'credit-constraints-default-posture-backfill';
const ELIGIBILITY_RULE_VERSION = 'credit_constraints_default_posture_v1';
const DEFAULT_LIMIT = 500;

const FAMILY_LABELS = {
  credit: 'credit',
  deposit: 'deposit',
  transactionGuarantee: 'transaction_guarantee',
};

const SELECT_CANDIDATES_SQL = `
WITH latest_cert AS (
  SELECT DISTINCT ON (organization_id)
    organization_id,
    certification_status,
    updated_at
  FROM organization_certifications
  ORDER BY organization_id, updated_at DESC, id DESC
),
active_member_orgs AS (
  SELECT
    organization_id,
    count(*) AS active_member_count
  FROM organization_members
  WHERE member_status = 'active'
  GROUP BY organization_id
),
candidate_orgs AS (
  SELECT
    o.id::text AS organization_id,
    (ccp.organization_id IS NULL) AS missing_credit,
    (odp.organization_id IS NULL) AS missing_deposit,
    (tgp.organization_id IS NULL) AS missing_transaction_guarantee
  FROM organizations o
  JOIN latest_cert cert
    ON cert.organization_id = o.id
   AND cert.certification_status = 'approved'
  JOIN active_member_orgs members
    ON members.organization_id = o.id
   AND members.active_member_count > 0
  LEFT JOIN organization_credit_constraint_postures ccp
    ON ccp.organization_id = o.id
  LEFT JOIN organization_deposit_postures odp
    ON odp.organization_id = o.id
  LEFT JOIN organization_transaction_guarantee_postures tgp
    ON tgp.organization_id = o.id
  WHERE o.status = 'active'
    AND (
      ccp.organization_id IS NULL
      OR odp.organization_id IS NULL
      OR tgp.organization_id IS NULL
    )
  ORDER BY o.created_at ASC, o.id ASC
)
SELECT *
FROM candidate_orgs
LIMIT $1
`;

const INSERT_CREDIT_SQL = `
INSERT INTO organization_credit_constraint_postures (
  id,
  organization_id,
  credit_constraint_status,
  performance_constraint_status,
  restriction_reason_code,
  advisory_reason_code,
  execution_availability_status,
  explanation_key,
  handoff_key,
  dependency_key
) VALUES (
  $1, $2, 'clear', 'clear', NULL, NULL, 'available',
  'credit_clear', 'credit_readonly_no_action', 'v22_payment_billing_required'
)
ON CONFLICT (organization_id) DO NOTHING
RETURNING id
`;

const INSERT_DEPOSIT_SQL = `
INSERT INTO organization_deposit_postures (
  id,
  organization_id,
  requirement_status,
  eligibility_status,
  restriction_status,
  deposit_posture_status,
  handoff_key,
  dependency_key
) VALUES (
  $1, $2, 'required', 'eligible', 'clear', 'handoff_required',
  'deposit_open_payment_dependency', 'v22_payment_billing_required'
)
ON CONFLICT (organization_id) DO NOTHING
RETURNING id
`;

const INSERT_GUARANTEE_SQL = `
INSERT INTO organization_transaction_guarantee_postures (
  id,
  organization_id,
  eligibility_status,
  restriction_status,
  explanation_key,
  handoff_key,
  dependency_key
) VALUES (
  $1, $2, 'eligible', 'clear',
  'transaction_guarantee_dependency_required',
  'transaction_guarantee_open_dependency',
  'v22_payment_billing_required'
)
ON CONFLICT (organization_id) DO NOTHING
RETURNING id
`;

function parseArgs(argv) {
  const options = {
    execute: false,
    limit: DEFAULT_LIMIT,
    runId: `${SCRIPT_NAME}-${new Date().toISOString().replace(/[:.]/g, '-')}`,
  };

  for (const arg of argv) {
    if (arg === '--execute') {
      options.execute = true;
      continue;
    }
    if (arg.startsWith('--limit=')) {
      const value = Number.parseInt(arg.slice('--limit='.length), 10);
      if (Number.isFinite(value) && value > 0) {
        options.limit = value;
      }
      continue;
    }
    if (arg.startsWith('--run-id=')) {
      const value = arg.slice('--run-id='.length).trim();
      if (value) {
        options.runId = value;
      }
    }
  }

  return options;
}

function buildDbConfig(env) {
  if (env.DATABASE_URL) {
    return { connectionString: env.DATABASE_URL };
  }
  return {
    host: env.POSTGRES_HOST,
    port: env.POSTGRES_PORT ? Number(env.POSTGRES_PORT) : 5432,
    user: env.POSTGRES_USER,
    password: env.POSTGRES_PASSWORD,
    database: env.POSTGRES_DB,
  };
}

function maskOrganizationRef(organizationId) {
  const normalized = String(organizationId ?? '').trim();
  return normalized ? `${normalized.slice(0, 8)}...` : 'unknown';
}

function missingFamilies(row) {
  const families = [];
  if (row.missing_credit) {
    families.push(FAMILY_LABELS.credit);
  }
  if (row.missing_deposit) {
    families.push(FAMILY_LABELS.deposit);
  }
  if (row.missing_transaction_guarantee) {
    families.push(FAMILY_LABELS.transactionGuarantee);
  }
  return families;
}

function summarizeCandidates(rows) {
  const summary = {
    candidateOrganizationCount: rows.length,
    missingPostureFamilyCount: 0,
    wouldInsertByFamily: {
      credit: 0,
      deposit: 0,
      transaction_guarantee: 0,
    },
    candidates: [],
  };

  for (const row of rows) {
    const families = missingFamilies(row);
    summary.missingPostureFamilyCount += families.length;
    for (const family of families) {
      summary.wouldInsertByFamily[family] += 1;
    }
    summary.candidates.push({
      maskedOrganizationRef: maskOrganizationRef(row.organization_id),
      missingFamilies: families,
    });
  }

  return summary;
}

function buildReceipt({ rows, options, noWrite, createdByFamily = null }) {
  const summary = summarizeCandidates(rows);
  return {
    script: SCRIPT_NAME,
    runId: options.runId,
    checkedAt: new Date().toISOString(),
    eligibilityRuleVersion: ELIGIBILITY_RULE_VERSION,
    noWrite,
    executeCommandPreview: `node apps/server/scripts/${SCRIPT_NAME}.cjs --execute --run-id=${options.runId}`,
    candidateOrganizationCount: summary.candidateOrganizationCount,
    missingPostureFamilyCount: summary.missingPostureFamilyCount,
    wouldInsertByFamily: summary.wouldInsertByFamily,
    createdByFamily,
    candidates: summary.candidates,
  };
}

async function loadCandidates(client, limit) {
  const result = await client.query(SELECT_CANDIDATES_SQL, [limit]);
  return result.rows;
}

async function executeBackfill(client, rows) {
  const createdByFamily = {
    credit: 0,
    deposit: 0,
    transaction_guarantee: 0,
  };

  await client.query('BEGIN');
  try {
    for (const row of rows) {
      const organizationId = row.organization_id;
      if (row.missing_credit) {
        const result = await client.query(INSERT_CREDIT_SQL, [randomUUID(), organizationId]);
        createdByFamily.credit += result.rowCount;
      }
      if (row.missing_deposit) {
        const result = await client.query(INSERT_DEPOSIT_SQL, [randomUUID(), organizationId]);
        createdByFamily.deposit += result.rowCount;
      }
      if (row.missing_transaction_guarantee) {
        const result = await client.query(INSERT_GUARANTEE_SQL, [randomUUID(), organizationId]);
        createdByFamily.transaction_guarantee += result.rowCount;
      }
    }
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  }

  return createdByFamily;
}

async function run(options, env = process.env) {
  const client = new Client(buildDbConfig(env));
  await client.connect();
  try {
    const rows = await loadCandidates(client, options.limit);
    if (!options.execute) {
      return buildReceipt({ rows, options, noWrite: true });
    }

    const createdByFamily = await executeBackfill(client, rows);
    return buildReceipt({ rows, options, noWrite: false, createdByFamily });
  } finally {
    await client.end();
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const receipt = await run(options);
  process.stdout.write(`${JSON.stringify(receipt, null, 2)}\n`);
}

if (require.main === module) {
  main().catch((error) => {
    process.stderr.write(`${SCRIPT_NAME} failed: ${error.message}\n`);
    process.exitCode = 1;
  });
}

module.exports = {
  ELIGIBILITY_RULE_VERSION,
  SCRIPT_NAME,
  buildReceipt,
  maskOrganizationRef,
  missingFamilies,
  parseArgs,
  summarizeCandidates,
};

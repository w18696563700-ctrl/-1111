#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');
const { Client } = require('pg');

const DEFAULT_MOBILE = '18696563700';
const ISOLATED_ORGANIZATION_ID = '4b79f76f-9d60-4a70-bf05-6fbb51dd4f01';
const ISOLATED_ORGANIZATION_NAME = 'Isolated Buyer Org 18696563700';
const ISOLATED_USCC = 'ISOLATED18696563700';

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const envFile = args['env-file'];
  const mobile = args.mobile || DEFAULT_MOBILE;

  if (!envFile) {
    throw new Error('Missing required --env-file. Refusing to run without an explicit isolated env file.');
  }

  const env = loadEnvFile(envFile);
  assertIsolatedEnv(env, envFile);

  const client = new Client({
    host: env.POSTGRES_HOST,
    port: Number(env.POSTGRES_PORT || '5432'),
    database: env.POSTGRES_DB,
    user: env.POSTGRES_USER,
    password: env.POSTGRES_PASSWORD,
  });

  await client.connect();
  try {
    await client.query('BEGIN');

    await ensureProjectTable(client);
    const user = await ensureUser(client, mobile);
    const organization = await ensureOrganization(client, user.id, mobile);
    const membership = await ensureMembership(client, organization.id, user.id);

    await client.query('COMMIT');

    const summary = {
      appName: env.APP_NAME,
      database: env.POSTGRES_DB,
      mobile,
      userId: user.id,
      organizationId: organization.id,
      organizationName: organization.name,
      membershipId: membership.id,
      roleKey: membership.role_key,
      memberStatus: membership.member_status,
    };

    console.log(JSON.stringify(summary, null, 2));
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    await client.end();
  }
}

function parseArgs(argv) {
  const parsed = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (!token.startsWith('--')) {
      continue;
    }
    const key = token.slice(2);
    const value = argv[index + 1];
    if (!value || value.startsWith('--')) {
      parsed[key] = 'true';
      continue;
    }
    parsed[key] = value;
    index += 1;
  }
  return parsed;
}

function loadEnvFile(filePath) {
  const absolutePath = path.resolve(filePath);
  if (!fs.existsSync(absolutePath)) {
    throw new Error(`Env file not found: ${absolutePath}`);
  }

  const content = fs.readFileSync(absolutePath, 'utf8');
  const env = {};
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }
    const separator = line.indexOf('=');
    if (separator <= 0) {
      continue;
    }
    const key = line.slice(0, separator).trim();
    const value = line.slice(separator + 1).trim();
    env[key] = value;
  }
  return env;
}

function assertIsolatedEnv(env, envFile) {
  const appName = String(env.APP_NAME || '');
  const database = String(env.POSTGRES_DB || '');
  const databaseUser = String(env.POSTGRES_USER || '');
  if (!appName.includes('isolated')) {
    throw new Error(`Refusing to run because APP_NAME is not isolated-only in ${envFile}.`);
  }
  if (!database.includes('isolated')) {
    throw new Error(`Refusing to run because POSTGRES_DB is not isolated-only in ${envFile}.`);
  }
  if (!databaseUser.includes('isolated')) {
    throw new Error(`Refusing to run because POSTGRES_USER is not isolated-only in ${envFile}.`);
  }
}

async function ensureProjectTable(client) {
  await client.query(`
    create table if not exists project (
      id varchar(64) primary key,
      project_no varchar(64) unique not null,
      organization_id varchar(64) not null default '',
      creator_user_id varchar(64),
      creator_actor_id varchar(64),
      title varchar(128) not null,
      building_type varchar(64) not null,
      budget_amount numeric(12,2) not null,
      description text,
      state varchar(32) not null default 'published',
      summary jsonb not null default '{}'::jsonb,
      published_at timestamptz,
      created_at timestamptz not null default now(),
      updated_at timestamptz not null default now()
    );
  `);
}

async function ensureUser(client, mobile) {
  const existing = await client.query(
    `select id, mobile, status
       from users
      where mobile = $1
      limit 1`,
    [mobile]
  );
  if (existing.rows[0]) {
    const user = existing.rows[0];
    if (user.status !== 'active') {
      await client.query(
        `update users
            set status = 'active',
                mobile_verified_at = now(),
                updated_at = now()
          where id = $1`,
        [user.id]
      );
      user.status = 'active';
    }
    return user;
  }

  const userId = randomUUID();
  const inserted = await client.query(
    `insert into users (
        id,
        mobile,
        mobile_verified_at,
        nickname,
        avatar_url,
        status,
        last_login_at,
        last_login_ip
      ) values (
        $1,
        $2,
        now(),
        null,
        null,
        'active',
        null,
        null
      )
      returning id, mobile, status`,
    [userId, mobile]
  );
  return inserted.rows[0];
}

async function ensureOrganization(client, createdBy, mobile) {
  const existing = await client.query(
    `select id, name, organization_type, status
       from organizations
      where id = $1
      limit 1`,
    [ISOLATED_ORGANIZATION_ID]
  );
  if (existing.rows[0]) {
    await client.query(
      `update organizations
          set name = $2,
              organization_type = 'buyer',
              contact_name = 'Isolated Buyer Admin',
              contact_mobile = $3,
              uscc = $4,
              intro = 'Isolated-only organization truth for package1 test account.',
              status = 'active',
              created_by = $5,
              updated_at = now()
        where id = $1`,
      [ISOLATED_ORGANIZATION_ID, ISOLATED_ORGANIZATION_NAME, mobile, ISOLATED_USCC, createdBy]
    );
    return {
      id: ISOLATED_ORGANIZATION_ID,
      name: ISOLATED_ORGANIZATION_NAME,
    };
  }

  const inserted = await client.query(
    `insert into organizations (
        id,
        name,
        organization_type,
        province_code,
        city_code,
        contact_name,
        contact_mobile,
        uscc,
        business_license_file_id,
        intro,
        status,
        created_by
      ) values (
        $1,
        $2,
        'buyer',
        null,
        null,
        'Isolated Buyer Admin',
        $3,
        $4,
        null,
        'Isolated-only organization truth for package1 test account.',
        'active',
        $5
      )
      returning id, name`,
    [ISOLATED_ORGANIZATION_ID, ISOLATED_ORGANIZATION_NAME, mobile, ISOLATED_USCC, createdBy]
  );
  return inserted.rows[0];
}

async function ensureMembership(client, organizationId, userId) {
  const existing = await client.query(
    `select id, organization_id, user_id, role_key, member_status
       from organization_members
      where organization_id = $1
        and user_id = $2
      limit 1`,
    [organizationId, userId]
  );
  if (existing.rows[0]) {
    const membership = existing.rows[0];
    await client.query(
      `update organization_members
          set role_key = 'buyer_admin',
              member_status = 'active',
              invited_by = null,
              invited_at = null,
              joined_at = coalesce(joined_at, now()),
              disabled_at = null
        where id = $1`,
      [membership.id]
    );
    membership.role_key = 'buyer_admin';
    membership.member_status = 'active';
    return membership;
  }

  const inserted = await client.query(
    `insert into organization_members (
        id,
        organization_id,
        user_id,
        role_key,
        member_status,
        invited_by,
        invited_at,
        joined_at,
        disabled_at
      ) values (
        $1,
        $2,
        $3,
        'buyer_admin',
        'active',
        null,
        null,
        now(),
        null
      )
      returning id, organization_id, user_id, role_key, member_status`,
    [randomUUID(), organizationId, userId]
  );
  return inserted.rows[0];
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});

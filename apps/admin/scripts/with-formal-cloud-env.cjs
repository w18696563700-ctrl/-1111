#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '../../..');
const envFile =
  process.env.FORMAL_CLOUD_ENV_FILE?.trim() ||
  path.join(repoRoot, 'infra', 'env', 'formal_cloud_target.env');

if (fs.existsSync(envFile)) {
  const content = fs.readFileSync(envFile, 'utf8');
  for (const rawLine of content.split(/\r?\n/u)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }
    const separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }
    const key = line.slice(0, separatorIndex).trim();
    const value = stripWrappingQuotes(line.slice(separatorIndex + 1).trim());
    if (!key || process.env[key]?.trim()) {
      continue;
    }
    process.env[key] = value;
  }
}

const scheme = process.env.FORMAL_CLOUD_SCHEME?.trim() || 'http';
const host = process.env.FORMAL_CLOUD_HOST?.trim();
const port = process.env.FORMAL_CLOUD_PORT?.trim() || '';
if (!process.env.FORMAL_CLOUD_ORIGIN) {
  if (!host) {
    console.error(
      'Formal cloud target is not configured. Update infra/env/formal_cloud_target.env or set FORMAL_CLOUD_HOST / FORMAL_CLOUD_ORIGIN.'
    );
    process.exit(1);
  }
  process.env.FORMAL_CLOUD_ORIGIN = port
    ? `${scheme}://${host}:${port}`
    : `${scheme}://${host}`;
}

if (!process.env.FORMAL_CLOUD_SERVER_ADMIN_BASE_URL) {
  process.env.FORMAL_CLOUD_SERVER_ADMIN_BASE_URL =
    `${process.env.FORMAL_CLOUD_ORIGIN.replace(/\/+$/u, '')}/server/admin`;
}

if (!process.env.SERVER_ADMIN_API_ENTRY_MODE?.trim()) {
  process.env.SERVER_ADMIN_API_ENTRY_MODE = 'cloud';
}

const [command, ...args] = process.argv.slice(2);
if (!command) {
  console.error(
    'with-formal-cloud-env.cjs requires a command, for example: next build'
  );
  process.exit(1);
}

const result = spawnSync(command, args, {
  stdio: 'inherit',
  env: process.env,
});

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}

process.exit(result.status ?? 1);

function stripWrappingQuotes(value) {
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

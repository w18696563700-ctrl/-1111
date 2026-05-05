#!/usr/bin/env node
'use strict';

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '../../..');
const openApiBundlePath = path.join(repoRoot, 'packages/contracts/openapi/openapi.bundle.json');

const endpoints = [
  {
    name: 'status',
    path: '/api/app/profile/organization-credit-scoring/status',
  },
  {
    name: 'explanation',
    path: '/api/app/profile/organization-credit-scoring/explanation',
  },
  {
    name: 'handoff',
    path: '/api/app/profile/organization-credit-scoring/handoff',
  },
];

const loginPath = '/api/app/auth/password/login';
const healthPaths = ['/health/bff/live', '/health/server/live'];

function printUsage() {
  console.log(`Usage: pnpm runtime:organization-credit-scoring-reserve:payload-parity

Environment:
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_BASE_URL=http://127.0.0.1:8080
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNTS_JSON='[{"label":"account_a","mobile":"...","password":"..."}]'

Single-account fallback:
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_MOBILE=...
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_PASSWORD=...
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNT_LABEL=account_a

Optional:
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCESS_TOKEN=...       Use a prepared token instead of password login.
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_SKIP_HEALTH=1          Skip /health checks.
  ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_TIMEOUT_MS=15000       Per-request timeout.

The script prints only sanitized reserve status and contract-parity summaries.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printUsage();
  process.exit(0);
}

function fail(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

function readOpenApiBundle() {
  if (!fs.existsSync(openApiBundlePath)) {
    fail(`OpenAPI bundle is missing: ${path.relative(repoRoot, openApiBundlePath)}`);
  }
  return JSON.parse(fs.readFileSync(openApiBundlePath, 'utf8'));
}

function normalizeBaseUrl(raw) {
  const value = (raw || 'http://127.0.0.1:8080').trim().replace(/\/+$/u, '');
  if (!value) {
    fail('ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_BASE_URL resolved to an empty value');
  }
  return value.endsWith('/api/app') ? value.slice(0, -'/api/app'.length) : value;
}

function parseBooleanEnv(value, defaultValue) {
  if (value === undefined || value === null || String(value).trim() === '') {
    return defaultValue;
  }
  return ['1', 'true', 'yes', 'y'].includes(String(value).trim().toLowerCase());
}

function parseAccounts(env) {
  const rawJson =
    env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNTS_JSON ||
    env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNT_JSON;
  if (rawJson && rawJson.trim()) {
    const parsed = JSON.parse(rawJson);
    const records = Array.isArray(parsed) ? parsed : [parsed];
    return records.map((record, index) => normalizeAccount(record, index));
  }

  const token = env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCESS_TOKEN?.trim();
  const mobile = env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_MOBILE?.trim();
  const password = env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_PASSWORD?.trim();
  if (token || (mobile && password)) {
    return [
      normalizeAccount(
        {
          label: env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNT_LABEL || 'account_1',
          mobile,
          password,
          accessToken: token,
        },
        0
      ),
    ];
  }

  fail(
    'Authenticated organization-credit-scoring reserve payload parity requires ' +
      'ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCOUNTS_JSON, ' +
      'or ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_MOBILE + ' +
      'ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_PASSWORD, ' +
      'or ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_ACCESS_TOKEN.'
  );
}

function normalizeAccount(record, index) {
  if (!record || typeof record !== 'object' || Array.isArray(record)) {
    fail(`Account entry #${index + 1} must be an object`);
  }

  const label = String(record.label || `account_${index + 1}`).trim() || `account_${index + 1}`;
  const accessToken = typeof record.accessToken === 'string' ? record.accessToken.trim() : '';
  const mobile = typeof record.mobile === 'string' ? record.mobile.trim() : '';
  const password = typeof record.password === 'string' ? record.password : '';

  if (!accessToken && (!mobile || !password)) {
    fail(`Account ${label} requires accessToken or mobile + password`);
  }

  return {
    label: sanitizeLabel(label),
    accessToken,
    mobile,
    password,
  };
}

function sanitizeLabel(label) {
  return label.replace(/[^\w:.-]/gu, '_').slice(0, 80);
}

function resolveRef(openApi, ref) {
  if (!ref.startsWith('#/')) {
    throw new Error(`Unsupported external $ref: ${ref}`);
  }
  return ref
    .slice(2)
    .split('/')
    .reduce((node, segment) => node?.[segment.replace(/~1/gu, '/').replace(/~0/gu, '~')], openApi);
}

function responseSchemaFor(openApi, endpointPath) {
  const schema = openApi.paths?.[endpointPath]?.get?.responses?.['200']?.content?.['application/json']?.schema;
  if (!schema) {
    fail(`OpenAPI 200 response schema is missing for ${endpointPath}`);
  }
  return schema;
}

function valueKind(value) {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  return typeof value;
}

function allowsType(schema, expectedType, actualValue) {
  const rawType = schema.type;
  const types = Array.isArray(rawType) ? rawType : rawType ? [rawType] : [];
  if (actualValue === null && types.includes('null')) return true;
  if (expectedType === 'integer') {
    return Number.isInteger(actualValue);
  }
  if (expectedType === 'number') {
    return typeof actualValue === 'number' && Number.isFinite(actualValue);
  }
  if (expectedType === 'array') {
    return Array.isArray(actualValue);
  }
  if (expectedType === 'object') {
    return actualValue !== null && typeof actualValue === 'object' && !Array.isArray(actualValue);
  }
  return typeof actualValue === expectedType;
}

function validateAgainstSchema(openApi, value, schema, location = '$') {
  if (schema.$ref) {
    return validateAgainstSchema(openApi, value, resolveRef(openApi, schema.$ref), location);
  }
  if (schema.oneOf) {
    const attempts = schema.oneOf.map((child) => validateAgainstSchema(openApi, value, child, location));
    const passed = attempts.find((attempt) => attempt.errors.length === 0);
    if (passed) return passed;
    return {
      errors: attempts.flatMap((attempt) => attempt.errors).slice(0, 12),
      extraFields: [],
    };
  }

  const rawType = schema.type;
  const types = Array.isArray(rawType) ? rawType : rawType ? [rawType] : [];
  if (types.length > 0) {
    if (value === null && types.includes('null')) {
      return { errors: [], extraFields: [] };
    }
    const nonNullTypes = types.filter((type) => type !== 'null');
    const typeMatched = nonNullTypes.some((type) => allowsType(schema, type, value));
    if (!typeMatched) {
      return {
        errors: [`${location}: expected ${types.join('|')}, got ${valueKind(value)}`],
        extraFields: [],
      };
    }
    if (schema.enum && !schema.enum.includes(value)) {
      return { errors: [`${location}: value is outside enum`], extraFields: [] };
    }
    if (schema.format === 'date-time' && typeof value === 'string' && Number.isNaN(Date.parse(value))) {
      return { errors: [`${location}: invalid date-time`], extraFields: [] };
    }
    if (!nonNullTypes.includes('object') && !nonNullTypes.includes('array')) {
      return { errors: [], extraFields: [] };
    }
  }

  if (Array.isArray(value)) {
    return validateArray(openApi, value, schema, location);
  }
  if (value && typeof value === 'object') {
    return validateObject(openApi, value, schema, location);
  }
  return { errors: [], extraFields: [] };
}

function validateArray(openApi, value, schema, location) {
  const errors = [];
  const extraFields = [];
  if (!schema.items) {
    return { errors, extraFields };
  }
  value.forEach((item, index) => {
    const child = validateAgainstSchema(openApi, item, schema.items, `${location}[${index}]`);
    errors.push(...child.errors);
    extraFields.push(...child.extraFields);
  });
  return { errors, extraFields };
}

function validateObject(openApi, value, schema, location) {
  const errors = [];
  const extraFields = [];
  const properties = schema.properties || {};
  const required = Array.isArray(schema.required) ? schema.required : [];
  const allowedKeys = new Set(Object.keys(properties));

  required.forEach((key) => {
    if (!Object.prototype.hasOwnProperty.call(value, key)) {
      errors.push(`${location}.${key}: missing required`);
    }
  });

  Object.keys(value).forEach((key) => {
    if (!allowedKeys.has(key)) {
      extraFields.push(`${location}.${key}`);
    }
  });

  Object.entries(properties).forEach(([key, childSchema]) => {
    if (Object.prototype.hasOwnProperty.call(value, key)) {
      const child = validateAgainstSchema(openApi, value[key], childSchema, `${location}.${key}`);
      errors.push(...child.errors);
      extraFields.push(...child.extraFields);
    }
  });

  return { errors, extraFields };
}

async function fetchJson(url, options, timeoutMs) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    const text = await response.text();
    let json = null;
    if (text) {
      try {
        json = JSON.parse(text);
      } catch {
        json = null;
      }
    }
    return { response, json };
  } finally {
    clearTimeout(timeout);
  }
}

async function passwordLogin(baseUrl, account, timeoutMs) {
  if (account.accessToken) {
    return {
      authSource: 'provided_token',
      loginStatus: 'skipped',
      accessToken: account.accessToken,
    };
  }

  const deviceId = `ocs-${crypto.randomUUID()}`;
  const result = await fetchJson(
    `${baseUrl}${loginPath}`,
    {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-device-id': deviceId,
      },
      body: JSON.stringify({
        mobile: account.mobile,
        password: account.password,
        consentAccepted: true,
        deviceId,
        deviceName: 'Organization Credit Scoring Reserve Payload Parity',
        osType: 'ci',
      }),
    },
    timeoutMs
  );

  const accessToken = typeof result.json?.accessToken === 'string' ? result.json.accessToken : '';
  return {
    authSource: 'password_login',
    loginStatus: result.response.status,
    shellBootstrapState: typeof result.json?.shellBootstrapState === 'string' ? result.json.shellBootstrapState : null,
    hasAccessToken: Boolean(accessToken),
    hasRefreshToken: typeof result.json?.refreshToken === 'string' && result.json.refreshToken.length > 0,
    accessToken,
  };
}

function payloadSummary(endpointName, payload) {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    return { payloadType: valueKind(payload) };
  }
  if (endpointName === 'status') {
    return {
      scorePresent: typeof payload.score === 'number',
      tierCode: payload.tierCode ?? null,
      tierLabel: payload.tierLabel ?? null,
      sampleStatus: payload.sampleStatus ?? null,
      riskPosture: payload.riskPosture ?? null,
      ratedCompletedOrderCount: payload.ratedCompletedOrderCount ?? null,
      positiveRate: payload.positiveRate ?? null,
      negativeRate: payload.negativeRate ?? null,
      verySatisfiedCount: payload.verySatisfiedCount ?? null,
      satisfiedCount: payload.satisfiedCount ?? null,
      passableCount: payload.passableCount ?? null,
      negativeCount: payload.negativeCount ?? null,
      actionableState: payload.actionableState ?? null,
      hasUpdatedAt: typeof payload.updatedAt === 'string',
    };
  }
  if (endpointName === 'explanation') {
    return {
      hasReasonSummary: typeof payload.reasonSummary === 'string',
      reasonCodeCount: Array.isArray(payload.reasonCodes) ? payload.reasonCodes.length : null,
      sampleStatus: payload.sampleStatus ?? null,
      riskPosture: payload.riskPosture ?? null,
      ratedCompletedOrderCount: payload.ratedCompletedOrderCount ?? null,
      positiveRate: payload.positiveRate ?? null,
      negativeRate: payload.negativeRate ?? null,
      hasUpdatedAt: typeof payload.updatedAt === 'string',
    };
  }
  return {
    actionableState: payload.actionableState ?? null,
    sampleStatus: payload.sampleStatus ?? null,
    riskPosture: payload.riskPosture ?? null,
    primaryActionCode: payload.primaryActionCode ?? null,
    hasPrimaryActionLabel: typeof payload.primaryActionLabel === 'string',
    hasHandoffMessage: typeof payload.handoffMessage === 'string',
    hasUpdatedAt: typeof payload.updatedAt === 'string',
  };
}

async function run() {
  const openApi = readOpenApiBundle();
  const baseUrl = normalizeBaseUrl(process.env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_BASE_URL);
  const timeoutMs = Number.parseInt(
    process.env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_TIMEOUT_MS || '15000',
    10
  );
  const skipHealth = parseBooleanEnv(
    process.env.ORGANIZATION_CREDIT_SCORING_RESERVE_PARITY_SKIP_HEALTH,
    false
  );
  const accounts = parseAccounts(process.env);
  const report = {
    conclusion: 'PASS',
    baseUrl,
    contractBundle: path.relative(repoRoot, openApiBundlePath),
    health: [],
    accounts: [],
  };

  endpoints.forEach((endpoint) => responseSchemaFor(openApi, endpoint.path));

  if (!skipHealth) {
    for (const healthPath of healthPaths) {
      const result = await fetchJson(`${baseUrl}${healthPath}`, { method: 'GET' }, timeoutMs);
      report.health.push({ method: 'GET', path: healthPath, status: result.response.status });
      if (result.response.status !== 200) {
        report.conclusion = 'FAIL';
      }
    }
  }

  for (const account of accounts) {
    const login = await passwordLogin(baseUrl, account, timeoutMs);
    const record = {
      label: account.label,
      authSource: login.authSource,
      loginStatus: login.loginStatus,
      shellBootstrapState: login.shellBootstrapState,
      hasAccessToken: login.hasAccessToken ?? true,
      hasRefreshToken: login.hasRefreshToken ?? null,
      endpoints: [],
    };

    if (!login.accessToken) {
      report.conclusion = 'FAIL';
      record.endpoints.push({ skipped: true, reason: 'missing_access_token' });
      report.accounts.push(record);
      continue;
    }

    for (const endpoint of endpoints) {
      const result = await fetchJson(
        `${baseUrl}${endpoint.path}`,
        {
          method: 'GET',
          headers: {
            accept: 'application/json',
            authorization: `Bearer ${login.accessToken}`,
          },
        },
        timeoutMs
      );
      const schema = responseSchemaFor(openApi, endpoint.path);
      const validation =
        result.response.status === 200
          ? validateAgainstSchema(openApi, result.json, schema)
          : { errors: ['non_200_response'], extraFields: [] };

      if (result.response.status !== 200 || validation.errors.length > 0 || validation.extraFields.length > 0) {
        report.conclusion = 'FAIL';
      }

      record.endpoints.push({
        name: endpoint.name,
        method: 'GET',
        path: endpoint.path,
        status: result.response.status,
        contractErrors: validation.errors.length,
        extraFields: validation.extraFields.length,
        firstErrors: validation.errors.slice(0, 5),
        firstExtraFields: validation.extraFields.slice(0, 5),
        summary: payloadSummary(endpoint.name, result.json),
      });
    }
    report.accounts.push(record);
  }

  console.log(JSON.stringify(report, null, 2));
  process.exit(report.conclusion === 'PASS' ? 0 : 1);
}

run().catch((error) => {
  console.error(`[FAIL] ${error.name}: ${error.message}`);
  process.exit(1);
});

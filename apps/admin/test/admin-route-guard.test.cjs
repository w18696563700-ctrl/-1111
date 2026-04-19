/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const {
  DEFAULT_ADMIN_NEXT_PATH,
  resolveProtectedPathAccess,
  sanitizeAdminNextPath,
} = require('../test-dist/core/auth/route-guard.js');

test('route guard redirects /project_review to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/project_review',
    requestUrl: 'http://admin.local/project_review',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Fproject_review',
  });
});

test('route guard allows /project_review detail when admin session carrier exists', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/project_review/report-case-1',
    requestUrl: 'http://admin.local/project_review/report-case-1',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard redirects /review/change_requests to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/change_requests',
    requestUrl: 'http://admin.local/review/change_requests',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Freview%2Fchange_requests',
  });
});

test('route guard allows /review/change_requests detail when admin session carrier exists', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/change_requests/change-request-1',
    requestUrl: 'http://admin.local/review/change_requests/change-request-1',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard redirects /review/enterprise_hub_applications to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/enterprise_hub_applications',
    requestUrl: 'http://admin.local/review/enterprise_hub_applications',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Freview%2Fenterprise_hub_applications',
  });
});

test('route guard allows /review/enterprise_hub_applications detail when admin session carrier exists', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/enterprise_hub_applications/application-1',
    requestUrl: 'http://admin.local/review/enterprise_hub_applications/application-1',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard redirects /review/organizations to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/organizations',
    requestUrl: 'http://admin.local/review/organizations',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Freview%2Forganizations',
  });
});

test('route guard allows /review/organizations detail when admin session carrier exists', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/organizations/organization-1',
    requestUrl: 'http://admin.local/review/organizations/organization-1',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard redirects /review/organizations detail to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/review/organizations/organization-1',
    requestUrl: 'http://admin.local/review/organizations/organization-1',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Freview%2Forganizations%2Forganization-1',
  });
});

test('route guard redirects /audit to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/audit',
    requestUrl: 'http://admin.local/audit',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Faudit',
  });
});

test('route guard allows /audit with existing admin session carrier', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/audit',
    requestUrl: 'http://admin.local/audit',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard redirects /template_config to login when admin session carrier is missing', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/template_config',
    requestUrl: 'http://admin.local/template_config',
    sessionCarrier: '',
  });

  assert.deepEqual(result, {
    outcome: 'redirect',
    location: 'http://admin.local/login?next=%2Ftemplate_config',
  });
});

test('route guard allows /template_config when admin session carrier exists', () => {
  const result = resolveProtectedPathAccess({
    pathname: '/template_config',
    requestUrl: 'http://admin.local/template_config',
    sessionCarrier: 'opaque-access-carrier',
  });

  assert.deepEqual(result, { outcome: 'allow' });
});

test('route guard sanitizes next targets to protected admin workbench paths only', () => {
  assert.equal(
    sanitizeAdminNextPath('/governance/penalties?status=active'),
    '/governance/penalties?status=active',
  );
  assert.equal(
    sanitizeAdminNextPath('/review/organizations/organization-1?status=pending_review'),
    '/review/organizations/organization-1?status=pending_review',
  );
  assert.equal(sanitizeAdminNextPath('/login'), DEFAULT_ADMIN_NEXT_PATH);
  assert.equal(
    sanitizeAdminNextPath('https://example.com/governance/appeals'),
    DEFAULT_ADMIN_NEXT_PATH,
  );
});

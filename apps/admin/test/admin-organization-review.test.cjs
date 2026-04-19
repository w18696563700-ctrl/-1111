/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const adminRoot = path.join(__dirname, '..');

test('organization review scaffold files exist and keep /review main seat on content-safety', () => {
  const reviewPageSource = readSource('src/app/review/page.tsx');
  const organizationListRouteSource = readSource('src/app/review/organizations/page.tsx');
  const organizationDetailRouteSource = readSource(
    'src/app/review/organizations/[organizationId]/page.tsx',
  );

  assert.match(reviewPageSource, /ReviewShell/);
  assert.doesNotMatch(reviewPageSource, /OrganizationReviewShell/);
  assert.match(organizationListRouteSource, /OrganizationReviewShell/);
  assert.match(organizationDetailRouteSource, /OrganizationReviewShell/);
});

test('organization review transport family does not reuse content-safety task naming', () => {
  const clientSource = readSource('src/core/server/admin-organization-review-api-client.ts');
  const shellSource = readSource('src/modules/review/organization-review-shell.tsx');
  const actionSource = readSource('src/modules/review/organization-review-actions.ts');

  assert.doesNotMatch(clientSource, /taskId|taskType|submissionId|content-safety/);
  assert.match(shellSource, /selectedOrganizationId/);
  assert.doesNotMatch(shellSource, /selectedTaskId/);
  assert.match(clientSource, /reviews\/organizations/);
  assert.match(shellSource, /review\/organizations/);
  assert.match(actionSource, /AdminApiError/);
  assert.match(actionSource, /error\.code/);
});

test('organization review actions keep approve/reject route and field shape inside /review/organizations only', () => {
  const actionSource = readSource('src/modules/review/organization-review-actions.ts');

  assert.match(actionSource, /approveOrganizationReviewAction/);
  assert.match(actionSource, /rejectOrganizationReviewAction/);
  assert.match(actionSource, /organizationId/);
  assert.match(actionSource, /filterOrganizationId/);
  assert.match(actionSource, /reason/);
  assert.match(actionSource, /note/);
  assert.match(actionSource, /review\/organizations/);
  assert.doesNotMatch(actionSource, /taskId|taskType|submissionId|content-safety/);
});

function readSource(relativePath) {
  return fs.readFileSync(path.join(adminRoot, relativePath), 'utf8');
}

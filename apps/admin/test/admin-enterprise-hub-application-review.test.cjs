/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

test('enterprise hub application review form source keeps action reason reviewNote aligned with the frozen payload contract', () => {
  const formFile = readSource('apps/admin/src/modules/review/enterprise-hub-application-review-form.tsx');

  assert.match(formFile, /applicationId/);
  assert.match(formFile, /buildReviewPayload\(formData, 'approved'\)/);
  assert.match(formFile, /buildReviewPayload\(formData, 'revision_required'\)/);
  assert.match(formFile, /buildReviewPayload\(formData, 'rejected'\)/);
  assert.match(formFile, /value: 'basic_info_incomplete'/);
  assert.match(formFile, /value: 'profile_incomplete'/);
  assert.match(formFile, /value: 'case_incomplete'/);
  assert.match(formFile, /value: 'contact_incomplete'/);
  assert.match(formFile, /value: 'certification_not_approved'/);
  assert.match(formFile, /value: 'other'/);
  assert.match(formFile, /reviewNote/);
  assert.match(formFile, /reason 不在允许的企业入驻审核拒绝理由集合内/);
});

test('enterprise hub application review routes and actions stay inside the dedicated /review/enterprise_hub_applications family', () => {
  const listPage = readSource('apps/admin/src/app/review/enterprise_hub_applications/page.tsx');
  const detailPage = readSource('apps/admin/src/app/review/enterprise_hub_applications/[applicationId]/page.tsx');
  const actionsFile = readSource('apps/admin/src/modules/review/enterprise-hub-application-review-actions.ts');

  assert.match(listPage, /EnterpriseHubApplicationReviewShell/);
  assert.match(detailPage, /selectedApplicationId/);
  assert.match(actionsFile, /reviewEnterpriseHubApplication/);
  assert.match(actionsFile, /\/review\/enterprise_hub_applications\//);
  assert.doesNotMatch(actionsFile, /changeRequestId/);
  assert.doesNotMatch(actionsFile, /taskId/);
});

test('enterprise hub application review shell and client keep a dedicated onboarding review family', () => {
  const shellFile = readSource('apps/admin/src/modules/review/enterprise-hub-application-review-shell.tsx');
  const clientFile = readSource('apps/admin/src/core/server/admin-enterprise-hub-application-review-api-client.ts');

  assert.match(shellFile, /\/review\/enterprise_hub_applications\*/);
  assert.match(shellFile, /action \+ reason \+ reviewNote/);
  assert.match(shellFile, /submitted[\s\S]*under_review/);
  assert.match(clientFile, /\/exhibition\/enterprise-hub\/applications/);
  assert.doesNotMatch(clientFile, /change-requests/);
  assert.doesNotMatch(clientFile, /reviews\/organizations/);
});

function readSource(relativePath) {
  return fs.readFileSync(
    path.join('/Users/wangweiwei/Desktop/展览装修之家总控', relativePath),
    'utf8',
  );
}

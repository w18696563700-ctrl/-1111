const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ExhibitionReportService,
} = require('../dist/apps/bff/src/routes/exhibition_report/exhibition-report.service.js');

function createService(overrides = {}) {
  return new ExhibitionReportService(
    {
      async post() {
        throw new Error('post mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildReadOnlyForwardHeaders(headers) {
        return {
          authorization: headers.authorization ?? 'Bearer test',
          'x-actor-id': headers['x-actor-id'] ?? headers['x-user-id'],
          'x-organization-id': headers['x-organization-id'],
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

function createAxiosError(status, code, message) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        statusCode: status,
        code,
        message,
        source: 'server',
      },
    },
  };
}

test('exhibition report submit forwards app request to server case input', async () => {
  const calls = [];
  const service = createService({
    serverClient: {
      async post(path, payload, options) {
        calls.push([path, payload, options]);
        return {
          reportCaseId: 'report-case-1',
          targetType: 'project',
          targetId: 'project-1',
          status: 'submitted',
          acceptMode: 'created',
          traceId: 'trace-1',
        };
      },
    },
  });

  const result = await service.submit(
    {
      targetType: 'project',
      targetId: 'project-1',
      reasonCode: 'fabricated_project',
    },
    {
      authorization: 'Bearer app',
      'x-user-id': 'user-1',
      'x-organization-id': 'org-1',
    },
  );

  assert.equal(calls[0][0], '/server/exhibition/report/submit');
  assert.deepEqual(calls[0][1], {
    targetType: 'project',
    targetId: 'project-1',
    reasonCode: 'fabricated_project',
  });
  assert.equal(calls[0][2].headers.authorization, 'Bearer app');
  assert.equal(calls[0][2].headers['x-actor-id'], 'user-1');
  assert.equal(calls[0][2].headers['x-organization-id'], 'org-1');
  assert.deepEqual(result, {
    reportCaseId: 'report-case-1',
    targetType: 'project',
    targetId: 'project-1',
    status: 'submitted',
    acceptMode: 'created',
    traceId: 'trace-1',
  });
});

test('exhibition report submit preserves server auth failure boundary', async () => {
  const service = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          401,
          'AUTH_SESSION_INVALID',
          'Current session is invalid or missing.',
        );
      },
    },
  });

  await assert.rejects(
    () =>
      service.submit(
        {
          targetType: 'project',
          targetId: 'project-1',
          reasonCode: 'fabricated_project',
        },
        { authorization: 'Bearer stale' },
      ),
    (error) => {
      assert.equal(error.getStatus(), 401);
      assert.equal(error.getResponse().code, 'AUTH_SESSION_INVALID');
      assert.equal(error.getResponse().source, 'server');
      return true;
    },
  );
});

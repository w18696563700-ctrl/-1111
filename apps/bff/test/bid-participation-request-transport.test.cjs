const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  BidParticipationRequestService,
} = require('../dist/apps/bff/src/routes/bid_participation_request/bid-participation-request.service.js');

function createService(overrides = {}) {
  return new BidParticipationRequestService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      async post() {
        throw new Error('post mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization ?? 'Bearer test',
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

test('bid participation request service forwards create with scoped headers', async () => {
  const calls = [];
  const service = createService({
    serverClient: {
      async post(path, payload, options) {
        calls.push([path, payload, options]);
        return {
          requestId: 'request-1',
          projectId: 'project-1',
          status: 'pending',
          threadId: 'request-1',
        };
      },
    },
  });

  const result = await service.requestParticipation(
    { projectId: 'project-1' },
    {
      authorization: 'Bearer app',
      'x-organization-id': 'supplier-org',
      'x-actor-role': 'supplier_admin',
    },
  );

  assert.equal(calls[0][0], '/server/projects/bid-participation/request');
  assert.deepEqual(calls[0][1], { projectId: 'project-1' });
  assert.equal(calls[0][2].headers.authorization, 'Bearer app');
  assert.equal(calls[0][2].headers['x-organization-id'], 'supplier-org');
  assert.equal(calls[0][2].headers['x-actor-role'], 'supplier_admin');
  assert.deepEqual(result, {
    requestId: 'request-1',
    projectId: 'project-1',
    status: 'pending',
    threadId: 'request-1',
  });
});

test('bid participation request service forwards review decisions without owning state', async () => {
  const calls = [];
  const service = createService({
    serverClient: {
      async post(path, payload, options) {
        calls.push([path, payload, options]);
        return {
          requestId: 'request-1',
          projectId: 'project-1',
          status: path.endsWith('/approve') ? 'approved' : 'rejected',
        };
      },
    },
  });

  const result = await service.approveRequest(
    'project-1',
    'request-1',
    { decisionNote: '主体认证通过' },
    {
      authorization: 'Bearer owner',
      'x-org-id': 'publisher-org',
      'x-role': 'publisher_admin',
    },
  );

  assert.equal(
    calls[0][0],
    '/server/my/projects/project-1/bid-participation/request-1/approve',
  );
  assert.deepEqual(calls[0][1], { decisionNote: '主体认证通过' });
  assert.equal(calls[0][2].headers['x-organization-id'], 'publisher-org');
  assert.equal(calls[0][2].headers['x-actor-role'], 'publisher_admin');
  assert.deepEqual(result, {
    requestId: 'request-1',
    projectId: 'project-1',
    status: 'approved',
  });
});

test('approved bid participation thread points to 4000 authorization gate before bid submit', async () => {
  const service = createService({
    serverClient: {
      async get(path, options) {
        assert.equal(path, '/server/projects/bid-participation/thread/detail');
        assert.deepEqual(options.params, { threadId: 'thread-1' });
        return {
          threadId: 'thread-1',
          threadType: 'bid_participation_review',
          projectId: 'project-1',
          requestId: 'request-1',
          requestStatus: 'approved',
          displayTitle: '项目竞标申请',
          requesterOrganization: {
            organizationId: 'supplier-org',
            displayName: '供应商',
            avatarUrl: null,
            certificationStatus: 'approved',
            legalName: '供应商有限公司',
            uscc: null,
          },
          items: [
            {
              itemId: 'item-1',
              itemKind: 'system_notice',
              title: '申请已通过',
              summary: '请继续提交竞标。',
              createdAt: '2026-06-01T10:00:00.000Z',
              action: {
                actionKey: 'bid_submit.open',
                objectType: 'bid_submit',
                canonicalPath: '/api/app/bid/submit',
                label: '提交竞标',
                params: {
                  projectId: 'project-1',
                },
              },
            },
          ],
          primaryReviewAction: null,
        };
      },
    },
  });

  const result = await service.getThreadDetail('thread-1', {});
  assert.equal(result.pricingGateRequired, true);
  assert.equal(result.pricingGateType, 'bid_service_fee_authorization_required');
  assert.deepEqual(result.pricingGateRouteTarget, {
    actionKey: 'bid_service_fee_authorization.open',
    objectType: 'bid_service_fee_authorization',
    canonicalPath: '/api/app/project/project-1/bid-service-fee-authorizations',
    label: '冻结竞标服务费预授权额度',
    params: {
      projectId: 'project-1',
      bidParticipationRequestId: 'request-1',
    },
  });
  assert.deepEqual(result.items[0].action, result.pricingGateRouteTarget);
});

test('bid participation request service rewrites forbidden and invalid-state errors', async () => {
  const forbiddenService = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          403,
          'BID_PARTICIPATION_REQUIRED',
          'Current actor must be approved before participating in this bid.',
        );
      },
    },
  });

  await assert.rejects(
    () => forbiddenService.requestParticipation({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'BID_PARTICIPATION_REQUIRED');
      assert.equal(error.getResponse().message, '当前主体需要先申请参与竞标。');
      return true;
    },
  );

  const invalidStateService = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'BID_PARTICIPATION_INVALID_STATE',
          'Current bid participation request is not in a valid state for this action.',
        );
      },
    },
  });

  await assert.rejects(
    () => invalidStateService.rejectRequest('project-1', 'request-1', {}, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'BID_PARTICIPATION_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前参与竞标申请状态暂不允许执行该操作。');
      return true;
    },
  );
});

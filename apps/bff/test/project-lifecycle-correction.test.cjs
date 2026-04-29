const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectLifecycleService
} = require('../dist/apps/bff/src/routes/project/project-lifecycle.service.js');

function createService(overrides = {}) {
  return new ProjectLifecycleService(
    {
      async post() {
        throw new Error('post mock missing');
      },
      ...overrides.serverClient
    },
    {
      buildForwardHeaders() {
        return { authorization: 'Bearer smoke' };
      }
    },
    new ErrorNormalizerService()
  );
}

function createAxiosError(status, code, message, details) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        source: 'server',
        ...(details ? { details } : {})
      }
    }
  };
}

test('project lifecycle correction forwards withdraw/archive/close and preserves accepted state carrier', async () => {
  const calls = [];
  const service = createService({
    serverClient: {
      async post(path, payload) {
        calls.push([path, payload]);
        if (path === '/server/projects/withdraw') {
          return { projectId: 'project-1', state: 'draft' };
        }
        return { projectId: 'project-1', state: 'archived' };
      }
    }
  });

  const withdrawn = await service.withdrawProject({ projectId: 'project-1' }, {});
  const archived = await service.archiveProject({ projectId: 'project-1' }, {});
  const closed = await service.closeProject({ projectId: 'project-1' }, {});

  assert.deepEqual(calls, [
    ['/server/projects/withdraw', { projectId: 'project-1' }],
    ['/server/projects/archive', { projectId: 'project-1' }],
    ['/server/projects/close', { projectId: 'project-1' }]
  ]);
  assert.deepEqual(withdrawn, { projectId: 'project-1', state: 'draft' });
  assert.deepEqual(archived, { projectId: 'project-1', state: 'archived' });
  assert.deepEqual(closed, { projectId: 'project-1', state: 'archived' });
});

test('project exit governance forwards new routes without calculating business state', async () => {
  const calls = [];
  const service = createService({
    serverClient: {
      async post(path, payload) {
        calls.push([path, payload]);
        if (path === '/server/projects/withdraw-published') {
          return {
            projectId: payload.projectId,
            previousState: 'published',
            state: 'submitted',
            action: 'withdraw_published_to_submitted',
            affectedBidCount: 2,
            affectedAuthorizationCount: 0,
            exitCaseId: 'exit-1'
          };
        }
        if (path === '/server/projects/discard-submitted') {
          return {
            projectId: payload.projectId,
            previousState: 'submitted',
            state: 'archived',
            action: 'discard_submitted',
            exitCaseId: 'exit-2'
          };
        }
        if (path === '/server/projects/cancellation/request') {
          return {
            projectId: payload.projectId,
            exitCaseId: 'exit-3',
            projectState: 'converted_to_order',
            caseStatus: 'requested',
            action: 'request_cancellation'
          };
        }
        if (path === '/server/projects/cancellation/respond') {
          return {
            projectId: payload.projectId,
            exitCaseId: payload.exitCaseId,
            projectState: 'submitted',
            caseStatus: 'accepted',
            action: 'accept_cancellation',
            orderId: 'order-1',
            orderState: 'cancelled'
          };
        }
        if (path === '/server/projects/breach/record-factory') {
          return {
            projectId: payload.projectId,
            exitCaseId: 'exit-4',
            projectState: 'converted_to_order',
            caseStatus: 'recorded',
            breachParty: 'factory',
            action: 'record_factory_breach',
            creditImpactCandidate: true
          };
        }
        throw new Error(`unexpected path ${path}`);
      }
    }
  });

  const withdrawn = await service.withdrawPublishedProject(
    { projectId: 'project-1', reasonCode: 'content_needs_revision' },
    {}
  );
  const discarded = await service.discardSubmittedProject(
    { projectId: 'project-2', reasonCode: 'no_longer_needed' },
    {}
  );
  const cancellation = await service.requestCancellation(
    {
      projectId: 'project-3',
      reasonCode: 'mutual_change',
      noAutomaticPenaltyConfirmed: true
    },
    {}
  );
  const cancellationAccepted = await service.respondCancellation(
    {
      projectId: 'project-3',
      exitCaseId: 'exit-3',
      decision: 'accept',
      noAutomaticPenaltyConfirmed: true
    },
    {}
  );
  const breach = await service.recordFactoryBreach(
    {
      projectId: 'project-4',
      reasonCode: 'factory_refused_fulfillment',
      noAutomaticPenaltyConfirmed: true
    },
    {}
  );

  assert.deepEqual(calls.map((item) => item[0]), [
    '/server/projects/withdraw-published',
    '/server/projects/discard-submitted',
    '/server/projects/cancellation/request',
    '/server/projects/cancellation/respond',
    '/server/projects/breach/record-factory'
  ]);
  assert.equal(withdrawn.state, 'submitted');
  assert.equal(discarded.state, 'archived');
  assert.equal(cancellation.caseStatus, 'requested');
  assert.equal(cancellationAccepted.caseStatus, 'accepted');
  assert.equal(cancellationAccepted.projectState, 'submitted');
  assert.equal(cancellationAccepted.orderState, 'cancelled');
  assert.equal(breach.caseStatus, 'recorded');
  assert.equal(breach.creditImpactCandidate, true);
});

test('project lifecycle correction uses route-specific invalid request codes before upstream forwarding', async () => {
  const service = createService();

  await assert.rejects(
    () => service.withdrawProject({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'PROJECT_WITHDRAW_INVALID');
      assert.equal(error.getResponse().message, '当前项目撤回参数无效，请检查后再试。');
      return true;
    }
  );
});

test('project lifecycle correction rewrites invalid state per route and preserves close boundary for order continuation', async () => {
  const withdrawService = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'PROJECT_INVALID_STATE',
          'Only submitted projects may be withdrawn back to draft.'
        );
      }
    }
  });
  const closeService = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'PROJECT_INVALID_STATE',
          'Projects that have entered order continuation must use the business close chain.'
        );
      }
    }
  });

  await assert.rejects(
    () => withdrawService.withdrawProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前项目尚未提交，暂不支持撤回到草稿。');
      return true;
    }
  );

  await assert.rejects(
    () => closeService.closeProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前项目已进入业务继续链，暂不支持从这里下架关闭。');
      return true;
    }
  );
});

test('project exit governance rewrites authorization and active-state failures', async () => {
  const service = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'PROJECT_EXIT_INVALID_STATE',
          'Current project has platform fee authorization records and must use the P0-Pay release chain first.'
        );
      }
    }
  });

  await assert.rejects(
    () => service.withdrawPublishedProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_EXIT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前项目存在竞标服务费预授权额度记录，需先完成释放或平台处理后再撤回。');
      return true;
    }
  );
});

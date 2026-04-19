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

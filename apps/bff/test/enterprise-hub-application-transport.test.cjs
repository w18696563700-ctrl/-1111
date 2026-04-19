const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');

function createAxiosError(status, code, message) {
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
      },
    },
  };
}

function createService(onPost) {
  return new EnterpriseHubService(
    {
      async post(path, payload, options) {
        return onPost(path, payload, options);
      },
    },
    {
      buildPublicHeadersWithOptionalActorHints() {
        return {};
      },
    },
    new ErrorNormalizerService(),
    {
      async buildCommandHeaders() {
        return {
          authorization: 'Bearer smoke',
          'x-organization-id': 'org-smoke',
        };
      },
    },
  );
}

test('ensureShell forwards only boardType and shapes the ensured shell response', async () => {
  let captured = null;
  const service = createService(async (path, payload, options) => {
    captured = { path, payload, options };
    return {
      enterpriseId: 'enterprise-1',
      boardType: 'factory',
      shellStatus: 'created',
    };
  });

  const result = await service.ensureShell(
    {
      boardType: 'factory',
      applicantName: '不应透传',
      applicantMobile: '13800000000',
    },
    {},
  );

  assert.deepEqual(result, {
    enterpriseId: 'enterprise-1',
    boardType: 'factory',
    shellStatus: 'created',
  });
  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/ensure-shell',
  );
  assert.deepEqual(captured.payload, {
    boardType: 'factory',
  });
  assert.equal(captured.options.headers['x-organization-id'], 'org-smoke');
});

test('createApplication keeps application-draft semantics and still forwards applicant fields', async () => {
  let captured = null;
  const service = createService(async (path, payload) => {
    captured = { path, payload };
    return {
      applicationId: 'application-1',
      enterpriseId: 'enterprise-1',
      applicationStatus: 'draft',
    };
  });

  const result = await service.createApplication(
    {
      applyBoardType: 'company',
      applicantName: '张三',
      applicantMobile: '13800000000',
    },
    {},
  );

  assert.deepEqual(result, {
    applicationId: 'application-1',
    enterpriseId: 'enterprise-1',
    applicationStatus: 'draft',
  });
  assert.equal(captured.path, '/server/exhibition/enterprise-hub/applications');
  assert.deepEqual(captured.payload, {
    applyBoardType: 'company',
    applicantName: '张三',
    applicantMobile: '13800000000',
  });
});

test('createApplicationForBoard injects the fixed board identity without requiring caller boardType', async () => {
  let captured = null;
  const service = createService(async (path, payload) => {
    captured = { path, payload };
    return {
      applicationId: 'application-2',
      enterpriseId: 'enterprise-2',
      applicationStatus: 'draft',
    };
  });

  const result = await service.createApplicationForBoard(
    'factory',
    {
      applicantName: '李四',
      applicantMobile: '13900000000',
    },
    {},
  );

  assert.equal(result.applicationId, 'application-2');
  assert.equal(captured.path, '/server/exhibition/enterprise-hub/applications');
  assert.deepEqual(captured.payload, {
    applyBoardType: 'factory',
    applicantName: '李四',
    applicantMobile: '13900000000',
  });
});

test('createApplicationForBoard rejects conflicting applyBoardType', async () => {
  const service = createService(async () => {
    throw new Error('should not call upstream on conflicting board identity');
  });

  await assert.rejects(
    () =>
      service.createApplicationForBoard(
        'supplier',
        {
          applyBoardType: 'company',
          applicantName: '王五',
          applicantMobile: '13700000000',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
      );
      assert.equal(
        error.getResponse().message,
        '当前独立入口只允许 supplier 板块申请。',
      );
      return true;
    },
  );
});

test('ensureShellForBoard injects the fixed board identity and trims payload noise', async () => {
  let captured = null;
  const service = createService(async (path, payload) => {
    captured = { path, payload };
    return {
      enterpriseId: 'enterprise-2',
      boardType: 'supplier',
      shellStatus: 'created',
    };
  });

  const result = await service.ensureShellForBoard(
    'supplier',
    {
      applicantName: '不应透传',
    },
    {},
  );

  assert.equal(result.boardType, 'supplier');
  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/ensure-shell',
  );
  assert.deepEqual(captured.payload, {
    boardType: 'supplier',
  });
});

test('ensureShellForBoard rejects conflicting boardType', async () => {
  const service = createService(async () => {
    throw new Error('should not call upstream on conflicting board identity');
  });

  await assert.rejects(
    () =>
      service.ensureShellForBoard(
        'company',
        {
          boardType: 'factory',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
      );
      assert.equal(
        error.getResponse().message,
        '当前独立入口只允许 company 板块建档。',
      );
      return true;
    },
  );
});

test('createCaseForBoard injects the fixed board identity', async () => {
  let captured = null;
  const service = createService(async (path, payload) => {
    captured = { path, payload };
    return {
      caseId: 'case-2',
      caseStatus: 'draft',
    };
  });

  const result = await service.createCaseForBoard(
    'enterprise-3',
    'factory',
    {
      title: '工厂案例',
      summary: '摘要',
      city: '成都',
    },
    {},
  );

  assert.deepEqual(result, {
    caseId: 'case-2',
    caseStatus: 'draft',
  });
  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-3/cases',
  );
  assert.deepEqual(captured.payload, {
    boardType: 'factory',
    title: '工厂案例',
    city: '成都',
    summary: '摘要',
  });
});

test('createCaseForBoard rejects conflicting boardType', async () => {
  const service = createService(async () => {
    throw new Error('should not call upstream on conflicting board identity');
  });

  await assert.rejects(
    () =>
      service.createCaseForBoard(
        'enterprise-4',
        'company',
        {
          boardType: 'supplier',
          title: '案例',
          summary: '摘要',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
      );
      assert.equal(
        error.getResponse().message,
        '当前独立入口只允许 company 板块案例。',
      );
      return true;
    },
  );
});

test('ensureShell maps permission denied to the new shell-specific organization message', async () => {
  const service = createService(async () => {
    throw createAxiosError(
      403,
      'ENTERPRISE_HUB_PERMISSION_DENIED',
      'Current organization scope cannot ensure enterprise listing shell.',
    );
  });

  await assert.rejects(
    () => service.ensureShell({ boardType: 'supplier' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_PERMISSION_DENIED',
      );
      assert.equal(
        error.getResponse().message,
        '当前组织身份不可用，暂时无法准备企业展示档。',
      );
      return true;
    },
  );
});

test('ensureShell maps shell unavailable to the controlled temporary-unavailable message', async () => {
  const service = createService(async () => {
    throw createAxiosError(
      503,
      'ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE',
      'Enterprise listing shell is temporarily unavailable.',
    );
  });

  await assert.rejects(
    () => service.ensureShell({ boardType: 'company' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 503);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE',
      );
      assert.equal(
        error.getResponse().message,
        '当前企业展示档暂时无法准备，请稍后再试。',
      );
      return true;
    },
  );
});

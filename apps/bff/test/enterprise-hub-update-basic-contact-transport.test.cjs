const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');

function createService(onPut) {
  return new EnterpriseHubService(
    {
      async put(path, payload, options) {
        return onPut(path, payload, options);
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

test('updateBasic forwards contactName and contactMobile through the canonical basic save path', async () => {
  let captured = null;
  const service = createService(async (path, payload, options) => {
    captured = { path, payload, options };
    return { ok: true, traceId: 'trace-1' };
  });

  const result = await service.updateBasic(
    'enterprise-1',
    {
      name: '企业A',
      contactName: '张三',
      contactMobile: '13800000000',
      shortIntro: '简介',
    },
    {},
  );

  assert.deepEqual(result, { ok: true, traceId: 'trace-1' });
  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-1/basic',
  );
  assert.deepEqual(captured.payload, {
    name: '企业A',
    contactName: '张三',
    contactMobile: '13800000000',
    shortIntro: '简介',
  });
  assert.equal(captured.options.headers['x-organization-id'], 'org-smoke');
});

test('updateBasic keeps payload stable when contact fields are absent', async () => {
  let capturedPayload = null;
  const service = createService(async (_path, payload) => {
    capturedPayload = payload;
    return { ok: true, traceId: 'trace-2' };
  });

  await service.updateBasic(
    'enterprise-2',
    {
      name: '企业B',
      shortIntro: '仅基础资料',
    },
    {},
  );

  assert.deepEqual(capturedPayload, {
    name: '企业B',
    shortIntro: '仅基础资料',
  });
});

test('updateBasic does not start accepting wechat phone email or position fields', async () => {
  let capturedPayload = null;
  const service = createService(async (_path, payload) => {
    capturedPayload = payload;
    return { ok: true, traceId: 'trace-3' };
  });

  await service.updateBasic(
    'enterprise-3',
    {
      contactName: '李四',
      contactMobile: '13900000000',
      wechat: 'wx-1',
      phone: '021-0000',
      email: 'demo@example.com',
      position: '销售总监',
    },
    {},
  );

  assert.deepEqual(capturedPayload, {
    contactName: '李四',
    contactMobile: '13900000000',
  });
});

const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { Module, RequestMethod } = require('@nestjs/common');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const {
  ProjectCommunicationWorkbenchController,
} = require('../src/routes/message_interaction/project-communication-workbench.controller.ts');
const {
  ProjectCommunicationWorkbenchBffService,
} = require('../src/routes/message_interaction/project-communication-workbench.service.ts');
const {
  ErrorNormalizerService,
} = require('../src/core/errors/error-normalizer.service.ts');

function createEntry(entryKey, group, label, reviewState = 'pending_review') {
  const material = group !== 'deal_confirmation';
  return {
    entryKey,
    group,
    label,
    summary: null,
    projectId: 'project-1',
    threadId: 'thread-1',
    bidId: 'bid-1',
    viewerRole: 'bidder',
    subjectOwnerRole: group === 'bid_materials' ? 'bidder' : group === 'deal_confirmation' ? 'platform' : 'publisher',
    availabilityState: material ? 'readable' : 'unavailable',
    reviewState: material ? reviewState : null,
    actionState: material ? 'enabled' : 'blocked',
    attachmentCount: material ? 1 : 0,
    latestFeedbackText: null,
    latestFeedbackAt: null,
    reviewedAt: null,
    routeTarget: {
      actionKey: material ? 'project_communication_material_review.open' : 'project_deal_confirmation.open',
      canonicalPath: material
        ? '/api/app/message/project-communication/workbench/material-review-detail'
        : '/api/app/project/{projectId}/deal-confirmations',
      params: { projectId: 'project-1', threadId: 'thread-1', bidId: 'bid-1', entryKey },
    },
    truthAnchor: {
      truthOwner: 'server',
      subjectType: material ? 'publisher_quote_basis_material' : 'deal_confirmation',
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      subjectOwnerOrganizationId: material ? 'org-publisher' : null,
      reviewerOrganizationId: material ? 'org-bidder' : null,
      materialKind: null,
      bidMaterialSlot: null,
      dealConfirmationId: null,
      sourceVersionToken: material ? 'source-token' : null,
    },
  };
}

function createWorkbenchResponse() {
  return {
    projectId: 'project-1',
    threadId: 'thread-1',
    viewerRole: 'bidder',
    generatedAt: '2026-05-02T02:00:00.000Z',
    entries: [
      createEntry('publisher_effect_image_review', 'publisher_materials', '效果图确认'),
      createEntry('publisher_construction_doc_review', 'publisher_materials', '尺寸图 / 施工图确认'),
      createEntry('publisher_material_sample_review', 'publisher_materials', '材质图 / 材料样板确认'),
      createEntry('publisher_equipment_material_list_review', 'publisher_materials', '设备物料清单确认'),
      createEntry('publisher_service_list_review', 'publisher_materials', '服务清单确认'),
      createEntry('bid_project_understanding_review', 'bid_materials', '项目理解确认'),
      createEntry('bid_quote_sheet_review', 'bid_materials', '报价表确认'),
      createEntry('bid_schedule_plan_review', 'bid_materials', '进度安排确认'),
      createEntry('contract_confirmation', 'deal_confirmation', '合同确认', null),
      createEntry('final_confirmed_amount_confirmation', 'deal_confirmation', '最终成交金额确认', null),
    ],
  };
}

function createService(calls, response = createWorkbenchResponse()) {
  return new ProjectCommunicationWorkbenchBffService(
    {
      async get(path, options) {
        calls.push({ method: 'GET', path, options });
        return response;
      },
      async post(path, body, options) {
        calls.push({ method: 'POST', path, body, options });
        return {
          entry: { ...response.entries[0], reviewState: 'confirmed' },
          entries: [{ ...response.entries[0], reviewState: 'confirmed' }],
          projectId: 'project-1',
          threadId: 'thread-1',
          viewerRole: 'bidder',
          updatedAt: '2026-05-02T02:01:00.000Z',
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer app-token',
          'x-request-id': 'req-1',
          'x-trace-id': 'trace-1',
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('workbench controller route is materialized', async () => {
  const calls = [];
  const service = {
    getWorkbench(projectId, threadId, counterpartOrganizationId, bidId) {
      calls.push({ projectId, threadId, counterpartOrganizationId, bidId });
      return createWorkbenchResponse();
    },
    reviewMaterial(payload) {
      calls.push({ payload });
      return { ok: true };
    },
  };
  class TestModule {}
  Module({
    controllers: [ProjectCommunicationWorkbenchController],
    providers: [{ provide: ProjectCommunicationWorkbenchBffService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');
  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, ProjectCommunicationWorkbenchController),
      'api/app/message/project-communication/workbench',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, ProjectCommunicationWorkbenchController.prototype.getWorkbench),
      RequestMethod.GET,
    );
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, ProjectCommunicationWorkbenchController.prototype.reviewMaterial),
      'material-review',
    );

    const response = await fetch(`${url}/api/app/message/project-communication/workbench?projectId=project-1&threadId=thread-1&bidId=bid-1`);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).entries.length, 10);
    assert.deepEqual(calls[0], {
      projectId: 'project-1',
      threadId: 'thread-1',
      counterpartOrganizationId: undefined,
      bidId: 'bid-1',
    });
  } finally {
    await app.close();
  }
});

test('BFF forwards workbench GET and preserves server review state', async () => {
  const calls = [];
  const response = createWorkbenchResponse();
  response.entries[0].reviewState = 'pending_review';
  response.entries[0].attachmentCount = 3;
  const service = createService(calls, response);
  const result = await service.getWorkbench(
    'project-1',
    'thread-1',
    undefined,
    'bid-1',
    { 'x-organization-id': 'org-bidder' },
  );

  assert.equal(calls[0].method, 'GET');
  assert.equal(calls[0].path, '/server/project-communication/workbench');
  assert.deepEqual(calls[0].options.params, {
    projectId: 'project-1',
    threadId: 'thread-1',
    counterpartOrganizationId: undefined,
    bidId: 'bid-1',
  });
  assert.equal(result.entries[0].attachmentCount, 3);
  assert.equal(result.entries[0].reviewState, 'pending_review');
});

test('BFF forwards material review POST without accepting deal entries', async () => {
  const calls = [];
  const service = createService(calls);
  const result = await service.reviewMaterial(
    {
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      entryKey: 'publisher_effect_image_review',
      reviewAction: 'confirm',
      sourceVersionToken: 'source-token',
      idempotencyKey: 'idempotency-1',
    },
    { 'x-organization-id': 'org-bidder' },
  );

  assert.equal(calls[0].method, 'POST');
  assert.equal(calls[0].path, '/server/project-communication/workbench/material-review');
  assert.equal(calls[0].body.entryKey, 'publisher_effect_image_review');
  assert.equal(result.entry.reviewState, 'confirmed');

  await assert.rejects(
    () =>
      service.reviewMaterial(
        {
          projectId: 'project-1',
          threadId: 'thread-1',
          bidId: 'bid-1',
          entryKey: 'final_confirmed_amount_confirmation',
          reviewAction: 'confirm',
          idempotencyKey: 'bad-entry',
        },
        {},
      ),
    (error) => error.getResponse?.().code === 'PROJECT_COMMUNICATION_WORKBENCH_INVALID',
  );
});

require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');

test('project publish audit record prefers verified actor source over raw request headers', async () => {
  const {
    ProjectPublishAuditService,
  } = require('../dist/modules/audit/project-publish-audit.service.js');

  const saved = [];
  const repository = {
    create(value) {
      return value;
    },
    async save(value) {
      saved.push(value);
      return value;
    },
  };
  const service = new ProjectPublishAuditService(repository);

  await service.record(
    {
      aggregateType: 'project_communication_message',
      aggregateId: 'message-1',
      eventType: 'ProjectCommunicationMessageSent',
      verifiedActor: {
        actorId: 'verified-actor',
        userId: 'verified-user',
        organizationId: 'verified-org',
      },
      payload: {
        projectId: 'project-1',
      },
    },
    {
      authorization: 'Bearer test',
      actorId: 'spoofed-actor',
      userId: 'spoofed-user',
      organizationId: 'spoofed-org',
      actorRole: 'buyer_admin',
      requestId: 'audit-verified-actor-test',
      traceId: 'trace-audit-verified-actor-test',
      userAgent: 'node-test',
      remoteIp: '127.0.0.1',
    },
  );

  assert.equal(saved.length, 1);
  assert.equal(saved[0].actorId, 'verified-actor');
  assert.equal(saved[0].userId, 'verified-user');
  assert.equal(saved[0].organizationId, 'verified-org');
  assert.equal(saved[0].requestId, 'audit-verified-actor-test');
  assert.deepEqual(saved[0].payload, { projectId: 'project-1' });
});

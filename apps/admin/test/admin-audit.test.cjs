/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const { AdminApiError } = require('../test-dist/core/server/admin-api-client.js');
const { loadAuditState } = require('../test-dist/modules/audit/audit-state.js');

test('audit queue/detail/filter consumption forwards bounded filters and selects the first audit log by default', async () => {
  const calls = [];
  const state = await loadAuditState(
    {
      sourceFamily: 'identity',
      objectType: 'organization_certification',
      requestId: 'request-1',
      traceId: 'trace-1',
    },
    {
      fetchList: async (query) => {
        calls.push({ kind: 'list', query });
        return {
          items: [
            {
              auditLogId: 'identity:11111111-1111-4111-8111-111111111111',
              sourceFamily: 'identity',
              objectType: 'organization_certification',
              objectId: 'cert-1',
              objectNo: 'CERT-001',
              action: 'OrganizationCertificationApproved',
              actorId: 'reviewer-user',
              actorRole: 'platform_reviewer',
              requestId: 'request-1',
              traceId: 'trace-1',
              occurredAt: '2026-04-11T01:00:00.000Z',
            },
          ],
          pagination: {
            page: 1,
            pageSize: 20,
            total: 1,
          },
        };
      },
      fetchDetail: async (auditLogId) => {
        calls.push({ kind: 'detail', auditLogId });
        return {
          auditLogId,
          sourceFamily: 'identity',
          objectType: 'organization_certification',
          objectId: 'cert-1',
          objectNo: 'CERT-001',
          action: 'OrganizationCertificationApproved',
          actorId: 'reviewer-user',
          actorRole: 'platform_reviewer',
          requestId: 'request-1',
          traceId: 'trace-1',
          occurredAt: '2026-04-11T01:00:00.000Z',
          beforeState: 'submitted',
          afterState: 'approved',
          reason: 'Manual audit pass.',
          payload: {},
        };
      },
    },
  );

  assert.deepEqual(calls, [
    {
      kind: 'list',
      query: {
        sourceFamily: 'identity',
        objectType: 'organization_certification',
        objectId: undefined,
        objectNo: undefined,
        actorId: undefined,
        requestId: 'request-1',
        traceId: 'trace-1',
        action: undefined,
        occurredFrom: undefined,
        occurredTo: undefined,
        page: 1,
        pageSize: 20,
      },
    },
    {
      kind: 'detail',
      auditLogId: 'identity:11111111-1111-4111-8111-111111111111',
    },
  ]);
  assert.equal(state.total, 1);
  assert.equal(state.items[0].sourceFamily, 'identity');
  assert.equal(state.detail.auditLogId, 'identity:11111111-1111-4111-8111-111111111111');
  assert.equal(state.error, null);
});

test('audit queue/detail consumption surfaces controlled Server Admin API errors', async () => {
  const state = await loadAuditState(
    { selectedAuditLogId: 'identity:missing' },
    {
      fetchList: async () => {
        throw new AdminApiError(404, 'AUDIT_LOG_RESOURCE_UNAVAILABLE', 'not found', null);
      },
      fetchDetail: async () => {
        throw new Error('should not run');
      },
    },
  );

  assert.deepEqual(state, {
    items: [],
    detail: null,
    total: 0,
    error: 'AUDIT_LOG_RESOURCE_UNAVAILABLE: not found',
  });
});

/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const { AdminApiError } = require('../test-dist/core/server/admin-api-client.js');
const {
  buildArchiveTemplateVersionPayload,
  buildCreateTemplatePayload,
  buildCreateTemplateVersionPayload,
  buildPublishTemplateVersionPayload,
  buildUpdateGroupingPayload,
  readTemplateId,
  readTemplateVersionId
} = require('../test-dist/modules/template_config/template-config-form.js');
const {
  loadTemplateConfigState
} = require('../test-dist/modules/template_config/template-config-state.js');

test('template_config state forwards bounded filters and selects first template/version/compare pair by default', async () => {
  const calls = [];
  const state = await loadTemplateConfigState(
    {
      status: 'published',
      groupRef: 'exhibition/project',
      keyword: '展会'
    },
    {
      fetchTemplates: async (query) => {
        calls.push({ kind: 'templates', query });
        return {
          items: [
            {
              templateId: 'template-1',
              templateKey: 'exhibition-intake',
              templateName: '展会项目立项模板',
              groupRef: 'exhibition/project',
              activeVersionId: 'version-2',
              status: 'published',
              updatedAt: '2026-04-11T01:00:00.000Z'
            }
          ],
          pagination: {
            page: 1,
            pageSize: 20,
            total: 1
          }
        };
      },
      fetchTemplate: async (templateId) => {
        calls.push({ kind: 'template', templateId });
        return {
          templateId,
          templateKey: 'exhibition-intake',
          templateName: '展会项目立项模板',
          description: '治理展会立项字段。',
          groupRef: 'exhibition/project',
          activeVersionId: 'version-2',
          status: 'published',
          publishedVersionCount: 2,
          createdAt: '2026-04-11T01:00:00.000Z',
          updatedAt: '2026-04-11T02:00:00.000Z'
        };
      },
      fetchVersions: async (templateId, query) => {
        calls.push({ kind: 'versions', templateId, query });
        return {
          items: [
            {
              templateVersionId: 'version-2',
              versionNo: 2,
              status: 'published',
              ruleVersionId: 'rule-v2',
              publishedAt: '2026-04-11T02:00:00.000Z',
              archivedAt: null,
              createdAt: '2026-04-11T01:30:00.000Z'
            },
            {
              templateVersionId: 'version-1',
              versionNo: 1,
              status: 'published',
              ruleVersionId: 'rule-v1',
              publishedAt: '2026-04-11T01:00:00.000Z',
              archivedAt: null,
              createdAt: '2026-04-11T00:30:00.000Z'
            }
          ],
          pagination: {
            page: 1,
            pageSize: 20,
            total: 2
          }
        };
      },
      fetchVersion: async (templateId, templateVersionId) => {
        calls.push({ kind: 'version', templateId, templateVersionId });
        return {
          templateVersionId,
          templateId,
          versionNo: 2,
          status: 'published',
          schema: { kind: 'object' },
          fields: [],
          rule: {
            templateRuleId: 'rule-project',
            ruleVersionId: 'rule-v2',
            assignmentRefs: ['exhibition']
          },
          publishedAt: '2026-04-11T02:00:00.000Z',
          archivedAt: null,
          createdAt: '2026-04-11T01:30:00.000Z'
        };
      },
      compareVersions: async (templateId, query) => {
        calls.push({ kind: 'compare', templateId, query });
        return {
          baseVersion: {
            templateVersionId: 'version-1',
            versionNo: 1
          },
          targetVersion: {
            templateVersionId: 'version-2',
            versionNo: 2
          },
          fieldDiff: {
            schemaChanged: true,
            schemaBefore: { kind: 'object', revision: 1 },
            schemaAfter: { kind: 'object', revision: 2 },
            addedFields: [],
            removedFields: [],
            changedFields: []
          },
          ruleDiff: {
            templateRuleIdChanged: false,
            ruleVersionIdChanged: true,
            assignmentRefsAdded: ['high_risk'],
            assignmentRefsRemoved: []
          },
          groupingDiff: {
            baseGroupRef: 'exhibition/project',
            targetGroupRef: 'exhibition/project',
            changed: false
          }
        };
      }
    }
  );

  assert.deepEqual(calls, [
    {
      kind: 'templates',
      query: {
        status: 'published',
        groupRef: 'exhibition/project',
        keyword: '展会',
        page: 1,
        pageSize: 20
      }
    },
    { kind: 'template', templateId: 'template-1' },
    {
      kind: 'versions',
      templateId: 'template-1',
      query: {
        page: 1,
        pageSize: 20
      }
    },
    {
      kind: 'version',
      templateId: 'template-1',
      templateVersionId: 'version-2'
    },
    {
      kind: 'compare',
      templateId: 'template-1',
      query: {
        baseVersionId: 'version-1',
        targetVersionId: 'version-2'
      }
    }
  ]);
  assert.equal(state.total, 1);
  assert.equal(state.selectedTemplateId, 'template-1');
  assert.equal(state.selectedTemplateVersionId, 'version-2');
  assert.equal(state.baseVersionId, 'version-1');
  assert.equal(state.targetVersionId, 'version-2');
  assert.equal(state.error, null);
});

test('template_config state surfaces controlled Server Admin API errors', async () => {
  const state = await loadTemplateConfigState(
    { selectedTemplateId: 'missing-template' },
    {
      fetchTemplates: async () => {
        throw new AdminApiError(404, 'TEMPLATE_CONFIG_TEMPLATE_RESOURCE_UNAVAILABLE', 'not found', null);
      },
      fetchTemplate: async () => {
        throw new Error('should not run');
      },
      fetchVersions: async () => {
        throw new Error('should not run');
      },
      fetchVersion: async () => {
        throw new Error('should not run');
      },
      compareVersions: async () => {
        throw new Error('should not run');
      }
    }
  );

  assert.deepEqual(state, {
    items: [],
    template: null,
    versions: [],
    version: null,
    compare: null,
    total: 0,
    selectedTemplateId: null,
    selectedTemplateVersionId: null,
    baseVersionId: null,
    targetVersionId: null,
    error: 'TEMPLATE_CONFIG_TEMPLATE_RESOURCE_UNAVAILABLE: not found'
  });
});

test('template_config form builders create bounded template/version/publish/archive/grouping payloads', () => {
  const templateForm = new FormData();
  templateForm.set('templateKey', 'exhibition-intake');
  templateForm.set('templateName', '展会项目立项模板');
  templateForm.set('description', '治理展会立项字段。');
  templateForm.set('groupRef', 'exhibition/project');

  const versionForm = new FormData();
  versionForm.set('templateId', 'template-1');
  versionForm.set('templateVersionId', 'version-2');
  versionForm.set('schemaJson', JSON.stringify({ kind: 'object', revision: 2 }));
  versionForm.set(
    'fieldsJson',
    JSON.stringify([
      {
        fieldKey: 'projectTitle',
        fieldType: 'string',
        required: true,
        defaultValue: null,
        displayOrder: 1
      }
    ])
  );
  versionForm.set('templateRuleId', 'rule-project');
  versionForm.set('ruleVersionId', 'rule-project-v2');
  versionForm.set('assignmentRefsText', 'exhibition\nproject_publish');
  versionForm.set('publishNote', 'publish template version');
  versionForm.set('archiveReason', 'archive old version');
  versionForm.set('groupRef', 'exhibition/project/high-risk');

  assert.deepEqual(buildCreateTemplatePayload(templateForm), {
    templateKey: 'exhibition-intake',
    templateName: '展会项目立项模板',
    description: '治理展会立项字段。',
    groupRef: 'exhibition/project'
  });
  assert.equal(readTemplateId(versionForm), 'template-1');
  assert.equal(readTemplateVersionId(versionForm), 'version-2');
  assert.deepEqual(buildCreateTemplateVersionPayload(versionForm), {
    schema: { kind: 'object', revision: 2 },
    fields: [
      {
        fieldKey: 'projectTitle',
        fieldType: 'string',
        required: true,
        defaultValue: null,
        displayOrder: 1
      }
    ],
    rule: {
      templateRuleId: 'rule-project',
      ruleVersionId: 'rule-project-v2',
      assignmentRefs: ['exhibition', 'project_publish']
    }
  });
  assert.deepEqual(buildPublishTemplateVersionPayload(versionForm), {
    publishNote: 'publish template version'
  });
  assert.deepEqual(buildArchiveTemplateVersionPayload(versionForm), {
    archiveReason: 'archive old version'
  });
  assert.deepEqual(buildUpdateGroupingPayload(versionForm), {
    groupRef: 'exhibition/project/high-risk'
  });
});

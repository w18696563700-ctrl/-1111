const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-template-config',
  traceId: 'trace-template-config',
  userAgent: '',
  remoteIp: ''
};

function makeService() {
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: context.actorId,
        userId: context.userId,
        organizationId: context.organizationId,
        requestId: context.requestId,
        traceId: context.traceId
      }
    })
  };
  const eligibility = {
    requireReviewer: async () => ({ actorRole: 'platform_reviewer' })
  };

  const {
    TemplateConfigStore
  } = require('../dist/modules/template_config/template-config.store.js');
  const {
    TemplateConfigPresenter
  } = require('../dist/modules/template_config/template-config.presenter.js');
  const {
    TemplateConfigAdminService
  } = require('../dist/modules/template_config/template-config-admin.service.js');

  return new TemplateConfigAdminService(
    new TemplateConfigStore(),
    verifier,
    eligibility,
    new TemplateConfigPresenter()
  );
}

test('template_config list/detail/version detail and compare form a bounded governance projection', async () => {
  const service = makeService();
  const template = await service.createTemplate(
    {
      templateKey: 'exhibition-intake',
      templateName: '展会项目立项模板',
      description: '用于展会项目创建的受控模板。',
      groupRef: 'exhibition/project'
    },
    context
  );

  const versionOne = await service.createVersion(
    template.templateId,
    {
      schema: { kind: 'object', revision: 1 },
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
        ruleVersionId: 'rule-project-v1',
        assignmentRefs: ['exhibition', 'project_publish']
      }
    },
    context
  );

  await service.publishVersion(
    template.templateId,
    versionOne.templateVersionId,
    { publishNote: 'publish v1' },
    context
  );
  await service.updateGrouping(
    template.templateId,
    { groupRef: 'exhibition/project/high-risk' },
    context
  );

  const versionTwo = await service.createVersion(
    template.templateId,
    {
      schema: { kind: 'object', revision: 2 },
      fields: [
        {
          fieldKey: 'projectTitle',
          fieldType: 'string',
          required: true,
          defaultValue: null,
          displayOrder: 1
        },
        {
          fieldKey: 'budget',
          fieldType: 'number',
          required: false,
          defaultValue: 0,
          displayOrder: 2
        }
      ],
      rule: {
        templateRuleId: 'rule-project',
        ruleVersionId: 'rule-project-v2',
        assignmentRefs: ['exhibition', 'project_publish', 'high_risk']
      }
    },
    context
  );

  const list = await service.list({ page: 1, pageSize: 20, status: undefined }, context);
  const detail = await service.detail(template.templateId, context);
  const versions = await service.versions(template.templateId, { page: 1, pageSize: 20 }, context);
  const versionDetail = await service.versionDetail(
    template.templateId,
    versionTwo.templateVersionId,
    context
  );
  const compare = await service.compare(
    template.templateId,
    versionOne.templateVersionId,
    versionTwo.templateVersionId,
    context
  );

  assert.equal(list.pagination.total, 1);
  assert.equal(list.items[0].templateKey, 'exhibition-intake');
  assert.equal(detail.templateId, template.templateId);
  assert.equal(detail.activeVersionId, versionOne.templateVersionId);
  assert.equal(versions.pagination.total, 2);
  assert.equal(versions.items[0].versionNo, 2);
  assert.equal(versionDetail.rule.ruleVersionId, 'rule-project-v2');
  assert.equal(compare.baseVersion.versionNo, 1);
  assert.equal(compare.targetVersion.versionNo, 2);
  assert.equal(compare.groupingDiff.baseGroupRef, 'exhibition/project');
  assert.equal(compare.groupingDiff.targetGroupRef, 'exhibition/project/high-risk');
  assert.equal(compare.groupingDiff.changed, true);
  assert.equal(compare.fieldDiff.addedFields.length, 1);
  assert.equal(compare.ruleDiff.ruleVersionIdChanged, true);
});

test('template_config filters by status/groupRef/keyword and falls back active version after archive', async () => {
  const service = makeService();
  const template = await service.createTemplate(
    {
      templateKey: 'contract-template',
      templateName: '合同模板',
      description: '合同条款模板。',
      groupRef: 'contract/default'
    },
    context
  );

  const versionOne = await service.createVersion(
    template.templateId,
    {
      schema: { kind: 'object', revision: 1 },
      fields: [
        {
          fieldKey: 'contractNo',
          fieldType: 'string',
          required: true,
          defaultValue: null,
          displayOrder: 1
        }
      ],
      rule: {
        templateRuleId: 'rule-contract',
        ruleVersionId: 'rule-contract-v1',
        assignmentRefs: ['contract']
      }
    },
    context
  );
  await service.publishVersion(
    template.templateId,
    versionOne.templateVersionId,
    { publishNote: 'publish contract v1' },
    context
  );

  const versionTwo = await service.createVersion(
    template.templateId,
    {
      schema: { kind: 'object', revision: 2 },
      fields: [
        {
          fieldKey: 'contractNo',
          fieldType: 'string',
          required: true,
          defaultValue: null,
          displayOrder: 1
        },
        {
          fieldKey: 'inspectionMode',
          fieldType: 'string',
          required: false,
          defaultValue: 'onsite',
          displayOrder: 2
        }
      ],
      rule: {
        templateRuleId: 'rule-contract',
        ruleVersionId: 'rule-contract-v2',
        assignmentRefs: ['contract', 'inspection']
      }
    },
    context
  );
  await service.publishVersion(
    template.templateId,
    versionTwo.templateVersionId,
    { publishNote: 'publish contract v2' },
    context
  );

  const filteredByStatus = await service.list(
    { page: 1, pageSize: 20, status: 'published', groupRef: undefined, keyword: undefined },
    context
  );
  const filteredByGroup = await service.list(
    { page: 1, pageSize: 20, status: undefined, groupRef: 'contract/default', keyword: undefined },
    context
  );
  const filteredByKeyword = await service.list(
    { page: 1, pageSize: 20, status: undefined, groupRef: undefined, keyword: '合同' },
    context
  );

  const archived = await service.archiveVersion(
    template.templateId,
    versionTwo.templateVersionId,
    { archiveReason: 'fallback to prior published version' },
    context
  );

  assert.equal(filteredByStatus.items.length, 1);
  assert.equal(filteredByGroup.items.length, 1);
  assert.equal(filteredByKeyword.items.length, 1);
  assert.equal(archived.template.activeVersionId, versionOne.templateVersionId);
  assert.equal(archived.version.status, 'archived');
});

test('template_config guards published version immutability', async () => {
  const service = makeService();
  const template = await service.createTemplate(
    {
      templateKey: 'inspection-template',
      templateName: '验收模板',
      description: null,
      groupRef: 'inspection/default'
    },
    context
  );
  const version = await service.createVersion(
    template.templateId,
    {
      schema: { kind: 'object', revision: 1 },
      fields: [
        {
          fieldKey: 'inspectionResult',
          fieldType: 'string',
          required: true,
          defaultValue: null,
          displayOrder: 1
        }
      ],
      rule: {
        templateRuleId: 'rule-inspection',
        ruleVersionId: 'rule-inspection-v1',
        assignmentRefs: ['inspection']
      }
    },
    context
  );

  await service.publishVersion(
    template.templateId,
    version.templateVersionId,
    { publishNote: 'publish inspection v1' },
    context
  );

  await assert.rejects(
    () =>
      service.publishVersion(
        template.templateId,
        version.templateVersionId,
        { publishNote: 'repeat publish should fail' },
        context
      ),
    (error) => error?.response?.code === 'TEMPLATE_CONFIG_INVALID_STATE'
  );
});

import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { templateConfigInvalid, templateConfigInvalidState, templateConfigTemplateResourceUnavailable, templateConfigTemplateVersionResourceUnavailable } from './template-config.errors';
import type {
  TemplateConfigArchiveCommand,
  TemplateConfigCompareProjection,
  TemplateConfigCreateTemplateCommand,
  TemplateConfigCreateVersionCommand,
  TemplateConfigField,
  TemplateConfigGroupingCommand,
  TemplateConfigListQuery,
  TemplateConfigPublishCommand,
  TemplateConfigRule,
  TemplateConfigTemplateRecord,
  TemplateConfigTemplateVersionRecord,
  TemplateConfigVersionListQuery
} from './template-config.types';

@Injectable()
export class TemplateConfigStore {
  private readonly templates = new Map<string, TemplateConfigTemplateRecord>();
  private readonly versions = new Map<string, TemplateConfigTemplateVersionRecord>();

  listTemplates(query: TemplateConfigListQuery) {
    const items = [...this.templates.values()]
      .filter((template) => this.matchesTemplateFilter(template, query))
      .sort((left, right) => right.updatedAt.getTime() - left.updatedAt.getTime());
    const total = items.length;
    return {
      items: items.slice((query.page - 1) * query.pageSize, query.page * query.pageSize).map((item) =>
        this.cloneTemplate(item)
      ),
      total
    };
  }

  getTemplate(templateId: string) {
    return this.cloneTemplate(this.requireTemplate(templateId));
  }

  listVersions(templateId: string, query: TemplateConfigVersionListQuery) {
    const template = this.requireTemplate(templateId);
    const items = template.versionIds
      .map((versionId) => this.requireVersion(templateId, versionId))
      .sort((left, right) => right.versionNo - left.versionNo);
    const total = items.length;
    return {
      items: items.slice((query.page - 1) * query.pageSize, query.page * query.pageSize).map((item) =>
        this.cloneVersion(item)
      ),
      total
    };
  }

  getVersion(templateId: string, templateVersionId: string) {
    return this.cloneVersion(this.requireVersion(templateId, templateVersionId));
  }

  compareVersions(
    templateId: string,
    baseVersionId: string,
    targetVersionId: string
  ): TemplateConfigCompareProjection {
    const baseVersion = this.requireVersion(templateId, baseVersionId);
    const targetVersion = this.requireVersion(templateId, targetVersionId);
    const fieldDiff = this.diffFields(baseVersion, targetVersion);
    return {
      baseVersion: {
        templateVersionId: baseVersion.templateVersionId,
        versionNo: baseVersion.versionNo
      },
      targetVersion: {
        templateVersionId: targetVersion.templateVersionId,
        versionNo: targetVersion.versionNo
      },
      fieldDiff: {
        schemaChanged: !this.isDeepEqual(baseVersion.schema, targetVersion.schema),
        schemaBefore: this.cloneValue(baseVersion.schema),
        schemaAfter: this.cloneValue(targetVersion.schema),
        addedFields: fieldDiff.addedFields,
        removedFields: fieldDiff.removedFields,
        changedFields: fieldDiff.changedFields
      },
      ruleDiff: this.diffRule(baseVersion, targetVersion),
      groupingDiff: {
        baseGroupRef: baseVersion.groupRefSnapshot,
        targetGroupRef: targetVersion.groupRefSnapshot,
        changed: baseVersion.groupRefSnapshot !== targetVersion.groupRefSnapshot
      }
    };
  }

  createTemplate(command: TemplateConfigCreateTemplateCommand) {
    const now = new Date();
    const template: TemplateConfigTemplateRecord = {
      templateId: randomUUID(),
      templateKey: this.readRequiredText(command.templateKey, 'templateKey', 128),
      templateName: this.readRequiredText(command.templateName, 'templateName', 128),
      description: this.readOptionalText(command.description, 500),
      groupRef: this.readOptionalText(command.groupRef, 128),
      status: 'draft',
      activeVersionId: null,
      publishedVersionCount: 0,
      createdAt: now,
      updatedAt: now,
      versionIds: []
    };
    this.templates.set(template.templateId, template);
    return { template: this.cloneTemplate(template) };
  }

  createVersion(templateId: string, command: TemplateConfigCreateVersionCommand) {
    const template = this.requireTemplate(templateId);
    const now = new Date();
    const versionNo =
      template.versionIds
        .map((versionId) => this.requireVersion(templateId, versionId).versionNo)
        .reduce((max, current) => Math.max(max, current), 0) + 1;
    const version: TemplateConfigTemplateVersionRecord = {
      templateVersionId: randomUUID(),
      templateId: template.templateId,
      versionNo,
      status: 'draft',
      schema: this.cloneValue(command.schema),
      fields: this.cloneFields(command.fields),
      rule: this.cloneRule(command.rule),
      groupRefSnapshot: template.groupRef,
      publishedAt: null,
      archivedAt: null,
      publishNote: null,
      archiveReason: null,
      createdAt: now,
      updatedAt: now
    };
    this.validateVersionPayload(version);
    template.versionIds = [...template.versionIds, version.templateVersionId];
    template.updatedAt = now;
    this.templates.set(template.templateId, template);
    this.versions.set(version.templateVersionId, version);
    return {
      template: this.cloneTemplate(template),
      version: this.cloneVersion(version)
    };
  }

  publishVersion(
    templateId: string,
    templateVersionId: string,
    command: TemplateConfigPublishCommand
  ) {
    const template = this.requireTemplate(templateId);
    const version = this.requireVersion(templateId, templateVersionId);
    if (version.status === 'published') {
      throw templateConfigInvalidState('Published template version is immutable.');
    }
    if (version.status === 'archived') {
      throw templateConfigInvalidState('Archived template version cannot be published again.');
    }
    const now = new Date();
    version.status = 'published';
    version.publishedAt = now;
    version.archivedAt = null;
    version.publishNote = this.readOptionalText(command.publishNote, 500);
    version.updatedAt = now;
    template.publishedVersionCount += 1;
    template.activeVersionId = version.templateVersionId;
    template.status = 'published';
    template.updatedAt = now;
    this.templates.set(template.templateId, template);
    this.versions.set(version.templateVersionId, version);
    return {
      template: this.cloneTemplate(template),
      version: this.cloneVersion(version)
    };
  }

  archiveVersion(
    templateId: string,
    templateVersionId: string,
    command: TemplateConfigArchiveCommand
  ) {
    const template = this.requireTemplate(templateId);
    const version = this.requireVersion(templateId, templateVersionId);
    if (version.status === 'archived') {
      throw templateConfigInvalidState('Archived template version is already archived.');
    }
    const now = new Date();
    version.status = 'archived';
    version.archivedAt = now;
    version.archiveReason = this.readOptionalText(command.archiveReason, 500);
    version.updatedAt = now;
    if (template.activeVersionId === version.templateVersionId) {
      const nextActive = template.versionIds
        .map((item) => this.requireVersion(templateId, item))
        .filter((item) => item.status === 'published' && item.templateVersionId !== version.templateVersionId)
        .sort((left, right) => {
          const leftTime = left.publishedAt?.getTime() ?? left.createdAt.getTime();
          const rightTime = right.publishedAt?.getTime() ?? right.createdAt.getTime();
          return rightTime - leftTime;
        })[0];
      template.activeVersionId = nextActive?.templateVersionId ?? null;
    }
    template.status = template.activeVersionId ? 'published' : 'archived';
    template.updatedAt = now;
    this.templates.set(template.templateId, template);
    this.versions.set(version.templateVersionId, version);
    return {
      template: this.cloneTemplate(template),
      version: this.cloneVersion(version)
    };
  }

  updateGrouping(templateId: string, command: TemplateConfigGroupingCommand) {
    const template = this.requireTemplate(templateId);
    const now = new Date();
    template.groupRef = this.readOptionalText(command.groupRef, 128);
    template.updatedAt = now;
    this.templates.set(template.templateId, template);
    return { template: this.cloneTemplate(template) };
  }

  private matchesTemplateFilter(template: TemplateConfigTemplateRecord, query: TemplateConfigListQuery) {
    if (query.status && template.status !== query.status) {
      return false;
    }
    if (query.groupRef && template.groupRef !== query.groupRef) {
      return false;
    }
    if (!query.keyword) {
      return true;
    }
    const keyword = query.keyword.toLowerCase();
    return [
      template.templateKey,
      template.templateName,
      template.description ?? '',
      template.groupRef ?? ''
    ].some((value) => value.toLowerCase().includes(keyword));
  }

  private requireTemplate(templateId: string) {
    const template = this.templates.get(templateId);
    if (!template) {
      throw templateConfigTemplateResourceUnavailable('Template resource is unavailable.');
    }
    return template;
  }

  private requireVersion(templateId: string, templateVersionId: string) {
    const version = this.versions.get(templateVersionId);
    if (!version || version.templateId !== templateId) {
      throw templateConfigTemplateVersionResourceUnavailable('Template version resource is unavailable.');
    }
    return version;
  }

  private cloneTemplate(template: TemplateConfigTemplateRecord): TemplateConfigTemplateRecord {
    return {
      ...template,
      createdAt: new Date(template.createdAt),
      updatedAt: new Date(template.updatedAt),
      versionIds: [...template.versionIds]
    };
  }

  private cloneVersion(version: TemplateConfigTemplateVersionRecord): TemplateConfigTemplateVersionRecord {
    return {
      ...version,
      schema: this.cloneValue(version.schema),
      fields: this.cloneFields(version.fields),
      rule: this.cloneRule(version.rule),
      publishedAt: version.publishedAt ? new Date(version.publishedAt) : null,
      archivedAt: version.archivedAt ? new Date(version.archivedAt) : null,
      createdAt: new Date(version.createdAt),
      updatedAt: new Date(version.updatedAt)
    };
  }

  private cloneFields(fields: TemplateConfigField[]) {
    return fields.map((field) => ({ ...field, defaultValue: this.cloneValue(field.defaultValue) }));
  }

  private cloneRule(rule: TemplateConfigRule) {
    return {
      templateRuleId: rule.templateRuleId,
      ruleVersionId: rule.ruleVersionId,
      assignmentRefs: [...rule.assignmentRefs]
    };
  }

  private cloneValue<T>(value: T): T {
    if (Array.isArray(value)) {
      return value.map((item) => this.cloneValue(item)) as T;
    }
    if (value && typeof value === 'object') {
      const cloned: Record<string, unknown> = {};
      for (const [key, child] of Object.entries(value as Record<string, unknown>)) {
        cloned[key] = this.cloneValue(child);
      }
      return cloned as T;
    }
    return value;
  }

  private diffFields(base: TemplateConfigTemplateVersionRecord, target: TemplateConfigTemplateVersionRecord) {
    const baseByKey = new Map(base.fields.map((field) => [field.fieldKey, field]));
    const targetByKey = new Map(target.fields.map((field) => [field.fieldKey, field]));
    const addedFields = target.fields.filter((field) => !baseByKey.has(field.fieldKey));
    const removedFields = base.fields.filter((field) => !targetByKey.has(field.fieldKey));
    const changedFields = target.fields
      .filter((field) => baseByKey.has(field.fieldKey))
      .map((field) => ({
        baseField: baseByKey.get(field.fieldKey) as TemplateConfigField,
        targetField: field
      }))
      .filter(({ baseField, targetField }) => !this.isDeepEqual(baseField, targetField))
      .map(({ baseField, targetField }) => ({
        fieldKey: targetField.fieldKey,
        baseField,
        targetField
      }));
    return { addedFields, removedFields, changedFields };
  }

  private diffRule(base: TemplateConfigTemplateVersionRecord, target: TemplateConfigTemplateVersionRecord) {
    const baseAssignmentRefs = new Set(base.rule.assignmentRefs);
    const targetAssignmentRefs = new Set(target.rule.assignmentRefs);
    return {
      templateRuleIdChanged: base.rule.templateRuleId !== target.rule.templateRuleId,
      ruleVersionIdChanged: base.rule.ruleVersionId !== target.rule.ruleVersionId,
      assignmentRefsAdded: [...targetAssignmentRefs].filter((item) => !baseAssignmentRefs.has(item)),
      assignmentRefsRemoved: [...baseAssignmentRefs].filter((item) => !targetAssignmentRefs.has(item))
    };
  }

  private isDeepEqual(left: unknown, right: unknown) {
    return JSON.stringify(left) === JSON.stringify(right);
  }

  private validateVersionPayload(version: TemplateConfigTemplateVersionRecord) {
    if (typeof version.schema !== 'object' || Array.isArray(version.schema) || version.schema === null) {
      throw templateConfigInvalid('schema must be an object.');
    }
    if (!Array.isArray(version.fields)) {
      throw templateConfigInvalid('fields must be an array.');
    }
    if (
      typeof version.rule !== 'object' ||
      version.rule === null ||
      Array.isArray(version.rule)
    ) {
      throw templateConfigInvalid('rule must be an object.');
    }
    for (const field of version.fields) {
      this.readRequiredText(field.fieldKey, 'fieldKey', 128);
      this.readRequiredText(field.fieldType, 'fieldType', 64);
      if (typeof field.required !== 'boolean') {
        throw templateConfigInvalid('field.required must be boolean.');
      }
      if (typeof field.displayOrder !== 'number' || !Number.isFinite(field.displayOrder)) {
        throw templateConfigInvalid('field.displayOrder must be a finite number.');
      }
    }
    this.readRequiredText(version.rule.templateRuleId, 'rule.templateRuleId', 128);
    this.readRequiredText(version.rule.ruleVersionId, 'rule.ruleVersionId', 128);
    if (!Array.isArray(version.rule.assignmentRefs)) {
      throw templateConfigInvalid('rule.assignmentRefs must be an array.');
    }
    for (const assignmentRef of version.rule.assignmentRefs) {
      this.readRequiredText(assignmentRef, 'rule.assignmentRefs[]', 128);
    }
  }

  private readRequiredText(value: unknown, fieldName: string, maxLength: number) {
    if (typeof value !== 'string') {
      throw templateConfigInvalid(`${fieldName} must be a string.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw templateConfigInvalid(`${fieldName} is required.`);
    }
    if (normalized.length > maxLength) {
      throw templateConfigInvalid(`${fieldName} exceeds the maximum length.`);
    }
    return normalized;
  }

  private readOptionalText(value: unknown, maxLength: number) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    if (!normalized) {
      return null;
    }
    if (normalized.length > maxLength) {
      throw templateConfigInvalid('text value exceeds the maximum length.');
    }
    return normalized;
  }
}

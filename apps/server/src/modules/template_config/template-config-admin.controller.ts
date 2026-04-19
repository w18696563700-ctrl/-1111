import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { templateConfigInvalid } from './template-config.errors';
import { TemplateConfigAdminService } from './template-config-admin.service';

@Controller('server/admin/config/templates')
export class TemplateConfigAdminController {
  constructor(private readonly templateConfigAdminService: TemplateConfigAdminService) {}

  @Get()
  list(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.templateConfigAdminService.list(normalizeListQuery(query), resolveRequestContext(headers));
  }

  @Get(':templateId')
  detail(@Param('templateId') templateId: string, @Headers() headers: HeaderBag) {
    return this.templateConfigAdminService.detail(templateId, resolveRequestContext(headers));
  }

  @Get(':templateId/versions')
  versions(
    @Param('templateId') templateId: string,
    @Query() query: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.versions(
      templateId,
      normalizeVersionListQuery(query),
      resolveRequestContext(headers)
    );
  }

  @Get(':templateId/versions/compare')
  compare(
    @Param('templateId') templateId: string,
    @Query() query: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    const baseVersionId = normalizeRequiredString(query.baseVersionId, 'baseVersionId', 128);
    const targetVersionId = normalizeRequiredString(query.targetVersionId, 'targetVersionId', 128);
    return this.templateConfigAdminService.compare(
      templateId,
      baseVersionId,
      targetVersionId,
      resolveRequestContext(headers)
    );
  }

  @Get(':templateId/versions/:templateVersionId')
  versionDetail(
    @Param('templateId') templateId: string,
    @Param('templateVersionId') templateVersionId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.versionDetail(
      templateId,
      templateVersionId,
      resolveRequestContext(headers)
    );
  }

  @Post()
  @HttpCode(200)
  createTemplate(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.templateConfigAdminService.createTemplate(normalizeCreateTemplate(body), resolveRequestContext(headers));
  }

  @Post(':templateId/versions')
  @HttpCode(200)
  createVersion(
    @Param('templateId') templateId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.createVersion(
      templateId,
      normalizeCreateVersion(body),
      resolveRequestContext(headers)
    );
  }

  @Post(':templateId/versions/:templateVersionId/publish')
  @HttpCode(200)
  publishVersion(
    @Param('templateId') templateId: string,
    @Param('templateVersionId') templateVersionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.publishVersion(
      templateId,
      templateVersionId,
      normalizePublish(body),
      resolveRequestContext(headers)
    );
  }

  @Post(':templateId/versions/:templateVersionId/archive')
  @HttpCode(200)
  archiveVersion(
    @Param('templateId') templateId: string,
    @Param('templateVersionId') templateVersionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.archiveVersion(
      templateId,
      templateVersionId,
      normalizeArchive(body),
      resolveRequestContext(headers)
    );
  }

  @Post(':templateId/grouping')
  @HttpCode(200)
  updateGrouping(
    @Param('templateId') templateId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.templateConfigAdminService.updateGrouping(
      templateId,
      normalizeGrouping(body),
      resolveRequestContext(headers)
    );
  }
}

function normalizeListQuery(query: Record<string, unknown>) {
  return {
    status: normalizeTemplateStatus(query.status),
    groupRef: normalizeOptionalString(query.groupRef),
    keyword: normalizeOptionalString(query.keyword),
    page: normalizePositiveInt(query.page, 1, 1_000),
    pageSize: normalizePositiveInt(query.pageSize, 20, 100)
  };
}

function normalizeVersionListQuery(query: Record<string, unknown>) {
  return {
    page: normalizePositiveInt(query.page, 1, 1_000),
    pageSize: normalizePositiveInt(query.pageSize, 20, 100)
  };
}

function normalizeCreateTemplate(body: Record<string, unknown>) {
  return {
    templateKey: normalizeRequiredString(body.templateKey, 'templateKey', 128),
    templateName: normalizeRequiredString(body.templateName, 'templateName', 128),
    description: normalizeOptionalString(body.description),
    groupRef: normalizeOptionalString(body.groupRef)
  };
}

function normalizeCreateVersion(body: Record<string, unknown>) {
  return {
    schema: normalizeObject(body.schema, 'schema'),
    fields: normalizeArray(body.fields, 'fields').map(normalizeField),
    rule: normalizeRule(body.rule)
  };
}

function normalizePublish(body: Record<string, unknown>) {
  return {
    publishNote: normalizeOptionalString(body.publishNote)
  };
}

function normalizeArchive(body: Record<string, unknown>) {
  return {
    archiveReason: normalizeOptionalString(body.archiveReason)
  };
}

function normalizeGrouping(body: Record<string, unknown>) {
  return {
    groupRef: normalizeOptionalString(body.groupRef)
  };
}

function normalizeField(value: unknown) {
  const field = normalizeObject(value, 'fields[]');
  return {
    fieldKey: normalizeRequiredString(field.fieldKey, 'fieldKey', 128),
    fieldType: normalizeRequiredString(field.fieldType, 'fieldType', 64),
    required: normalizeBoolean(field.required, 'required'),
    defaultValue: field.defaultValue ?? null,
    displayOrder: normalizeNumber(field.displayOrder, 'displayOrder')
  };
}

function normalizeRule(value: unknown) {
  const rule = normalizeObject(value, 'rule');
  return {
    templateRuleId: normalizeRequiredString(rule.templateRuleId, 'rule.templateRuleId', 128),
    ruleVersionId: normalizeRequiredString(rule.ruleVersionId, 'rule.ruleVersionId', 128),
    assignmentRefs: normalizeArray(rule.assignmentRefs, 'rule.assignmentRefs').map((item) =>
      normalizeRequiredString(item, 'rule.assignmentRefs[]', 128)
    )
  };
}

function normalizeTemplateStatus(value: unknown) {
  const normalized = normalizeOptionalString(value);
  if (!normalized) {
    return undefined;
  }
  return ['draft', 'published', 'archived', 'deprecated'].includes(normalized)
    ? (normalized as 'draft' | 'published' | 'archived' | 'deprecated')
    : undefined;
}

function normalizeOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return undefined;
  }
  const normalized = value.trim();
  return normalized ? normalized : undefined;
}

function normalizeRequiredString(value: unknown, fieldName: string, maxLength: number) {
  if (typeof value !== 'string') {
    throw templateConfigInvalid(`${fieldName} 为必填项。`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw templateConfigInvalid(`${fieldName} 为必填项。`);
  }
  if (normalized.length > maxLength) {
    throw templateConfigInvalid(`${fieldName} 长度超出限制。`);
  }
  return normalized;
}

function normalizePositiveInt(value: unknown, defaultValue: number, maxValue: number) {
  if (value === undefined || value === null || value === '') {
    return defaultValue;
  }
  const parsed = typeof value === 'number' ? value : Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > maxValue) {
    throw templateConfigInvalid('page/pageSize 必须是有效正整数。');
  }
  return parsed;
}

function normalizeBoolean(value: unknown, fieldName: string) {
  if (typeof value !== 'boolean') {
    throw templateConfigInvalid(`${fieldName} must be boolean.`);
  }
  return value;
}

function normalizeNumber(value: unknown, fieldName: string) {
  const parsed = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(parsed)) {
    throw templateConfigInvalid(`${fieldName} must be a finite number.`);
  }
  return parsed;
}

function normalizeArray(value: unknown, fieldName: string) {
  if (!Array.isArray(value)) {
    throw templateConfigInvalid(`${fieldName} must be an array.`);
  }
  return value;
}

function normalizeObject(value: unknown, fieldName: string) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw templateConfigInvalid(`${fieldName} must be an object.`);
  }
  return value as Record<string, unknown>;
}

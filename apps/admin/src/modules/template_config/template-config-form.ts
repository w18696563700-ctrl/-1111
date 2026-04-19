import type {
  ArchiveAdminTemplateConfigVersionPayload,
  CreateAdminTemplateConfigTemplatePayload,
  CreateAdminTemplateConfigVersionPayload,
  PublishAdminTemplateConfigVersionPayload,
  UpdateAdminTemplateConfigGroupingPayload
} from '../../core/server/admin-api-client';

export function readTemplateId(formData: FormData) {
  return readRequired(formData, 'templateId', 128);
}

export function readTemplateVersionId(formData: FormData) {
  return readRequired(formData, 'templateVersionId', 128);
}

export function buildCreateTemplatePayload(
  formData: FormData
): CreateAdminTemplateConfigTemplatePayload {
  return {
    templateKey: readRequired(formData, 'templateKey', 128),
    templateName: readRequired(formData, 'templateName', 128),
    description: readOptional(formData, 'description', 500),
    groupRef: readOptional(formData, 'groupRef', 128)
  };
}

export function buildCreateTemplateVersionPayload(
  formData: FormData
): CreateAdminTemplateConfigVersionPayload {
  return {
    schema: readJsonObject(formData, 'schemaJson'),
    fields: readJsonArray(formData, 'fieldsJson'),
    rule: {
      templateRuleId: readRequired(formData, 'templateRuleId', 128),
      ruleVersionId: readRequired(formData, 'ruleVersionId', 128),
      assignmentRefs: readAssignmentRefs(formData)
    }
  };
}

export function buildPublishTemplateVersionPayload(
  formData: FormData
): PublishAdminTemplateConfigVersionPayload {
  return {
    publishNote: readOptional(formData, 'publishNote', 500)
  };
}

export function buildArchiveTemplateVersionPayload(
  formData: FormData
): ArchiveAdminTemplateConfigVersionPayload {
  return {
    archiveReason: readOptional(formData, 'archiveReason', 500)
  };
}

export function buildUpdateGroupingPayload(
  formData: FormData
): UpdateAdminTemplateConfigGroupingPayload {
  return {
    groupRef: readOptional(formData, 'groupRef', 128)
  };
}

function readAssignmentRefs(formData: FormData) {
  const raw = readOptional(formData, 'assignmentRefsText', 500) ?? '';
  return raw
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function readJsonObject(formData: FormData, key: string) {
  const parsed = readJson(formData, key);
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error(`${key} 必须是 JSON object。`);
  }
  return parsed as Record<string, unknown>;
}

function readJsonArray(formData: FormData, key: string) {
  const parsed = readJson(formData, key);
  if (!Array.isArray(parsed)) {
    throw new Error(`${key} 必须是 JSON array。`);
  }
  return parsed as Array<{
    fieldKey: string;
    fieldType: string;
    required: boolean;
    defaultValue: unknown;
    displayOrder: number;
  }>;
}

function readJson(formData: FormData, key: string) {
  const value = readRequired(formData, key, 4000);
  try {
    return JSON.parse(value) as unknown;
  } catch {
    throw new Error(`${key} 必须是合法 JSON。`);
  }
}

function readRequired(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function readOptional(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    return null;
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

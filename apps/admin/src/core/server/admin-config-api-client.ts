import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type TemplateConfigStatus = 'draft' | 'published' | 'archived' | 'deprecated';

export type AdminTemplateConfigField = {
  fieldKey: string;
  fieldType: string;
  required: boolean;
  defaultValue: unknown;
  displayOrder: number;
};

export type AdminTemplateConfigRule = {
  templateRuleId: string;
  ruleVersionId: string;
  assignmentRefs: string[];
};

export type AdminTemplateConfigTemplateListItem = {
  templateId: string;
  templateKey: string;
  templateName: string;
  groupRef: string | null;
  activeVersionId: string | null;
  status: TemplateConfigStatus;
  updatedAt: string;
};

export type AdminTemplateConfigTemplateDetail = AdminTemplateConfigTemplateListItem & {
  description: string | null;
  publishedVersionCount: number;
  createdAt: string;
};

export type AdminTemplateConfigVersionListItem = {
  templateVersionId: string;
  versionNo: number;
  status: TemplateConfigStatus;
  ruleVersionId: string;
  publishedAt: string | null;
  archivedAt: string | null;
  createdAt: string;
};

export type AdminTemplateConfigVersionDetail = {
  templateVersionId: string;
  templateId: string;
  versionNo: number;
  status: TemplateConfigStatus;
  schema: Record<string, unknown>;
  fields: AdminTemplateConfigField[];
  rule: AdminTemplateConfigRule;
  publishedAt: string | null;
  archivedAt: string | null;
  createdAt: string;
};

export type AdminTemplateConfigCompareResponse = {
  baseVersion: {
    templateVersionId: string;
    versionNo: number;
  };
  targetVersion: {
    templateVersionId: string;
    versionNo: number;
  };
  fieldDiff: {
    schemaChanged: boolean;
    schemaBefore: Record<string, unknown>;
    schemaAfter: Record<string, unknown>;
    addedFields: AdminTemplateConfigField[];
    removedFields: AdminTemplateConfigField[];
    changedFields: Array<{
      fieldKey: string;
      baseField: AdminTemplateConfigField;
      targetField: AdminTemplateConfigField;
    }>;
  };
  ruleDiff: {
    templateRuleIdChanged: boolean;
    ruleVersionIdChanged: boolean;
    assignmentRefsAdded: string[];
    assignmentRefsRemoved: string[];
  };
  groupingDiff: {
    baseGroupRef: string | null;
    targetGroupRef: string | null;
    changed: boolean;
  };
};

export type AdminTemplateConfigTemplateListResponse = {
  items: AdminTemplateConfigTemplateListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
  };
};

export type AdminTemplateConfigVersionListResponse = {
  items: AdminTemplateConfigVersionListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
  };
};

export type CreateAdminTemplateConfigTemplatePayload = {
  templateKey: string;
  templateName: string;
  description?: string | null;
  groupRef?: string | null;
};

export type CreateAdminTemplateConfigVersionPayload = {
  schema: Record<string, unknown>;
  fields: AdminTemplateConfigField[];
  rule: AdminTemplateConfigRule;
};

export type PublishAdminTemplateConfigVersionPayload = {
  publishNote?: string | null;
};

export type ArchiveAdminTemplateConfigVersionPayload = {
  archiveReason?: string | null;
};

export type UpdateAdminTemplateConfigGroupingPayload = {
  groupRef?: string | null;
};

export async function fetchAdminTemplateConfigs(query: {
  status?: TemplateConfigStatus;
  groupRef?: string;
  keyword?: string;
  page?: number;
  pageSize?: number;
} = {}) {
  return adminJsonRequest<AdminTemplateConfigTemplateListResponse>(
    `/config/templates${toQueryString(query)}`
  );
}

export async function fetchAdminTemplateConfigTemplate(templateId: string) {
  return adminJsonRequest<AdminTemplateConfigTemplateDetail>(
    `/config/templates/${encodeURIComponent(templateId)}`
  );
}

export async function fetchAdminTemplateConfigVersions(
  templateId: string,
  query: { page?: number; pageSize?: number } = {}
) {
  return adminJsonRequest<AdminTemplateConfigVersionListResponse>(
    `/config/templates/${encodeURIComponent(templateId)}/versions${toQueryString(query)}`
  );
}

export async function fetchAdminTemplateConfigVersion(
  templateId: string,
  templateVersionId: string
) {
  return adminJsonRequest<AdminTemplateConfigVersionDetail>(
    `/config/templates/${encodeURIComponent(templateId)}/versions/${encodeURIComponent(templateVersionId)}`
  );
}

export async function compareAdminTemplateConfigVersions(
  templateId: string,
  query: { baseVersionId: string; targetVersionId: string }
) {
  return adminJsonRequest<AdminTemplateConfigCompareResponse>(
    `/config/templates/${encodeURIComponent(templateId)}/versions/compare${toQueryString(query)}`
  );
}

export async function createAdminTemplateConfigTemplate(
  payload: CreateAdminTemplateConfigTemplatePayload
) {
  return adminJsonRequest<AdminTemplateConfigTemplateDetail>('/config/templates', {
    method: 'POST',
    body: payload
  });
}

export async function createAdminTemplateConfigVersion(
  templateId: string,
  payload: CreateAdminTemplateConfigVersionPayload
) {
  return adminJsonRequest<AdminTemplateConfigVersionDetail>(
    `/config/templates/${encodeURIComponent(templateId)}/versions`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function publishAdminTemplateConfigVersion(
  templateId: string,
  templateVersionId: string,
  payload: PublishAdminTemplateConfigVersionPayload
) {
  return adminJsonRequest<{
    template: AdminTemplateConfigTemplateDetail;
    version: AdminTemplateConfigVersionDetail;
  }>(
    `/config/templates/${encodeURIComponent(templateId)}/versions/${encodeURIComponent(
      templateVersionId
    )}/publish`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function archiveAdminTemplateConfigVersion(
  templateId: string,
  templateVersionId: string,
  payload: ArchiveAdminTemplateConfigVersionPayload
) {
  return adminJsonRequest<{
    template: AdminTemplateConfigTemplateDetail;
    version: AdminTemplateConfigVersionDetail;
  }>(
    `/config/templates/${encodeURIComponent(templateId)}/versions/${encodeURIComponent(
      templateVersionId
    )}/archive`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function updateAdminTemplateConfigGrouping(
  templateId: string,
  payload: UpdateAdminTemplateConfigGroupingPayload
) {
  return adminJsonRequest<AdminTemplateConfigTemplateDetail>(
    `/config/templates/${encodeURIComponent(templateId)}/grouping`,
    {
      method: 'POST',
      body: payload
    }
  );
}

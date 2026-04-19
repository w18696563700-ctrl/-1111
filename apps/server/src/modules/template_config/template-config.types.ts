export type TemplateConfigTemplateStatus = 'draft' | 'published' | 'archived' | 'deprecated';
export type TemplateConfigVersionStatus = 'draft' | 'published' | 'archived' | 'deprecated';

export type TemplateConfigField = {
  fieldKey: string;
  fieldType: string;
  required: boolean;
  defaultValue: unknown;
  displayOrder: number;
};

export type TemplateConfigRule = {
  templateRuleId: string;
  ruleVersionId: string;
  assignmentRefs: string[];
};

export type TemplateConfigListQuery = {
  status?: TemplateConfigTemplateStatus;
  groupRef?: string;
  keyword?: string;
  page: number;
  pageSize: number;
};

export type TemplateConfigVersionListQuery = {
  page: number;
  pageSize: number;
};

export type TemplateConfigCreateTemplateCommand = {
  templateKey: string;
  templateName: string;
  description: string | null;
  groupRef: string | null;
};

export type TemplateConfigCreateVersionCommand = {
  schema: Record<string, unknown>;
  fields: TemplateConfigField[];
  rule: TemplateConfigRule;
};

export type TemplateConfigPublishCommand = {
  publishNote: string | null;
};

export type TemplateConfigArchiveCommand = {
  archiveReason: string | null;
};

export type TemplateConfigGroupingCommand = {
  groupRef: string | null;
};

export type TemplateConfigTemplateRecord = {
  templateId: string;
  templateKey: string;
  templateName: string;
  description: string | null;
  groupRef: string | null;
  status: TemplateConfigTemplateStatus;
  activeVersionId: string | null;
  publishedVersionCount: number;
  createdAt: Date;
  updatedAt: Date;
  versionIds: string[];
};

export type TemplateConfigTemplateVersionRecord = {
  templateVersionId: string;
  templateId: string;
  versionNo: number;
  status: TemplateConfigVersionStatus;
  schema: Record<string, unknown>;
  fields: TemplateConfigField[];
  rule: TemplateConfigRule;
  groupRefSnapshot: string | null;
  publishedAt: Date | null;
  archivedAt: Date | null;
  publishNote: string | null;
  archiveReason: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export type TemplateConfigCompareProjection = {
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
    addedFields: TemplateConfigField[];
    removedFields: TemplateConfigField[];
    changedFields: Array<{
      fieldKey: string;
      baseField: TemplateConfigField;
      targetField: TemplateConfigField;
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

export type TemplateConfigTemplateListItem = {
  templateId: string;
  templateKey: string;
  templateName: string;
  groupRef: string | null;
  activeVersionId: string | null;
  status: TemplateConfigTemplateStatus;
  updatedAt: Date;
};

export type TemplateConfigTemplateDetail = TemplateConfigTemplateListItem & {
  description: string | null;
  publishedVersionCount: number;
  createdAt: Date;
};

export type TemplateConfigVersionListItem = {
  templateVersionId: string;
  versionNo: number;
  status: TemplateConfigVersionStatus;
  ruleVersionId: string;
  publishedAt: Date | null;
  archivedAt: Date | null;
  createdAt: Date;
};

export type TemplateConfigVersionDetail = {
  templateVersionId: string;
  templateId: string;
  versionNo: number;
  status: TemplateConfigVersionStatus;
  schema: Record<string, unknown>;
  fields: TemplateConfigField[];
  rule: TemplateConfigRule;
  publishedAt: Date | null;
  archivedAt: Date | null;
  createdAt: Date;
};

export type TemplateConfigCreateTemplateResult = {
  template: TemplateConfigTemplateRecord;
};

export type TemplateConfigCreateVersionResult = {
  template: TemplateConfigTemplateRecord;
  version: TemplateConfigTemplateVersionRecord;
};

export type TemplateConfigLifecycleResult = {
  template: TemplateConfigTemplateRecord;
  version: TemplateConfigTemplateVersionRecord;
};

export type TemplateConfigGroupingResult = {
  template: TemplateConfigTemplateRecord;
};

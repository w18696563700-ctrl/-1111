import {
  AdminApiError,
  AdminTemplateConfigCompareResponse,
  AdminTemplateConfigTemplateDetail,
  AdminTemplateConfigTemplateListItem,
  AdminTemplateConfigVersionDetail,
  AdminTemplateConfigVersionListItem,
  TemplateConfigStatus,
  compareAdminTemplateConfigVersions,
  fetchAdminTemplateConfigTemplate,
  fetchAdminTemplateConfigVersion,
  fetchAdminTemplateConfigVersions,
  fetchAdminTemplateConfigs
} from '../../core/server/admin-api-client';

type TemplateConfigClient = {
  fetchTemplates: typeof fetchAdminTemplateConfigs;
  fetchTemplate: typeof fetchAdminTemplateConfigTemplate;
  fetchVersions: typeof fetchAdminTemplateConfigVersions;
  fetchVersion: typeof fetchAdminTemplateConfigVersion;
  compareVersions: typeof compareAdminTemplateConfigVersions;
};

export type TemplateConfigShellState = {
  items: AdminTemplateConfigTemplateListItem[];
  template: AdminTemplateConfigTemplateDetail | null;
  versions: AdminTemplateConfigVersionListItem[];
  version: AdminTemplateConfigVersionDetail | null;
  compare: AdminTemplateConfigCompareResponse | null;
  total: number;
  selectedTemplateId: string | null;
  selectedTemplateVersionId: string | null;
  baseVersionId: string | null;
  targetVersionId: string | null;
  error: string | null;
};

const DEFAULT_CLIENT: TemplateConfigClient = {
  fetchTemplates: fetchAdminTemplateConfigs,
  fetchTemplate: fetchAdminTemplateConfigTemplate,
  fetchVersions: fetchAdminTemplateConfigVersions,
  fetchVersion: fetchAdminTemplateConfigVersion,
  compareVersions: compareAdminTemplateConfigVersions
};

const STATUS_OPTIONS: TemplateConfigStatus[] = ['draft', 'published', 'archived', 'deprecated'];

export async function loadTemplateConfigState(
  input: {
    selectedTemplateId?: string;
    selectedTemplateVersionId?: string;
    baseVersionId?: string;
    targetVersionId?: string;
    status?: string;
    groupRef?: string;
    keyword?: string;
  },
  client: TemplateConfigClient = DEFAULT_CLIENT
): Promise<TemplateConfigShellState> {
  try {
    const list = await client.fetchTemplates({
      status: readTemplateConfigStatus(input.status),
      groupRef: readOptionalFilter(input.groupRef),
      keyword: readOptionalFilter(input.keyword),
      page: 1,
      pageSize: 20
    });
    const selectedTemplateId = input.selectedTemplateId ?? list.items[0]?.templateId ?? null;
    if (!selectedTemplateId) {
      return {
        items: list.items,
        template: null,
        versions: [],
        version: null,
        compare: null,
        total: list.pagination.total,
        selectedTemplateId: null,
        selectedTemplateVersionId: null,
        baseVersionId: null,
        targetVersionId: null,
        error: null
      };
    }

    const template = await client.fetchTemplate(selectedTemplateId);
    const versions = await client.fetchVersions(selectedTemplateId, { page: 1, pageSize: 20 });
    const selectedTemplateVersionId =
      input.selectedTemplateVersionId ?? versions.items[0]?.templateVersionId ?? null;
    const version = selectedTemplateVersionId
      ? await client.fetchVersion(selectedTemplateId, selectedTemplateVersionId)
      : null;
    const comparePair = resolveComparePair(
      input.baseVersionId,
      input.targetVersionId,
      versions.items
    );
    const compare =
      comparePair.baseVersionId && comparePair.targetVersionId
        ? await client.compareVersions(selectedTemplateId, comparePair)
        : null;

    return {
      items: list.items,
      template,
      versions: versions.items,
      version,
      compare,
      total: list.pagination.total,
      selectedTemplateId,
      selectedTemplateVersionId,
      baseVersionId: comparePair.baseVersionId ?? null,
      targetVersionId: comparePair.targetVersionId ?? null,
      error: null
    };
  } catch (error) {
    return {
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
      error: toTemplateConfigLoadError(error)
    };
  }
}

export function readTemplateConfigStatus(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as TemplateConfigStatus)
    ? (value as TemplateConfigStatus)
    : undefined;
}

export function toTemplateConfigLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '无法从服务端管理接口加载模板治理台。';
}

function resolveComparePair(
  baseVersionId: string | undefined,
  targetVersionId: string | undefined,
  versions: AdminTemplateConfigVersionListItem[]
) {
  const normalizedBaseVersionId = readOptionalFilter(baseVersionId);
  const normalizedTargetVersionId = readOptionalFilter(targetVersionId);
  if (normalizedBaseVersionId && normalizedTargetVersionId) {
    return {
      baseVersionId: normalizedBaseVersionId,
      targetVersionId: normalizedTargetVersionId
    };
  }
  if (versions.length < 2) {
    return {
      baseVersionId: null,
      targetVersionId: null
    };
  }
  return {
    baseVersionId: versions[1].templateVersionId,
    targetVersionId: versions[0].templateVersionId
  };
}

function readOptionalFilter(value: string | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : undefined;
}

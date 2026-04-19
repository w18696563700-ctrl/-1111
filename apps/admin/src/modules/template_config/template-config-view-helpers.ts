export type TemplateConfigViewFilters = {
  selectedTemplateVersionId?: string;
  status?: string;
  groupRef?: string;
  keyword?: string;
};

export function buildTemplateHref(templateId: string, filters: TemplateConfigViewFilters) {
  const params = new URLSearchParams();
  params.set('templateId', templateId);
  appendFilterParams(params, filters);
  return `/template_config?${params.toString()}`;
}

export function buildVersionHref(
  templateId: string,
  templateVersionId: string,
  filters: TemplateConfigViewFilters
) {
  const params = new URLSearchParams();
  params.set('templateId', templateId);
  params.set('templateVersionId', templateVersionId);
  appendFilterParams(params, filters);
  return `/template_config?${params.toString()}`;
}

export function toNoticeText(notice: string) {
  switch (notice) {
    case 'template_created':
      return 'template identity 已创建。';
    case 'template_version_created':
      return 'draft version 已创建。';
    case 'template_version_published':
      return 'version 已发布。';
    case 'template_version_archived':
      return 'version 已归档。';
    case 'template_grouping_updated':
      return 'groupRef 已更新。';
    default:
      return notice;
  }
}

export function formatDate(value: string | null) {
  if (!value) {
    return '暂无';
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString('zh-CN', { hour12: false });
}

function appendFilterParams(params: URLSearchParams, filters: TemplateConfigViewFilters) {
  if (filters.status?.trim()) {
    params.set('status', filters.status.trim());
  }
  if (filters.groupRef?.trim()) {
    params.set('groupRef', filters.groupRef.trim());
  }
  if (filters.keyword?.trim()) {
    params.set('keyword', filters.keyword.trim());
  }
}

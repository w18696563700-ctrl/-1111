import {
  AdminApiError,
  AdminExhibitionReportCaseDetail,
  AdminExhibitionReportCaseListItem,
  ExhibitionReportCaseStatus,
  ExhibitionReportTargetType,
  fetchExhibitionReportCase,
  fetchExhibitionReportCases
} from '../../core/server/admin-api-client';

type ProjectReviewClient = {
  fetchList: typeof fetchExhibitionReportCases;
  fetchDetail: typeof fetchExhibitionReportCase;
};

export type ProjectReviewShellState = {
  items: AdminExhibitionReportCaseListItem[];
  detail: AdminExhibitionReportCaseDetail | null;
  total: number;
  error: string | null;
};

const DEFAULT_CLIENT: ProjectReviewClient = {
  fetchList: fetchExhibitionReportCases,
  fetchDetail: fetchExhibitionReportCase
};

const STATUS_OPTIONS: ExhibitionReportCaseStatus[] = [
  'submitted',
  'under_review',
  'explanation_requested',
  'escalated',
  'decided',
  'closed'
];

const TARGET_TYPE_OPTIONS: ExhibitionReportTargetType[] = [
  'project',
  'project_profile',
  'bid',
  'contract',
  'inspection'
];

export async function loadProjectReviewState(
  input: {
    selectedReportCaseId?: string;
    status?: string;
    targetType?: string;
    keyword?: string;
  },
  client: ProjectReviewClient = DEFAULT_CLIENT
): Promise<ProjectReviewShellState> {
  try {
    const list = await client.fetchList({
      page: 1,
      pageSize: 20,
      status: readProjectReviewStatus(input.status),
      targetType: readProjectReviewTargetType(input.targetType),
      keyword: input.keyword?.trim() || undefined
    });
    const reportCaseId = input.selectedReportCaseId ?? list.items[0]?.reportCaseId;
    const detail = reportCaseId ? await client.fetchDetail(reportCaseId) : null;
    return {
      items: list.items,
      detail,
      total: list.pagination.total,
      error: null
    };
  } catch (error) {
    return {
      items: [],
      detail: null,
      total: 0,
      error: toProjectReviewLoadError(error)
    };
  }
}

export function readProjectReviewStatus(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as ExhibitionReportCaseStatus)
    ? (value as ExhibitionReportCaseStatus)
    : undefined;
}

export function readProjectReviewTargetType(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return TARGET_TYPE_OPTIONS.includes(value as ExhibitionReportTargetType)
    ? (value as ExhibitionReportTargetType)
    : undefined;
}

export function toProjectReviewLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '无法从服务端管理接口加载举报案件台。';
}

import { ProjectEntity } from '../project/entities/project.entity';

export const PROJECT_NAME_ACCESS_MASKED_TITLE = '项目名称需申请查看';
export const PROJECT_NAME_ACCESS_THREAD_TYPE = 'project_name_access_review';

export function buildProjectDisplayTitle(project: Pick<ProjectEntity, 'title' | 'exhibitionName'>) {
  const exhibitionName = normalizeText(project.exhibitionName);
  if (exhibitionName) {
    return exhibitionName;
  }
  return normalizeText(project.title) || '未命名项目';
}

export function buildProjectNameAccessThreadRouteTarget(input: {
  threadId: string;
  projectId: string;
  requestId: string;
}) {
  return {
    objectType: 'project_name_access_thread',
    actionKey: 'project_name_access_thread.open',
    canonicalPath: '/api/app/project/name-access/thread/detail',
    params: {
      threadId: input.threadId,
      projectId: input.projectId,
      requestId: input.requestId,
    },
  };
}

export function buildProjectNameAccessSeedSummary(input: {
  displayName: string;
  state: 'pending' | 'approved' | 'rejected';
}): {
  seedType:
    | 'project_name_access_requested'
    | 'project_name_access_approved'
    | 'project_name_access_rejected';
  title: string;
  summary: string;
  ctaLabel: string;
} {
  const counterpart = normalizeText(input.displayName) || '当前组织';
  if (input.state === 'approved') {
    return {
      seedType: 'project_name_access_approved',
      title: '项目名称查看申请已通过',
      summary: `${counterpart} 的项目名称查看申请已通过。`,
      ctaLabel: '查看结果',
    };
  }
  if (input.state === 'rejected') {
    return {
      seedType: 'project_name_access_rejected',
      title: '项目名称查看申请已拒绝',
      summary: `${counterpart} 的项目名称查看申请已被拒绝。`,
      ctaLabel: '查看结果',
    };
  }
  return {
    seedType: 'project_name_access_requested',
    title: '新的项目名称查看申请',
    summary: `${counterpart} 申请查看当前项目名称。`,
    ctaLabel: '查看申请',
  };
}

export function buildProjectNameAccessThreadSummary(input: {
  requesterOrganizationName: string;
  state: 'pending' | 'approved' | 'rejected';
}) {
  const requester = normalizeText(input.requesterOrganizationName) || '当前组织';
  if (input.state === 'approved') {
    return `${requester} 的项目名称查看申请已通过。`;
  }
  if (input.state === 'rejected') {
    return `${requester} 的项目名称查看申请已拒绝。`;
  }
  return `${requester} 申请查看当前项目名称。`;
}

function normalizeText(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized || null;
}

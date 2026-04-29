import { ProjectEntity } from '../project/entities/project.entity';

export const BID_PARTICIPATION_MASKED_TITLE = '项目名称需申请查看';
export const BID_PARTICIPATION_THREAD_TYPE = 'bid_participation_review';

export function buildBidParticipationDisplayTitle(project: Pick<ProjectEntity, 'title' | 'exhibitionName'>) {
  const exhibitionName = normalizeText(project.exhibitionName);
  if (exhibitionName) {
    return exhibitionName;
  }
  return normalizeText(project.title) || '未命名项目';
}

export function buildBidParticipationThreadRouteTarget(input: {
  threadId: string;
  projectId: string;
  requestId: string;
}) {
  return {
    objectType: 'bid_participation_request',
    actionKey: 'bid_participation_request.open',
    canonicalPath: '/api/app/project/bid-participation/thread/detail',
    params: {
      threadId: input.threadId,
      projectId: input.projectId,
      requestId: input.requestId,
    },
  };
}

export function buildBidParticipationSubmitRouteTarget(input: { projectId: string }) {
  return {
    objectType: 'bid_submit',
    actionKey: 'bid_submit.open',
    canonicalPath: '/api/app/bid/submit',
    params: {
      projectId: input.projectId,
    },
  };
}

export function buildBidParticipationThreadSummary(input: {
  requesterOrganizationName: string;
  state: 'pending' | 'approved' | 'rejected';
}) {
  const requester = normalizeText(input.requesterOrganizationName) || '当前组织';
  if (input.state === 'approved') {
    return `${requester} 的参与竞标申请已通过，可继续提交竞标。`;
  }
  if (input.state === 'rejected') {
    return `${requester} 的参与竞标申请已拒绝。`;
  }
  return `${requester} 申请参与当前项目竞标。`;
}

function normalizeText(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized || null;
}


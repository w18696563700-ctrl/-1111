export const TRADING_IM_MESSAGE_KIND_ACTOR = 'actor_message';
export const TRADING_IM_MESSAGE_KIND_SYSTEM_SEED = 'system_seed';
export const TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED = 'bid_submitted';

export function buildBidThreadRouteTarget(input: {
  threadId: string;
  projectId: string;
  bidId: string;
}) {
  return {
    objectType: 'bid_thread',
    actionKey: 'bid_thread.open',
    canonicalPath: '/api/app/bid/thread/detail',
    params: {
      threadId: input.threadId,
      projectId: input.projectId,
      bidId: input.bidId,
    },
  };
}

export function buildBidSubmissionSnapshotAction(input: { projectId: string; bidId: string }) {
  return {
    objectType: 'bid_submission_snapshot',
    actionKey: 'bid_submission_snapshot.open',
    canonicalPath: '/api/app/bid/submission/snapshot',
    params: {
      projectId: input.projectId,
      bidId: input.bidId,
    },
  };
}

export function buildBidSubmittedSeedBody(
  bidderDisplayName: string,
  submittedAt?: Date | null,
) {
  const normalizedDisplayName = bidderDisplayName.trim() || '当前竞标方';
  const submittedAtText =
    submittedAt instanceof Date && !Number.isNaN(submittedAt.getTime())
      ? submittedAt.toISOString()
      : null;
  return submittedAtText
    ? `${normalizedDisplayName} 已提交竞标，提交时间 ${submittedAtText}。可点击查看本次竞标摘要。`
    : `${normalizedDisplayName} 已提交竞标，可点击查看本次竞标摘要。`;
}

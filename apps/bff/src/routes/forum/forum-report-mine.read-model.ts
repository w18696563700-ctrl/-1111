type ServerForumReportListResponse = {
  items?: unknown;
  count?: unknown;
  traceId?: unknown;
};

type ServerForumReportItem = {
  ticketId?: unknown;
  targetType?: unknown;
  targetId?: unknown;
  reasonCode?: unknown;
  reasonDetail?: unknown;
  status?: unknown;
  submittedAt?: unknown;
  updatedAt?: unknown;
  targetSnapshot?: unknown;
};

export type ForumReportTargetSnapshotView = Record<string, string | null>;

export type ForumReportMineItemView = {
  ticketId: string;
  targetType: string;
  targetTypeLabel: string;
  targetId: string;
  targetSummary: string;
  reasonCode: string;
  reasonLabel: string;
  reasonDetail: string | null;
  status: string;
  statusLabel: string;
  submittedAt: string;
  updatedAt: string;
  targetSnapshot: ForumReportTargetSnapshotView;
};

export type ForumReportMineListView = {
  items: ForumReportMineItemView[];
  count: number;
  traceId: string | null;
};

export type ForumReportMineDetailView = ForumReportMineItemView;

export function shapeForumReportMineList(result: Record<string, unknown>): ForumReportMineListView {
  const body = result as ServerForumReportListResponse;
  const items = Array.isArray(body.items) ? body.items : [];
  const shapedItems = items.map((item) => shapeForumReportMineItem(item));
  return {
    items: shapedItems,
    count: readCount(body.count, shapedItems.length),
    traceId: readNullableString(body.traceId),
  };
}

export function shapeForumReportMineDetail(result: Record<string, unknown>): ForumReportMineDetailView {
  return shapeForumReportMineItem(result);
}

function shapeForumReportMineItem(raw: unknown): ForumReportMineItemView {
  const item = asRecord(raw) as ServerForumReportItem;
  const ticketId = readRequiredString(item.ticketId, 'forum report ticketId is missing');
  const targetType = readRequiredString(item.targetType, 'forum report targetType is missing');
  const targetId = readRequiredString(item.targetId, 'forum report targetId is missing');
  const reasonCode = readRequiredString(item.reasonCode, 'forum report reasonCode is missing');
  const status = readRequiredString(item.status, 'forum report status is missing');
  const submittedAt = readRequiredString(item.submittedAt, 'forum report submittedAt is missing');
  const updatedAt = readRequiredString(item.updatedAt, 'forum report updatedAt is missing');
  const targetSnapshot = shapeTargetSnapshot(targetType, targetId, item.targetSnapshot);

  return {
    ticketId,
    targetType,
    targetTypeLabel: labelTargetType(targetType),
    targetId,
    targetSummary: summarizeTarget(targetType, targetSnapshot),
    reasonCode,
    reasonLabel: labelReason(reasonCode),
    reasonDetail: readNullableString(item.reasonDetail),
    status,
    statusLabel: labelStatus(status),
    submittedAt,
    updatedAt,
    targetSnapshot,
  };
}

function shapeTargetSnapshot(
  targetType: string,
  targetId: string,
  raw: unknown,
): ForumReportTargetSnapshotView {
  const snapshot = asRecord(raw);
  if (targetType === 'post') {
    return compactRecord({
      targetType: 'post',
      postId: readNullableString(snapshot.postId) ?? targetId,
      topicId: readNullableString(snapshot.topicId),
      title: readNullableString(snapshot.title),
      excerpt: readNullableString(snapshot.excerpt),
      publishedAt: readNullableString(snapshot.publishedAt),
    });
  }
  if (targetType === 'comment') {
    return compactRecord({
      targetType: 'comment',
      commentId: readNullableString(snapshot.commentId) ?? targetId,
      postId: readNullableString(snapshot.postId),
      parentCommentId: readNullableString(snapshot.parentCommentId),
      bodyPreview: readNullableString(snapshot.bodyPreview),
      publishedAt: readNullableString(snapshot.publishedAt),
    });
  }
  return compactRecord({ targetType, targetId });
}

function summarizeTarget(targetType: string, snapshot: ForumReportTargetSnapshotView): string {
  if (targetType === 'post') {
    return snapshot.title ?? snapshot.excerpt ?? '帖子内容';
  }
  if (targetType === 'comment') {
    return snapshot.bodyPreview ?? '评论内容';
  }
  return '举报内容';
}

function labelTargetType(targetType: string): string {
  if (targetType === 'post') {
    return '帖子';
  }
  if (targetType === 'comment') {
    return '评论';
  }
  return '内容';
}

function labelReason(reasonCode: string): string {
  const labels: Record<string, string> = {
    ad_or_solicitation: '广告或导流',
    abuse_or_insult: '辱骂或人身攻击',
    flamebait_or_conflict: '引战或恶意争吵',
    spam_or_flood: '刷屏或垃圾内容',
    plagiarism_or_repost: '抄袭或重复搬运',
    other: '其他问题',
  };
  return labels[reasonCode] ?? '其他问题';
}

function labelStatus(status: string): string {
  const labels: Record<string, string> = {
    submitted: '已提交，待平台处理',
    pending_review: '待平台处理',
    resolved: '已处理',
    rejected: '未采纳',
    closed: '已关闭',
  };
  return labels[status] ?? '处理中';
}

function readCount(value: unknown, fallback: number): number {
  if (typeof value === 'number' && Number.isInteger(value) && value >= 0) {
    return value;
  }
  return fallback;
}

function readRequiredString(value: unknown, message: string): string {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  throw new Error(message);
}

function readNullableString(value: unknown): string | null {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
}

function compactRecord(value: Record<string, string | null>): ForumReportTargetSnapshotView {
  return Object.fromEntries(Object.entries(value).filter(([, item]) => item !== null));
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
}

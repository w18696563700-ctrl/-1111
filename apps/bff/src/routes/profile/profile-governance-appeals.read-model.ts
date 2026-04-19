type ServerAppealPagination = {
  page?: unknown;
  pageSize?: unknown;
  total?: unknown;
  hasMore?: unknown;
};

type ServerAppealPenalty = {
  penaltyId?: unknown;
  penaltyType?: unknown;
  penaltyStatus?: unknown;
  reasonSummary?: unknown;
  effectiveFrom?: unknown;
  effectiveUntil?: unknown;
};

type ServerAppealListItem = {
  appealCaseId?: unknown;
  status?: unknown;
  submittedAt?: unknown;
  decidedAt?: unknown;
  penaltyId?: unknown;
  penaltyType?: unknown;
  penaltyStatus?: unknown;
  effectiveFrom?: unknown;
  effectiveUntil?: unknown;
};

type ServerAppealDetail = {
  appealCaseId?: unknown;
  status?: unknown;
  reason?: unknown;
  decision?: unknown;
  decisionNote?: unknown;
  evidenceFileAssetIds?: unknown;
  submittedAt?: unknown;
  decidedAt?: unknown;
  penalty?: unknown;
};

export type GovernanceAppealPenaltySummaryView = {
  penaltyId: string;
  penaltyType: string;
  penaltyTypeLabel: string;
  penaltyStatus: string;
  penaltyStatusLabel: string;
  reasonSummary: string | null;
  effectiveFrom: string | null;
  effectiveUntil: string | null;
};

export type GovernanceAppealListItemView = {
  appealCaseId: string;
  status: string;
  statusLabel: string;
  submittedAt: string;
  decidedAt: string | null;
  penalty: GovernanceAppealPenaltySummaryView;
};

export type GovernanceAppealListView = {
  items: GovernanceAppealListItemView[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type GovernanceAppealDetailView = {
  appealCaseId: string;
  status: string;
  statusLabel: string;
  appealReason: string | null;
  decision: string | null;
  decisionLabel: string | null;
  decisionNote: string | null;
  evidenceFileAssetIds: string[];
  submittedAt: string;
  decidedAt: string | null;
  penalty: GovernanceAppealPenaltySummaryView;
};

export function readGovernanceAppealListViewModel(value: Record<string, unknown>): GovernanceAppealListView {
  const items = Array.isArray(value.items)
    ? value.items.map((item) => readGovernanceAppealListItem(asRecord(item)))
    : [];
  const pagination = readPagination(asRecord(value.pagination), items.length);
  return { items, pagination };
}

export function readGovernanceAppealDetailViewModel(
  value: Record<string, unknown>,
): GovernanceAppealDetailView {
  const source = value as ServerAppealDetail;
  const appealCaseId = readRequiredString(source.appealCaseId, 'appealCaseId');
  const status = readRequiredString(source.status, 'status');
  const submittedAt = readRequiredString(source.submittedAt, 'submittedAt');
  return {
    appealCaseId,
    status,
    statusLabel: labelAppealStatus(status),
    appealReason: readNullableString(source.reason),
    decision: readNullableString(source.decision),
    decisionLabel: labelAppealDecision(readNullableString(source.decision)),
    decisionNote: readNullableString(source.decisionNote),
    evidenceFileAssetIds: readStringArray(source.evidenceFileAssetIds),
    submittedAt,
    decidedAt: readNullableString(source.decidedAt),
    penalty: readPenaltySummary(asRecord(source.penalty)),
  };
}

function readGovernanceAppealListItem(value: Record<string, unknown>): GovernanceAppealListItemView {
  const source = value as ServerAppealListItem;
  const appealCaseId = readRequiredString(source.appealCaseId, 'appealCaseId');
  const status = readRequiredString(source.status, 'status');
  const penaltyId = readRequiredString(source.penaltyId, 'penaltyId');
  const penaltyType = readRequiredString(source.penaltyType, 'penaltyType');
  const penaltyStatus = readRequiredString(source.penaltyStatus, 'penaltyStatus');
  const submittedAt = readRequiredString(source.submittedAt, 'submittedAt');

  return {
    appealCaseId,
    status,
    statusLabel: labelAppealStatus(status),
    submittedAt,
    decidedAt: readNullableString(source.decidedAt),
    penalty: {
      penaltyId,
      penaltyType,
      penaltyTypeLabel: labelPenaltyType(penaltyType),
      penaltyStatus,
      penaltyStatusLabel: labelPenaltyStatus(penaltyStatus),
      reasonSummary: null,
      effectiveFrom: readNullableString(source.effectiveFrom),
      effectiveUntil: readNullableString(source.effectiveUntil),
    },
  };
}

function readPenaltySummary(value: Record<string, unknown>): GovernanceAppealPenaltySummaryView {
  const penaltyId = readRequiredString(value.penaltyId, 'penalty.penaltyId');
  const penaltyType = readRequiredString(value.penaltyType, 'penalty.penaltyType');
  const penaltyStatus = readRequiredString(value.status, 'penalty.status');
  return {
    penaltyId,
    penaltyType,
    penaltyTypeLabel: labelPenaltyType(penaltyType),
    penaltyStatus,
    penaltyStatusLabel: labelPenaltyStatus(penaltyStatus),
    reasonSummary: readNullableString(value.reasonSummary),
    effectiveFrom: readNullableString(value.effectiveFrom),
    effectiveUntil: readNullableString(value.effectiveUntil),
  };
}

function readPagination(value: Record<string, unknown>, fallbackTotal: number) {
  return {
    page: readPositiveInt(value.page, 1),
    pageSize: readPositiveInt(value.pageSize, fallbackTotal || 20),
    total: readPositiveInt(value.total, fallbackTotal),
    hasMore: readBoolean(value.hasMore, false),
  };
}

function labelAppealStatus(status: string): string {
  const labels: Record<string, string> = {
    submitted: '已提交',
    under_review: '审核中',
    upheld: '维持原处罚',
    modified: '处罚已调整',
    revoked: '处罚已撤销',
    closed: '已关闭',
  };
  return labels[status] ?? '处理中';
}

function labelAppealDecision(decision: string | null): string | null {
  if (decision === 'uphold') {
    return '维持原处罚';
  }
  if (decision === 'modify') {
    return '处罚已调整';
  }
  if (decision === 'revoke') {
    return '处罚已撤销';
  }
  return null;
}

function labelPenaltyType(value: string): string {
  const labels: Record<string, string> = {
    warning: '警告提醒',
    watchlist: '观察名单',
    restrict_publish: '限制发布',
    restrict_bid: '限制接单',
    blacklist: '黑名单限制',
  };
  return labels[value] ?? '治理限制';
}

function labelPenaltyStatus(value: string): string {
  const labels: Record<string, string> = {
    active: '生效中',
    lifted: '已解除',
    expired: '已到期',
  };
  return labels[value] ?? '处理中';
}

function readRequiredString(value: unknown, field: string): string {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  throw new Error(`Governance appeal response is missing ${field}.`);
}

function readNullableString(value: unknown): string | null {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
}

function readStringArray(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0)
    : [];
}

function readPositiveInt(value: unknown, fallback: number): number {
  if (typeof value === 'number' && Number.isInteger(value) && value >= 0) {
    return value;
  }
  return fallback;
}

function readBoolean(value: unknown, fallback: boolean): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
}

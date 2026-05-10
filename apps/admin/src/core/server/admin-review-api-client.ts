import { adminJsonRequest } from './admin-api-runtime';

export type AdminReviewTaskType = 'profile_safety_submission' | 'forum_report_ticket';

export type AdminReviewTask = {
  taskId: string;
  taskType: AdminReviewTaskType;
  sourceTable: string;
  subjectId: string;
  subjectUserId?: string;
  status: string;
  fieldKey?: string;
  targetType?: string;
  targetId?: string;
  targetAuthorUserId?: string | null;
  submittedAt: string;
  updatedAt: string;
  allowedActions?: string[];
};

export type AdminReviewTaskDetail = AdminReviewTask & {
  currentValue?: string | null;
  proposedValue?: string | null;
  proposedFileAssetId?: string | null;
  proposedAvatarUrl?: string | null;
  engineType?: string;
  ruleDecision?: string;
  matchedRuleIds?: string[];
  rejectReasonCode?: string | null;
  rejectReason?: string | null;
  reviewedBy?: string | null;
  reviewedAt?: string | null;
  targetOrganizationId?: string | null;
  reporterUserId?: string;
  reporterActorId?: string;
  reporterOrganizationId?: string;
  reasonCode?: string;
  reasonDetail?: string | null;
  targetSnapshot?: Record<string, unknown>;
  viewOnlyReason?: string;
};

export type AdminForumReportDecision = 'resolved' | 'rejected' | 'closed';

export type AdminReviewTaskListResponse = {
  items: AdminReviewTask[];
  count: number;
  traceId: string;
};

export async function fetchContentSafetyReviewTasks() {
  return adminJsonRequest<AdminReviewTaskListResponse>('/content-safety/review-tasks');
}

export async function fetchContentSafetyReviewTask(taskId: string) {
  return adminJsonRequest<AdminReviewTaskDetail>(
    `/content-safety/review-tasks/${encodeURIComponent(taskId)}`
  );
}

export async function approveProfileSafetySubmission(
  submissionId: string,
  payload: { reviewNote?: string }
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/content-safety/profile-submissions/${encodeURIComponent(submissionId)}/approve`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function rejectProfileSafetySubmission(
  submissionId: string,
  payload: { reason: string }
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/content-safety/profile-submissions/${encodeURIComponent(submissionId)}/reject`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function decideForumReport(
  ticketId: string,
  payload: { decision: AdminForumReportDecision; reason: string }
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/content-safety/forum-reports/${encodeURIComponent(ticketId)}/decide`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function verifyAdminSessionCarrier(sessionCarrier: string) {
  return adminJsonRequest<AdminReviewTaskListResponse>(
    '/content-safety/review-tasks',
    {},
    {
      incomingHeaders: new Headers(),
      sessionCarrier
    }
  );
}

import { Injectable } from '@nestjs/common';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { ProfileSafetySubmissionEntity } from '../profile/entities/profile-safety-submission.entity';

const PROFILE_SAFETY_TASK_TYPE = 'profile_safety_submission';
const FORUM_REPORT_TASK_TYPE = 'forum_report_ticket';
const FORUM_VIEW_ONLY_REASON = 'forum_report_ticket_p0_view_only';

@Injectable()
export class ContentSafetyReviewTaskPresenter {
  toListResponse(
    items: Array<Record<string, unknown>>,
    traceId: string
  ) {
    return {
      items,
      count: items.length,
      traceId
    };
  }

  toProfileTaskListItem(submission: ProfileSafetySubmissionEntity) {
    return {
      taskId: this.buildTaskId(PROFILE_SAFETY_TASK_TYPE, submission.id),
      taskType: PROFILE_SAFETY_TASK_TYPE,
      sourceTable: 'profile_safety_submissions',
      subjectId: submission.id,
      subjectUserId: submission.userId,
      status: submission.status,
      fieldKey: submission.fieldKey,
      submittedAt: submission.createdAt.toISOString(),
      updatedAt: submission.updatedAt.toISOString(),
      allowedActions: this.toProfileAllowedActions(submission.status)
    };
  }

  toProfileTaskDetail(submission: ProfileSafetySubmissionEntity) {
    return {
      ...this.toProfileTaskListItem(submission),
      currentValue: submission.currentValue,
      proposedValue: submission.proposedValue,
      proposedFileAssetId: submission.proposedFileAssetId,
      proposedAvatarUrl: submission.proposedAvatarUrl,
      engineType: submission.engineType,
      ruleDecision: submission.ruleDecision,
      matchedRuleIds: submission.matchedRuleIds,
      rejectReasonCode: submission.rejectReasonCode,
      rejectReason: submission.rejectReason,
      reviewedBy: submission.reviewedBy,
      reviewedAt: submission.reviewedAt?.toISOString() ?? null
    };
  }

  toForumReportTaskListItem(ticket: ForumReportTicketEntity) {
    return {
      taskId: this.buildTaskId(FORUM_REPORT_TASK_TYPE, ticket.id),
      taskType: FORUM_REPORT_TASK_TYPE,
      sourceTable: 'forum_report_ticket',
      subjectId: ticket.id,
      status: ticket.status,
      targetType: ticket.targetType,
      targetId: ticket.targetId,
      targetAuthorUserId: ticket.targetAuthorUserId,
      submittedAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString(),
      allowedActions: []
    };
  }

  toForumReportTaskDetail(ticket: ForumReportTicketEntity) {
    return {
      ...this.toForumReportTaskListItem(ticket),
      targetOrganizationId: ticket.targetOrganizationId,
      reporterUserId: ticket.reporterUserId,
      reporterActorId: ticket.reporterActorId,
      reporterOrganizationId: ticket.reporterOrganizationId,
      reasonCode: ticket.reasonCode,
      reasonDetail: ticket.reasonDetail,
      targetSnapshot: ticket.targetSnapshot,
      viewOnlyReason: FORUM_VIEW_ONLY_REASON
    };
  }

  buildTaskId(taskType: string, subjectId: string) {
    return `${taskType}:${subjectId}`;
  }

  private toProfileAllowedActions(status: string) {
    return status === 'pending_review' ? ['approve', 'reject'] : [];
  }
}

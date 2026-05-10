import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import {
  VerifiedCurrentSessionContext,
  requireVerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProfileSafetyReviewService } from '../profile/profile-safety-review.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import {
  contentSafetyReviewTaskInvalid,
  contentSafetyReviewTaskInvalidState,
  contentSafetyReviewTaskUnavailable
} from '../review/review.errors';
import { ContentSafetyAuditService } from './content-safety-audit.service';

const FORUM_REPORT_ALLOWED_DECISIONS = new Set(['resolved', 'rejected', 'closed']);
const FORUM_REPORT_DECIDABLE_STATUSES = new Set(['submitted', 'pending_review']);

@Injectable()
export class ContentSafetyReviewTaskWriteService {
  constructor(
    private readonly profileSafetyReviewService: ProfileSafetyReviewService,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService
  ) {}

  approveProfileSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.profileSafetyReviewService.approveSubmission(submissionId, body, context);
  }

  rejectProfileSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.profileSafetyReviewService.rejectSubmission(submissionId, body, context);
  }

  async decideForumReport(
    ticketId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    const normalizedTicketId = readRequiredText(ticketId, 'ticketId', 64);
    const decision = readForumReportDecision(body.decision);
    const reason = readRequiredText(body.reason, 'reason', 500);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.requireManualReviewer(currentSession);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ForumReportTicketEntity);
      const ticket = await repository.findOneBy({ id: normalizedTicketId });
      if (!ticket) {
        throw contentSafetyReviewTaskUnavailable('Forum report ticket is unavailable.');
      }
      if (!FORUM_REPORT_DECIDABLE_STATUSES.has(ticket.status)) {
        throw contentSafetyReviewTaskInvalidState('Forum report ticket is not decidable.');
      }

      const previousStatus = ticket.status;
      ticket.status = decision;
      await repository.save(ticket);
      await this.auditService.record(
        {
          subjectType: 'forum_report_ticket',
          subjectId: ticket.id,
          userId: ticket.reporterUserId,
          actorId: currentSession.actorId,
          actorRole: readActorRole(reviewer),
          action: 'forum_report_decide',
          engineType: 'manual',
          decision,
          reasonCode: 'forum_report_decide',
          reason,
          metadata: {
            ticketId: ticket.id,
            targetType: ticket.targetType,
            targetId: ticket.targetId,
            previousStatus,
            nextStatus: decision
          }
        },
        context,
        manager
      );

      return {
        ok: true,
        ticketId: ticket.id,
        previousStatus,
        status: decision,
        traceId: context.traceId
      };
    });
  }

  private async requireManualReviewer(currentSession: VerifiedCurrentSessionContext) {
    const eligibilityService = this.eligibilityService as {
      requireManualReviewer?: (session: typeof currentSession) => Promise<unknown>;
      requireReviewer: (session: typeof currentSession) => Promise<unknown>;
    };
    if (eligibilityService.requireManualReviewer) {
      return eligibilityService.requireManualReviewer(currentSession);
    }
    return eligibilityService.requireReviewer(currentSession);
  }
}

function readForumReportDecision(value: unknown) {
  if (typeof value !== 'string' || !FORUM_REPORT_ALLOWED_DECISIONS.has(value)) {
    throw contentSafetyReviewTaskInvalid('Forum report decision is invalid.');
  }
  return value as 'resolved' | 'rejected' | 'closed';
}

function readRequiredText(value: unknown, field: string, maxLength: number) {
  if (typeof value !== 'string') {
    throw contentSafetyReviewTaskInvalid(`${field} is invalid.`);
  }
  const normalized = value.trim();
  if (!normalized || normalized.length > maxLength) {
    throw contentSafetyReviewTaskInvalid(`${field} is invalid.`);
  }
  return normalized;
}

function readActorRole(value: unknown) {
  if (!value || typeof value !== 'object' || !('actorRole' in value)) {
    return '';
  }
  const actorRole = (value as { actorRole?: unknown }).actorRole;
  return typeof actorRole === 'string' ? actorRole : '';
}

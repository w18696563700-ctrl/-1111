import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import {
  CONTENT_SAFETY_FORUM_REPORT_REASON_CODES,
  CONTENT_SAFETY_FORUM_REPORT_TARGET_TYPES,
  ContentSafetyForumReportReasonCode,
  ContentSafetyForumReportTargetType
} from '../content_safety/content-safety.constants';
import { ContentSafetySnapshotService } from '../content_safety/content-safety-snapshot.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';
import { forumPostUnavailable, forumReportInvalid } from './forum.errors';
import { ForumReportPresenter } from './forum-report.presenter';

type ForumReportCommand = {
  targetType: ContentSafetyForumReportTargetType;
  targetId: string;
  reasonCode: ContentSafetyForumReportReasonCode;
  reasonDetail: string | null;
};

type ForumReportTarget = {
  targetAuthorUserId: string | null;
  targetOrganizationId: string | null;
  targetSnapshot: Record<string, unknown>;
};

const REASON_CODE_SET = new Set<string>(CONTENT_SAFETY_FORUM_REPORT_REASON_CODES);
const TARGET_TYPE_SET = new Set<string>(CONTENT_SAFETY_FORUM_REPORT_TARGET_TYPES);
const REASON_DETAIL_MAX_LENGTH = 200;

@Injectable()
export class ForumReportService {
  constructor(
    @InjectRepository(ForumCommentEntity)
    private readonly commentRepository: Repository<ForumCommentEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly snapshotService: ContentSafetySnapshotService,
    private readonly presenter: ForumReportPresenter
  ) {}

  async submitReport(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumReportInvalid('organizationId is unavailable for forum report submit.');
    }

    const target = await this.loadReportTarget(command);
    const ticket = this.createTicket(command, {
      reporterUserId: currentSession.userId,
      reporterActorId: currentSession.actorId,
      reporterOrganizationId: scope.organization.id,
      target
    });

    const savedTicket = await this.dataSource.transaction(async (manager) => {
      const reportRepository = manager.getRepository(ForumReportTicketEntity);
      const persistedTicket = await reportRepository.save(ticket);
      const snapshot = await this.snapshotService.captureForumReportTarget(
        {
          reportTicketId: persistedTicket.id,
          reporterUserId: persistedTicket.reporterUserId,
          targetType: command.targetType,
          targetId: command.targetId,
          reasonCode: command.reasonCode,
          reasonDetail: command.reasonDetail,
          targetSnapshot: target.targetSnapshot
        },
        manager
      );
      await this.auditService.record(
        {
          subjectType: 'forum_report_ticket',
          subjectId: persistedTicket.id,
          userId: persistedTicket.reporterUserId,
          actorId: persistedTicket.reporterActorId,
          actorRole: scope.roleKeys[0] ?? '',
          action: 'forum_report_submitted',
          engineType: 'manual',
          decision: persistedTicket.status,
          reasonCode: persistedTicket.reasonCode,
          reason: persistedTicket.reasonDetail,
          metadata: {
            targetType: persistedTicket.targetType,
            targetId: persistedTicket.targetId,
            targetOrganizationId: persistedTicket.targetOrganizationId,
            snapshotId: snapshot.id
          }
        },
        context,
        manager
      );
      return persistedTicket;
    });

    return this.presenter.toSubmitResponse(savedTicket);
  }

  private async loadReportTarget(command: ForumReportCommand): Promise<ForumReportTarget> {
    if (command.targetType === 'comment') {
      return this.loadCommentReportTarget(command.targetId);
    }

    return this.loadPostReportTarget(command.targetId);
  }

  private async loadPostReportTarget(postId: string): Promise<ForumReportTarget> {
    const post = await this.postRepository.findOneBy({ id: postId, state: 'published' });
    if (!post) {
      throw forumPostUnavailable('Forum report target post is unavailable.');
    }
    return {
      targetAuthorUserId: post.authorUserId,
      targetOrganizationId: post.organizationId,
      targetSnapshot: {
        targetType: 'post',
        postId: post.id,
        organizationId: post.organizationId,
        authorUserId: post.authorUserId,
        topicId: post.topicId,
        title: post.title,
        body: post.body,
        excerpt: post.excerpt,
        state: post.state,
        publishedAt: post.publishedAt.toISOString(),
        attachmentFileAssetIds: post.attachmentFileAssetIds
      }
    };
  }

  private async loadCommentReportTarget(commentId: string): Promise<ForumReportTarget> {
    const comment = await this.commentRepository.findOneBy({
      id: commentId,
      state: 'published'
    });
    if (!comment) {
      throw forumPostUnavailable('Forum report target comment is unavailable.');
    }

    const post = await this.postRepository.findOneBy({
      id: comment.postId,
      state: 'published'
    });
    if (!post) {
      throw forumPostUnavailable('Forum report target comment post is unavailable.');
    }

    return {
      targetAuthorUserId: comment.authorUserId,
      targetOrganizationId: comment.organizationId,
      targetSnapshot: {
        targetType: 'comment',
        commentId: comment.id,
        postId: comment.postId,
        parentCommentId: comment.parentCommentId,
        organizationId: comment.organizationId,
        authorUserId: comment.authorUserId,
        authorActorId: comment.authorActorId,
        body: comment.body,
        state: comment.state,
        publishedAt: comment.publishedAt.toISOString(),
        createdAt: comment.createdAt.toISOString(),
        updatedAt: comment.updatedAt.toISOString(),
        postState: post.state
      }
    };
  }

  private createTicket(
    command: ForumReportCommand,
    input: {
      reporterUserId: string;
      reporterActorId: string;
      reporterOrganizationId: string;
      target: ForumReportTarget;
    }
  ) {
    const ticket = new ForumReportTicketEntity();
    ticket.id = randomUUID();
    ticket.targetType = command.targetType;
    ticket.targetId = command.targetId;
    ticket.targetAuthorUserId = input.target.targetAuthorUserId;
    ticket.targetOrganizationId = input.target.targetOrganizationId;
    ticket.reporterUserId = input.reporterUserId;
    ticket.reporterActorId = input.reporterActorId;
    ticket.reporterOrganizationId = input.reporterOrganizationId;
    ticket.reasonCode = command.reasonCode;
    ticket.reasonDetail = command.reasonDetail;
    ticket.status = 'submitted';
    ticket.targetSnapshot = input.target.targetSnapshot;
    return ticket;
  }

  private toCommand(payload: Record<string, unknown>): ForumReportCommand {
    const source = this.asRecord(payload);
    return {
      targetType: this.readTargetType(source.targetType),
      targetId: this.readTargetId(source.targetId),
      reasonCode: this.readReasonCode(source.reasonCode),
      reasonDetail: this.readReasonDetail(source.reasonDetail)
    };
  }

  private readTargetType(value: unknown): ContentSafetyForumReportTargetType {
    const normalized = this.readRequiredString(value, 'targetType');
    if (!TARGET_TYPE_SET.has(normalized)) {
      throw forumReportInvalid('targetType must be post or comment.');
    }
    return normalized as ContentSafetyForumReportTargetType;
  }

  private readTargetId(value: unknown) {
    const normalized = this.readRequiredString(value, 'targetId');
    if (normalized.length > 64) {
      throw forumReportInvalid('targetId is invalid for forum report submit.');
    }
    return normalized;
  }

  private readReasonCode(value: unknown): ContentSafetyForumReportReasonCode {
    const normalized = this.readRequiredString(value, 'reasonCode');
    if (!REASON_CODE_SET.has(normalized)) {
      throw forumReportInvalid('reasonCode is invalid for forum report submit.');
    }
    return normalized as ContentSafetyForumReportReasonCode;
  }

  private readReasonDetail(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw forumReportInvalid('reasonDetail must be a string when provided.');
    }
    const normalized = value.trim();
    if (!normalized) {
      return null;
    }
    if (normalized.length > REASON_DETAIL_MAX_LENGTH) {
      throw forumReportInvalid('reasonDetail exceeds the Forum Report P0 length boundary.');
    }
    return normalized;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw forumReportInvalid(`${field} is required for forum report submit.`);
    }
    return value.trim();
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw forumReportInvalid('Forum report payload must be an object.');
    }
    return value as Record<string, unknown>;
  }
}

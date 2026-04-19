import { Injectable } from '@nestjs/common';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';

const SNAPSHOT_TITLE_LIMIT = 80;
const SNAPSHOT_TEXT_LIMIT = 120;

@Injectable()
export class ForumReportPresenter {
  toSubmitResponse(ticket: ForumReportTicketEntity) {
    return {
      reportTicketId: ticket.id,
      status: ticket.status,
      target: {
        targetType: ticket.targetType,
        targetId: ticket.targetId
      },
      reason: {
        reasonCode: ticket.reasonCode,
        reasonDetail: ticket.reasonDetail
      },
      submittedAt: ticket.createdAt.toISOString()
    };
  }

  toReadModel(ticket: ForumReportTicketEntity) {
    return {
      reportTicketId: ticket.id,
      targetType: ticket.targetType,
      targetId: ticket.targetId,
      targetAuthorUserId: ticket.targetAuthorUserId,
      targetOrganizationId: ticket.targetOrganizationId,
      reporterUserId: ticket.reporterUserId,
      reporterActorId: ticket.reporterActorId,
      reporterOrganizationId: ticket.reporterOrganizationId,
      reasonCode: ticket.reasonCode,
      reasonDetail: ticket.reasonDetail,
      status: ticket.status,
      targetSnapshot: ticket.targetSnapshot,
      submittedAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString()
    };
  }

  toMyReportListResponse(tickets: ForumReportTicketEntity[], traceId: string) {
    return {
      items: tickets.map((ticket) => this.toMyReportListItem(ticket)),
      count: tickets.length,
      traceId
    };
  }

  toMyReportDetail(ticket: ForumReportTicketEntity) {
    return {
      ticketId: ticket.id,
      targetType: ticket.targetType,
      targetId: ticket.targetId,
      reasonCode: ticket.reasonCode,
      reasonDetail: ticket.reasonDetail,
      status: ticket.status,
      submittedAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString(),
      targetSnapshot: this.toMinimalTargetSnapshot(ticket)
    };
  }

  private toMyReportListItem(ticket: ForumReportTicketEntity) {
    return {
      ticketId: ticket.id,
      targetType: ticket.targetType,
      targetId: ticket.targetId,
      reasonCode: ticket.reasonCode,
      status: ticket.status,
      submittedAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString(),
      targetSnapshot: this.toMinimalTargetSnapshot(ticket)
    };
  }

  private toMinimalTargetSnapshot(ticket: ForumReportTicketEntity) {
    const snapshot = ticket.targetSnapshot ?? {};
    if (ticket.targetType === 'post') {
      return this.compactRecord({
        targetType: 'post',
        postId: this.readString(snapshot.postId) ?? ticket.targetId,
        topicId: this.readString(snapshot.topicId),
        title: this.trimText(this.readString(snapshot.title), SNAPSHOT_TITLE_LIMIT),
        excerpt: this.trimText(
          this.readString(snapshot.excerpt) ?? this.readString(snapshot.body),
          SNAPSHOT_TEXT_LIMIT
        ),
        state: this.readString(snapshot.state),
        publishedAt: this.readString(snapshot.publishedAt)
      });
    }
    if (ticket.targetType === 'comment') {
      return this.compactRecord({
        targetType: 'comment',
        commentId: this.readString(snapshot.commentId) ?? ticket.targetId,
        postId: this.readString(snapshot.postId),
        parentCommentId: this.readString(snapshot.parentCommentId),
        bodyPreview: this.trimText(this.readString(snapshot.body), SNAPSHOT_TEXT_LIMIT),
        state: this.readString(snapshot.state),
        publishedAt: this.readString(snapshot.publishedAt)
      });
    }
    return { targetType: ticket.targetType, targetId: ticket.targetId };
  }

  private compactRecord(value: Record<string, string | null>) {
    return Object.fromEntries(
      Object.entries(value).filter(([, item]) => item !== null && item !== '')
    );
  }

  private readString(value: unknown) {
    return typeof value === 'string' && value.trim() ? value.trim() : null;
  }

  private trimText(value: string | null, maxLength: number) {
    if (!value || value.length <= maxLength) {
      return value;
    }
    return `${value.slice(0, maxLength - 1)}...`;
  }
}

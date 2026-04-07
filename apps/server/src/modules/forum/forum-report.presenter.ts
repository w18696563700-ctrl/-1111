import { Injectable } from '@nestjs/common';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';

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
}

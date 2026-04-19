import { Injectable } from '@nestjs/common';
import { ExhibitionReportCaseEntity } from './entities/exhibition-report-case.entity';

@Injectable()
export class ExhibitionReportCasePresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  toListItem(reportCase: ExhibitionReportCaseEntity) {
    return {
      reportCaseId: reportCase.id,
      targetType: reportCase.targetType,
      targetId: reportCase.targetId,
      reasonCode: reportCase.reasonCode,
      status: reportCase.status,
      temporaryRestrictionState: reportCase.temporaryRestrictionState,
      submittedAt: this.toIso(reportCase.createdAt)
    };
  }

  toDetail(reportCase: ExhibitionReportCaseEntity) {
    return {
      reportCaseId: reportCase.id,
      targetType: reportCase.targetType,
      targetId: reportCase.targetId,
      targetTitle: this.readNullableString(reportCase.metadata.targetTitle),
      reasonCode: reportCase.reasonCode,
      reasonDetail: reportCase.reasonDetail,
      status: reportCase.status,
      temporaryRestrictionState: reportCase.temporaryRestrictionState,
      reviewTaskId: reportCase.reviewTaskId,
      governanceTicketId: reportCase.governanceTicketRef,
      reporter: {
        actorId: reportCase.reporterUserId,
        organizationId: reportCase.reporterOrganizationId
      },
      evidenceFileAssetIds: reportCase.evidenceFileAssetIds,
      submittedAt: this.toIso(reportCase.createdAt),
      explanationRequestedAt: this.toIso(reportCase.explanationRequestedAt),
      explanationReceivedAt: this.toIso(reportCase.explanationReceivedAt),
      adjudicationResult: reportCase.adjudicationResult,
      decidedAt: this.toIso(reportCase.decidedAt),
      decisionNote: reportCase.decisionNote
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }

  private toIso(value: Date | null | undefined) {
    return value ? value.toISOString() : null;
  }

  private readNullableString(value: unknown) {
    return typeof value === 'string' && value.trim() ? value.trim() : null;
  }
}

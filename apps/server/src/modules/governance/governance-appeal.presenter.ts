import { Injectable } from '@nestjs/common';
import { GovernanceAppealCaseEntity } from './entities/governance-appeal-case.entity';

@Injectable()
export class GovernanceAppealPresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  toListItem(appeal: GovernanceAppealCaseEntity) {
    return {
      appealCaseId: appeal.id,
      penaltyId: appeal.penaltyId,
      status: appeal.status,
      submittedAt: this.toIso(appeal.submittedAt)
    };
  }

  toDetail(appeal: GovernanceAppealCaseEntity) {
    return {
      appealCaseId: appeal.id,
      penaltyId: appeal.penaltyId,
      status: appeal.status,
      reason: appeal.reason,
      evidenceFileAssetIds: appeal.evidenceFileAssetIds,
      submittedAt: this.toIso(appeal.submittedAt),
      decidedAt: this.toIso(appeal.decidedAt),
      decisionNote: appeal.decisionNote
    };
  }

  toDecisionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }

  private toIso(value: Date | null | undefined) {
    return value ? value.toISOString() : null;
  }
}

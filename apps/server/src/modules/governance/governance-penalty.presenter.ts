import { Injectable } from '@nestjs/common';
import { GovernancePenaltyStatus } from './governance.constants';
import { GovernancePenaltyEntity } from './entities/governance-penalty.entity';

@Injectable()
export class GovernancePenaltyPresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  toListItem(penalty: GovernancePenaltyEntity, now = new Date()) {
    return {
      penaltyId: penalty.id,
      subjectType: penalty.subjectType,
      subjectId: penalty.subjectId,
      penaltyType: penalty.penaltyType,
      status: this.toEffectiveStatus(penalty, now),
      effectiveFrom: this.toIso(penalty.effectiveFrom),
      effectiveUntil: this.toIso(penalty.effectiveUntil)
    };
  }

  toDetail(penalty: GovernancePenaltyEntity, now = new Date()) {
    return {
      penaltyId: penalty.id,
      subjectType: penalty.subjectType,
      subjectId: penalty.subjectId,
      penaltyType: penalty.penaltyType,
      status: this.toEffectiveStatus(penalty, now),
      reasonCode: penalty.reasonCode,
      reasonSummary: penalty.reasonSummary,
      evidenceFileAssetIds: penalty.evidenceFileAssetIds,
      effectiveFrom: this.toIso(penalty.effectiveFrom),
      effectiveUntil: this.toIso(penalty.effectiveUntil),
      createdAt: this.toIso(penalty.createdAt),
      createdBy: penalty.createdBy
    };
  }

  toApplyResponse(penalty: GovernancePenaltyEntity, traceId: string) {
    return {
      ok: true,
      penaltyId: penalty.id,
      status: this.toEffectiveStatus(penalty),
      traceId
    };
  }

  toEffectiveStatus(penalty: GovernancePenaltyEntity, now = new Date()): GovernancePenaltyStatus {
    if (penalty.status === 'active' && penalty.effectiveUntil && penalty.effectiveUntil.getTime() <= now.getTime()) {
      return 'expired';
    }
    return penalty.status as GovernancePenaltyStatus;
  }

  private toIso(value: Date | null | undefined) {
    return value ? value.toISOString() : null;
  }
}

import { Injectable } from '@nestjs/common';

type ReserveRiskPosture = 'LOW' | 'MEDIUM' | 'HIGH' | null;
type ReserveSampleStatus = 'UNAVAILABLE' | 'INSUFFICIENT' | 'SUFFICIENT';

type ShadowAggregateProjection = {
  score: number | null;
  tierCode: string | null;
  tierLabel: string | null;
  sampleStatus: ReserveSampleStatus;
  riskPosture: ReserveRiskPosture;
  ratedCompletedOrderCount: number;
  positiveRate: number | null;
  negativeRate: number | null;
  verySatisfiedCount: number;
  satisfiedCount: number;
  passableCount: number;
  negativeCount: number;
  reasonSummary: string | null;
  actionableState: string | null;
  reasonCodes: string[];
  updatedAt: Date | null;
};

@Injectable()
export class OrganizationCreditScoringPresenter {
  toStatus(input: ShadowAggregateProjection) {
    return {
      score: input.score,
      tierCode: input.tierCode,
      tierLabel: input.tierLabel,
      sampleStatus: input.sampleStatus,
      riskPosture: input.riskPosture,
      ratedCompletedOrderCount: input.ratedCompletedOrderCount,
      positiveRate: input.positiveRate,
      negativeRate: input.negativeRate,
      verySatisfiedCount: input.verySatisfiedCount,
      satisfiedCount: input.satisfiedCount,
      passableCount: input.passableCount,
      negativeCount: input.negativeCount,
      reasonSummary: input.reasonSummary,
      actionableState: input.actionableState,
      updatedAt: input.updatedAt?.toISOString() ?? null,
    };
  }

  toExplanation(input: ShadowAggregateProjection) {
    return {
      reasonSummary: input.reasonSummary ?? '',
      reasonCodes: input.reasonCodes,
      sampleStatus: input.sampleStatus,
      riskPosture: input.riskPosture,
      ratedCompletedOrderCount: input.ratedCompletedOrderCount,
      positiveRate: input.positiveRate,
      negativeRate: input.negativeRate,
      verySatisfiedCount: input.verySatisfiedCount,
      satisfiedCount: input.satisfiedCount,
      passableCount: input.passableCount,
      negativeCount: input.negativeCount,
      updatedAt: input.updatedAt?.toISOString() ?? null,
    };
  }

  toHandoff(input: ShadowAggregateProjection) {
    return {
      actionableState: input.actionableState,
      sampleStatus: input.sampleStatus,
      riskPosture: input.riskPosture,
      primaryActionCode: this.resolvePrimaryActionCode(input.actionableState),
      primaryActionLabel: this.resolvePrimaryActionLabel(input.actionableState),
      handoffMessage: this.resolveHandoffMessage(input.actionableState, input.reasonSummary),
      updatedAt: input.updatedAt?.toISOString() ?? null,
    };
  }

  private resolvePrimaryActionCode(actionableState: string | null) {
    switch (actionableState) {
      case 'stable':
        return 'reserve_stable';
      case 'watch':
        return 'reserve_watch';
      case 'alert':
        return 'reserve_alert';
      default:
        return null;
    }
  }

  private resolvePrimaryActionLabel(actionableState: string | null) {
    switch (actionableState) {
      case 'stable':
        return '保持稳定';
      case 'watch':
        return '持续关注';
      case 'alert':
        return '风险预警';
      default:
        return null;
    }
  }

  private resolveHandoffMessage(actionableState: string | null, reasonSummary: string | null) {
    if (!actionableState) {
      return null;
    }
    if (reasonSummary) {
      return reasonSummary;
    }
    switch (actionableState) {
      case 'stable':
        return '当前样本已足够，未来主线可稳定参考。';
      case 'watch':
        return '当前评分处于关注区间，建议持续观察。';
      case 'alert':
        return '当前评分处于风险警戒区间，建议进入人工复核。';
      default:
        return null;
    }
  }
}

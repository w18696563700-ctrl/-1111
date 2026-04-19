import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { OrganizationCreditShadowAggregateEntity } from './entities/organization-credit-shadow-aggregate.entity';
import {
  futureCreditFamilyUnavailable,
  futureVisibilityOrAuthorizationUnavailable,
  shadowResultUnavailable,
} from './organization-credit-scoring.errors';
import { OrganizationCreditScoringPresenter } from './organization-credit-scoring.presenter';

type ShadowAggregateRow = {
  organizationId: string;
  aggregationMode: string | null;
  sampleStatus: string | null;
  ratedCompletedOrderCount: number | string | null;
  verySatisfiedCount: number | string | null;
  satisfiedCount: number | string | null;
  passableCount: number | string | null;
  negativeCount: number | string | null;
  positiveRate: number | string | null;
  negativeRate: number | string | null;
  recentConsecutiveNegativeCount: number | string | null;
  last20RatedNegativeRate: number | string | null;
  baseScore: number | string | null;
  rawScore: number | string | null;
  effectiveScore: number | string | null;
  publicScore: number | string | null;
  tierCode: string | null;
  riskPosture: string | null;
  tierReasonCodes: string[] | null;
  postureReasonCodes: string[] | null;
  reasonSummary: string | null;
  version: number | string | null;
  lastRatedOrderId: string | null;
  lastRatedAt: Date | string | null;
  updatedAt: Date | string | null;
};

@Injectable()
export class OrganizationCreditScoringQueryService {
  constructor(
    @InjectRepository(OrganizationCreditShadowAggregateEntity)
    private readonly aggregateRepository: Repository<OrganizationCreditShadowAggregateEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: OrganizationCreditScoringPresenter,
  ) {}

  async getStatus(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toStatus(projection);
  }

  async getExplanation(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toExplanation(projection);
  }

  async getHandoff(context: RequestContext) {
    const projection = await this.buildProjection(context);
    return this.presenter.toHandoff(projection);
  }

  private async buildProjection(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const aggregate = await this.loadShadowAggregate(organizationId);
    if (!aggregate) {
      throw shadowResultUnavailable('Future reserve shadow result is unavailable.');
    }

    const sampleStatus = this.resolveSampleStatus(aggregate.sampleStatus);
    const score = sampleStatus === 'SUFFICIENT' ? this.requireInteger(aggregate.publicScore) : null;
    const tierCode = sampleStatus === 'SUFFICIENT' ? this.requireString(aggregate.tierCode) : null;
    const tierLabel = sampleStatus === 'SUFFICIENT' ? this.resolveTierLabel(tierCode) : null;
    const riskPosture = sampleStatus === 'SUFFICIENT' ? this.requireRiskPosture(aggregate.riskPosture) : null;
    const actionableState = sampleStatus === 'SUFFICIENT'
      ? this.resolveActionableState(aggregate.riskPosture)
      : null;
    const reasonCodes = this.mergeReasonCodes(
      this.normalizeReasonCodes(aggregate.tierReasonCodes),
      this.normalizeReasonCodes(aggregate.postureReasonCodes),
    );

    return {
      score,
      tierCode,
      tierLabel,
      sampleStatus,
      riskPosture,
      ratedCompletedOrderCount: this.resolveInteger(aggregate.ratedCompletedOrderCount) ?? 0,
      positiveRate: sampleStatus === 'SUFFICIENT' ? this.resolveDecimal(aggregate.positiveRate) : null,
      negativeRate: sampleStatus === 'SUFFICIENT' ? this.resolveDecimal(aggregate.negativeRate) : null,
      verySatisfiedCount: this.resolveInteger(aggregate.verySatisfiedCount) ?? 0,
      satisfiedCount: this.resolveInteger(aggregate.satisfiedCount) ?? 0,
      passableCount: this.resolveInteger(aggregate.passableCount) ?? 0,
      negativeCount: this.resolveInteger(aggregate.negativeCount) ?? 0,
      reasonSummary: this.normalizeString(aggregate.reasonSummary),
      actionableState,
      reasonCodes,
      updatedAt: this.resolveDate(aggregate.updatedAt),
    };
  }

  private async requireCurrentOrganizationId(context: RequestContext) {
    try {
      const currentSession = await requireVerifiedCurrentSessionContext(
        context,
        this.currentSessionVerificationService,
      );
      await this.eligibilityService.requireAuthenticatedActor(currentSession);
      const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
      if (!scope) {
        throw futureVisibilityOrAuthorizationUnavailable(
          'Current organization scope is unavailable for future reserve credit scoring.',
        );
      }
      return scope.organization.id;
    } catch (error) {
      if (this.isReserveError(error)) {
        throw error;
      }
      throw futureVisibilityOrAuthorizationUnavailable(
        'Current organization scope is unavailable for future reserve credit scoring.',
      );
    }
  }

  private async loadShadowAggregate(organizationId: string) {
    try {
      return await this.aggregateRepository.findOneBy({ organizationId });
    } catch (error) {
      throw futureCreditFamilyUnavailable(
        'Future reserve credit family is unavailable for shadow read projection.',
      );
    }
  }

  private resolveSampleStatus(value: string | null | undefined): 'UNAVAILABLE' | 'INSUFFICIENT' | 'SUFFICIENT' {
    const normalized = this.normalizeString(value);
    if (!normalized) {
      return 'UNAVAILABLE';
    }
    if (normalized === 'insufficient') {
      return 'INSUFFICIENT';
    }
    if (normalized === 'ready') {
      return 'SUFFICIENT';
    }
    throw futureCreditFamilyUnavailable('Unexpected future reserve sample status.');
  }

  private resolveTierLabel(tierCode: string | null) {
    switch (tierCode) {
      case 'T1':
        return '60-69';
      case 'T2':
        return '70-79';
      case 'T3':
        return '80-89';
      case 'T4':
        return '90-100';
      default:
        throw futureCreditFamilyUnavailable('Unexpected future reserve tier code.');
    }
  }

  private requireRiskPosture(value: string | null | undefined) {
    switch (this.normalizeString(value)) {
      case 'normal':
        return 'LOW' as const;
      case 'observe':
        return 'MEDIUM' as const;
      case 'risk_alert':
        return 'HIGH' as const;
      default:
        throw futureCreditFamilyUnavailable('Unexpected future reserve risk posture.');
    }
  }

  private resolveActionableState(value: string | null | undefined) {
    switch (this.normalizeString(value)) {
      case 'normal':
        return 'stable';
      case 'observe':
        return 'watch';
      case 'risk_alert':
        return 'alert';
      default:
        throw futureCreditFamilyUnavailable('Unexpected future reserve actionable state.');
    }
  }

  private mergeReasonCodes(left: string[], right: string[]) {
    const merged: string[] = [];
    for (const code of [...left, ...right]) {
      if (code && !merged.includes(code)) {
        merged.push(code);
      }
    }
    return merged;
  }

  private normalizeReasonCodes(value: string[] | null) {
    return (value ?? [])
      .map((item) => this.normalizeString(item))
      .filter((item): item is string => Boolean(item));
  }

  private resolveInteger(value: number | string | null | undefined) {
    if (value === null || value === undefined || value === '') {
      return null;
    }
    const numeric = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(numeric) ? Math.round(numeric) : null;
  }

  private requireInteger(value: number | string | null | undefined) {
    const numeric = this.resolveInteger(value);
    if (numeric === null) {
      throw futureCreditFamilyUnavailable('Unexpected future reserve integer value.');
    }
    return numeric;
  }

  private requireString(value: string | null | undefined) {
    const normalized = this.normalizeString(value);
    if (!normalized) {
      throw futureCreditFamilyUnavailable('Unexpected future reserve string value.');
    }
    return normalized;
  }

  private resolveDecimal(value: number | string | null | undefined) {
    if (value === null || value === undefined || value === '') {
      return null;
    }
    const numeric = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(numeric) ? Math.round(numeric * 100) / 100 : null;
  }

  private resolveDate(value: Date | string | null | undefined) {
    if (!value) {
      return null;
    }
    if (value instanceof Date) {
      return value;
    }
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private normalizeString(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : '';
  }

  private isReserveError(error: unknown) {
    return (
      Boolean(error) &&
      typeof error === 'object' &&
      'response' in error &&
      typeof (error as { response?: { code?: string } }).response?.code === 'string' &&
      [
        'SHADOW_RESULT_UNAVAILABLE',
        'SAMPLE_INSUFFICIENT',
        'FUTURE_CREDIT_FAMILY_UNAVAILABLE',
        'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE',
        'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
      ].includes((error as { response?: { code?: string } }).response?.code ?? '')
    );
  }
}

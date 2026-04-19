import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, LessThanOrEqual, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { GovernanceAppealCaseEntity } from '../governance/entities/governance-appeal-case.entity';
import { GovernancePenaltyEntity } from '../governance/entities/governance-penalty.entity';
import { GovernancePenaltyType } from '../governance/governance.constants';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';

type GovernanceStatusValue = 'normal' | 'watchlisted' | 'restricted' | 'blacklisted' | 'permanently_banned';
type WhitelistStatusValue = 'none' | 'active';
type AppealEntryStateValue = 'not_available' | 'available' | 'pending';

type CurrentPenaltySummary = {
  penaltyId: string;
  penaltyType: string;
  status: string;
  effectiveFrom: string;
  effectiveUntil: string | null;
  reasonSummary: string | null;
  appealAllowed: boolean;
};

export type ProfileGovernanceStatusResponse = {
  organizationId: string | null;
  governanceStatus: GovernanceStatusValue;
  whitelistStatus: WhitelistStatusValue;
  appealEntryState: AppealEntryStateValue;
  currentPenalty: CurrentPenaltySummary | null;
  violationScoreSnapshot: number;
  violationScoreUpdatedAt: string | null;
};

type PenaltyEvaluation = {
  penalty: GovernancePenaltyEntity;
  relatedAppeals: GovernanceAppealCaseEntity[];
  invalidatingAppeal: GovernanceAppealCaseEntity | null;
};

const SCOREABLE_PENALTY_STATUSES = new Set(['active', 'lifted', 'expired']);
const ACTIVE_PENALTY_STATUSES = new Set(['active']);
const GOVERNANCE_PENALTY_SCORE_WEIGHTS: Record<GovernancePenaltyType, number> = {
  warning: 1,
  watchlist: 2,
  restrict_publish: 3,
  restrict_bid: 3,
  blacklist: 5
};

@Injectable()
export class ProfileGovernanceStatusQueryService {
  constructor(
    @InjectRepository(GovernancePenaltyEntity)
    private readonly penaltyRepository: Repository<GovernancePenaltyEntity>,
    @InjectRepository(GovernanceAppealCaseEntity)
    private readonly appealRepository: Repository<GovernanceAppealCaseEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async getStatus(context: RequestContext): Promise<ProfileGovernanceStatusResponse> {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      return this.toEmptyStatus();
    }

    const now = new Date();
    const penalties = await this.loadRelevantPenalties(scope.organization.id, scope.membership.id, now);
    if (!penalties.length) {
      return this.toEmptyStatus(scope.organization.id);
    }

    const penaltyIds = penalties.map((penalty) => penalty.id);
    const appeals = await this.loadAppeals(penaltyIds);
    return this.deriveStatus(scope.organization.id, penalties, appeals, now);
  }

  private async loadRelevantPenalties(organizationId: string, memberId: string, now: Date) {
    return this.penaltyRepository.find({
      where: [
        {
          subjectType: 'organization',
          subjectId: organizationId,
          status: In([...SCOREABLE_PENALTY_STATUSES]),
          effectiveFrom: LessThanOrEqual(now)
        },
        {
          subjectType: 'organization_member',
          subjectId: memberId,
          status: In([...SCOREABLE_PENALTY_STATUSES]),
          effectiveFrom: LessThanOrEqual(now)
        }
      ],
      order: {
        effectiveFrom: 'DESC',
        createdAt: 'DESC'
      }
    });
  }

  private async loadAppeals(penaltyIds: string[]) {
    if (!penaltyIds.length) {
      return [];
    }
    return this.appealRepository.find({
      where: {
        penaltyId: In(penaltyIds)
      },
      order: {
        decidedAt: 'DESC',
        submittedAt: 'DESC',
        createdAt: 'DESC'
      }
    });
  }

  private deriveStatus(
    organizationId: string,
    penalties: GovernancePenaltyEntity[],
    appeals: GovernanceAppealCaseEntity[],
    now: Date
  ): ProfileGovernanceStatusResponse {
    const appealMap = this.groupAppealsByPenaltyId(appeals);
    const evaluations = penalties.map((penalty) => {
      const relatedAppeals = appealMap.get(penalty.id) ?? [];
      return {
        penalty,
        relatedAppeals,
        invalidatingAppeal: this.resolveInvalidatingAppeal(relatedAppeals)
      } satisfies PenaltyEvaluation;
    });

    const scorePenalties = evaluations
      .filter((evaluation) =>
        this.isScoreEligiblePenalty(evaluation.penalty, evaluation.invalidatingAppeal)
      )
      .map((evaluation) => evaluation.penalty);
    const currentPenalties = scorePenalties.filter((penalty) => this.isCurrentActivePenalty(penalty, now));
    const currentPenalty = this.pickCurrentPenalty(currentPenalties);
    const currentPenaltyAppeals = currentPenalty ? appealMap.get(currentPenalty.id) ?? [] : [];
    const invalidatingAppealTimestamps = evaluations
      .map((evaluation) => evaluation.invalidatingAppeal)
      .filter((appeal): appeal is GovernanceAppealCaseEntity => Boolean(appeal))
      .map((appeal) => this.resolveAppealTimestamp(appeal));

    return {
      organizationId,
      governanceStatus: this.resolveGovernanceStatus(currentPenalties),
      whitelistStatus: 'none',
      appealEntryState: this.resolveAppealEntryState(currentPenalty, currentPenaltyAppeals),
      currentPenalty: currentPenalty ? this.toPenaltySummary(currentPenalty, currentPenaltyAppeals) : null,
      violationScoreSnapshot: this.resolveViolationScoreSnapshot(scorePenalties),
      violationScoreUpdatedAt: this.resolveViolationScoreUpdatedAt(
        scorePenalties,
        invalidatingAppealTimestamps
      )
    };
  }

  private toEmptyStatus(organizationId: string | null = null): ProfileGovernanceStatusResponse {
    return {
      organizationId,
      governanceStatus: 'normal',
      whitelistStatus: 'none',
      appealEntryState: 'not_available',
      currentPenalty: null,
      violationScoreSnapshot: 0,
      violationScoreUpdatedAt: null
    };
  }

  private groupAppealsByPenaltyId(appeals: GovernanceAppealCaseEntity[]) {
    const appealMap = new Map<string, GovernanceAppealCaseEntity[]>();
    for (const appeal of appeals) {
      const bucket = appealMap.get(appeal.penaltyId) ?? [];
      bucket.push(appeal);
      appealMap.set(appeal.penaltyId, bucket);
    }
    return appealMap;
  }

  private resolveInvalidatingAppeal(appeals: GovernanceAppealCaseEntity[]) {
    const decidedAppeals = appeals
      .filter((appeal) => this.isFinalAppealDecision(appeal))
      .sort((left, right) => this.compareDates(right.decidedAt, left.decidedAt));
    const latest = decidedAppeals[0] ?? null;
    if (!latest) {
      return null;
    }
    if (latest.decision === 'revoke' || latest.decision === 'modify') {
      return latest;
    }
    return null;
  }

  private isFinalAppealDecision(appeal: GovernanceAppealCaseEntity) {
    return Boolean(appeal.decision && appeal.decidedAt);
  }

  private isScoreEligiblePenalty(
    penalty: GovernancePenaltyEntity,
    invalidatingAppeal: GovernanceAppealCaseEntity | null
  ) {
    if (!SCOREABLE_PENALTY_STATUSES.has(penalty.status)) {
      return false;
    }
    if (invalidatingAppeal) {
      return false;
    }
    return true;
  }

  private isCurrentActivePenalty(penalty: GovernancePenaltyEntity, now: Date) {
    if (!ACTIVE_PENALTY_STATUSES.has(penalty.status)) {
      return false;
    }
    return penalty.effectiveFrom.getTime() <= now.getTime() && this.isEffectiveUntilOpen(penalty, now);
  }

  private isEffectiveUntilOpen(penalty: GovernancePenaltyEntity, now: Date) {
    if (!penalty.effectiveUntil) {
      return true;
    }
    return penalty.effectiveUntil.getTime() > now.getTime();
  }

  private pickCurrentPenalty(penalties: GovernancePenaltyEntity[]) {
    if (!penalties.length) {
      return null;
    }
    return [...penalties].sort((left, right) => {
      const rankDelta = this.resolvePenaltyRank(right.penaltyType) - this.resolvePenaltyRank(left.penaltyType);
      if (rankDelta !== 0) {
        return rankDelta;
      }
      const effectiveFromDelta = right.effectiveFrom.getTime() - left.effectiveFrom.getTime();
      if (effectiveFromDelta !== 0) {
        return effectiveFromDelta;
      }
      const createdAtDelta = right.createdAt.getTime() - left.createdAt.getTime();
      if (createdAtDelta !== 0) {
        return createdAtDelta;
      }
      return right.id.localeCompare(left.id);
    })[0];
  }

  private resolveGovernanceStatus(penalties: GovernancePenaltyEntity[]): GovernanceStatusValue {
    let strongestRank = 0;
    for (const penalty of penalties) {
      strongestRank = Math.max(strongestRank, this.resolvePenaltyRank(penalty.penaltyType));
    }
    if (strongestRank >= 3) {
      return 'blacklisted';
    }
    if (strongestRank >= 2) {
      return 'restricted';
    }
    if (strongestRank >= 1) {
      return 'watchlisted';
    }
    return 'normal';
  }

  private resolvePenaltyRank(penaltyType: string) {
    return this.resolvePenaltyWeightRank(penaltyType);
  }

  private resolveAppealEntryState(
    currentPenalty: GovernancePenaltyEntity | null,
    appeals: GovernanceAppealCaseEntity[]
  ): AppealEntryStateValue {
    if (!currentPenalty) {
      return 'not_available';
    }
    if (this.hasPendingAppeal(appeals)) {
      return 'pending';
    }
    return 'available';
  }

  private hasPendingAppeal(appeals: GovernanceAppealCaseEntity[]) {
    return appeals.some((appeal) => appeal.status === 'submitted' || appeal.status === 'under_review');
  }

  private toPenaltySummary(
    penalty: GovernancePenaltyEntity,
    appeals: GovernanceAppealCaseEntity[]
  ): CurrentPenaltySummary {
    return {
      penaltyId: penalty.id,
      penaltyType: penalty.penaltyType,
      status: penalty.status,
      effectiveFrom: penalty.effectiveFrom.toISOString(),
      effectiveUntil: penalty.effectiveUntil?.toISOString() ?? null,
      reasonSummary: penalty.reasonSummary,
      appealAllowed: !this.hasPendingAppeal(appeals)
    };
  }

  private resolveViolationScoreSnapshot(penalties: GovernancePenaltyEntity[]) {
    return penalties.reduce(
      (total, penalty) => total + this.resolvePenaltyScoreWeight(penalty.penaltyType),
      0
    );
  }

  private resolveViolationScoreUpdatedAt(
    scorePenalties: GovernancePenaltyEntity[],
    invalidatingAppealTimestamps: Date[]
  ) {
    const timestamps = [
      ...scorePenalties.map((penalty) => penalty.effectiveFrom.getTime()),
      ...invalidatingAppealTimestamps.map((timestamp) => timestamp.getTime())
    ];
    if (!timestamps.length) {
      return null;
    }
    return new Date(Math.max(...timestamps)).toISOString();
  }

  private resolveAppealTimestamp(appeal: GovernanceAppealCaseEntity) {
    return appeal.decidedAt ?? appeal.updatedAt;
  }

  private compareDates(left: Date | null, right: Date | null) {
    const leftTime = left?.getTime() ?? 0;
    const rightTime = right?.getTime() ?? 0;
    return leftTime - rightTime;
  }

  private resolvePenaltyScoreWeight(penaltyType: string) {
    const normalized = this.normalizePenaltyType(penaltyType);
    if (!normalized) {
      return 0;
    }
    return GOVERNANCE_PENALTY_SCORE_WEIGHTS[normalized] ?? 0;
  }

  private resolvePenaltyWeightRank(penaltyType: string) {
    const normalized = this.normalizePenaltyType(penaltyType);
    switch (normalized) {
      case 'blacklist':
        return 3;
      case 'restrict_publish':
      case 'restrict_bid':
        return 2;
      case 'watchlist':
        return 1;
      default:
        return 0;
    }
  }

  private normalizePenaltyType(penaltyType: string): GovernancePenaltyType | null {
    switch (penaltyType) {
      case 'warning':
      case 'watchlist':
      case 'restrict_publish':
      case 'restrict_bid':
      case 'blacklist':
        return penaltyType;
      default:
        return null;
    }
  }
}

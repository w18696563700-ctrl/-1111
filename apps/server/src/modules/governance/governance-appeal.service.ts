import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  GOVERNANCE_APPEAL_DECISIONS,
  GOVERNANCE_APPEAL_STATUSES,
  GovernanceAppealDecision,
  GovernanceAppealStatus
} from './governance.constants';
import { GovernanceAppealCaseEntity } from './entities/governance-appeal-case.entity';
import { GovernancePenaltyEntity } from './entities/governance-penalty.entity';
import {
  governanceAppealDecideInvalid,
  governanceAppealResourceUnavailable,
  governanceInvalidState,
  governancePenaltyResourceUnavailable
} from './governance.errors';
import { GovernanceAppealPresenter } from './governance-appeal.presenter';

type GovernanceAppealDecideCommand = {
  decision: GovernanceAppealDecision;
  decisionNote: string | null;
};

@Injectable()
export class GovernanceAppealService {
  constructor(
    @InjectRepository(GovernanceAppealCaseEntity)
    private readonly appealRepository: Repository<GovernanceAppealCaseEntity>,
    @InjectRepository(GovernancePenaltyEntity)
    private readonly penaltyRepository: Repository<GovernancePenaltyEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly dataSource: DataSource,
    private readonly presenter: GovernanceAppealPresenter
  ) {}

  async list(query: Record<string, unknown>, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 100);
    const status = this.readOptionalStatus(query.status);
    const keyword = this.readOptionalText(query.keyword, 128);
    const qb = this.appealRepository.createQueryBuilder('appeal');

    if (status) {
      qb.andWhere('appeal.status = :status', { status });
    }
    if (keyword) {
      qb.andWhere(
        '(appeal.penalty_id ILIKE :keyword OR appeal.reason ILIKE :keyword OR appeal.decision_note ILIKE :keyword)',
        { keyword: `%${keyword}%` }
      );
    }

    const total = await qb.getCount();
    const appeals = await qb
      .orderBy('appeal.submitted_at', 'DESC')
      .offset((page - 1) * pageSize)
      .limit(pageSize)
      .getMany();

    return {
      items: appeals.map((appeal) => this.presenter.toListItem(appeal)),
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async detail(appealCaseId: string, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const id = this.readId(appealCaseId, 'appealCaseId');
    const appeal = await this.appealRepository.findOneBy({ id });
    if (!appeal) {
      throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
    }
    return this.presenter.toDetail(appeal);
  }

  async decide(appealCaseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const reviewer = await this.requireGovernanceReviewer(context);
    const command = this.toDecideCommand(payload);
    const appealId = this.readId(appealCaseId, 'appealCaseId');
    const now = new Date();

    await this.dataSource.transaction(async (manager) => {
      const appeals = manager.getRepository(GovernanceAppealCaseEntity);
      const penalties = manager.getRepository(GovernancePenaltyEntity);
      const appeal = await appeals.findOneBy({ id: appealId });
      if (!appeal) {
        throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
      }
      if (!this.isDecidableStatus(appeal.status)) {
        throw governanceInvalidState('Governance appeal case cannot be decided in current state.');
      }

      const penalty = await penalties.findOneBy({ id: appeal.penaltyId });
      if (!penalty) {
        throw governancePenaltyResourceUnavailable('Governance penalty resource is unavailable.');
      }

      const nextStatus = this.mapDecisionToStatus(command.decision);
      const previousStatus = appeal.status;
      appeal.status = nextStatus;
      appeal.decision = command.decision;
      appeal.decisionNote = command.decisionNote;
      appeal.decidedAt = now;
      appeal.decidedBy = reviewer.currentSession.actorId;
      appeal.updatedAt = now;
      await appeals.save(appeal);

      if (command.decision === 'revoke') {
        penalty.status = 'lifted';
        penalty.effectiveUntil = penalty.effectiveUntil ?? now;
        penalty.updatedAt = now;
        await penalties.save(penalty);
      }

      await this.auditService.record(
        {
          subjectType: 'governance_appeal',
          subjectId: appeal.id,
          userId: null,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'governance_appeal_decide',
          engineType: 'manual',
          decision: command.decision,
          reasonCode: 'governance_appeal_decide',
          reason: command.decisionNote,
          matchedRuleIds: [],
          metadata: {
            appealCaseId: appeal.id,
            penaltyId: appeal.penaltyId,
            previousStatus,
            nextStatus,
            penaltyStatusAfterDecision: penalty.status
          }
        },
        context,
        manager
      );
    });

    return this.presenter.toDecisionAck(context.traceId);
  }

  private async requireGovernanceReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private isDecidableStatus(status: string) {
    return status === 'submitted' || status === 'under_review';
  }

  private mapDecisionToStatus(decision: GovernanceAppealDecision): GovernanceAppealStatus {
    if (decision === 'uphold') {
      return 'upheld';
    }
    if (decision === 'modify') {
      return 'modified';
    }
    return 'revoked';
  }

  private toDecideCommand(payload: Record<string, unknown>): GovernanceAppealDecideCommand {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw governanceAppealDecideInvalid('Governance appeal decide payload must be an object.');
    }
    return {
      decision: this.readEnum(
        payload.decision,
        GOVERNANCE_APPEAL_DECISIONS,
        'decision'
      ) as GovernanceAppealDecision,
      decisionNote: this.readOptionalText(payload.decisionNote, 500)
    };
  }

  private readOptionalStatus(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    return this.readEnum(value, GOVERNANCE_APPEAL_STATUSES, 'status') as GovernanceAppealStatus;
  }

  private readId(value: unknown, field: string) {
    const id = this.readRequiredText(value, field, 64);
    if (!/^[a-zA-Z0-9._:-]{4,64}$/.test(id)) {
      throw governanceAppealDecideInvalid(`${field} must be a valid identifier.`);
    }
    return id;
  }

  private readPositiveInt(value: unknown, fallback: number, max: number) {
    if (value === undefined || value === null || value === '') {
      return fallback;
    }
    const numeric = Number(value);
    if (!Number.isInteger(numeric) || numeric <= 0 || numeric > max) {
      throw governanceAppealDecideInvalid('Pagination values are invalid.');
    }
    return numeric;
  }

  private readRequiredText(value: unknown, field: string, max: number) {
    if (typeof value !== 'string') {
      throw governanceAppealDecideInvalid(`${field} is required.`);
    }
    const trimmed = value.trim();
    if (!trimmed) {
      throw governanceAppealDecideInvalid(`${field} is required.`);
    }
    if (trimmed.length > max) {
      throw governanceAppealDecideInvalid(`${field} exceeds maximum length ${max}.`);
    }
    return trimmed;
  }

  private readOptionalText(value: unknown, max: number) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    if (typeof value !== 'string') {
      throw governanceAppealDecideInvalid('Text field must be a string.');
    }
    const trimmed = value.trim();
    if (!trimmed) {
      return null;
    }
    if (trimmed.length > max) {
      throw governanceAppealDecideInvalid(`Text field exceeds maximum length ${max}.`);
    }
    return trimmed;
  }

  private readEnum(value: unknown, allowed: readonly string[], field: string) {
    if (typeof value !== 'string') {
      throw governanceAppealDecideInvalid(`${field} is invalid.`);
    }
    if (!allowed.includes(value)) {
      throw governanceAppealDecideInvalid(`${field} is invalid.`);
    }
    return value;
  }
}

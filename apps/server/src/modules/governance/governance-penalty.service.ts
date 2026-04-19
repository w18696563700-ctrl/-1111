import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository, SelectQueryBuilder } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import {
  GOVERNANCE_PENALTY_STATUSES,
  GOVERNANCE_PENALTY_TYPES,
  GOVERNANCE_SUBJECT_TYPES,
  GovernancePenaltyStatus,
  GovernancePenaltyType,
  GovernanceSubjectType
} from './governance.constants';
import { GovernancePenaltyEntity } from './entities/governance-penalty.entity';
import { governancePenaltyApplyInvalid, governancePenaltyResourceUnavailable } from './governance.errors';
import { GovernancePenaltyPresenter } from './governance-penalty.presenter';

type GovernancePenaltyApplyCommand = {
  subjectType: GovernanceSubjectType;
  subjectId: string;
  penaltyType: GovernancePenaltyType;
  reasonCode: string;
  reasonSummary: string | null;
  evidenceFileAssetIds: string[];
  effectiveUntil: Date | null;
};

@Injectable()
export class GovernancePenaltyService {
  constructor(
    @InjectRepository(GovernancePenaltyEntity)
    private readonly penaltyRepository: Repository<GovernancePenaltyEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly dataSource: DataSource,
    private readonly presenter: GovernancePenaltyPresenter
  ) {}

  async list(query: Record<string, unknown>, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 100);
    const status = this.readOptionalStatus(query.status);
    const keyword = this.readOptionalText(query.keyword, 128);
    const qb = this.penaltyRepository.createQueryBuilder('penalty');

    if (status) {
      this.applyStatusFilter(qb, status);
    }
    if (keyword) {
      qb.andWhere(
        '(penalty.subject_id ILIKE :keyword OR penalty.reason_code ILIKE :keyword OR penalty.reason_summary ILIKE :keyword)',
        { keyword: `%${keyword}%` }
      );
    }

    const total = await qb.getCount();
    const penalties = await qb
      .orderBy('penalty.created_at', 'DESC')
      .offset((page - 1) * pageSize)
      .limit(pageSize)
      .getMany();

    return {
      items: penalties.map((penalty) => this.presenter.toListItem(penalty)),
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async detail(penaltyId: string, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const id = this.readId(penaltyId, 'penaltyId');
    const penalty = await this.penaltyRepository.findOneBy({ id });
    if (!penalty) {
      throw governancePenaltyResourceUnavailable('Governance penalty resource is unavailable.');
    }
    return this.presenter.toDetail(penalty);
  }

  async apply(payload: Record<string, unknown>, context: RequestContext) {
    const reviewer = await this.requireGovernanceReviewer(context);
    const command = this.toApplyCommand(payload);
    await this.requireSubjectAvailable(command.subjectType, command.subjectId);

    const now = new Date();
    const penalty = await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(GovernancePenaltyEntity);
      const created = repository.create({
        id: randomUUID(),
        subjectType: command.subjectType,
        subjectId: command.subjectId,
        penaltyType: command.penaltyType,
        status: 'active',
        reasonCode: command.reasonCode,
        reasonSummary: command.reasonSummary,
        evidenceFileAssetIds: command.evidenceFileAssetIds,
        effectiveFrom: now,
        effectiveUntil: command.effectiveUntil,
        createdBy: reviewer.currentSession.actorId,
        operatorActorId: reviewer.currentSession.actorId,
        operatorUserId: reviewer.currentSession.userId,
        operatorRole: reviewer.actorRole,
        metadata: {
          source: 'cs027_governance_penalty_p1a',
          boundary: 'server_admin_penalty_apply_only'
        },
        createdAt: now,
        updatedAt: now
      });
      const saved = await repository.save(created);
      await this.auditService.record(
        {
          subjectType: 'governance_penalty',
          subjectId: saved.id,
          userId: null,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'governance_penalty_apply',
          engineType: 'manual',
          decision: saved.status,
          reasonCode: saved.reasonCode,
          reason: saved.reasonSummary,
          matchedRuleIds: [],
          metadata: {
            subjectType: saved.subjectType,
            subjectId: saved.subjectId,
            penaltyType: saved.penaltyType,
            status: saved.status,
            effectiveFrom: saved.effectiveFrom.toISOString(),
            effectiveUntil: saved.effectiveUntil?.toISOString() ?? null,
            evidenceFileAssetIds: saved.evidenceFileAssetIds
          }
        },
        context,
        manager
      );
      return saved;
    });

    return this.presenter.toApplyResponse(penalty, context.traceId);
  }

  private async requireGovernanceReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private async requireSubjectAvailable(subjectType: GovernanceSubjectType, subjectId: string) {
    const subject =
      subjectType === 'organization'
        ? await this.organizationRepository.findOneBy({ id: subjectId })
        : await this.organizationMemberRepository.findOneBy({ id: subjectId });
    if (!subject) {
      throw governancePenaltyApplyInvalid('Governance penalty subject is unavailable.');
    }
  }

  private applyStatusFilter(
    qb: SelectQueryBuilder<GovernancePenaltyEntity>,
    status: GovernancePenaltyStatus
  ) {
    const now = new Date();
    if (status === 'active') {
      qb.andWhere(
        "penalty.status = 'active' AND (penalty.effective_until IS NULL OR penalty.effective_until > :now)",
        { now }
      );
      return;
    }
    if (status === 'expired') {
      qb.andWhere(
        "penalty.status = 'expired' OR (penalty.status = 'active' AND penalty.effective_until IS NOT NULL AND penalty.effective_until <= :now)",
        { now }
      );
      return;
    }
    qb.andWhere('penalty.status = :status', { status });
  }

  private toApplyCommand(payload: Record<string, unknown>): GovernancePenaltyApplyCommand {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw governancePenaltyApplyInvalid('Governance penalty apply payload must be an object.');
    }
    const subjectType = this.readEnum(
      payload.subjectType,
      GOVERNANCE_SUBJECT_TYPES,
      'subjectType'
    ) as GovernanceSubjectType;
    return {
      subjectType,
      subjectId: this.readUuidLikeId(payload.subjectId, 'subjectId'),
      penaltyType: this.readEnum(
        payload.penaltyType,
        GOVERNANCE_PENALTY_TYPES,
        'penaltyType'
      ) as GovernancePenaltyType,
      reasonCode: this.readRequiredText(payload.reasonCode, 'reasonCode', 64),
      reasonSummary: this.readOptionalText(payload.reasonSummary, 500),
      evidenceFileAssetIds: this.readEvidenceFileAssetIds(payload.evidenceFileAssetIds),
      effectiveUntil: this.readOptionalFutureDate(payload.effectiveUntil, 'effectiveUntil')
    };
  }

  private readOptionalStatus(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    return this.readEnum(value, GOVERNANCE_PENALTY_STATUSES, 'status') as GovernancePenaltyStatus;
  }

  private readEnum(value: unknown, allowed: readonly string[], fieldName: string) {
    if (typeof value !== 'string') {
      throw governancePenaltyApplyInvalid(`${fieldName} is required.`);
    }
    const normalized = value.trim();
    if (!allowed.includes(normalized)) {
      throw governancePenaltyApplyInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readId(value: unknown, fieldName: string) {
    return this.readRequiredText(value, fieldName, 64);
  }

  private readUuidLikeId(value: unknown, fieldName: string) {
    const normalized = this.readId(value, fieldName);
    if (!/^[0-9a-fA-F-]{32,36}$/.test(normalized)) {
      throw governancePenaltyApplyInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readRequiredText(value: unknown, fieldName: string, maxLength: number) {
    if (typeof value !== 'string') {
      throw governancePenaltyApplyInvalid(`${fieldName} is required.`);
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > maxLength) {
      throw governancePenaltyApplyInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readOptionalText(value: unknown, maxLength: number) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    if (typeof value !== 'string') {
      throw governancePenaltyApplyInvalid('Optional text field is invalid.');
    }
    const normalized = value.trim();
    if (!normalized) {
      return null;
    }
    if (normalized.length > maxLength) {
      throw governancePenaltyApplyInvalid('Optional text field is too long.');
    }
    return normalized;
  }

  private readEvidenceFileAssetIds(value: unknown) {
    if (value === undefined || value === null) {
      return [];
    }
    if (!Array.isArray(value) || value.length > 20) {
      throw governancePenaltyApplyInvalid('evidenceFileAssetIds is invalid.');
    }
    const ids = value.map((item) => this.readId(item, 'evidenceFileAssetIds'));
    if (new Set(ids).size !== ids.length) {
      throw governancePenaltyApplyInvalid('evidenceFileAssetIds must be unique.');
    }
    return ids;
  }

  private readOptionalFutureDate(value: unknown, fieldName: string) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    if (typeof value !== 'string') {
      throw governancePenaltyApplyInvalid(`${fieldName} is invalid.`);
    }
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime()) || parsed.getTime() <= Date.now()) {
      throw governancePenaltyApplyInvalid(`${fieldName} is invalid.`);
    }
    return parsed;
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound: number) {
    const parsed =
      typeof value === 'string' ? Number.parseInt(value, 10) : typeof value === 'number' ? value : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }
}

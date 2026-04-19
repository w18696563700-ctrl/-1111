import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { ContentSafetySnapshotEntity } from '../content_safety/entities/content-safety-snapshot.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  GOVERNANCE_RESCAN_SCOPE_TYPES,
  GovernanceRescanScopeType
} from './governance.constants';
import {
  governanceRescanJobCreateInvalid,
  governanceRescanJobResourceUnavailable
} from './governance.errors';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { GovernanceRescanJobEntity } from './entities/governance-rescan-job.entity';
import { GovernanceRescanJobPresenter } from './governance-rescan-job.presenter';

type GovernanceRescanJobCreateCommand = {
  scopeType: GovernanceRescanScopeType;
  windowStart: Date;
  windowEnd: Date;
  reason: string;
  ruleSetVersion: string;
  engineMode: string;
};

const BOUNDED_FORUM_RESCAN_SCOPE = 'forum_content';
const HIGH_SIGNAL_REPORT_REASON_CODES = new Set([
  'ad_or_solicitation',
  'abuse_or_insult',
  'flamebait_or_conflict',
  'spam_or_flood',
  'plagiarism_or_repost'
]);

@Injectable()
export class GovernanceRescanJobService {
  constructor(
    @InjectRepository(GovernanceRescanJobEntity)
    private readonly rescanJobRepository: Repository<GovernanceRescanJobEntity>,
    @InjectRepository(ForumReportTicketEntity)
    private readonly forumReportTicketRepository: Repository<ForumReportTicketEntity>,
    @InjectRepository(ContentSafetySnapshotEntity)
    private readonly snapshotRepository: Repository<ContentSafetySnapshotEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly dataSource: DataSource,
    private readonly presenter: GovernanceRescanJobPresenter
  ) {}

  async create(payload: Record<string, unknown>, context: RequestContext) {
    const reviewer = await this.requireGovernanceReviewer(context);
    const command = this.toCreateCommand(payload);
    const summary = await this.selectCandidateSummary(command);
    const now = new Date();

    const job = await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(GovernanceRescanJobEntity);
      const created = repository.create({
        id: randomUUID(),
        scopeType: command.scopeType,
        status: 'queued',
        windowStart: command.windowStart,
        windowEnd: command.windowEnd,
        candidateCount: summary.candidateCount,
        flaggedCount: summary.flaggedCount,
        reason: command.reason,
        ruleSetVersion: command.ruleSetVersion,
        engineMode: command.engineMode,
        createdBy: reviewer.currentSession.actorId,
        completedAt: null,
        createdAt: now,
        updatedAt: now
      });
      const saved = await repository.save(created);
      await this.auditService.record(
        {
          subjectType: 'governance_rescan_job',
          subjectId: saved.id,
          userId: reviewer.currentSession.userId,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'governance_rescan_job_create',
          engineType: 'manual',
          decision: saved.status,
          reasonCode: 'governance_rescan_job_create',
          reason: saved.reason,
          matchedRuleIds: [],
          metadata: {
            scopeType: saved.scopeType,
            windowStart: saved.windowStart.toISOString(),
            windowEnd: saved.windowEnd.toISOString(),
            candidateCount: saved.candidateCount,
            flaggedCount: saved.flaggedCount,
            ruleSetVersion: saved.ruleSetVersion,
            engineMode: saved.engineMode
          }
        },
        context,
        manager
      );
      return saved;
    });

    return this.presenter.toCreateResponse(job, context.traceId);
  }

  async list(query: Record<string, unknown>, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 100);
    const qb = this.rescanJobRepository.createQueryBuilder('job');
    const total = await qb.getCount();
    const rows = await qb
      .orderBy('job.created_at', 'DESC')
      .offset((page - 1) * pageSize)
      .limit(pageSize)
      .getMany();

    return {
      items: rows.map((job) => this.presenter.toListItem(job)),
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async detail(rescanJobId: string, context: RequestContext) {
    await this.requireGovernanceReviewer(context);
    const id = this.readId(rescanJobId, 'rescanJobId');
    const job = await this.rescanJobRepository.findOneBy({ id });
    if (!job) {
      throw governanceRescanJobResourceUnavailable('Governance rescan job resource is unavailable.');
    }
    return this.presenter.toDetail(job);
  }

  private async requireGovernanceReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private async selectCandidateSummary(command: GovernanceRescanJobCreateCommand) {
    if (command.scopeType !== BOUNDED_FORUM_RESCAN_SCOPE) {
      return {
        candidateCount: 0,
        flaggedCount: 0
      };
    }

    const snapshots = await this.snapshotRepository.find({
      where: { subjectType: 'forum_report_ticket' }
    });
    if (!snapshots.length) {
      return {
        candidateCount: 0,
        flaggedCount: 0
      };
    }

    const tickets = await this.forumReportTicketRepository.find();
    const ticketMap = new Map(tickets.map((ticket) => [ticket.id, ticket]));
    let candidateCount = 0;
    let flaggedCount = 0;

    for (const snapshot of snapshots) {
      const ticket = ticketMap.get(snapshot.subjectId);
      if (!ticket) {
        continue;
      }
      if (ticket.status !== 'submitted') {
        continue;
      }
      const parsedSnapshot = this.parseSnapshot(snapshot.currentValue);
      if (!parsedSnapshot) {
        continue;
      }
      if (!this.isSupportedTargetType(parsedSnapshot.targetType)) {
        continue;
      }
      const publishedAt = this.parseDate(parsedSnapshot.publishedAt);
      if (!publishedAt || !this.isWithinWindow(publishedAt, command.windowStart, command.windowEnd)) {
        continue;
      }

      candidateCount += 1;
      if (HIGH_SIGNAL_REPORT_REASON_CODES.has(ticket.reasonCode)) {
        flaggedCount += 1;
      }
    }

    return {
      candidateCount,
      flaggedCount
    };
  }

  private toCreateCommand(payload: Record<string, unknown>): GovernanceRescanJobCreateCommand {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw governanceRescanJobCreateInvalid('Governance rescan job create payload must be an object.');
    }
    const source = payload as Record<string, unknown>;
    const scopeType = this.readScopeType(source.scopeType);
    const windowStart = this.readDate(source.windowStart, 'windowStart');
    const windowEnd = this.readDate(source.windowEnd, 'windowEnd');
    if (windowEnd.getTime() <= windowStart.getTime()) {
      throw governanceRescanJobCreateInvalid('windowEnd must be later than windowStart.');
    }

    return {
      scopeType,
      windowStart,
      windowEnd,
      reason: this.readRequiredText(source.reason, 'reason', 1000),
      ruleSetVersion: this.readOptionalText(source.ruleSetVersion, 'ruleSetVersion', 64, 'forum_content_rescan_v1'),
      engineMode: this.readOptionalText(source.engineMode, 'engineMode', 64, 'bounded_rules')
    };
  }

  private readScopeType(value: unknown) {
    const normalized = this.readRequiredText(value, 'scopeType', 32);
    if (!GOVERNANCE_RESCAN_SCOPE_TYPES.includes(normalized as GovernanceRescanScopeType)) {
      throw governanceRescanJobCreateInvalid('scopeType is invalid.');
    }
    return normalized as GovernanceRescanScopeType;
  }

  private readDate(value: unknown, field: string) {
    const normalized = this.readRequiredText(value, field, 64);
    const parsed = new Date(normalized);
    if (Number.isNaN(parsed.getTime())) {
      throw governanceRescanJobCreateInvalid(`${field} is invalid.`);
    }
    return parsed;
  }

  private parseSnapshot(value: string | null) {
    if (!value) {
      return null;
    }
    try {
      const parsed = JSON.parse(value) as Record<string, unknown>;
      return {
        targetType: typeof parsed.targetType === 'string' ? parsed.targetType.trim() : '',
        publishedAt: typeof parsed.publishedAt === 'string' ? parsed.publishedAt.trim() : ''
      };
    } catch {
      return null;
    }
  }

  private parseDate(value: string) {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private isSupportedTargetType(value: string) {
    return value === 'post' || value === 'comment';
  }

  private isWithinWindow(value: Date, windowStart: Date, windowEnd: Date) {
    return value.getTime() >= windowStart.getTime() && value.getTime() < windowEnd.getTime();
  }

  private readId(value: unknown, fieldName: string) {
    const normalized = this.readRequiredText(value, fieldName, 64);
    if (!/^[a-zA-Z0-9._:-]{4,64}$/.test(normalized)) {
      throw governanceRescanJobCreateInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readRequiredText(value: unknown, fieldName: string, maxLength: number) {
    if (typeof value !== 'string') {
      throw governanceRescanJobCreateInvalid(`${fieldName} is required.`);
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > maxLength) {
      throw governanceRescanJobCreateInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readOptionalText(
    value: unknown,
    fieldName: string,
    maxLength: number,
    fallback: string
  ) {
    if (value === undefined || value === null || value === '') {
      return fallback;
    }
    if (typeof value !== 'string') {
      throw governanceRescanJobCreateInvalid(`${fieldName} is invalid.`);
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > maxLength) {
      throw governanceRescanJobCreateInvalid(`${fieldName} is invalid.`);
    }
    return normalized;
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound: number) {
    const parsed =
      typeof value === 'string'
        ? Number.parseInt(value, 10)
        : typeof value === 'number'
          ? value
          : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }
}

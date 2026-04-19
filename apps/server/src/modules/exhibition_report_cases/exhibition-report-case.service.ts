import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  canDecide,
  canEscalate,
  canRequestExplanation,
  readListQuery,
  readReportCaseId,
  toDecideCommand,
  toEscalateCommand,
  toRequestExplanationCommand
} from './exhibition-report-case.command-reader';
import {
  exhibitionReportDecideInvalid,
  exhibitionReportEscalateInvalid,
  exhibitionReportInvalid,
  exhibitionReportInvalidState,
  exhibitionReportRequestExplanationInvalid,
  exhibitionReportResourceUnavailable
} from './exhibition-report-case.errors';
import { ExhibitionReportCasePresenter } from './exhibition-report-case.presenter';
import { ExhibitionReportCaseEntity } from './entities/exhibition-report-case.entity';

@Injectable()
export class ExhibitionReportCaseService {
  constructor(
    @InjectRepository(ExhibitionReportCaseEntity)
    private readonly reportCaseRepository: Repository<ExhibitionReportCaseEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly dataSource: DataSource,
    private readonly presenter: ExhibitionReportCasePresenter
  ) {}

  async list(query: Record<string, unknown>, context: RequestContext) {
    await this.requireReviewer(context);
    const normalizedQuery = readListQuery(query, exhibitionReportInvalid);
    const qb = this.reportCaseRepository.createQueryBuilder('report_case');

    if (normalizedQuery.status) {
      qb.andWhere('report_case.status = :status', { status: normalizedQuery.status });
    }
    if (normalizedQuery.targetType) {
      qb.andWhere('report_case.target_type = :targetType', {
        targetType: normalizedQuery.targetType
      });
    }
    if (normalizedQuery.keyword) {
      qb.andWhere(
        `(report_case.target_id ILIKE :keyword
          OR report_case.reason_code ILIKE :keyword
          OR COALESCE(report_case.reason_detail, '') ILIKE :keyword
          OR COALESCE(report_case.review_task_id, '') ILIKE :keyword
          OR COALESCE(report_case.governance_ticket_ref, '') ILIKE :keyword)`,
        { keyword: `%${normalizedQuery.keyword}%` }
      );
    }

    const total = await qb.getCount();
    const items = await qb
      .orderBy('report_case.created_at', 'DESC')
      .offset((normalizedQuery.page - 1) * normalizedQuery.pageSize)
      .limit(normalizedQuery.pageSize)
      .getMany();

    return {
      items: items.map((item) => this.presenter.toListItem(item)),
      pagination: this.presenter.toPagination(
        normalizedQuery.page,
        normalizedQuery.pageSize,
        total
      )
    };
  }

  async detail(reportCaseId: string, context: RequestContext) {
    await this.requireReviewer(context);
    const reportCase = await this.requireReportCase(
      reportCaseId,
      exhibitionReportInvalid,
      exhibitionReportResourceUnavailable
    );
    return this.presenter.toDetail(reportCase);
  }

  async requestExplanation(
    reportCaseId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const reviewer = await this.requireReviewer(context);
    const command = toRequestExplanationCommand(
      payload,
      exhibitionReportRequestExplanationInvalid
    );
    const id = readReportCaseId(
      reportCaseId,
      'reportCaseId',
      exhibitionReportRequestExplanationInvalid
    );
    const now = new Date();

    await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ExhibitionReportCaseEntity);
      const reportCase = await repository.findOneBy({ id });
      if (!reportCase) {
        throw exhibitionReportResourceUnavailable('Exhibition report case resource is unavailable.');
      }
      if (!canRequestExplanation(reportCase.status)) {
        throw exhibitionReportInvalidState(
          'Exhibition report case cannot request explanation in current state.'
        );
      }

      reportCase.status = 'explanation_requested';
      reportCase.explanationRequestedAt = now;
      reportCase.explanationDueAt = command.dueAt;
      reportCase.updatedAt = now;
      reportCase.metadata = {
        ...reportCase.metadata,
        explanationQuestion: command.question
      };
      await repository.save(reportCase);

      await this.auditService.record(
        {
          subjectType: 'exhibition_report_case',
          subjectId: reportCase.id,
          userId: reportCase.reporterUserId,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'exhibition_report_case_request_explanation',
          engineType: 'manual',
          decision: reportCase.status,
          reasonCode: 'request_explanation',
          reason: command.question,
          matchedRuleIds: [],
          metadata: {
            reportCaseId: reportCase.id,
            targetType: reportCase.targetType,
            targetId: reportCase.targetId,
            dueAt: command.dueAt?.toISOString() ?? null
          }
        },
        context,
        manager
      );
    });

    return this.presenter.toActionAck(context.traceId);
  }

  async decide(reportCaseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const reviewer = await this.requireReviewer(context);
    const command = toDecideCommand(payload, exhibitionReportDecideInvalid);
    const id = readReportCaseId(reportCaseId, 'reportCaseId', exhibitionReportDecideInvalid);
    const now = new Date();

    await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ExhibitionReportCaseEntity);
      const reportCase = await repository.findOneBy({ id });
      if (!reportCase) {
        throw exhibitionReportResourceUnavailable('Exhibition report case resource is unavailable.');
      }
      if (!canDecide(reportCase.status)) {
        throw exhibitionReportInvalidState(
          'Exhibition report case cannot be decided in current state.'
        );
      }

      const previousStatus = reportCase.status;
      const previousRestriction = reportCase.temporaryRestrictionState;
      reportCase.status = 'decided';
      reportCase.adjudicationResult = command.adjudicationResult;
      reportCase.decisionNote = command.decisionNote;
      reportCase.decidedAt = now;
      reportCase.updatedAt = now;
      if (
        command.adjudicationResult === 'not_established' &&
        reportCase.temporaryRestrictionState === 'active'
      ) {
        reportCase.temporaryRestrictionState = 'lifted';
      }
      await repository.save(reportCase);

      await this.auditService.record(
        {
          subjectType: 'exhibition_report_case',
          subjectId: reportCase.id,
          userId: reportCase.reporterUserId,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'exhibition_report_case_decide',
          engineType: 'manual',
          decision: command.adjudicationResult,
          reasonCode: 'report_case_decide',
          reason: command.decisionNote,
          matchedRuleIds: [],
          metadata: {
            reportCaseId: reportCase.id,
            previousStatus,
            nextStatus: reportCase.status,
            previousTemporaryRestrictionState: previousRestriction,
            nextTemporaryRestrictionState: reportCase.temporaryRestrictionState
          }
        },
        context,
        manager
      );
    });

    return this.presenter.toActionAck(context.traceId);
  }

  async escalate(
    reportCaseId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const reviewer = await this.requireReviewer(context);
    const command = toEscalateCommand(payload, exhibitionReportEscalateInvalid);
    const id = readReportCaseId(reportCaseId, 'reportCaseId', exhibitionReportEscalateInvalid);
    const now = new Date();

    await this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ExhibitionReportCaseEntity);
      const reportCase = await repository.findOneBy({ id });
      if (!reportCase) {
        throw exhibitionReportResourceUnavailable('Exhibition report case resource is unavailable.');
      }
      if (!canEscalate(reportCase.status)) {
        throw exhibitionReportInvalidState(
          'Exhibition report case cannot be escalated in current state.'
        );
      }

      const governanceTicketRef =
        reportCase.governanceTicketRef ?? `gov-${randomUUID().replace(/-/g, '').slice(0, 24)}`;
      reportCase.status = 'escalated';
      reportCase.governanceTicketRef = governanceTicketRef;
      if (reportCase.temporaryRestrictionState === 'not_applied') {
        reportCase.temporaryRestrictionState = 'active';
      }
      reportCase.updatedAt = now;
      reportCase.metadata = {
        ...reportCase.metadata,
        escalationReason: command.reason
      };
      await repository.save(reportCase);

      await this.auditService.record(
        {
          subjectType: 'exhibition_report_case',
          subjectId: reportCase.id,
          userId: reportCase.reporterUserId,
          actorId: reviewer.currentSession.actorId,
          actorRole: reviewer.actorRole,
          action: 'exhibition_report_case_escalate',
          engineType: 'manual',
          decision: reportCase.status,
          reasonCode: 'report_case_escalate',
          reason: command.reason,
          matchedRuleIds: [],
          metadata: {
            reportCaseId: reportCase.id,
            governanceTicketId: governanceTicketRef,
            temporaryRestrictionState: reportCase.temporaryRestrictionState
          }
        },
        context,
        manager
      );
    });

    return this.presenter.toActionAck(context.traceId);
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private async requireReportCase(
    value: unknown,
    invalidError: (message: string) => Error,
    unavailableError: (message: string) => Error
  ) {
    const id = readReportCaseId(value, 'reportCaseId', invalidError);
    const reportCase = await this.reportCaseRepository.findOneBy({ id });
    if (!reportCase) {
      throw unavailableError('Exhibition report case resource is unavailable.');
    }
    return reportCase;
  }
}

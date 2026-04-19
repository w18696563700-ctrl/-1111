import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';
import { forumReportInvalid, forumReportUnavailable } from './forum.errors';
import { ForumReportPresenter } from './forum-report.presenter';

const DEFAULT_MY_REPORT_LIMIT = 50;
const MAX_MY_REPORT_LIMIT = 100;

@Injectable()
export class ForumReportQueryService {
  constructor(
    @InjectRepository(ForumReportTicketEntity)
    private readonly reportRepository: Repository<ForumReportTicketEntity>,
    private readonly presenter: ForumReportPresenter,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async listLatestReportTickets(limit = 50) {
    const tickets = await this.reportRepository.find({
      order: { createdAt: 'DESC' },
      take: Math.max(1, Math.min(limit, 100))
    });
    return {
      items: tickets.map((ticket) => this.presenter.toReadModel(ticket))
    };
  }

  async getReportTicket(reportTicketId: string) {
    const normalized = reportTicketId.trim();
    const ticket = normalized
      ? await this.reportRepository.findOneBy({ id: normalized })
      : null;
    return ticket ? this.presenter.toReadModel(ticket) : null;
  }

  async listMine(query: Record<string, unknown>, context: RequestContext) {
    const currentSession = await this.loadCurrentReporter(context);
    const tickets = await this.reportRepository.find({
      where: { reporterUserId: currentSession.userId },
      order: { createdAt: 'DESC' },
      take: this.readLimit(query.limit)
    });
    return this.presenter.toMyReportListResponse(tickets, context.traceId);
  }

  async getMineReportTicket(ticketId: string, context: RequestContext) {
    const currentSession = await this.loadCurrentReporter(context);
    const ticket = await this.reportRepository.findOneBy({
      id: this.readTicketId(ticketId),
      reporterUserId: currentSession.userId
    });
    if (!ticket) {
      throw forumReportUnavailable('Forum report ticket is unavailable for the current reporter.');
    }
    return this.presenter.toMyReportDetail(ticket);
  }

  private async loadCurrentReporter(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    return currentSession;
  }

  private readLimit(value: unknown) {
    const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return DEFAULT_MY_REPORT_LIMIT;
    }
    return Math.min(parsed, MAX_MY_REPORT_LIMIT);
  }

  private readTicketId(value: string) {
    const normalized = value.trim();
    if (!normalized || normalized.length > 64) {
      throw forumReportInvalid('ticketId is invalid for my forum report detail.');
    }
    return normalized;
  }
}

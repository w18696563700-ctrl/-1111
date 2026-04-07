import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';
import { ForumReportPresenter } from './forum-report.presenter';

@Injectable()
export class ForumReportQueryService {
  constructor(
    @InjectRepository(ForumReportTicketEntity)
    private readonly reportRepository: Repository<ForumReportTicketEntity>,
    private readonly presenter: ForumReportPresenter
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
}

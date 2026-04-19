import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { auditLogQueryInvalid, auditLogResourceUnavailable } from './audit-log.errors';
import { matchesAuditLogFilters, readAuditLogListQuery } from './audit-log.query';
import { AuditLogPresenter } from './audit-log.presenter';
import { IdentityAuditLogEntity } from './identity-audit-log.entity';
import { ProjectPublishAuditLogEntity } from './project-publish-audit-log.entity';

@Injectable()
export class AuditLogQueryService {
  constructor(
    @InjectRepository(IdentityAuditLogEntity)
    private readonly identityAuditRepository: Repository<IdentityAuditLogEntity>,
    @InjectRepository(ProjectPublishAuditLogEntity)
    private readonly projectPublishAuditRepository: Repository<ProjectPublishAuditLogEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: AuditLogPresenter
  ) {}

  async list(query: Record<string, unknown>, context: RequestContext) {
    await this.requireReviewer(context);
    const normalizedQuery = readAuditLogListQuery(query, auditLogQueryInvalid);
    const [identityRows, projectPublishRows] = await Promise.all([
      normalizedQuery.sourceFamily === 'project_publish'
        ? []
        : this.identityAuditRepository.find(),
      normalizedQuery.sourceFamily === 'identity'
        ? []
        : this.projectPublishAuditRepository.find()
    ]);

    const items = [
      ...identityRows.map((row) => this.presenter.fromIdentity(row)),
      ...projectPublishRows.map((row) => this.presenter.fromProjectPublish(row))
    ]
      .filter((item) => matchesAuditLogFilters(item, normalizedQuery))
      .sort((left, right) => Date.parse(right.occurredAt) - Date.parse(left.occurredAt));

    const total = items.length;
    const paged = items.slice(
      (normalizedQuery.page - 1) * normalizedQuery.pageSize,
      normalizedQuery.page * normalizedQuery.pageSize
    );

    return {
      items: paged.map((item) => this.presenter.toListItem(item)),
      pagination: this.presenter.toPagination(
        normalizedQuery.page,
        normalizedQuery.pageSize,
        total
      )
    };
  }

  async detail(auditLogId: string, context: RequestContext) {
    await this.requireReviewer(context);
    const parsed = this.presenter.parseAuditLogId(auditLogId);
    if (!parsed) {
      throw auditLogQueryInvalid('auditLogId is invalid.');
    }

    if (parsed.sourceFamily === 'identity') {
      const entry = await this.identityAuditRepository.findOneBy({ id: parsed.rawId });
      if (!entry) {
        throw auditLogResourceUnavailable('Audit log resource is unavailable.');
      }
      return this.presenter.toDetail(this.presenter.fromIdentity(entry));
    }

    const entry = await this.projectPublishAuditRepository.findOneBy({ id: parsed.rawId });
    if (!entry) {
      throw auditLogResourceUnavailable('Audit log resource is unavailable.');
    }
    return this.presenter.toDetail(this.presenter.fromProjectPublish(entry));
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireReviewer(currentSession);
  }
}

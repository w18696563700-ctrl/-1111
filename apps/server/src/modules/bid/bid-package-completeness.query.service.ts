import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { RequestContext } from '../../shared/request-context';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidEntity } from './entities/bid.entity';
import { BidPresenter } from './bid.presenter';
import {
  bidPackageCompletenessInvalid,
  bidPackageCompletenessUnavailable
} from './bid.errors';

const BUYER_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const SUPPLIER_ROLE_KEYS = new Set(['supplier_admin', 'supplier_member(scoped)']);

type CompletenessCommand = {
  projectId: string;
  bidId: string;
};

@Injectable()
export class BidPackageCompletenessQueryService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly presenter: BidPresenter
  ) {}

  async getPackageCompleteness(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCompletenessCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw bidPackageCompletenessUnavailable('Current bid package completeness is unavailable.');
    }
    const canReadBuyer = scope.roleKeys.some((roleKey) => BUYER_ROLE_KEYS.has(roleKey));
    const canReadSupplier = scope.roleKeys.some((roleKey) => SUPPLIER_ROLE_KEYS.has(roleKey));
    if (!canReadBuyer && !canReadSupplier) {
      throw bidPackageCompletenessUnavailable('Current bid package completeness is unavailable.');
    }

    return this.dataSource.transaction(async (manager) => {
      const auditContext = {
        ...context,
        actorId: currentSession.actorId,
        userId: currentSession.userId,
        organizationId: scope.organization.id,
        requestId: currentSession.requestId,
        traceId: currentSession.traceId
      };

      const buyerCandidate = canReadBuyer
        ? await this.loadBuyerCandidate(command, scope.organization.id)
        : null;
      const candidate =
        buyerCandidate ?? (canReadSupplier
          ? await this.loadSupplierCandidate(command, scope.organization.id)
          : null);
      if (!candidate) {
        throw bidPackageCompletenessUnavailable('Current bid package completeness is unavailable.');
      }

      const { project, bid } = candidate;
      const quoteAmountReady = this.toPositiveNumber(bid.quoteAmount) > 0;
      const proposalSummaryReady = this.hasText(bid.proposalSummary);
      const missingItems: string[] = [];
      if (!quoteAmountReady) {
        missingItems.push('quote_amount');
      }
      if (!proposalSummaryReady) {
        missingItems.push('proposal_summary');
      }

      const state = missingItems.length === 0 ? 'complete' : 'incomplete';
      await this.auditService.record(
        {
          aggregateType: 'bid_package_completeness',
          aggregateId: bid.id,
          eventType: 'bid_completeness_evaluated',
          payload: {
            projectId: project.id,
            bidId: bid.id,
            actorUserId: currentSession.userId,
            actorOrgId: scope.organization.id,
            result: state,
            state,
            missingItems,
            quoteAmountReady,
            proposalSummaryReady,
            submittedAt: bid.createdAt.toISOString()
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toPackageCompletenessResponse({
        projectId: project.id,
        bidId: bid.id,
        state,
        missingItems,
        quoteAmountReady,
        proposalSummaryReady
      });
    });
  }

  private async loadBuyerCandidate(command: CompletenessCommand, organizationId: string) {
    const project = await this.projectRepository.findOneBy({
      id: command.projectId,
      organizationId
    });
    if (!project || project.state !== 'published' || project.publishedAt === null) {
      return null;
    }

    const bid = await this.bidRepository.findOneBy({
      id: command.bidId,
      projectId: project.id,
      state: 'submitted'
    });
    if (!bid) {
      return null;
    }

    return { project, bid } as const;
  }

  private async loadSupplierCandidate(command: CompletenessCommand, organizationId: string) {
    const bid = await this.bidRepository.findOneBy({
      id: command.bidId,
      projectId: command.projectId,
      organizationId,
      state: 'submitted'
    });
    if (!bid) {
      return null;
    }

    const project = await this.projectRepository.findOneBy({
      id: command.projectId
    });
    if (!project || project.state !== 'published' || project.publishedAt === null) {
      return null;
    }

    return { project, bid } as const;
  }

  private toCompletenessCommand(payload: Record<string, unknown>): CompletenessCommand {
    const source = this.asRecord(payload);
    return {
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      bidId: this.readRequiredString(source.bidId, 'bidId')
    };
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw bidPackageCompletenessInvalid('Bid package completeness body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw bidPackageCompletenessInvalid(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw bidPackageCompletenessInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private hasText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return Boolean(normalized);
  }

  private toPositiveNumber(value: string | number) {
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      return 0;
    }
    return parsed;
  }
}

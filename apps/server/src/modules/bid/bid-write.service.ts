import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidEntity } from './entities/bid.entity';
import { BidPresenter } from './bid.presenter';
import {
  bidDuplicateSubmission,
  bidResourceUnavailable,
  bidSubmitInvalid
} from './bid.errors';

type SubmitBidCommand = {
  projectId: string;
  quoteAmount: number;
  proposalSummary: string;
};

@Injectable()
export class BidWriteService {
  constructor(
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: BidPresenter
  ) {}

  async submitBid(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSubmitBidCommand(payload);
    const project = await this.projectRepository.findOneBy({ id: command.projectId });
    if (!project) {
      throw bidResourceUnavailable('Current project is unavailable for bid submit.');
    }

    const { currentSession, scope } =
      await this.eligibilityService.requireBidSubmitEligibilityFromContext(
        context,
        this.currentSessionVerificationService,
        project
      );
    const bidId = randomUUID();
    const submittedAt = new Date();
    const submittedBy = this.resolveSubmittedBy(currentSession.actorId, currentSession.userId);
    const bid = this.bidRepository.create({
      id: bidId,
      bidNo: this.buildBidNo(project.projectNo, bidId),
      projectId: project.id,
      bidderOrganizationId: scope.organization.id,
      organizationId: scope.organization.id,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      quoteAmount: command.quoteAmount.toFixed(2),
      proposalSummary: command.proposalSummary,
      state: 'submitted',
      submittedBy,
      submittedAt
    });

    try {
      await this.dataSource.transaction(async (manager) => {
        const bidRepository = manager.getRepository(BidEntity);
        const existingBid = await bidRepository.findOneBy({
          projectId: project.id,
          bidderOrganizationId: scope.organization.id
        });
        if (existingBid) {
          throw bidDuplicateSubmission('Current actor has already submitted a bid for this project.');
        }

        await bidRepository.save(bid);
        await manager.getRepository(IdentityAuditLogEntity).save({
          id: randomUUID(),
          objectType: 'bid',
          objectId: bid.id,
          objectNo: project.projectNo,
          action: 'BidSubmitted',
          actorId: currentSession.userId,
          actorRole: scope.membership.roleKey,
          beforeState: '',
          afterState: bid.state,
          reason: `projectId=${project.id}; quoteAmount=${bid.quoteAmount}`,
          requestId: context.requestId,
          traceId: context.traceId,
          occurredAt: new Date()
        });
      });
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw bidDuplicateSubmission('Current actor has already submitted a bid for this project.');
      }
      throw error;
    }

    return this.presenter.toAcceptedResponse(bid.id);
  }

  private toSubmitBidCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      quoteAmount: this.readQuoteAmount(source.quoteAmount),
      proposalSummary: this.readRequiredString(source.proposalSummary, 'proposalSummary')
    } satisfies SubmitBidCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw bidSubmitInvalid('Bid submit body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw bidSubmitInvalid(`Field \`${field}\` is required for bid submit.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw bidSubmitInvalid(`Field \`${field}\` is required for bid submit.`);
    }
    return normalized;
  }

  private readQuoteAmount(value: unknown) {
    const amount = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(amount) || amount <= 0) {
      throw bidSubmitInvalid('Field `quoteAmount` must be a positive number for bid submit.');
    }
    return amount;
  }

  private buildBidNo(projectNo: string, bidId: string) {
    const normalizedProjectNo = projectNo.trim();
    const suffix = bidId.replace(/-/g, '').slice(0, 12).toUpperCase();
    const prefixSource = normalizedProjectNo ? `BID-${normalizedProjectNo}` : 'BID';
    const maxPrefixLength = Math.max(0, 64 - suffix.length - 1);
    const prefix = prefixSource.slice(0, maxPrefixLength);
    return `${prefix}-${suffix}`;
  }

  private resolveSubmittedBy(actorId: string | null | undefined, userId: string | null | undefined) {
    const submittedBy = this.readOptionalText(actorId) ?? this.readOptionalText(userId);
    if (!submittedBy) {
      throw bidResourceUnavailable('Current bid submit actor is unavailable.');
    }
    return submittedBy;
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}

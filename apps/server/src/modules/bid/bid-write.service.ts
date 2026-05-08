import { Injectable } from '@nestjs/common';
import { createHash, randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { BidParticipationRequestAccessService } from '../bid_participation_request/bid-participation-request-access.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectCommunicationMaterialReviewEntity } from '../project_communication/entities/project-communication-material-review.entity';
import { ProjectCommunicationBusinessEventService } from '../project_communication/project-communication-business-event.service';
import type {
  ProjectBidMaterialSlot,
  ProjectCommunicationMaterialReviewEntryKey
} from '../project_communication/project-communication-workbench.types';
import { BidSubmittedSeedService } from '../trading_im/bid-submitted-seed.service';
import { BidSubmissionAttachmentTruthService } from './bid-submission-attachment-truth.service';
import { BidEntity } from './entities/bid.entity';
import { BidPresenter } from './bid.presenter';
import {
  bidDuplicateSubmission,
  bidPermissionDenied,
  bidResourceUnavailable,
  bidSupplementConflict,
  bidSubmitInvalid
} from './bid.errors';

type SubmitBidCommand = {
  projectId: string;
  quoteAmount: number;
  proposalSummary: string;
  projectUnderstandingFileAssetId: string;
  quoteSheetFileAssetId: string;
  schedulePlanFileAssetId: string;
};

type SupplementBidSubmissionCommand = SubmitBidCommand & {
  bidId: string;
  entryKey: ProjectCommunicationMaterialReviewEntryKey;
  bidMaterialSlot: ProjectBidMaterialSlot | null;
  sourceVersionToken: string;
};

const BID_SUPPLEMENT_ENTRY_SLOTS: Record<string, ProjectBidMaterialSlot> = {
  bid_project_understanding_review: 'project_understanding',
  bid_quote_sheet_review: 'quote_sheet',
  bid_schedule_plan_review: 'schedule_plan'
};

@Injectable()
export class BidWriteService {
  constructor(
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(ProjectCommunicationMaterialReviewEntity)
    private readonly materialReviewRepository: Repository<ProjectCommunicationMaterialReviewEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly bidSubmissionAttachmentTruthService: BidSubmissionAttachmentTruthService,
    private readonly bidSubmittedSeedService: BidSubmittedSeedService,
    private readonly presenter: BidPresenter,
    private readonly bidParticipationAccessService: BidParticipationRequestAccessService,
    private readonly projectCommunicationBusinessEventService?: ProjectCommunicationBusinessEventService
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
    await this.bidParticipationAccessService.requireApprovedForOrganization(
      project,
      scope.organization.id,
    );
    const bidId = randomUUID();
    const submittedAt = new Date();
    const submittedBy = this.resolveSubmittedBy(currentSession.actorId, currentSession.userId);
    const attachments = await this.bidSubmissionAttachmentTruthService.validateAndNormalize(
      {
        projectUnderstandingFileAssetId: command.projectUnderstandingFileAssetId,
        quoteSheetFileAssetId: command.quoteSheetFileAssetId,
        schedulePlanFileAssetId: command.schedulePlanFileAssetId,
      },
      project.id,
      scope.organization.id,
    );
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
      projectUnderstandingFileAssetId: attachments.projectUnderstandingFileAssetId,
      quoteSheetFileAssetId: attachments.quoteSheetFileAssetId,
      schedulePlanFileAssetId: attachments.schedulePlanFileAssetId,
      state: 'submitted',
      submittedBy,
      submittedAt
    });

    let threadId = '';
    let seedMessageId = '';
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
        const seed = await this.bidSubmittedSeedService.createForSubmittedBid({
          manager,
          project,
          bid,
          bidderDisplayName: scope.organization.name ?? ''
        });
        await this.projectCommunicationBusinessEventService?.emitBidSubmitted({
          manager,
          project,
          bid,
          actorUserId: currentSession.userId,
          actorId: currentSession.actorId
        });
        threadId = seed.threadId;
        seedMessageId = seed.seedMessageId;
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
          reason: `projectId=${project.id}; bidderOrganizationId=${scope.organization.id}; quoteAmount=${bid.quoteAmount}; projectUnderstandingFileAssetId=${bid.projectUnderstandingFileAssetId}; quoteSheetFileAssetId=${bid.quoteSheetFileAssetId}; schedulePlanFileAssetId=${bid.schedulePlanFileAssetId}`,
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

    return this.presenter.toAcceptedResponse({
      bidId: bid.id,
      projectId: project.id,
      threadId,
      seedMessageId
    });
  }

  async supplementBidSubmission(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSupplementBidSubmissionCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw bidPermissionDenied('Current organization scope is required for bid supplement.');
    }

    const [project, bid] = await Promise.all([
      this.projectRepository.findOneBy({ id: command.projectId }),
      this.bidRepository.findOneBy({ id: command.bidId })
    ]);
    if (!project || !bid || bid.projectId !== project.id) {
      throw bidResourceUnavailable('Current bid supplement resource is unavailable.');
    }
    const bidderOrganizationId = this.bidderOrganizationId(bid);
    if (bidderOrganizationId !== scope.organization.id) {
      throw bidPermissionDenied('Current organization cannot supplement this bid.');
    }
    await this.bidParticipationAccessService.requireApprovedForOrganization(
      project,
      scope.organization.id
    );

    const expectedSlot = this.expectedSupplementSlot(command);
    const review = await this.materialReviewRepository.findOneBy({
      projectId: project.id,
      bidId: bid.id,
      reviewerOrganizationId: project.organizationId,
      entryKey: command.entryKey
    });
    this.assertSupplementReviewWritable(review, expectedSlot, command);

    const attachments = await this.bidSubmissionAttachmentTruthService.validateAndNormalize(
      {
        projectUnderstandingFileAssetId: command.projectUnderstandingFileAssetId,
        quoteSheetFileAssetId: command.quoteSheetFileAssetId,
        schedulePlanFileAssetId: command.schedulePlanFileAssetId
      },
      project.id,
      bidderOrganizationId
    );
    const refreshedAt = new Date();

    await this.dataSource.transaction(async (manager) => {
      const bidRepository = manager.getRepository(BidEntity);
      const reviewRepository = manager.getRepository(ProjectCommunicationMaterialReviewEntity);
      const currentBid = await bidRepository.findOneBy({ id: bid.id });
      const currentReview = await reviewRepository.findOneBy({
        projectId: project.id,
        bidId: bid.id,
        reviewerOrganizationId: project.organizationId,
        entryKey: command.entryKey
      });
      if (!currentBid || currentBid.projectId !== project.id) {
        throw bidResourceUnavailable('Current bid supplement resource is unavailable.');
      }
      if (this.bidderOrganizationId(currentBid) !== bidderOrganizationId) {
        throw bidPermissionDenied('Current organization cannot supplement this bid.');
      }
      this.assertSupplementReviewWritable(currentReview, expectedSlot, command);

      currentBid.quoteAmount = command.quoteAmount.toFixed(2);
      currentBid.proposalSummary = command.proposalSummary;
      currentBid.projectUnderstandingFileAssetId = attachments.projectUnderstandingFileAssetId;
      currentBid.quoteSheetFileAssetId = attachments.quoteSheetFileAssetId;
      currentBid.schedulePlanFileAssetId = attachments.schedulePlanFileAssetId;
      currentBid.updatedAt = refreshedAt;
      await bidRepository.save(currentBid);

      currentReview!.reviewState = 'pending_review';
      currentReview!.feedbackReasonCodes = [];
      currentReview!.feedbackText = null;
      currentReview!.feedbackByUserId = null;
      currentReview!.feedbackAt = null;
      currentReview!.confirmedByUserId = null;
      currentReview!.confirmedAt = null;
      currentReview!.sourceVersionToken = this.bidMaterialSourceVersionToken(
        currentBid,
        expectedSlot,
        refreshedAt
      );
      currentReview!.requestId = context.requestId;
      currentReview!.traceId = context.traceId;
      await reviewRepository.save(currentReview!);

      await this.projectCommunicationBusinessEventService?.emitBidMaterialSupplementSubmitted({
        manager,
        project,
        bid: currentBid,
        review: currentReview!,
        actorUserId: currentSession.userId,
        actorId: currentSession.actorId
      });
      await manager.getRepository(IdentityAuditLogEntity).save({
        id: randomUUID(),
        objectType: 'bid',
        objectId: currentBid.id,
        objectNo: project.projectNo,
        action: 'BidMaterialSupplemented',
        actorId: currentSession.userId,
        actorRole: scope.membership.roleKey,
        beforeState: 'needs_supplement',
        afterState: 'pending_review',
        reason: `projectId=${project.id}; bidId=${currentBid.id}; entryKey=${command.entryKey}; slot=${expectedSlot}`,
        requestId: context.requestId,
        traceId: context.traceId,
        occurredAt: new Date()
      });
    });

    return this.presenter.toSupplementAcceptedResponse({
      bidId: bid.id,
      projectId: project.id,
      entryKey: command.entryKey
    });
  }

  private toSubmitBidCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      quoteAmount: this.readQuoteAmount(source.quoteAmount),
      proposalSummary: this.readRequiredString(source.proposalSummary, 'proposalSummary'),
      projectUnderstandingFileAssetId: this.readRequiredString(
        source.projectUnderstandingFileAssetId,
        'projectUnderstandingFileAssetId',
      ),
      quoteSheetFileAssetId: this.readRequiredString(
        source.quoteSheetFileAssetId,
        'quoteSheetFileAssetId',
      ),
      schedulePlanFileAssetId: this.readRequiredString(
        source.schedulePlanFileAssetId,
        'schedulePlanFileAssetId',
      ),
    } satisfies SubmitBidCommand;
  }

  private toSupplementBidSubmissionCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      ...this.toSubmitBidCommand(payload),
      bidId: this.readRequiredString(source.bidId, 'bidId'),
      entryKey: this.readRequiredString(
        source.entryKey,
        'entryKey'
      ) as ProjectCommunicationMaterialReviewEntryKey,
      bidMaterialSlot: this.readOptionalBidMaterialSlot(source.bidMaterialSlot),
      sourceVersionToken: this.readRequiredString(
        source.sourceVersionToken,
        'sourceVersionToken'
      )
    } satisfies SupplementBidSubmissionCommand;
  }

  private readOptionalBidMaterialSlot(value: unknown) {
    if (value === null || value === undefined || value === '') {
      return null;
    }
    const normalized = this.readRequiredString(value, 'bidMaterialSlot');
    if (
      normalized !== 'project_understanding' &&
      normalized !== 'quote_sheet' &&
      normalized !== 'schedule_plan'
    ) {
      throw bidSubmitInvalid('Field `bidMaterialSlot` is invalid for bid supplement.');
    }
    return normalized as ProjectBidMaterialSlot;
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

  private expectedSupplementSlot(command: SupplementBidSubmissionCommand) {
    const slot = BID_SUPPLEMENT_ENTRY_SLOTS[command.entryKey];
    if (!slot) {
      throw bidSubmitInvalid('Field `entryKey` is invalid for bid supplement.');
    }
    if (command.bidMaterialSlot && command.bidMaterialSlot !== slot) {
      throw bidSubmitInvalid('Field `bidMaterialSlot` does not match bid supplement entry.');
    }
    return slot;
  }

  private assertSupplementReviewWritable(
    review: ProjectCommunicationMaterialReviewEntity | null,
    expectedSlot: ProjectBidMaterialSlot,
    command: SupplementBidSubmissionCommand
  ) {
    if (!review) {
      throw bidSupplementConflict('Current bid material review is unavailable for supplement.');
    }
    if (
      review.subjectType !== 'bid_submission_material' ||
      review.bidMaterialSlot !== expectedSlot ||
      review.entryKey !== command.entryKey
    ) {
      throw bidSupplementConflict('Current bid material review does not match supplement entry.');
    }
    if (review.reviewState !== 'needs_supplement') {
      throw bidSupplementConflict('Current bid material is not waiting for supplement.');
    }
    if (review.sourceVersionToken !== command.sourceVersionToken) {
      throw bidSupplementConflict('Current bid material source has changed.');
    }
  }

  private bidMaterialSourceVersionToken(
    bid: BidEntity,
    slot: ProjectBidMaterialSlot,
    refreshedAt: Date
  ) {
    return createHash('sha256')
      .update(
        [
          bid.id,
          slot,
          this.bidSlotFileAssetId(bid, slot) ?? '',
          refreshedAt.toISOString()
        ].join('|'),
        'utf8'
      )
      .digest('hex');
  }

  private bidSlotFileAssetId(bid: BidEntity, slot: ProjectBidMaterialSlot) {
    if (slot === 'project_understanding') return bid.projectUnderstandingFileAssetId;
    if (slot === 'quote_sheet') return bid.quoteSheetFileAssetId;
    return bid.schedulePlanFileAssetId;
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

  private bidderOrganizationId(bid: BidEntity) {
    return bid.bidderOrganizationId || bid.organizationId;
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}

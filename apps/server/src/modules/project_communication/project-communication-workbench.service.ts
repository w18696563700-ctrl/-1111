import { ConflictException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'crypto';
import { DataSource, In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { BidEntity } from '../bid/entities/bid.entity';
import { ProjectAttachmentEntity } from '../project/entities/project-attachment.entity';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import {
  projectCommunicationForbidden,
  projectCommunicationInvalid,
  projectCommunicationUnavailable,
  projectCommunicationWorkbenchConflict,
  projectCommunicationWorkbenchForbidden,
  projectCommunicationWorkbenchInvalid
} from './project-communication.errors';
import {
  ProjectCommunicationMaterialReviewCommand,
  readOptionalString,
  readRequiredString,
  toProjectCommunicationMaterialReviewCommand
} from './project-communication-workbench-command.parser';
import {
  ProjectCommunicationWorkbenchEntryProjection,
  ProjectCommunicationWorkbenchPresenter,
  ProjectCommunicationWorkbenchSourceFileProjection
} from './project-communication-workbench.presenter';
import {
  ProjectBidMaterialSlot,
  ProjectCommunicationWorkbenchEntryDefinition,
  ProjectCommunicationWorkbenchViewerRole,
  ProjectQuoteBasisMaterialKind,
  projectCommunicationWorkbenchEntryDefinitions
} from './project-communication-workbench.types';

type WorkbenchScope = {
  projectId: string;
  thread: ProjectCommunicationThreadEntity;
  bid: BidEntity | null;
  viewerOrganizationId: string;
  viewerRole: ProjectCommunicationWorkbenchViewerRole;
};

type MaterialSource = {
  attachmentCount: number;
  sourceVersionToken: string | null;
  sourceFiles: ProjectCommunicationWorkbenchSourceFileProjection[];
};

const PUBLISHER_MATERIAL_KINDS: ProjectQuoteBasisMaterialKind[] = [
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
];

const BID_MATERIAL_SLOT_LABELS: Record<ProjectBidMaterialSlot, string> = {
  project_understanding: '项目理解',
  quote_sheet: '报价表',
  schedule_plan: '进度安排'
};

@Injectable()
export class ProjectCommunicationWorkbenchService {
  constructor(
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository: Repository<ProjectCommunicationThreadEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    @InjectRepository(ProjectCommunicationMaterialReviewEntity)
    private readonly reviewRepository: Repository<ProjectCommunicationMaterialReviewEntity>,
    private readonly dataSource: DataSource,
    private readonly accessService: ProjectCommunicationAccessService,
    private readonly presenter: ProjectCommunicationWorkbenchPresenter
  ) {}

  async getWorkbench(query: Record<string, unknown>, context: RequestContext) {
    const scope = await this.resolveScope(query, context);
    const entries = await this.buildEntries(scope);
    return this.presenter.toWorkbench({
      projectId: scope.projectId,
      threadId: scope.thread.id,
      viewerRole: scope.viewerRole,
      entries
    });
  }

  async reviewMaterial(payload: Record<string, unknown>, context: RequestContext) {
    const command = toProjectCommunicationMaterialReviewCommand(payload);
    return this.dataSource.transaction(async (manager) => {
      const scope = await this.resolveScope(
        {
          projectId: command.projectId,
          threadId: command.threadId,
          bidId: command.bidId
        },
        context,
        manager.getRepository(ProjectCommunicationThreadEntity),
        manager.getRepository(BidEntity)
      );
      const entries = await this.buildEntries(
        scope,
        manager.getRepository(ProjectAttachmentEntity),
        manager.getRepository(ProjectCommunicationMaterialReviewEntity)
      );
      const currentEntry = entries.find((entry) => entry.definition.entryKey === command.entryKey);
      if (!currentEntry) {
        throw projectCommunicationWorkbenchInvalid(
          'PROJECT_COMMUNICATION_WORKBENCH_ENTRY_INVALID',
          'Current workbench entry is invalid.'
        );
      }
      this.assertWritableReviewEntry(currentEntry, command, scope);
      const saved = await this.saveReview(currentEntry, command, context, manager.getRepository(ProjectCommunicationMaterialReviewEntity));
      const refreshedEntries = await this.buildEntries(
        scope,
        manager.getRepository(ProjectAttachmentEntity),
        manager.getRepository(ProjectCommunicationMaterialReviewEntity)
      );
      const updatedEntry =
        refreshedEntries.find((entry) => entry.definition.entryKey === saved.entryKey) ?? currentEntry;
      return this.presenter.toMaterialReviewResponse({
        entry: updatedEntry,
        entries: refreshedEntries,
        projectId: scope.projectId,
        threadId: scope.thread.id,
        viewerRole: scope.viewerRole
      });
    });
  }

  private async resolveScope(
    source: Record<string, unknown>,
    context: RequestContext,
    threadRepository = this.threadRepository,
    bidRepository = this.bidRepository
  ): Promise<WorkbenchScope> {
    const projectId = readRequiredString(source.projectId, 'projectId');
    const threadId = readRequiredString(source.threadId, 'threadId');
    const thread = await threadRepository.findOneBy({ id: threadId, projectId });
    if (!thread) {
      throw projectCommunicationUnavailable('Current project communication thread is unavailable.');
    }
    const actor = await this.accessService.requireExistingThreadParticipant(thread, context);
    const bid = await this.resolveBid(projectId, source.bidId, thread, bidRepository);
    return {
      projectId,
      thread,
      bid,
      viewerOrganizationId: actor.organizationId,
      viewerRole: actor.isOwner ? 'publisher' : 'bidder'
    };
  }

  private async resolveBid(
    projectId: string,
    rawBidId: unknown,
    thread: ProjectCommunicationThreadEntity,
    repository: Repository<BidEntity>
  ) {
    const bidId = readOptionalString(rawBidId);
    const where = bidId
      ? { id: bidId, projectId }
      : { projectId, bidderOrganizationId: thread.counterpartOrganizationId };
    const bid = await repository.findOneBy(where);
    if (!bid) {
      return null;
    }
    const bidderOrganizationId = this.bidderOrganizationId(bid);
    if (bid.projectId !== projectId || bidderOrganizationId !== thread.counterpartOrganizationId) {
      throw projectCommunicationForbidden('Current bid is not aligned with this project communication thread.', {
        projectId,
        threadId: thread.id,
        bidId: bid.id
      });
    }
    return bid;
  }

  private async buildEntries(
    scope: WorkbenchScope,
    attachmentRepository = this.attachmentRepository,
    reviewRepository = this.reviewRepository
  ) {
    const publisherSources = await this.publisherMaterialSources(scope.projectId, attachmentRepository);
    const reviews = scope.bid
      ? await reviewRepository.findBy({ projectId: scope.projectId, bidId: scope.bid.id })
      : [];
    return projectCommunicationWorkbenchEntryDefinitions.map((definition) =>
      this.toEntryProjection(definition, scope, publisherSources, reviews)
    );
  }

  private async publisherMaterialSources(
    projectId: string,
    repository: Repository<ProjectAttachmentEntity>
  ) {
    const attachments = await repository.find({
      where: {
        projectId,
        attachmentKind: In(PUBLISHER_MATERIAL_KINDS),
        visibility: 'owner_private'
      },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });
    const grouped = new Map<ProjectQuoteBasisMaterialKind, ProjectAttachmentEntity[]>();
    for (const attachment of attachments) {
      const kind = attachment.attachmentKind as ProjectQuoteBasisMaterialKind;
      grouped.set(kind, [...(grouped.get(kind) ?? []), attachment]);
    }
    const result = new Map<ProjectQuoteBasisMaterialKind, MaterialSource>();
    for (const kind of PUBLISHER_MATERIAL_KINDS) {
      const items = grouped.get(kind) ?? [];
      result.set(kind, {
        attachmentCount: items.length,
        sourceVersionToken: items.length > 0 ? this.hashSource(items.map((item) => `${item.id}:${item.fileAssetId}:${item.createdAt.toISOString()}`)) : null,
        sourceFiles: items.map((item) => ({
          fileAssetId: item.fileAssetId,
          fileName: item.fileName,
          mimeType: item.mimeType,
          sortOrder: item.sortOrder
        }))
      });
    }
    return result;
  }

  private toEntryProjection(
    definition: ProjectCommunicationWorkbenchEntryDefinition,
    scope: WorkbenchScope,
    publisherSources: Map<ProjectQuoteBasisMaterialKind, MaterialSource>,
    reviews: ProjectCommunicationMaterialReviewEntity[]
  ): ProjectCommunicationWorkbenchEntryProjection {
    if (definition.group === 'deal_confirmation') {
      return this.toDealEntry(definition, scope);
    }
    const source = this.resolveMaterialSource(definition, scope, publisherSources);
    const subjectOwnerOrganizationId = definition.subjectOwnerRole === 'publisher'
      ? scope.thread.ownerOrganizationId
      : scope.bid ? this.bidderOrganizationId(scope.bid) : null;
    const reviewerOrganizationId = definition.subjectOwnerRole === 'publisher'
      ? scope.bid ? this.bidderOrganizationId(scope.bid) : scope.thread.counterpartOrganizationId
      : scope.thread.ownerOrganizationId;
    const review = scope.bid
      ? reviews.find((item) => item.entryKey === definition.entryKey && item.reviewerOrganizationId === reviewerOrganizationId) ?? null
      : null;
    const currentReview = review?.sourceVersionToken === source.sourceVersionToken ? review : null;
    const reviewState = source.attachmentCount === 0
      ? 'unsubmitted'
      : currentReview?.reviewState ?? 'pending_review';
    const canAct = source.attachmentCount > 0 &&
      reviewerOrganizationId === scope.viewerOrganizationId &&
      subjectOwnerOrganizationId !== scope.viewerOrganizationId;
    return {
      definition,
      projectId: scope.projectId,
      threadId: scope.thread.id,
      bidId: scope.bid?.id ?? null,
      viewerRole: scope.viewerRole,
      availabilityState: source.attachmentCount > 0 ? 'readable' : 'unsubmitted',
      reviewState,
      actionState: canAct ? 'enabled' : source.attachmentCount > 0 ? 'readonly' : 'blocked',
      attachmentCount: source.attachmentCount,
      review: currentReview,
      subjectOwnerOrganizationId,
      reviewerOrganizationId,
      sourceVersionToken: source.sourceVersionToken,
      sourceFiles: source.sourceFiles
    };
  }

  private toDealEntry(
    definition: ProjectCommunicationWorkbenchEntryDefinition,
    scope: WorkbenchScope
  ): ProjectCommunicationWorkbenchEntryProjection {
    return {
      definition,
      projectId: scope.projectId,
      threadId: scope.thread.id,
      bidId: scope.bid?.id ?? null,
      viewerRole: scope.viewerRole,
      availabilityState: 'unavailable',
      reviewState: null,
      actionState: 'blocked',
      attachmentCount: 0,
      review: null,
      subjectOwnerOrganizationId: null,
      reviewerOrganizationId: null,
      sourceVersionToken: null,
      sourceFiles: []
    };
  }

  private resolveMaterialSource(
    definition: ProjectCommunicationWorkbenchEntryDefinition,
    scope: WorkbenchScope,
    publisherSources: Map<ProjectQuoteBasisMaterialKind, MaterialSource>
  ) {
    if (definition.materialKind) {
      return publisherSources.get(definition.materialKind) ?? {
        attachmentCount: 0,
        sourceVersionToken: null,
        sourceFiles: []
      };
    }
    const fileAssetId = scope.bid && definition.bidMaterialSlot
      ? this.bidSlotFileAssetId(scope.bid, definition.bidMaterialSlot)
      : null;
    return {
      attachmentCount: fileAssetId ? 1 : 0,
      sourceVersionToken: fileAssetId && scope.bid && definition.bidMaterialSlot
        ? this.hashSource([scope.bid.id, definition.bidMaterialSlot, fileAssetId, scope.bid.updatedAt.toISOString()])
        : null,
      sourceFiles: fileAssetId && definition.bidMaterialSlot
        ? [{
            fileAssetId,
            fileName: BID_MATERIAL_SLOT_LABELS[definition.bidMaterialSlot],
            mimeType: 'application/octet-stream',
            sortOrder: 0
          }]
        : []
    };
  }

  private assertWritableReviewEntry(
    entry: ProjectCommunicationWorkbenchEntryProjection,
    command: ProjectCommunicationMaterialReviewCommand,
    scope: WorkbenchScope
  ) {
    if (entry.availabilityState !== 'readable' || !entry.sourceVersionToken) {
      throw projectCommunicationWorkbenchInvalid(
        'PROJECT_COMMUNICATION_MATERIAL_UNSUBMITTED',
        'Current material is not submitted.'
      );
    }
    if (entry.actionState !== 'enabled') {
      throw projectCommunicationWorkbenchForbidden(
        'PROJECT_COMMUNICATION_MATERIAL_REVIEWER_MISMATCH',
        'Current organization cannot review this material.'
      );
    }
    if (command.sourceVersionToken && command.sourceVersionToken !== entry.sourceVersionToken) {
      throw projectCommunicationWorkbenchConflict(
        'PROJECT_COMMUNICATION_MATERIAL_SOURCE_CONFLICT',
        'Current material source has changed.'
      );
    }
    if (!scope.bid) {
      throw projectCommunicationInvalid('Field `bidId` is required for material review.');
    }
    if (command.reviewAction === 'request_supplement' && command.feedbackReasonCodes.length === 0 && !command.feedbackText) {
      throw projectCommunicationWorkbenchInvalid(
        'PROJECT_COMMUNICATION_MATERIAL_FEEDBACK_REQUIRED',
        'Feedback reason or text is required when requesting supplement.'
      );
    }
  }

  private async saveReview(
    entry: ProjectCommunicationWorkbenchEntryProjection,
    command: ProjectCommunicationMaterialReviewCommand,
    context: RequestContext,
    repository: Repository<ProjectCommunicationMaterialReviewEntity>
  ) {
    const existing = await repository.findOneBy({
      projectId: entry.projectId,
      bidId: entry.bidId ?? '',
      reviewerOrganizationId: entry.reviewerOrganizationId ?? '',
      entryKey: command.entryKey
    });
    const review = existing ?? repository.create({ id: randomUUID() });
    review.projectId = entry.projectId;
    review.threadId = entry.threadId;
    review.bidId = entry.bidId ?? '';
    review.entryKey = command.entryKey;
    review.subjectType = entry.definition.subjectType as ProjectCommunicationMaterialReviewEntity['subjectType'];
    review.materialKind = entry.definition.materialKind;
    review.bidMaterialSlot = entry.definition.bidMaterialSlot;
    review.subjectOwnerOrganizationId = entry.subjectOwnerOrganizationId ?? '';
    review.reviewerOrganizationId = entry.reviewerOrganizationId ?? '';
    review.sourceVersionToken = entry.sourceVersionToken ?? '';
    review.requestId = context.requestId;
    review.traceId = context.traceId;
    this.applyReviewAction(review, command, context);
    try {
      return await repository.save(review);
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw new ConflictException({
          code: 'PROJECT_COMMUNICATION_MATERIAL_REVIEW_CONFLICT',
          message: 'Current material review was updated concurrently.'
        });
      }
      throw error;
    }
  }

  private applyReviewAction(
    review: ProjectCommunicationMaterialReviewEntity,
    command: ProjectCommunicationMaterialReviewCommand,
    context: RequestContext
  ) {
    const now = new Date();
    if (command.reviewAction === 'confirm') {
      review.reviewState = 'confirmed';
      review.feedbackReasonCodes = [];
      review.feedbackText = null;
      review.feedbackByUserId = null;
      review.feedbackAt = null;
      review.confirmedByUserId = context.userId;
      review.confirmedAt = now;
      return;
    }
    review.reviewState = 'needs_supplement';
    review.feedbackReasonCodes = command.feedbackReasonCodes;
    review.feedbackText = command.feedbackText;
    review.feedbackByUserId = context.userId;
    review.feedbackAt = now;
    review.confirmedByUserId = null;
    review.confirmedAt = null;
  }

  private bidSlotFileAssetId(bid: BidEntity, slot: ProjectBidMaterialSlot) {
    if (slot === 'project_understanding') return bid.projectUnderstandingFileAssetId;
    if (slot === 'quote_sheet') return bid.quoteSheetFileAssetId;
    return bid.schedulePlanFileAssetId;
  }

  private bidderOrganizationId(bid: BidEntity) {
    return bid.bidderOrganizationId || bid.organizationId;
  }

  private hashSource(parts: string[]) {
    return createHash('sha256').update(parts.join('|'), 'utf8').digest('hex');
  }

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

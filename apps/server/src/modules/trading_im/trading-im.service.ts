import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, In, Repository } from 'typeorm';
import {
  VerifiedCurrentSessionContext,
  requireVerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { BidThreadConfirmationCardEntity } from './entities/bid-thread-confirmation-card.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from './entities/project-clarification.entity';
import {
  bidThreadForbidden,
  bidThreadUnavailable,
  projectClarificationForbidden,
  projectClarificationUnavailable,
  threadAttachmentInvalid,
  threadConfirmationInvalid,
  threadMessageInvalid
} from './trading-im.errors';
import { TradingImParticipantRole, TradingImPresenter } from './trading-im.presenter';

type ProjectAccess = {
  currentSession: VerifiedCurrentSessionContext;
  project: ProjectEntity;
  organizationId: string;
  participantRole: TradingImParticipantRole;
  canCreateClarification: boolean;
};

type ThreadAccess = {
  currentSession: VerifiedCurrentSessionContext;
  project: ProjectEntity;
  bid: BidEntity;
  organizationId: string;
  participantRole: Exclude<TradingImParticipantRole, 'viewer'>;
};

const CONFIRMATION_TYPES = new Set(['quote', 'craft_material', 'schedule']);

@Injectable()
export class TradingImService {
  constructor(
    @InjectRepository(ProjectClarificationEntity)
    private readonly clarificationRepository: Repository<ProjectClarificationEntity>,
    @InjectRepository(BidPrivateThreadEntity)
    private readonly threadRepository: Repository<BidPrivateThreadEntity>,
    @InjectRepository(BidThreadMessageEntity)
    private readonly messageRepository: Repository<BidThreadMessageEntity>,
    @InjectRepository(BidThreadConfirmationCardEntity)
    private readonly confirmationRepository: Repository<BidThreadConfirmationCardEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: TradingImPresenter
  ) {}

  async listProjectClarifications(projectId: string | undefined, context: RequestContext) {
    const access = await this.resolveProjectAccess(projectId, context);
    const items = await this.clarificationRepository.find({
      where: { projectId: access.project.id, lifecycleState: 'active' },
      order: { createdAt: 'ASC' }
    });
    return this.presenter.toClarificationList(access.project.id, items, {
      canCreate: access.canCreateClarification,
      reason: access.canCreateClarification ? 'participant_allowed' : 'view_only'
    });
  }

  async createProjectClarification(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.readClarificationCommand(payload);
    const access = await this.resolveProjectAccess(command.projectId, context);
    if (!access.canCreateClarification) {
      throw projectClarificationForbidden('Current actor cannot create project clarification.');
    }
    await this.assertFileAssets(command.attachmentFileAssetIds, access.organizationId);

    const clarification = this.clarificationRepository.create({
      id: randomUUID(),
      projectId: access.project.id,
      authorUserId: access.currentSession.userId,
      authorActorId: access.currentSession.actorId,
      authorOrganizationId: access.organizationId,
      authorRole: access.participantRole,
      body: command.body,
      attachmentFileAssetIds: command.attachmentFileAssetIds,
      lifecycleState: 'active'
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ProjectClarificationEntity).save(clarification);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'project_clarification',
        objectId: clarification.id,
        objectNo: access.project.projectNo,
        action: 'ProjectClarificationCreated',
        actorId: access.currentSession.userId,
        actorRole: access.participantRole,
        afterState: clarification.lifecycleState,
        reason: `projectId=${access.project.id}`,
        context
      });
    });

    return this.presenter.toClarification(clarification);
  }

  async getBidThreadDetail(query: { projectId?: string; bidId?: string }, context: RequestContext) {
    const access = await this.resolveThreadAccess(query.projectId, query.bidId, context);
    const thread = await this.resolveOrCreateThread(access);
    return this.toThreadDetail(thread, access);
  }

  async sendBidThreadMessage(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.readThreadMessageCommand(payload);
    const access = await this.resolveThreadAccess(command.projectId, command.bidId, context);
    await this.assertFileAssets(command.attachmentFileAssetIds, access.organizationId);
    const thread = await this.resolveOrCreateThread(access);
    if (thread.lifecycleState !== 'open') {
      throw bidThreadForbidden('Current bid thread is not open for messages.');
    }

    const message = this.messageRepository.create({
      id: randomUUID(),
      threadId: thread.id,
      projectId: access.project.id,
      bidId: access.bid.id,
      senderUserId: access.currentSession.userId,
      senderActorId: access.currentSession.actorId,
      senderOrganizationId: access.organizationId,
      senderRole: access.participantRole,
      body: command.body,
      attachmentFileAssetIds: command.attachmentFileAssetIds,
      messageState: 'active'
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(BidThreadMessageEntity).save(message);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'bid_thread_message',
        objectId: message.id,
        objectNo: access.bid.bidNo,
        action: 'BidThreadMessageSent',
        actorId: access.currentSession.userId,
        actorRole: access.participantRole,
        afterState: message.messageState,
        reason: `projectId=${access.project.id}; bidId=${access.bid.id}; threadId=${thread.id}`,
        context
      });
    });

    return this.presenter.toThreadMessage(message);
  }

  async createConfirmationCard(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.readConfirmationCommand(payload);
    const access = await this.resolveThreadAccess(command.projectId, command.bidId, context);
    const thread = await this.resolveOrCreateThread(access);
    const sourceMessage = await this.messageRepository.findOneBy({
      id: command.sourceMessageId,
      threadId: thread.id,
      projectId: access.project.id,
      bidId: access.bid.id
    });
    if (!sourceMessage) {
      throw threadConfirmationInvalid('Source message is unavailable for confirmation card.');
    }

    const card = this.confirmationRepository.create({
      id: randomUUID(),
      threadId: thread.id,
      projectId: access.project.id,
      bidId: access.bid.id,
      confirmationType: command.confirmationType,
      sourceMessageId: command.sourceMessageId,
      summary: command.summary,
      creatorUserId: access.currentSession.userId,
      creatorActorId: access.currentSession.actorId,
      creatorOrganizationId: access.organizationId,
      creatorRole: access.participantRole,
      cardState: 'active'
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(BidThreadConfirmationCardEntity).save(card);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'bid_thread_confirmation_card',
        objectId: card.id,
        objectNo: access.bid.bidNo,
        action: 'ConfirmationCardCreated',
        actorId: access.currentSession.userId,
        actorRole: access.participantRole,
        afterState: card.cardState,
        reason: `projectId=${access.project.id}; bidId=${access.bid.id}; threadId=${thread.id}`,
        context
      });
    });

    return this.presenter.toConfirmationCard(card);
  }

  private async toThreadDetail(thread: BidPrivateThreadEntity, access: ThreadAccess) {
    const [messages, confirmationCards] = await Promise.all([
      this.messageRepository.find({ where: { threadId: thread.id }, order: { createdAt: 'ASC' } }),
      this.confirmationRepository.find({ where: { threadId: thread.id }, order: { createdAt: 'ASC' } })
    ]);
    return this.presenter.toThreadDetail({
      thread,
      participantRole: access.participantRole,
      messages,
      confirmationCards,
      availability: {
        canSendMessage: thread.lifecycleState === 'open',
        canCreateConfirmation: thread.lifecycleState === 'open',
        reason: thread.lifecycleState === 'open' ? 'participant_allowed' : 'thread_not_open'
      }
    });
  }

  private async resolveProjectAccess(projectId: string | undefined, context: RequestContext) {
    const normalizedProjectId = this.readRequiredId(projectId, projectClarificationUnavailable);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project || project.state === 'archived' || project.publishedAt === null) {
      throw projectClarificationUnavailable('Current project is unavailable for clarification.');
    }

    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id ?? '';
    if (organizationId && organizationId === project.organizationId) {
      return { currentSession, project, organizationId, participantRole: 'project_owner', canCreateClarification: true };
    }
    if (organizationId) {
      const bid = await this.bidRepository.findOneBy({
        projectId: project.id,
        bidderOrganizationId: organizationId
      });
      if (bid) {
        return { currentSession, project, organizationId, participantRole: 'bidder', canCreateClarification: true };
      }
    }
    return { currentSession, project, organizationId, participantRole: 'viewer', canCreateClarification: false };
  }

  private async resolveThreadAccess(projectId: string | undefined, bidId: string | undefined, context: RequestContext) {
    const normalizedProjectId = this.readRequiredId(projectId, bidThreadUnavailable);
    const normalizedBidId = this.readRequiredId(bidId, bidThreadUnavailable);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    const bid = await this.bidRepository.findOneBy({ id: normalizedBidId, projectId: normalizedProjectId });
    if (!project || !bid) {
      throw bidThreadUnavailable('Current project-bid thread is unavailable.');
    }
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id ?? '';
    if (!organizationId) {
      throw bidThreadForbidden('Current organization scope is required for bid thread.');
    }
    if (organizationId === project.organizationId) {
      return { currentSession, project, bid, organizationId, participantRole: 'project_owner' } satisfies ThreadAccess;
    }
    if (organizationId === bid.bidderOrganizationId || organizationId === bid.organizationId) {
      return { currentSession, project, bid, organizationId, participantRole: 'bidder' } satisfies ThreadAccess;
    }
    throw bidThreadForbidden('Current organization is not a participant of this bid thread.');
  }

  private async resolveOrCreateThread(access: ThreadAccess) {
    const existing = await this.threadRepository.findOneBy({ projectId: access.project.id, bidId: access.bid.id });
    if (existing) {
      return existing;
    }
    const thread = this.threadRepository.create({
      id: randomUUID(),
      projectId: access.project.id,
      bidId: access.bid.id,
      projectOwnerOrganizationId: access.project.organizationId,
      bidderOrganizationId: access.bid.bidderOrganizationId || access.bid.organizationId,
      lifecycleState: 'open'
    });
    try {
      return await this.threadRepository.save(thread);
    } catch (error) {
      if (!this.isUniqueViolation(error)) {
        throw error;
      }
      const raced = await this.threadRepository.findOneBy({ projectId: access.project.id, bidId: access.bid.id });
      if (!raced) {
        throw error;
      }
      return raced;
    }
  }

  private async assertFileAssets(fileAssetIds: string[], organizationId: string) {
    if (!fileAssetIds.length) {
      return;
    }
    if (!organizationId) {
      throw threadAttachmentInvalid('Current organization scope is required for attachments.');
    }
    const assets = await this.fileAssetRepository.findBy({ id: In(fileAssetIds) });
    const assetMap = new Map(assets.map((asset) => [asset.id, asset]));
    for (const fileAssetId of fileAssetIds) {
      const asset = assetMap.get(fileAssetId);
      if (!asset || asset.organizationId !== organizationId) {
        throw threadAttachmentInvalid('Attachment FileAsset is unavailable for current actor.');
      }
    }
  }

  private readClarificationCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, threadMessageInvalid);
    return {
      projectId: this.readRequiredId(source.projectId, projectClarificationUnavailable),
      body: this.readBody(source.body),
      attachmentFileAssetIds: this.readFileAssetIds(source.attachmentFileAssetIds)
    };
  }

  private readThreadMessageCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, threadMessageInvalid);
    return {
      projectId: this.readRequiredId(source.projectId, bidThreadUnavailable),
      bidId: this.readRequiredId(source.bidId, bidThreadUnavailable),
      body: this.readBody(source.body),
      attachmentFileAssetIds: this.readFileAssetIds(source.attachmentFileAssetIds)
    };
  }

  private readConfirmationCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, threadConfirmationInvalid);
    const confirmationType = this.readRequiredText(source.confirmationType, threadConfirmationInvalid);
    if (!CONFIRMATION_TYPES.has(confirmationType)) {
      throw threadConfirmationInvalid('Confirmation type is not admitted in Round A.');
    }
    return {
      projectId: this.readRequiredId(source.projectId, bidThreadUnavailable),
      bidId: this.readRequiredId(source.bidId, bidThreadUnavailable),
      confirmationType,
      summary: this.readRequiredText(source.summary, threadConfirmationInvalid),
      sourceMessageId: this.readRequiredId(source.sourceMessageId, threadConfirmationInvalid)
    };
  }

  private readFileAssetIds(value: unknown) {
    if (value === undefined || value === null) {
      return [];
    }
    if (!Array.isArray(value) || value.some((item) => typeof item !== 'string' || !item.trim())) {
      throw threadAttachmentInvalid('Attachment FileAssetIds must be a string array.');
    }
    return [...new Set(value.map((item) => item.trim()))];
  }

  private readBody(value: unknown) {
    const body = this.readRequiredText(value, threadMessageInvalid);
    if (body.length > 2000) {
      throw threadMessageInvalid('Thread message body exceeds Round A limit.');
    }
    return body;
  }

  private readRequiredId(value: unknown, factory: (message: string) => Error) {
    return this.readRequiredText(value, factory);
  }

  private readRequiredText(value: unknown, factory: (message: string) => Error) {
    if (typeof value !== 'string') {
      throw factory('Required string field is missing.');
    }
    const normalized = value.trim();
    if (!normalized) {
      throw factory('Required string field is missing.');
    }
    return normalized;
  }

  private asRecord(value: unknown, factory: (message: string) => Error) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw factory('Request body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private async recordAudit(
    repository: Repository<IdentityAuditLogEntity>,
    params: {
      objectType: string;
      objectId: string;
      objectNo: string;
      action: string;
      actorId: string | null;
      actorRole: string;
      afterState: string;
      reason: string;
      context: RequestContext;
    }
  ) {
    await repository.save({
      id: randomUUID(),
      objectType: params.objectType,
      objectId: params.objectId,
      objectNo: params.objectNo,
      action: params.action,
      actorId: params.actorId,
      actorRole: params.actorRole,
      beforeState: '',
      afterState: params.afterState,
      reason: params.reason,
      requestId: params.context.requestId,
      traceId: params.context.traceId,
      occurredAt: new Date()
    });
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}

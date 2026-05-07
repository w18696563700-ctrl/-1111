import { Injectable } from '@nestjs/common';
import { createHash, randomUUID } from 'crypto';
import { EntityManager } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { NotificationService } from '../notifications/notification.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import type { ProjectCommunicationWorkbenchEntryProjection } from './project-communication-workbench.presenter';

type BusinessEventInput = {
  manager: EntityManager;
  project: Pick<ProjectEntity, 'id' | 'organizationId'>;
  counterpartOrganizationId: string;
  senderOrganizationId: string;
  senderUserId: string;
  senderActorId?: string | null;
  body: string;
  sourceType: string;
  sourceId: string;
  eventType: string;
  payload?: Record<string, unknown>;
};

@Injectable()
export class ProjectCommunicationBusinessEventService {
  constructor(private readonly notifications: NotificationService) {}

  async emitBidParticipationReviewResult(input: {
    manager: EntityManager;
    project: Pick<ProjectEntity, 'id' | 'organizationId'>;
    request: BidParticipationRequestEntity;
    reviewState: 'approved' | 'rejected';
    actorUserId: string;
    actorId?: string | null;
  }) {
    const approved = input.reviewState === 'approved';
    return this.emitProjectCommunicationBusinessEvent({
      manager: input.manager,
      project: input.project,
      counterpartOrganizationId: input.request.requesterOrganizationId,
      senderOrganizationId: input.project.organizationId,
      senderUserId: input.actorUserId,
      senderActorId: input.actorId,
      body: approved
        ? '参与竞标申请已通过，可继续提交竞标报价和三项资料。'
        : '参与竞标申请未通过，请查看审核结果或联系发布方。',
      sourceType: 'bid_participation_request',
      sourceId: input.request.id,
      eventType: approved ? 'bid_participation_approved' : 'bid_participation_rejected',
      payload: {
        requestId: input.request.id,
        reviewState: input.reviewState
      }
    });
  }

  async emitBidSubmitted(input: {
    manager: EntityManager;
    project: Pick<ProjectEntity, 'id' | 'organizationId'>;
    bid: BidEntity;
    actorUserId: string;
    actorId?: string | null;
  }) {
    const bidderOrganizationId = input.bid.bidderOrganizationId || input.bid.organizationId;
    return this.emitProjectCommunicationBusinessEvent({
      manager: input.manager,
      project: input.project,
      counterpartOrganizationId: bidderOrganizationId,
      senderOrganizationId: bidderOrganizationId,
      senderUserId: input.actorUserId,
      senderActorId: input.actorId,
      body: '竞标报价和三项资料已提交，请发布方进入资料确认单处理。',
      sourceType: 'bid',
      sourceId: input.bid.id,
      eventType: 'bid_submitted_material_review_pending',
      payload: {
        bidId: input.bid.id,
        quoteAmount: input.bid.quoteAmount
      }
    });
  }

  async emitMaterialReviewResult(input: {
    manager: EntityManager;
    entry: ProjectCommunicationWorkbenchEntryProjection;
    review: ProjectCommunicationMaterialReviewEntity;
    actorUserId: string;
    actorId?: string | null;
  }) {
    const projectOwnerOrganizationId =
      input.entry.viewerRole === 'publisher'
        ? input.entry.reviewerOrganizationId ?? ''
        : input.entry.subjectOwnerOrganizationId ?? '';
    const counterpartOrganizationId =
      input.entry.viewerRole === 'publisher'
        ? input.entry.subjectOwnerOrganizationId ?? ''
        : input.entry.reviewerOrganizationId ?? '';
    const body =
      input.review.reviewState === 'confirmed'
        ? `${input.entry.definition.label}已确认。`
        : `${input.entry.definition.label}需要补充资料，请查看资料确认单反馈。`;
    return this.emitProjectCommunicationBusinessEvent({
      manager: input.manager,
      project: {
        id: input.entry.projectId,
        organizationId: projectOwnerOrganizationId
      },
      counterpartOrganizationId,
      senderOrganizationId: input.entry.reviewerOrganizationId ?? '',
      senderUserId: input.actorUserId,
      senderActorId: input.actorId,
      body,
      sourceType: 'project_communication_material_review',
      sourceId: input.review.id,
      eventType:
        input.review.reviewState === 'confirmed'
          ? 'material_review_confirmed'
          : 'material_review_supplement_requested',
      payload: {
        entryKey: input.entry.definition.entryKey,
        group: input.entry.definition.group,
        bidId: input.entry.bidId,
        reviewState: input.review.reviewState,
        materialReviewId: input.review.id
      }
    });
  }

  async emitBidMaterialConfirmationCompleted(input: {
    manager: EntityManager;
    entry: ProjectCommunicationWorkbenchEntryProjection;
    actorUserId: string;
    actorId?: string | null;
  }) {
    if (input.entry.definition.group !== 'bid_materials' || !input.entry.bidId) {
      return null;
    }
    return this.emitProjectCommunicationBusinessEvent({
      manager: input.manager,
      project: {
        id: input.entry.projectId,
        organizationId: input.entry.reviewerOrganizationId ?? ''
      },
      counterpartOrganizationId: input.entry.subjectOwnerOrganizationId ?? '',
      senderOrganizationId: input.entry.reviewerOrganizationId ?? '',
      senderUserId: input.actorUserId,
      senderActorId: input.actorId,
      body: '发布方已确认完你的资料：项目理解、报价表、进度安排。请完成 4000 元竞标服务费预授权额度；完成后项目级自由发送将开启。',
      sourceType: 'project_communication_material_review',
      sourceId: input.entry.bidId,
      eventType: 'bid_materials_confirmed_service_fee_authorization_required',
      payload: {
        bidId: input.entry.bidId,
        group: input.entry.definition.group,
        requiredNextAction: 'complete_service_fee_authorization'
      }
    });
  }

  private async emitProjectCommunicationBusinessEvent(input: BusinessEventInput) {
    const ownerOrganizationId = input.project.organizationId?.trim() ?? '';
    const counterpartOrganizationId = input.counterpartOrganizationId.trim();
    const senderOrganizationId = input.senderOrganizationId.trim();
    const senderUserId = input.senderUserId.trim();
    if (
      !input.project.id ||
      !ownerOrganizationId ||
      !counterpartOrganizationId ||
      !senderOrganizationId ||
      !senderUserId ||
      ownerOrganizationId === counterpartOrganizationId
    ) {
      return null;
    }
    const thread = await this.getOrCreateThread({
      manager: input.manager,
      projectId: input.project.id,
      ownerOrganizationId,
      counterpartOrganizationId
    });
    const clientMessageId = this.clientMessageId([
      input.sourceType,
      input.sourceId,
      input.eventType,
      ownerOrganizationId,
      counterpartOrganizationId
    ]);
    const existing = await input.manager.getRepository(ProjectCommunicationMessageEntity).findOneBy({
      threadId: thread.id,
      senderOrganizationId,
      clientMessageId
    });
    if (existing) {
      return existing;
    }
    const message = input.manager.getRepository(ProjectCommunicationMessageEntity).create({
      id: randomUUID(),
      threadId: thread.id,
      projectId: input.project.id,
      senderUserId,
      senderActorId: input.senderActorId?.trim() || null,
      senderOrganizationId,
      messageKind: 'text',
      body: input.body,
      payload: {
        eventType: input.eventType,
        sourceType: input.sourceType,
        sourceId: input.sourceId,
        ...(input.payload ?? {})
      },
      clientMessageId,
      messageState: 'active'
    });
    try {
      const saved = await input.manager.getRepository(ProjectCommunicationMessageEntity).save(message);
      thread.lastMessageId = saved.id;
      thread.lastMessageAt = saved.createdAt ?? new Date();
      await input.manager.getRepository(ProjectCommunicationThreadEntity).save(thread);
      await this.notifications.createProjectCommunicationMessageNotification(
        saved,
        thread,
        senderOrganizationId,
        input.manager
      );
      return saved;
    } catch (error) {
      if (!this.isUniqueViolation(error)) {
        throw error;
      }
      return input.manager.getRepository(ProjectCommunicationMessageEntity).findOneBy({
        threadId: thread.id,
        senderOrganizationId,
        clientMessageId
      });
    }
  }

  private async getOrCreateThread(input: {
    manager: EntityManager;
    projectId: string;
    ownerOrganizationId: string;
    counterpartOrganizationId: string;
  }) {
    const repository = input.manager.getRepository(ProjectCommunicationThreadEntity);
    const existing = await repository.findOneBy({
      projectId: input.projectId,
      ownerOrganizationId: input.ownerOrganizationId,
      counterpartOrganizationId: input.counterpartOrganizationId
    });
    if (existing) {
      return existing;
    }
    const thread = repository.create({
      id: randomUUID(),
      projectId: input.projectId,
      ownerOrganizationId: input.ownerOrganizationId,
      counterpartOrganizationId: input.counterpartOrganizationId,
      threadState: 'open',
      lastMessageId: null,
      lastMessageAt: null
    });
    try {
      return await repository.save(thread);
    } catch (error) {
      if (!this.isUniqueViolation(error)) {
        throw error;
      }
      const reloaded = await repository.findOneBy({
        projectId: input.projectId,
        ownerOrganizationId: input.ownerOrganizationId,
        counterpartOrganizationId: input.counterpartOrganizationId
      });
      if (!reloaded) {
        throw error;
      }
      return reloaded;
    }
  }

  private clientMessageId(parts: string[]) {
    const digest = createHash('sha256').update(parts.join('|'), 'utf8').digest('hex');
    return `business:${digest.slice(0, 48)}`;
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}

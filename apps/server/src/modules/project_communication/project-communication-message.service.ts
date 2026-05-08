import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, MoreThan, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { NotificationService } from '../notifications/notification.service';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import { ProjectCommunicationBusinessStateService } from './project-communication-business-state.service';
import {
  projectCommunicationInvalid,
  projectCommunicationUnavailable
} from './project-communication.errors';
import { ProjectCommunicationPresenter } from './project-communication.presenter';
import { ProjectCommunicationRealtimeEventService } from './project-communication-realtime-event.service';

type SendMessageCommand = {
  threadId: string;
  projectId: string;
  messageKind: ProjectCommunicationMessageKind;
  body: string;
  payload: Record<string, unknown>;
  clientMessageId: string | null;
};

type MarkReadCommand = {
  threadId: string;
  projectId: string;
  lastReadMessageId: string;
};

const MESSAGE_LIMIT_DEFAULT = 50;
const MESSAGE_LIMIT_MAX = 100;
const MESSAGE_BODY_MAX = 2000;
const MESSAGE_CONFIRMATION_TITLE_MAX = 80;
const MESSAGE_CONFIRMATION_SUMMARY_MAX = 500;
const PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND = 'project_communication_attachment';

type ProjectCommunicationMessageKind = 'text' | 'image' | 'file' | 'confirmation_card';
type ProjectCommunicationConfirmationType = 'quote' | 'material_process' | 'schedule';

const MESSAGE_KINDS = new Set<ProjectCommunicationMessageKind>([
  'text',
  'image',
  'file',
  'confirmation_card'
]);

const CONFIRMATION_TYPES = new Set<ProjectCommunicationConfirmationType>([
  'quote',
  'material_process',
  'schedule'
]);

@Injectable()
export class ProjectCommunicationMessageService {
  constructor(
    @InjectRepository(ProjectCommunicationMessageEntity)
    private readonly messageRepository: Repository<ProjectCommunicationMessageEntity>,
    private readonly dataSource: DataSource,
    private readonly accessService: ProjectCommunicationAccessService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly presenter: ProjectCommunicationPresenter,
    private readonly realtimeEvents: ProjectCommunicationRealtimeEventService,
    private readonly businessStateService?: ProjectCommunicationBusinessStateService,
    private readonly notifications?: NotificationService
  ) {}

  async getOrCreateThread(query: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const counterpartOrganizationId = this.readOptionalString(query.counterpartOrganizationId);
    const threadId = this.readOptionalString(query.threadId);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectCommunicationThreadEntity);
      if (threadId) {
        const thread = await repository.findOneBy({ id: threadId, projectId });
        if (!thread) {
          throw projectCommunicationUnavailable('Current project communication thread is unavailable.');
        }
        const actor = await this.accessService.requireExistingThreadParticipant(thread, context, manager);
        if (counterpartOrganizationId) {
          const expectedCounterpartOrganizationId = this.counterpartOrganizationIdForViewer(
            thread,
            actor.organizationId
          );
          if (counterpartOrganizationId !== expectedCounterpartOrganizationId) {
            throw projectCommunicationInvalid(
              'Field `counterpartOrganizationId` does not match this communication thread.'
            );
          }
        }
        const state = await this.buildBusinessStateForThread({
          thread,
          viewerOrganizationId: actor.organizationId
        });
        return this.presenter.toThread(thread, state.chatAvailability);
      }

      const pair = await this.accessService.requireProjectConversationPair(
        projectId,
        counterpartOrganizationId ?? undefined,
        context,
        manager
      );
      const presentThread = async (thread: ProjectCommunicationThreadEntity) => {
        const state = await this.buildBusinessStateForThread({
          thread,
          viewerOrganizationId: pair.organizationId
        });
        return this.presenter.toThread(thread, state.chatAvailability);
      };
      const existing = await repository.findOneBy({
        projectId: pair.project.id,
        ownerOrganizationId: pair.ownerOrganizationId,
        counterpartOrganizationId: pair.counterpartOrganizationId
      });
      if (existing) {
        return presentThread(existing);
      }

      const thread = repository.create({
        id: randomUUID(),
        projectId: pair.project.id,
        ownerOrganizationId: pair.ownerOrganizationId,
        counterpartOrganizationId: pair.counterpartOrganizationId,
        threadState: 'open',
        lastMessageId: null,
        lastMessageAt: null
      });
      try {
        await repository.save(thread);
      } catch (error) {
        if (!this.isUniqueViolation(error)) {
          throw error;
        }
        const raced = await repository.findOneBy({
          projectId: pair.project.id,
          ownerOrganizationId: pair.ownerOrganizationId,
          counterpartOrganizationId: pair.counterpartOrganizationId
        });
        if (raced) {
          return presentThread(raced);
        }
        throw error;
      }
      return presentThread(thread);
    });
  }

  async listMessages(query: Record<string, unknown>, context: RequestContext) {
    const threadId = this.readRequiredString(query.threadId, 'threadId');
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const cursor = this.readOptionalCursor(query.cursor);
    const limit = this.readLimit(query.limit);
    const { actor, thread } = await this.requireThreadParticipant(threadId, projectId, context);
    const where = cursor
      ? { threadId: thread.id, projectId: thread.projectId, createdAt: MoreThan(cursor) }
      : { threadId: thread.id, projectId: thread.projectId };
    const items = await this.messageRepository.find({
      where,
      order: { createdAt: 'ASC', id: 'ASC' },
      take: limit
    });
    const readProjection = await this.loadCounterpartReadProjection(
      thread,
      actor.organizationId
    );
    return this.presenter.toMessages(items, readProjection);
  }

  async sendMessage(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSendMessageCommand(payload);
    let createdMessage: ProjectCommunicationMessageEntity | null = null;
    const result = await this.dataSource.transaction(async (manager) => {
      const { actor, thread } = await this.requireThreadParticipant(
        command.threadId,
        command.projectId,
        context,
        manager
      );
      const messageRepository = manager.getRepository(ProjectCommunicationMessageEntity);
      const threadRepository = manager.getRepository(ProjectCommunicationThreadEntity);
      const existing = await this.findClientMessage(
        command.clientMessageId,
        thread.id,
        actor.organizationId,
        messageRepository
      );
      if (existing) {
        return this.presenter.toMessage(existing);
      }
      const businessState = await this.buildBusinessStateForThread({
        thread,
        viewerOrganizationId: actor.organizationId
      });
      if (!businessState.chatAvailability.canSendMessage) {
        throw projectCommunicationInvalid(
          businessState.chatAvailability.lockReasonText ?? '当前项目沟通暂不可发送消息。'
        );
      }
      await this.ensureMessagePayload(command, actor.organizationId, thread.projectId, manager);

      const message = messageRepository.create({
        id: randomUUID(),
        threadId: thread.id,
        projectId: thread.projectId,
        senderUserId: actor.currentSession.userId,
        senderActorId: actor.currentSession.actorId || null,
        senderOrganizationId: actor.organizationId,
        messageKind: command.messageKind,
        body: command.body,
        payload: command.payload,
        clientMessageId: command.clientMessageId,
        messageState: 'active'
      });
      try {
        await messageRepository.save(message);
      } catch (error) {
        if (!this.isUniqueViolation(error)) {
          throw error;
        }
        const raced = await this.findClientMessage(
          command.clientMessageId,
          thread.id,
          actor.organizationId,
          messageRepository
        );
        if (raced) {
          return this.presenter.toMessage(raced);
        }
        throw error;
      }
      thread.lastMessageId = message.id;
      thread.lastMessageAt = message.createdAt;
      await threadRepository.save(thread);
      await this.auditService.record(
        {
          aggregateType: 'project_communication_message',
          aggregateId: message.id,
          eventType: 'ProjectCommunicationMessageSent',
          verifiedActor: {
            actorId: actor.currentSession.actorId,
            userId: actor.currentSession.userId,
            organizationId: actor.organizationId
          },
          payload: {
            threadId: thread.id,
            projectId: thread.projectId,
            senderOrganizationId: actor.organizationId,
            messageKind: message.messageKind,
            attachmentFileAssetId: this.readPayloadAttachmentFileAssetId(message.payload),
            confirmationType: this.readPayloadConfirmationType(message.payload)
          }
        },
        context,
        manager
      );
      await this.notifications?.createProjectCommunicationMessageNotification(
        message,
        thread,
        actor.organizationId,
        manager
      );
      createdMessage = message;
      return this.presenter.toMessage(message);
    });
    if (createdMessage) {
      this.realtimeEvents.publishMessageCreated(createdMessage);
    }
    return result;
  }

  private async buildBusinessStateForThread(input: {
    thread: ProjectCommunicationThreadEntity;
    viewerOrganizationId: string;
  }) {
    if (this.businessStateService) {
      return this.businessStateService.buildForThread(input);
    }
    return {
      businessTodoSummary: {
        bidParticipationReviewPendingCount: 0,
        publisherMaterialReviewPendingCount: 0,
        bidMaterialReviewPendingCount: 0,
        dealConfirmationPendingCount: 0,
        totalPendingCount: 0
      },
      chatAvailability: {
        canSendMessage: true,
        lockReasonCode: null,
        lockReasonText: null,
        requiredNextAction: 'none'
      }
    } as const;
  }

  async listRealtimeEvents(query: Record<string, unknown>, context: RequestContext) {
    const threadId = this.readRequiredString(query.threadId, 'threadId');
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const afterEventId = this.readOptionalString(query.afterEventId);
    await this.requireThreadParticipant(threadId, projectId, context);
    return {
      items: this.realtimeEvents.listThreadEvents(threadId, projectId, afterEventId)
    };
  }

  async markRead(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toMarkReadCommand(payload);
    return this.dataSource.transaction(async (manager) => {
      const { actor, thread } = await this.requireThreadParticipant(
        command.threadId,
        command.projectId,
        context,
        manager
      );
      await this.ensureReadMessageBelongsToThread(command.lastReadMessageId, thread, manager);
      const repository = manager.getRepository(ProjectCommunicationReadCursorEntity);
      const cursor =
        (await repository.findOneBy({
          threadId: thread.id,
          organizationId: actor.organizationId
        })) ??
        repository.create({
          threadId: thread.id,
          projectId: thread.projectId,
          organizationId: actor.organizationId
        });
      cursor.lastReadMessageId = command.lastReadMessageId;
      cursor.lastReadAt = new Date();
      await repository.save(cursor);
      return this.presenter.toReadCursor(cursor);
    });
  }

  private async requireThreadParticipant(
    threadId: string,
    projectId: string,
    context: RequestContext,
    manager = this.dataSource.manager
  ) {
    const thread = await manager.getRepository(ProjectCommunicationThreadEntity).findOneBy({
      id: threadId,
      projectId
    });
    if (!thread) {
      throw projectCommunicationUnavailable('Current project communication thread is unavailable.');
    }
    const actor = await this.accessService.requireExistingThreadParticipant(thread, context, manager);
    return { actor, thread };
  }

  private async loadCounterpartReadProjection(
    thread: ProjectCommunicationThreadEntity,
    viewerOrganizationId: string
  ) {
    const counterpartOrganizationId = this.counterpartOrganizationIdForViewer(
      thread,
      viewerOrganizationId
    );
    const cursor = await this.dataSource
      .getRepository(ProjectCommunicationReadCursorEntity)
      .findOneBy({
        threadId: thread.id,
        organizationId: counterpartOrganizationId
      });
    const boundary = cursor?.lastReadMessageId
      ? await this.messageRepository.findOneBy({
          id: cursor.lastReadMessageId,
          threadId: thread.id,
          projectId: thread.projectId
        })
      : null;
    return {
      viewerOrganizationId,
      counterpartReadCursor: cursor ?? null,
      counterpartReadBoundaryMessage: boundary ?? null
    };
  }

  private counterpartOrganizationIdForViewer(
    thread: ProjectCommunicationThreadEntity,
    viewerOrganizationId: string
  ) {
    return thread.ownerOrganizationId === viewerOrganizationId
      ? thread.counterpartOrganizationId
      : thread.ownerOrganizationId;
  }

  private async ensureReadMessageBelongsToThread(
    messageId: string,
    thread: ProjectCommunicationThreadEntity,
    manager = this.dataSource.manager
  ) {
    const message = await manager.getRepository(ProjectCommunicationMessageEntity).findOneBy({
      id: messageId,
      threadId: thread.id,
      projectId: thread.projectId
    });
    if (!message) {
      throw projectCommunicationInvalid('Field `lastReadMessageId` does not belong to this thread.');
    }
  }

  private async findClientMessage(
    clientMessageId: string | null,
    threadId: string,
    senderOrganizationId: string,
    repository: Repository<ProjectCommunicationMessageEntity>
  ) {
    if (!clientMessageId) {
      return null;
    }
    return repository.findOneBy({ threadId, senderOrganizationId, clientMessageId });
  }

  private toSendMessageCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    const messageKind = this.readMessageKind(source.messageKind);
    const messagePayload = this.readMessagePayload(messageKind, source.payload);
    const body = this.readMessageBody(messageKind, source.body, messagePayload);
    return {
      threadId: this.readRequiredString(source.threadId, 'threadId'),
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      messageKind,
      body,
      payload: messagePayload,
      clientMessageId: this.readOptionalString(source.clientMessageId)
    } satisfies SendMessageCommand;
  }

  private readMessageKind(value: unknown): ProjectCommunicationMessageKind {
    const normalized = value === undefined || value === null ? 'text' : this.readRequiredString(value, 'messageKind');
    if (MESSAGE_KINDS.has(normalized as ProjectCommunicationMessageKind)) {
      return normalized as ProjectCommunicationMessageKind;
    }
    throw projectCommunicationInvalid('Field `messageKind` is not supported for project communication.');
  }

  private readMessagePayload(kind: ProjectCommunicationMessageKind, value: unknown) {
    if (kind === 'text') {
      if (value === undefined || value === null) {
        return {};
      }
      const payload = this.asRecord(value);
      if (Object.keys(payload).length > 0) {
        throw projectCommunicationInvalid('Text project communication messages do not accept payload.');
      }
      return {};
    }
    if (kind === 'image' || kind === 'file') {
      return { attachment: this.readAttachmentPayload(kind, value) };
    }
    return { confirmation: this.readConfirmationPayload(value) };
  }

  private readAttachmentPayload(kind: 'image' | 'file', value: unknown) {
    const payload = this.asRecord(value);
    const attachment = this.asRecord(payload.attachment);
    const category = this.readRequiredString(attachment.category, 'payload.attachment.category');
    if (category !== kind) {
      throw projectCommunicationInvalid('Field `payload.attachment.category` must match messageKind.');
    }
    const mimeType = this.readRequiredString(attachment.mimeType, 'payload.attachment.mimeType');
    if (kind === 'image' && !mimeType.toLowerCase().startsWith('image/')) {
      throw projectCommunicationInvalid('Image project communication message requires image mimeType.');
    }
    return {
      fileAssetId: this.readRequiredString(attachment.fileAssetId, 'payload.attachment.fileAssetId'),
      fileName: this.readBoundedString(attachment.fileName, 'payload.attachment.fileName', 180),
      mimeType,
      size: this.readPositiveInteger(attachment.size, 'payload.attachment.size'),
      category
    };
  }

  private readConfirmationPayload(value: unknown) {
    const payload = this.asRecord(value);
    const confirmation = this.asRecord(payload.confirmation);
    const confirmationType = this.readRequiredString(
      confirmation.confirmationType,
      'payload.confirmation.confirmationType'
    );
    if (!CONFIRMATION_TYPES.has(confirmationType as ProjectCommunicationConfirmationType)) {
      throw projectCommunicationInvalid('Field `payload.confirmation.confirmationType` is not supported.');
    }
    const status = this.readOptionalString(confirmation.status) ?? 'proposed';
    if (status !== 'proposed') {
      throw projectCommunicationInvalid('Field `payload.confirmation.status` is not supported.');
    }
    return {
      confirmationType,
      title: this.readBoundedString(confirmation.title, 'payload.confirmation.title', MESSAGE_CONFIRMATION_TITLE_MAX),
      summary: this.readBoundedString(
        confirmation.summary,
        'payload.confirmation.summary',
        MESSAGE_CONFIRMATION_SUMMARY_MAX
      ),
      status
    };
  }

  private readMessageBody(
    kind: ProjectCommunicationMessageKind,
    value: unknown,
    payload: Record<string, unknown>
  ) {
    if (kind === 'text') {
      return this.readBodyText(this.readRequiredString(value, 'body'));
    }
    const optional = this.readOptionalString(value);
    if (kind === 'confirmation_card') {
      return this.readBodyText(optional ?? this.readPayloadConfirmationTitle(payload));
    }
    return this.readBodyText(optional ?? '');
  }

  private readBodyText(value: string) {
    if (value.length > MESSAGE_BODY_MAX) {
      throw projectCommunicationInvalid(`Field \`body\` must be ${MESSAGE_BODY_MAX} chars or less.`);
    }
    return value;
  }

  private async ensureMessagePayload(
    command: SendMessageCommand,
    senderOrganizationId: string,
    projectId: string,
    manager = this.dataSource.manager
  ) {
    if (command.messageKind !== 'image' && command.messageKind !== 'file') {
      return;
    }
    const attachment = this.asRecord(command.payload.attachment);
    const fileAssetId = this.readRequiredString(attachment.fileAssetId, 'payload.attachment.fileAssetId');
    const fileAsset = await manager.getRepository(FileAssetEntity).findOneBy({ id: fileAssetId });
    if (!fileAsset) {
      throw projectCommunicationInvalid('Current FileAsset truth is unavailable for project communication message.');
    }
    if (
      fileAsset.businessType !== 'project' ||
      fileAsset.businessId !== projectId ||
      fileAsset.fileKind !== PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND ||
      fileAsset.organizationId !== senderOrganizationId ||
      fileAsset.mimeType !== attachment.mimeType ||
      fileAsset.size !== attachment.size
    ) {
      throw projectCommunicationInvalid('Current FileAsset truth is not aligned with project communication message.');
    }
    if (command.messageKind === 'image' && !fileAsset.mimeType.toLowerCase().startsWith('image/')) {
      throw projectCommunicationInvalid('Current FileAsset truth is not an image.');
    }
  }

  private toMarkReadCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      threadId: this.readRequiredString(source.threadId, 'threadId'),
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      lastReadMessageId: this.readRequiredString(source.lastReadMessageId, 'lastReadMessageId')
    } satisfies MarkReadCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw projectCommunicationInvalid('Project communication body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectCommunicationInvalid(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectCommunicationInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw projectCommunicationInvalid('Optional string field must be a string when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readOptionalCursor(value: unknown) {
    const normalized = this.readOptionalString(value);
    if (!normalized) {
      return null;
    }
    const parsed = new Date(normalized);
    if (Number.isNaN(parsed.getTime())) {
      throw projectCommunicationInvalid('Field `cursor` must be an ISO timestamp.');
    }
    return parsed;
  }

  private readLimit(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return MESSAGE_LIMIT_DEFAULT;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      throw projectCommunicationInvalid('Field `limit` must be a positive integer.');
    }
    return Math.min(parsed, MESSAGE_LIMIT_MAX);
  }

  private readBoundedString(value: unknown, field: string, maxLength: number) {
    const normalized = this.readRequiredString(value, field);
    if (normalized.length > maxLength) {
      throw projectCommunicationInvalid(`Field \`${field}\` must be ${maxLength} chars or less.`);
    }
    return normalized;
  }

  private readPositiveInteger(value: unknown, field: string) {
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      throw projectCommunicationInvalid(`Field \`${field}\` must be a positive integer.`);
    }
    return parsed;
  }

  private readPayloadConfirmationTitle(payload: Record<string, unknown>) {
    const confirmation = this.asRecord(payload.confirmation);
    return this.readRequiredString(confirmation.title, 'payload.confirmation.title');
  }

  private readPayloadAttachmentFileAssetId(payload: Record<string, unknown>) {
    const attachment = this.readOptionalRecord(payload.attachment);
    return typeof attachment?.fileAssetId === 'string' ? attachment.fileAssetId : null;
  }

  private readPayloadConfirmationType(payload: Record<string, unknown>) {
    const confirmation = this.readOptionalRecord(payload.confirmation);
    return typeof confirmation?.confirmationType === 'string' ? confirmation.confirmationType : null;
  }

  private readOptionalRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      return null;
    }
    return value as Record<string, unknown>;
  }

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

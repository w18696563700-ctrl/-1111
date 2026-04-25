import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, MoreThan, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import {
  projectCommunicationInvalid,
  projectCommunicationUnavailable
} from './project-communication.errors';
import { ProjectCommunicationPresenter } from './project-communication.presenter';
import { ProjectCommunicationRealtimeEventService } from './project-communication-realtime-event.service';

type SendMessageCommand = {
  threadId: string;
  projectId: string;
  body: string;
  clientMessageId: string | null;
};

type MarkReadCommand = {
  threadId: string;
  projectId: string;
  lastReadMessageId: string | null;
};

const MESSAGE_LIMIT_DEFAULT = 50;
const MESSAGE_LIMIT_MAX = 100;
const MESSAGE_BODY_MAX = 2000;

@Injectable()
export class ProjectCommunicationMessageService {
  constructor(
    @InjectRepository(ProjectCommunicationMessageEntity)
    private readonly messageRepository: Repository<ProjectCommunicationMessageEntity>,
    private readonly dataSource: DataSource,
    private readonly accessService: ProjectCommunicationAccessService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly presenter: ProjectCommunicationPresenter,
    private readonly realtimeEvents: ProjectCommunicationRealtimeEventService
  ) {}

  async getOrCreateThread(query: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const counterpartOrganizationId = this.readOptionalString(query.counterpartOrganizationId);

    return this.dataSource.transaction(async (manager) => {
      const pair = await this.accessService.requireProjectConversationPair(
        projectId,
        counterpartOrganizationId ?? undefined,
        context,
        manager
      );
      const repository = manager.getRepository(ProjectCommunicationThreadEntity);
      const existing = await repository.findOneBy({
        projectId: pair.project.id,
        ownerOrganizationId: pair.ownerOrganizationId,
        counterpartOrganizationId: pair.counterpartOrganizationId
      });
      if (existing) {
        return this.presenter.toThread(existing);
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
          return this.presenter.toThread(raced);
        }
        throw error;
      }
      return this.presenter.toThread(thread);
    });
  }

  async listMessages(query: Record<string, unknown>, context: RequestContext) {
    const threadId = this.readRequiredString(query.threadId, 'threadId');
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const cursor = this.readOptionalCursor(query.cursor);
    const limit = this.readLimit(query.limit);
    const { thread } = await this.requireThreadParticipant(threadId, projectId, context);
    const where = cursor
      ? { threadId: thread.id, projectId: thread.projectId, createdAt: MoreThan(cursor) }
      : { threadId: thread.id, projectId: thread.projectId };
    const items = await this.messageRepository.find({
      where,
      order: { createdAt: 'ASC', id: 'ASC' },
      take: limit
    });
    return this.presenter.toMessages(items);
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

      const message = messageRepository.create({
        id: randomUUID(),
        threadId: thread.id,
        projectId: thread.projectId,
        senderUserId: actor.currentSession.userId,
        senderActorId: actor.currentSession.actorId || null,
        senderOrganizationId: actor.organizationId,
        messageKind: 'text',
        body: command.body,
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
          payload: {
            threadId: thread.id,
            projectId: thread.projectId,
            senderOrganizationId: actor.organizationId
          }
        },
        context,
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

  private async ensureReadMessageBelongsToThread(
    messageId: string | null,
    thread: ProjectCommunicationThreadEntity,
    manager = this.dataSource.manager
  ) {
    if (!messageId) {
      return;
    }
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
    const body = this.readRequiredString(source.body, 'body');
    if (body.length > MESSAGE_BODY_MAX) {
      throw projectCommunicationInvalid(`Field \`body\` must be ${MESSAGE_BODY_MAX} chars or less.`);
    }
    return {
      threadId: this.readRequiredString(source.threadId, 'threadId'),
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      body,
      clientMessageId: this.readOptionalString(source.clientMessageId)
    } satisfies SendMessageCommand;
  }

  private toMarkReadCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      threadId: this.readRequiredString(source.threadId, 'threadId'),
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      lastReadMessageId: this.readOptionalString(source.lastReadMessageId)
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

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

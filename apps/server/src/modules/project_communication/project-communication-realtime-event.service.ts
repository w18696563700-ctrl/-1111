import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { projectCommunicationInvalid } from './project-communication.errors';

export const PROJECT_COMMUNICATION_MESSAGE_CREATED_EVENT =
  'project_communication.message.created' as const;

export type ProjectCommunicationMessageCreatedEvent = {
  eventId: string;
  eventType: typeof PROJECT_COMMUNICATION_MESSAGE_CREATED_EVENT;
  messageId: string;
  threadId: string;
  projectId: string;
  senderOrganizationId: string;
  messageKind: string;
  body: string;
  payload: Record<string, unknown> | null;
  clientMessageId: string | null;
  createdAt: string;
};

const EVENT_BUFFER_LIMIT = 500;

@Injectable()
export class ProjectCommunicationRealtimeEventService {
  private readonly events: ProjectCommunicationMessageCreatedEvent[] = [];

  publishMessageCreated(
    message: ProjectCommunicationMessageEntity
  ): ProjectCommunicationMessageCreatedEvent {
    this.ensureMessageBoundary(message);
    const event: ProjectCommunicationMessageCreatedEvent = {
      eventId: randomUUID(),
      eventType: PROJECT_COMMUNICATION_MESSAGE_CREATED_EVENT,
      messageId: message.id,
      threadId: message.threadId,
      projectId: message.projectId,
      senderOrganizationId: message.senderOrganizationId,
      messageKind: message.messageKind,
      body: message.body,
      payload: this.toPayload(message.payload),
      clientMessageId: message.clientMessageId,
      createdAt: message.createdAt.toISOString()
    };
    this.events.push(event);
    if (this.events.length > EVENT_BUFFER_LIMIT) {
      this.events.splice(0, this.events.length - EVENT_BUFFER_LIMIT);
    }
    return event;
  }

  listThreadEvents(threadId: string, projectId: string, afterEventId: string | null) {
    const scoped = this.events.filter(
      (event) => event.threadId === threadId && event.projectId === projectId
    );
    if (!afterEventId) {
      return scoped;
    }
    const index = scoped.findIndex((event) => event.eventId === afterEventId);
    if (index < 0) {
      return scoped;
    }
    return scoped.slice(index + 1);
  }

  clearForTest() {
    this.events.splice(0, this.events.length);
  }

  private ensureMessageBoundary(message: ProjectCommunicationMessageEntity) {
    if (!message.id || !message.threadId || !message.projectId || !message.senderOrganizationId) {
      throw projectCommunicationInvalid(
        'Project communication message-created event requires messageId, threadId, projectId, and senderOrganizationId.'
      );
    }
    if (!(message.createdAt instanceof Date) || Number.isNaN(message.createdAt.getTime())) {
      throw projectCommunicationInvalid(
        'Project communication message-created event requires createdAt.'
      );
    }
  }

  private toPayload(payload: Record<string, unknown> | null | undefined) {
    if (!payload || Object.keys(payload).length === 0) {
      return null;
    }
    return payload;
  }
}

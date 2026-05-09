import { Injectable } from '@nestjs/common';
import { ProjectAlbumPhotoEntity } from './entities/project-album-photo.entity';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import type { ProjectCommunicationChatAvailability } from './project-communication-business-state.service';

type ProjectCommunicationMessageReadProjection = {
  viewerOrganizationId?: string | null;
  counterpartReadCursor?: ProjectCommunicationReadCursorEntity | null;
  counterpartReadBoundaryMessage?: ProjectCommunicationMessageEntity | null;
};

@Injectable()
export class ProjectCommunicationPresenter {
  toThread(
    thread: ProjectCommunicationThreadEntity,
    chatAvailability?: ProjectCommunicationChatAvailability
  ) {
    return {
      threadId: thread.id,
      projectId: thread.projectId,
      ownerOrganizationId: thread.ownerOrganizationId,
      counterpartOrganizationId: thread.counterpartOrganizationId,
      ...(chatAvailability ? { chatAvailability, generatedAt: new Date().toISOString() } : {}),
      threadState: thread.threadState,
      lastMessageId: thread.lastMessageId,
      lastMessageAt: thread.lastMessageAt?.toISOString() ?? null,
      createdAt: thread.createdAt.toISOString(),
      updatedAt: thread.updatedAt.toISOString()
    };
  }

  toMessage(
    message: ProjectCommunicationMessageEntity,
    projection: ProjectCommunicationMessageReadProjection = {}
  ) {
    const readState = this.readStateForMessage(message, projection);
    return {
      messageId: message.id,
      threadId: message.threadId,
      projectId: message.projectId,
      senderUserId: message.senderUserId,
      senderActorId: message.senderActorId,
      senderOrganizationId: message.senderOrganizationId,
      messageKind: message.messageKind,
      body: message.body,
      payload: this.toMessagePayload(message.payload),
      clientMessageId: message.clientMessageId,
      messageState: message.messageState,
      deliveryState: 'persisted',
      readState,
      readByCounterpartAt:
        readState === 'read_by_counterpart'
          ? projection.counterpartReadCursor?.lastReadAt.toISOString() ?? null
          : null,
      createdAt: message.createdAt.toISOString()
    };
  }

  toMessages(
    items: ProjectCommunicationMessageEntity[],
    projection: ProjectCommunicationMessageReadProjection = {}
  ) {
    const last = items.at(-1) ?? null;
    return {
      items: items.map((item) => this.toMessage(item, projection)),
      nextCursor: last?.createdAt.toISOString() ?? null
    };
  }

  private readStateForMessage(
    message: ProjectCommunicationMessageEntity,
    projection: ProjectCommunicationMessageReadProjection
  ) {
    const viewerOrganizationId = projection.viewerOrganizationId?.trim();
    if (!viewerOrganizationId || message.senderOrganizationId !== viewerOrganizationId) {
      return 'not_applicable';
    }
    if (this.isReadByCounterpart(message, projection)) {
      return 'read_by_counterpart';
    }
    return 'unread_by_counterpart';
  }

  private isReadByCounterpart(
    message: ProjectCommunicationMessageEntity,
    projection: ProjectCommunicationMessageReadProjection
  ) {
    const cursor = projection.counterpartReadCursor;
    if (!cursor) {
      return false;
    }
    const boundary = projection.counterpartReadBoundaryMessage;
    if (cursor.lastReadMessageId && boundary?.threadId === message.threadId) {
      return message.createdAt <= boundary.createdAt;
    }
    return message.createdAt <= cursor.lastReadAt;
  }

  private toMessagePayload(payload: Record<string, unknown> | null | undefined) {
    if (!payload || Object.keys(payload).length === 0) {
      return null;
    }
    return payload;
  }

  toReadCursor(cursor: ProjectCommunicationReadCursorEntity) {
    return {
      threadId: cursor.threadId,
      projectId: cursor.projectId,
      organizationId: cursor.organizationId,
      lastReadMessageId: cursor.lastReadMessageId,
      lastReadAt: cursor.lastReadAt.toISOString(),
      updatedAt: cursor.updatedAt.toISOString()
    };
  }

  toAlbumList(projectId: string, items: ProjectAlbumPhotoEntity[]) {
    return {
      projectId,
      limit: 50,
      photoCount: items.length,
      items: items.map((item) => this.toAlbumPhoto(item))
    };
  }

  toAlbumPhoto(photo: ProjectAlbumPhotoEntity) {
    return {
      photoId: photo.id,
      projectId: photo.projectId,
      fileAssetId: photo.fileAssetId,
      category: photo.category,
      caption: photo.caption,
      mimeType: photo.mimeType,
      sortOrder: photo.sortOrder,
      photoState: photo.photoState,
      uploadedByUserId: photo.uploadedByUserId,
      uploadedByActorId: photo.uploadedByActorId,
      uploadedByOrganizationId: photo.uploadedByOrganizationId,
      createdAt: photo.createdAt.toISOString(),
      removedAt: photo.removedAt?.toISOString() ?? null
    };
  }
}

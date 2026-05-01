import { Injectable } from '@nestjs/common';
import { ProjectAlbumPhotoEntity } from './entities/project-album-photo.entity';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';

@Injectable()
export class ProjectCommunicationPresenter {
  toThread(thread: ProjectCommunicationThreadEntity) {
    return {
      threadId: thread.id,
      projectId: thread.projectId,
      ownerOrganizationId: thread.ownerOrganizationId,
      counterpartOrganizationId: thread.counterpartOrganizationId,
      threadState: thread.threadState,
      lastMessageId: thread.lastMessageId,
      lastMessageAt: thread.lastMessageAt?.toISOString() ?? null,
      createdAt: thread.createdAt.toISOString(),
      updatedAt: thread.updatedAt.toISOString()
    };
  }

  toMessage(message: ProjectCommunicationMessageEntity) {
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
      createdAt: message.createdAt.toISOString()
    };
  }

  toMessages(items: ProjectCommunicationMessageEntity[]) {
    const last = items.at(-1) ?? null;
    return {
      items: items.map((item) => this.toMessage(item)),
      nextCursor: last?.createdAt.toISOString() ?? null
    };
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

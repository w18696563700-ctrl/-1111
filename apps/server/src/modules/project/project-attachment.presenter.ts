import { Injectable } from '@nestjs/common';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';

@Injectable()
export class ProjectAttachmentPresenter {
  toReadModel(attachment: ProjectAttachmentEntity) {
    return {
      attachmentId: attachment.id,
      projectId: attachment.projectId,
      fileAssetId: attachment.fileAssetId,
      fileName: attachment.fileName,
      attachmentKind: attachment.attachmentKind,
      mimeType: attachment.mimeType,
      visibility: attachment.visibility,
      sortOrder: attachment.sortOrder,
      createdAt: attachment.createdAt.toISOString(),
      createdBy: attachment.createdBy
    };
  }

  toListResponse(attachments: ProjectAttachmentEntity[]) {
    return {
      items: attachments.map((attachment) => this.toReadModel(attachment))
    };
  }

  toDeleteResponse(projectId: string, attachmentId: string) {
    return {
      projectId,
      attachmentId
    };
  }
}

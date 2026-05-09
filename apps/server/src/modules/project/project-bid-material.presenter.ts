import { Injectable } from '@nestjs/common';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';

@Injectable()
export class ProjectBidMaterialPresenter {
  toReadModel(attachment: ProjectAttachmentEntity) {
    return {
      attachmentId: attachment.id,
      projectId: attachment.projectId,
      fileAssetId: attachment.fileAssetId,
      fileName: attachment.fileName,
      attachmentKind: attachment.attachmentKind,
      mimeType: attachment.mimeType,
      sortOrder: attachment.sortOrder,
      createdAt: attachment.createdAt.toISOString()
    };
  }

  toListResponse(
    projectId: string,
    attachments: ProjectAttachmentEntity[],
    materialReview: Record<string, unknown> | null = null
  ) {
    return {
      projectId,
      attachments: attachments.map((attachment) => this.toReadModel(attachment)),
      materialReview
    };
  }
}

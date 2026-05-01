import { BadRequestException, ForbiddenException, Injectable, ServiceUnavailableException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { RequestContext } from '../../shared/request-context';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';

const PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND = 'project_communication_attachment';

@Injectable()
export class ProjectCommunicationFilePreviewService {
  constructor(
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository: Repository<ProjectCommunicationThreadEntity>,
    @InjectRepository(ProjectCommunicationMessageEntity)
    private readonly messageRepository: Repository<ProjectCommunicationMessageEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly accessService: ProjectCommunicationAccessService,
    private readonly publicUrlService: UploadPublicUrlService,
    private readonly config: RuntimeConfigService
  ) {}

  async getPreviewAccess(query: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredString(query.projectId, 'projectId');
    const threadId = this.readRequiredString(query.threadId, 'threadId');
    const fileAssetId = this.readRequiredString(query.fileAssetId, 'fileAssetId');
    const thread = await this.threadRepository.findOneBy({ id: threadId, projectId });
    if (!thread) {
      throw this.unavailable('Current project communication thread is unavailable for file preview.');
    }
    await this.accessService.requireExistingThreadParticipant(thread, context);
    const message = await this.findAttachmentMessage(projectId, threadId, fileAssetId);
    if (!message) {
      throw this.forbidden('Current FileAsset is not attached to this project communication thread.');
    }
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: fileAssetId });
    if (!fileAsset || !this.isProjectCommunicationFileAsset(fileAsset, projectId)) {
      throw this.forbidden('Current FileAsset truth is not aligned with project communication preview.');
    }
    const previewType = this.previewType(fileAsset.mimeType);
    const canPreview = previewType !== 'unsupported';
    const accessUrl = canPreview ? await this.publicUrlService.buildObjectAccessUrl(fileAsset.objectKey) : null;
    if (canPreview && !accessUrl) {
      throw this.unavailable('Current file preview access URL is unavailable.');
    }
    return {
      fileAssetId,
      projectId,
      threadId,
      previewType,
      canPreview,
      fileName: this.readPayloadFileName(message.payload) ?? fileAsset.id,
      mimeType: fileAsset.mimeType,
      accessUrl,
      expiresAt: accessUrl ? this.buildExpiresAt() : null,
      contentLengthBytes: fileAsset.size,
      downloadAvailable: true,
      fallbackReason: canPreview ? null : 'unsupported_mime_type'
    };
  }

  private async findAttachmentMessage(projectId: string, threadId: string, fileAssetId: string) {
    const items = await this.messageRepository.find({ where: { projectId, threadId } });
    return items.find((item) => this.readPayloadFileAssetId(item.payload) === fileAssetId) ?? null;
  }

  private isProjectCommunicationFileAsset(fileAsset: FileAssetEntity, projectId: string) {
    return fileAsset.businessType === 'project' &&
      fileAsset.businessId === projectId &&
      fileAsset.fileKind === PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND;
  }

  private previewType(mimeType: string) {
    const normalized = mimeType.toLowerCase();
    if (normalized.startsWith('image/')) {
      return 'image';
    }
    if (normalized === 'application/pdf') {
      return 'pdf';
    }
    if (normalized.startsWith('text/') || normalized === 'application/json') {
      return 'text';
    }
    return 'unsupported';
  }

  private readPayloadFileAssetId(payload: Record<string, unknown> | null | undefined) {
    const attachment = this.readOptionalRecord(payload?.attachment);
    return typeof attachment?.fileAssetId === 'string' ? attachment.fileAssetId : null;
  }

  private readPayloadFileName(payload: Record<string, unknown> | null | undefined) {
    const attachment = this.readOptionalRecord(payload?.attachment);
    return typeof attachment?.fileName === 'string' ? attachment.fileName : null;
  }

  private readOptionalRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      return null;
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw new BadRequestException({ code: 'FILE_PREVIEW_UNAVAILABLE', message: `Field \`${field}\` is required.` });
    }
    return value.trim();
  }

  private forbidden(message: string) {
    return new ForbiddenException({ code: 'FILE_PREVIEW_FORBIDDEN', message });
  }

  private unavailable(message: string) {
    return new ServiceUnavailableException({ code: 'FILE_PREVIEW_UNAVAILABLE', message });
  }

  private buildExpiresAt() {
    const seconds = Number.isFinite(this.config.uploadSignedUrlExpiresSeconds)
      ? this.config.uploadSignedUrlExpiresSeconds
      : 0;
    return new Date(Date.now() + Math.max(seconds, 0) * 1000).toISOString();
  }
}

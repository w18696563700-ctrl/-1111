import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectEntity } from './entities/project.entity';
import {
  fileAccessInvalid,
  fileAccessNotFound,
  fileAccessPermissionDenied,
  fileAccessUnavailable
} from './project-attachment-file-access.errors';

type FileAccessMode = 'preview' | 'download';

const OWNER_PRIVATE_VISIBILITY = 'owner_private';
const PROJECT_UPLOAD_BUSINESS_TYPE = 'project';
const PROJECT_UPLOAD_FILE_KIND = 'project_attachment';
const FILE_ACCESS_MODES = new Set<FileAccessMode>(['preview', 'download']);

@Injectable()
export class ProjectAttachmentFileAccessService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly publicUrlService: UploadPublicUrlService,
    private readonly config: RuntimeConfigService
  ) {}

  async getAccess(query: Record<string, unknown>, context: RequestContext) {
    const fileAssetId = this.readRequiredString(query.fileAssetId, 'fileAssetId');
    const mode = this.readMode(query.mode);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );

    const fileAsset = await this.fileAssetRepository.findOneBy({ id: fileAssetId });
    if (!fileAsset) {
      throw fileAccessNotFound('Current FileAsset is unavailable for file access.');
    }
    const attachment = await this.attachmentRepository.findOneBy({ fileAssetId: fileAsset.id });
    if (!attachment || this.normalizeText(attachment.visibility) !== OWNER_PRIVATE_VISIBILITY) {
      throw fileAccessNotFound('Current project attachment binding is unavailable for file access.');
    }
    const project = await this.projectRepository.findOneBy({ id: attachment.projectId });
    if (!project) {
      throw fileAccessNotFound('Current project is unavailable for file access.');
    }
    if (this.normalizeText(currentSession.organizationId) !== this.normalizeText(project.organizationId)) {
      throw fileAccessPermissionDenied('Current actor lacks owner permission for this project attachment.');
    }

    await this.eligibilityService.requireCurrentOrganizationScope(
      currentSession,
      project.organizationId
    );
    this.ensureProjectAttachmentFileAsset(fileAsset, project);

    const accessUrl = await this.publicUrlService.buildObjectAccessUrl(fileAsset.objectKey);
    if (!accessUrl) {
      throw fileAccessUnavailable('Current project attachment access URL is unavailable.');
    }

    return {
      fileAssetId: fileAsset.id,
      mode,
      accessUrl,
      fileName: attachment.fileName,
      mimeType: this.normalizeText(fileAsset.mimeType),
      expiresAt: this.buildExpiresAt(),
      contentLengthBytes: fileAsset.size
    };
  }

  private ensureProjectAttachmentFileAsset(fileAsset: FileAssetEntity, project: ProjectEntity) {
    if (
      this.normalizeText(fileAsset.businessType) !== PROJECT_UPLOAD_BUSINESS_TYPE ||
      this.normalizeText(fileAsset.businessId) !== this.normalizeText(project.id) ||
      this.normalizeText(fileAsset.fileKind) !== PROJECT_UPLOAD_FILE_KIND ||
      this.normalizeText(fileAsset.organizationId) !== this.normalizeText(project.organizationId)
    ) {
      throw fileAccessUnavailable('Current FileAsset truth is not aligned with the project attachment.');
    }
  }

  private readMode(value: unknown): FileAccessMode {
    const mode = this.readRequiredString(value, 'mode') as FileAccessMode;
    if (!FILE_ACCESS_MODES.has(mode)) {
      throw fileAccessInvalid('mode must be preview or download.');
    }
    return mode;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw fileAccessInvalid(`${field} is required for file access.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw fileAccessInvalid(`${field} is required for file access.`);
    }
    return normalized;
  }

  private buildExpiresAt() {
    const expiresSeconds = Number.isFinite(this.config.uploadSignedUrlExpiresSeconds)
      ? this.config.uploadSignedUrlExpiresSeconds
      : 0;
    return new Date(Date.now() + Math.max(expiresSeconds, 0) * 1000).toISOString();
  }

  private normalizeText(value: string | null | undefined) {
    return value?.trim() ?? '';
  }
}

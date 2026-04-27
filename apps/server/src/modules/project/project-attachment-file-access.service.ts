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
type FileAccessScope = 'owner_private' | 'bid_material';

const OWNER_PRIVATE_VISIBILITY = 'owner_private';
const PROJECT_UPLOAD_BUSINESS_TYPE = 'project';
const PROJECT_UPLOAD_FILE_KIND = 'project_attachment';
const FILE_ACCESS_MODES = new Set<FileAccessMode>(['preview', 'download']);
const FILE_ACCESS_SCOPES = new Set<FileAccessScope>(['owner_private', 'bid_material']);
const BID_MATERIAL_ATTACHMENT_KINDS = new Set([
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
]);

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
    const accessScope = this.readAccessScope(query.accessScope);
    const requestedProjectId = this.readOptionalString(query.projectId);
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
    if (requestedProjectId && requestedProjectId !== project.id) {
      throw fileAccessPermissionDenied('Current file access request is not aligned with the requested project.');
    }

    if (accessScope === 'bid_material') {
      await this.requireBidMaterialAccess(currentSession, project, attachment);
    } else {
      await this.requireOwnerPrivateAccess(currentSession, project);
    }
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

  private async requireOwnerPrivateAccess(
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>,
    project: ProjectEntity
  ) {
    if (this.normalizeText(currentSession.organizationId) !== this.normalizeText(project.organizationId)) {
      throw fileAccessPermissionDenied('Current actor lacks owner permission for this project attachment.');
    }

    await this.eligibilityService.requireCurrentOrganizationScope(
      currentSession,
      project.organizationId
    );
  }

  private async requireBidMaterialAccess(
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>,
    project: ProjectEntity,
    attachment: ProjectAttachmentEntity
  ) {
    if (!BID_MATERIAL_ATTACHMENT_KINDS.has(this.normalizeText(attachment.attachmentKind))) {
      throw fileAccessPermissionDenied('Current project attachment is not available for bid-material access.');
    }

    await this.eligibilityService.requireBidSubmitEligibility(
      currentSession,
      project
    );
  }

  private readMode(value: unknown): FileAccessMode {
    const mode = this.readRequiredString(value, 'mode') as FileAccessMode;
    if (!FILE_ACCESS_MODES.has(mode)) {
      throw fileAccessInvalid('mode must be preview or download.');
    }
    return mode;
  }

  private readAccessScope(value: unknown): FileAccessScope {
    if (value === undefined || value === null || value === '') {
      return OWNER_PRIVATE_VISIBILITY;
    }
    const scope = this.readRequiredString(value, 'accessScope') as FileAccessScope;
    if (!FILE_ACCESS_SCOPES.has(scope)) {
      throw fileAccessInvalid('accessScope must be owner_private or bid_material.');
    }
    return scope;
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw fileAccessInvalid('projectId must be a string when provided for file access.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
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

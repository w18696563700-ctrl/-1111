import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidParticipationRequestAccessService } from '../bid_participation_request/bid-participation-request-access.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectPublicResourceEntity } from './entities/project-public-resource.entity';
import { ProjectEntity } from './entities/project.entity';
import { ForumPostEntity } from '../forum/entities/forum-post.entity';
import {
  fileAccessInvalid,
  fileAccessNotFound,
  fileAccessPermissionDenied,
  fileAccessUnavailable
} from './project-attachment-file-access.errors';

type FileAccessMode = 'preview' | 'download';
type FileAccessScope = 'owner_private' | 'bid_material' | 'public_resource';
type BidSubmissionAttachmentField =
  | 'projectUnderstandingFileAssetId'
  | 'quoteSheetFileAssetId'
  | 'schedulePlanFileAssetId';

const FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE = 'forum_draft_attachment';
const OWNER_PRIVATE_VISIBILITY = 'owner_private';
const APP_SHARED_VISIBILITY = 'app_shared';
const PUBLIC_RESOURCE_SCOPE = 'public_resource';
const PROJECT_UPLOAD_BUSINESS_TYPE = 'project';
const PROJECT_UPLOAD_FILE_KIND = 'project_attachment';
const FILE_ACCESS_MODES = new Set<FileAccessMode>(['preview', 'download']);
const FILE_ACCESS_SCOPES = new Set<FileAccessScope>([
  'owner_private',
  'bid_material',
  PUBLIC_RESOURCE_SCOPE
]);
const BID_MATERIAL_ATTACHMENT_KINDS = new Set([
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
]);
const BID_SUBMISSION_ATTACHMENT_FIELDS: {
  field: BidSubmissionAttachmentField;
  fileKind: string;
}[] = [
  { field: 'projectUnderstandingFileAssetId', fileKind: 'bid_project_understanding' },
  { field: 'quoteSheetFileAssetId', fileKind: 'bid_quote_sheet' },
  { field: 'schedulePlanFileAssetId', fileKind: 'bid_schedule_plan' }
];
const BID_SUBMISSION_ATTACHMENT_FILE_KINDS = new Set(
  BID_SUBMISSION_ATTACHMENT_FIELDS.map((item) => item.fileKind)
);
const PUBLIC_RESOURCE_CATEGORIES = new Set([
  'contract_template',
  'process_guide',
  'other_resource'
]);
const PUBLIC_RESOURCE_ALLOWED_MIME_TYPES = new Set([
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
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
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectPublicResourceEntity)
    private readonly publicResourceRepository: Repository<ProjectPublicResourceEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly forumPostRepository: Repository<ForumPostEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly publicUrlService: UploadPublicUrlService,
    private readonly config: RuntimeConfigService,
    private readonly bidParticipationAccessService: BidParticipationRequestAccessService
  ) {}

  async getAccess(query: Record<string, unknown>, context: RequestContext) {
    const fileAssetId = this.readRequiredString(query.fileAssetId, 'fileAssetId');
    const mode = this.readMode(query.mode);
    const hasExplicitAccessScope = this.hasExplicitAccessScope(query.accessScope);
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

    if (accessScope === PUBLIC_RESOURCE_SCOPE) {
      return this.getPublicResourceAccess(fileAsset, mode, currentSession);
    }

    const attachment = await this.attachmentRepository.findOneBy({ fileAssetId: fileAsset.id });
    if (!attachment || this.normalizeText(attachment.visibility) !== OWNER_PRIVATE_VISIBILITY) {
      if (!hasExplicitAccessScope) {
        const bidSubmissionAttachmentAccess = await this.tryGetBidSubmissionAttachmentAccess(
          fileAsset,
          mode,
          requestedProjectId,
          currentSession
        );
        if (bidSubmissionAttachmentAccess) {
          return bidSubmissionAttachmentAccess;
        }
        const forumPostAccess = await this.tryGetForumPostAttachmentAccess(
          fileAsset,
          mode,
          currentSession
        );
        if (forumPostAccess) {
          return forumPostAccess;
        }
        const publicResourceAccess = await this.tryGetPublicResourceAccess(
          fileAsset,
          mode,
          currentSession
        );
        if (publicResourceAccess) {
          return publicResourceAccess;
        }
      }
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

  private async getPublicResourceAccess(
    fileAsset: FileAssetEntity,
    mode: FileAccessMode,
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>
  ) {
    const result = await this.tryGetPublicResourceAccess(fileAsset, mode, currentSession);
    if (!result) {
      throw fileAccessNotFound('Current public resource binding is unavailable for file access.');
    }
    return result;
  }

  private async tryGetPublicResourceAccess(
    fileAsset: FileAssetEntity,
    mode: FileAccessMode,
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>
  ) {
    if (mode !== 'download') {
      throw fileAccessInvalid('public_resource access only supports download mode.');
    }

    const publicResource = await this.publicResourceRepository.findOneBy({
      fileAssetId: fileAsset.id
    });
    if (!publicResource || !this.isReadablePublicResource(publicResource, fileAsset)) {
      return null;
    }

    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const accessUrl = await this.publicUrlService.buildObjectAccessUrl(fileAsset.objectKey);
    if (!accessUrl) {
      throw fileAccessUnavailable('Current public resource access URL is unavailable.');
    }

    return {
      fileAssetId: fileAsset.id,
      mode,
      accessUrl,
      fileName: publicResource.fileName,
      mimeType: this.normalizeMimeType(fileAsset.mimeType),
      expiresAt: this.buildExpiresAt(),
      contentLengthBytes: fileAsset.size
    };
  }

  private async tryGetForumPostAttachmentAccess(
    fileAsset: FileAssetEntity,
    mode: FileAccessMode,
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>
  ) {
    if (this.normalizeText(fileAsset.businessType) !== FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE) {
      return null;
    }

    const post = await this.forumPostRepository
      .createQueryBuilder('post')
      .where('post.state = :state', { state: 'published' })
      .andWhere('post.attachment_file_asset_ids @> :fileAssetIds', {
        fileAssetIds: JSON.stringify([fileAsset.id])
      })
      .orderBy('post.published_at', 'DESC')
      .getOne();
    if (!post) {
      return null;
    }

    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    this.ensureForumAttachmentFileAsset(fileAsset, post);

    const accessUrl = await this.publicUrlService.buildObjectAccessUrl(fileAsset.objectKey);
    if (!accessUrl) {
      throw fileAccessUnavailable('Current forum attachment access URL is unavailable.');
    }

    return {
      fileAssetId: fileAsset.id,
      mode,
      accessUrl,
      fileName: this.toFileName(fileAsset.objectKey),
      mimeType: this.normalizeMimeType(fileAsset.mimeType),
      expiresAt: this.buildExpiresAt(),
      contentLengthBytes: fileAsset.size
    };
  }

  private async tryGetBidSubmissionAttachmentAccess(
    fileAsset: FileAssetEntity,
    mode: FileAccessMode,
    requestedProjectId: string | null,
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>
  ) {
    if (!BID_SUBMISSION_ATTACHMENT_FILE_KINDS.has(this.normalizeText(fileAsset.fileKind))) {
      return null;
    }

    const bid = await this.findBidSubmissionAttachmentBid(fileAsset.id);
    if (!bid) {
      return null;
    }
    const project = await this.projectRepository.findOneBy({ id: bid.projectId });
    if (!project) {
      throw fileAccessNotFound('Current bid project is unavailable for file access.');
    }
    if (requestedProjectId && requestedProjectId !== project.id) {
      throw fileAccessPermissionDenied('Current file access request is not aligned with the requested bid project.');
    }

    this.ensureBidSubmissionAttachmentFileAsset(fileAsset, bid, project);
    await this.requireBidSubmissionAttachmentAccess(currentSession, project, bid);

    const accessUrl = await this.publicUrlService.buildObjectAccessUrl(fileAsset.objectKey);
    if (!accessUrl) {
      throw fileAccessUnavailable('Current bid submission attachment access URL is unavailable.');
    }

    return {
      fileAssetId: fileAsset.id,
      mode,
      accessUrl,
      fileName: this.toFileName(fileAsset.objectKey),
      mimeType: this.normalizeMimeType(fileAsset.mimeType),
      expiresAt: this.buildExpiresAt(),
      contentLengthBytes: fileAsset.size
    };
  }

  private findBidSubmissionAttachmentBid(fileAssetId: string) {
    return this.bidRepository
      .createQueryBuilder('bid')
      .where('bid.projectUnderstandingFileAssetId = :fileAssetId', { fileAssetId })
      .orWhere('bid.quoteSheetFileAssetId = :fileAssetId', { fileAssetId })
      .orWhere('bid.schedulePlanFileAssetId = :fileAssetId', { fileAssetId })
      .getOne();
  }

  private isReadablePublicResource(
    resource: ProjectPublicResourceEntity,
    fileAsset: FileAssetEntity
  ) {
    const resourceMimeType = this.normalizeMimeType(resource.mimeType);
    return (
      this.normalizeText(resource.visibility) === APP_SHARED_VISIBILITY &&
      resource.publishedAt instanceof Date &&
      !Number.isNaN(resource.publishedAt.getTime()) &&
      PUBLIC_RESOURCE_CATEGORIES.has(this.normalizeText(resource.resourceCategory)) &&
      PUBLIC_RESOURCE_ALLOWED_MIME_TYPES.has(resourceMimeType) &&
      resourceMimeType === this.normalizeMimeType(fileAsset.mimeType)
    );
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

  private ensureForumAttachmentFileAsset(fileAsset: FileAssetEntity, post: ForumPostEntity) {
    if (
      this.normalizeText(fileAsset.businessType) !== FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE ||
      this.normalizeText(fileAsset.businessId) !== this.normalizeText(post.sourceDraftId) ||
      this.normalizeText(fileAsset.organizationId) !== this.normalizeText(post.organizationId)
    ) {
      throw fileAccessUnavailable('Current FileAsset truth is not aligned with the forum post attachment.');
    }
  }

  private ensureBidSubmissionAttachmentFileAsset(
    fileAsset: FileAssetEntity,
    bid: BidEntity,
    project: ProjectEntity
  ) {
    const slot = BID_SUBMISSION_ATTACHMENT_FIELDS.find(
      (item) => this.normalizeText(bid[item.field]) === this.normalizeText(fileAsset.id)
    );
    if (!slot) {
      throw fileAccessUnavailable('Current FileAsset truth is not aligned with the bid submission attachment.');
    }
    if (
      this.normalizeText(fileAsset.businessType) !== PROJECT_UPLOAD_BUSINESS_TYPE ||
      this.normalizeText(fileAsset.businessId) !== this.normalizeText(project.id) ||
      this.normalizeText(fileAsset.fileKind) !== slot.fileKind ||
      this.normalizeText(fileAsset.organizationId) !== this.bidderOrganizationId(bid)
    ) {
      throw fileAccessUnavailable('Current FileAsset truth is not aligned with the bid submission attachment.');
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

    const scope = await this.eligibilityService.requireBidSubmitEligibility(
      currentSession,
      project
    );
    await this.bidParticipationAccessService.requireApprovedForOrganization(
      project,
      scope.organization.id,
    );
  }

  private async requireBidSubmissionAttachmentAccess(
    currentSession: Awaited<ReturnType<typeof requireVerifiedCurrentSessionContext>>,
    project: ProjectEntity,
    bid: BidEntity
  ) {
    const currentOrganizationId = this.normalizeText(currentSession.organizationId);
    const publisherOrganizationId = this.normalizeText(project.organizationId);
    const bidderOrganizationId = this.bidderOrganizationId(bid);

    if (currentOrganizationId === publisherOrganizationId) {
      await this.eligibilityService.requireCurrentOrganizationScope(currentSession, publisherOrganizationId);
      return;
    }

    if (currentOrganizationId === bidderOrganizationId) {
      await this.eligibilityService.requireCurrentOrganizationScope(currentSession, bidderOrganizationId);
      return;
    }

    throw fileAccessPermissionDenied('Current actor cannot access this bid submission attachment.');
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
      throw fileAccessInvalid('accessScope must be owner_private, bid_material, or public_resource.');
    }
    return scope;
  }

  private hasExplicitAccessScope(value: unknown) {
    return value !== undefined && value !== null && value !== '';
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

  private toFileName(objectKey: string) {
    const segments = objectKey.split('/');
    const fileName = segments[segments.length - 1]?.trim();
    return fileName || objectKey;
  }

  private bidderOrganizationId(bid: BidEntity) {
    return this.normalizeText(bid.bidderOrganizationId || bid.organizationId);
  }

  private normalizeText(value: string | null | undefined) {
    return value?.trim() ?? '';
  }

  private normalizeMimeType(value: string | null | undefined) {
    return this.normalizeText(value).toLowerCase();
  }
}

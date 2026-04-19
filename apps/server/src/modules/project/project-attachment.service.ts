import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { ProjectEntity } from './entities/project.entity';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import {
  projectAttachmentDuplicate,
  projectAttachmentInvalid,
  projectAttachmentUnavailable
} from './project-attachment.errors';
import { ProjectAttachmentPresenter } from './project-attachment.presenter';
import { projectInvalidState, projectUnavailable } from './project.errors';

type AttachmentBindCommand = {
  fileAssetId: string;
  fileName: string;
  attachmentKind: ProjectAttachmentKind;
  sortOrder: number | null;
};

type ProjectAttachmentKind = 'effect_image' | 'construction_doc' | 'other_material';

const OWNER_PRIVATE_VISIBILITY = 'owner_private';
const PROJECT_UPLOAD_BUSINESS_TYPE = 'project';
const PROJECT_UPLOAD_FILE_KIND = 'project_attachment';
const ATTACHMENT_CORRIDOR_STATES = new Set([
  'submitted',
  'published',
  'bidding_closed',
  'awarded',
  'converted_to_order'
]);
const IMAGE_MIMES = new Set(['image/png', 'image/jpeg', 'image/webp']);
const DOCUMENT_MIMES = new Set([
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
]);
const ATTACHMENT_KIND_MIMES = new Map<ProjectAttachmentKind, Set<string>>([
  ['effect_image', IMAGE_MIMES],
  ['construction_doc', DOCUMENT_MIMES],
  ['other_material', new Set([...IMAGE_MIMES, ...DOCUMENT_MIMES])]
]);

@Injectable()
export class ProjectAttachmentService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectAttachmentPresenter
  ) {}

  async list(projectId: string, context: RequestContext) {
    const { scope } = await this.eligibilityService.requireProjectPublishEligibilityFromContext(
      context,
      this.currentSessionVerificationService
    );
    const project = await this.requireOwnedAttachmentProject(
      projectId,
      scope.organization.id,
      this.projectRepository
    );
    const attachments = await this.attachmentRepository.find({
      where: { projectId: project.id },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });
    return this.presenter.toListResponse(attachments);
  }

  async bind(projectId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toBindCommand(payload);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );

    return this.dataSource.transaction(async (manager) => {
      const projectRepository = manager.getRepository(ProjectEntity);
      const attachmentRepository = manager.getRepository(ProjectAttachmentEntity);
      const fileAssetRepository = manager.getRepository(FileAssetEntity);
      const project = await this.requireOwnedAttachmentProject(
        projectId,
        scope.organization.id,
        projectRepository
      );
      const fileAsset = await fileAssetRepository.findOneBy({ id: command.fileAssetId });
      if (!fileAsset) {
        throw projectAttachmentUnavailable('Current FileAsset truth is unavailable for project attachment bind.');
      }
      this.ensureProjectFileAsset(fileAsset, project);
      this.ensureAttachmentMime(command.attachmentKind, fileAsset.mimeType);

      const existing = await attachmentRepository.findOneBy({
        projectId: project.id,
        fileAssetId: fileAsset.id
      });
      if (existing) {
        throw projectAttachmentDuplicate('Current FileAsset is already bound as an active project attachment.');
      }

      const attachment = attachmentRepository.create({
        id: randomUUID(),
        projectId: project.id,
        fileAssetId: fileAsset.id,
        fileName: command.fileName,
        attachmentKind: command.attachmentKind,
        mimeType: this.normalizeMimeType(fileAsset.mimeType),
        visibility: OWNER_PRIVATE_VISIBILITY,
        sortOrder: command.sortOrder ?? (await this.resolveNextSortOrder(project.id, attachmentRepository)),
        createdBy: this.resolveCreatedBy(currentSession.actorId, currentSession.userId)
      });

      try {
        await attachmentRepository.save(attachment);
      } catch (error) {
        if (this.isUniqueViolation(error)) {
          throw projectAttachmentDuplicate('Current FileAsset is already bound as an active project attachment.');
        }
        throw error;
      }

      await this.auditService.record(
        {
          aggregateType: 'project_attachment',
          aggregateId: attachment.id,
          eventType: 'project_attachment_created',
          payload: {
            projectId: attachment.projectId,
            fileAssetId: attachment.fileAssetId,
            attachmentKind: attachment.attachmentKind,
            visibility: attachment.visibility
          }
        },
        context,
        manager
      );

      return this.presenter.toReadModel(attachment);
    });
  }

  async remove(projectId: string, attachmentId: string, context: RequestContext) {
    const normalizedAttachmentId = this.readRouteId(attachmentId, 'attachmentId');
    const { scope } = await this.eligibilityService.requireProjectPublishEligibilityFromContext(
      context,
      this.currentSessionVerificationService
    );

    return this.dataSource.transaction(async (manager) => {
      const projectRepository = manager.getRepository(ProjectEntity);
      const attachmentRepository = manager.getRepository(ProjectAttachmentEntity);
      const project = await this.requireOwnedAttachmentProject(
        projectId,
        scope.organization.id,
        projectRepository
      );
      const attachment = await attachmentRepository.findOneBy({
        id: normalizedAttachmentId,
        projectId: project.id
      });
      if (!attachment) {
        throw projectAttachmentUnavailable('Current project attachment is unavailable.');
      }

      await attachmentRepository.delete({ id: attachment.id });
      await this.auditService.record(
        {
          aggregateType: 'project_attachment',
          aggregateId: attachment.id,
          eventType: 'project_attachment_deleted',
          payload: {
            projectId: attachment.projectId,
            fileAssetId: attachment.fileAssetId,
            attachmentKind: attachment.attachmentKind
          }
        },
        context,
        manager
      );

      return this.presenter.toDeleteResponse(project.id, attachment.id);
    });
  }

  private async requireOwnedAttachmentProject(
    projectId: string,
    organizationId: string,
    repository: Repository<ProjectEntity>
  ) {
    const normalizedProjectId = this.readRouteId(projectId, 'projectId');
    const project = await repository.findOneBy({ id: normalizedProjectId });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    if (project.organizationId !== organizationId) {
      throw authPermissionInsufficient('Current actor lacks the required owner scope for project attachments.', {
        reason: 'owner_scope_required',
        organizationId,
        projectOrganizationId: project.organizationId
      });
    }
    if (!this.canEnterAttachmentCorridor(project.state)) {
      throw projectInvalidState('Only submitted-or-later projects may enter the project attachment corridor.');
    }
    return project;
  }

  private canEnterAttachmentCorridor(state: string | null) {
    const normalizedState = this.normalizeText(state);
    return normalizedState ? ATTACHMENT_CORRIDOR_STATES.has(normalizedState) : false;
  }

  private ensureProjectFileAsset(fileAsset: FileAssetEntity, project: ProjectEntity) {
    if (
      this.normalizeText(fileAsset.businessType) !== PROJECT_UPLOAD_BUSINESS_TYPE ||
      this.normalizeText(fileAsset.businessId) !== project.id ||
      this.normalizeText(fileAsset.fileKind) !== PROJECT_UPLOAD_FILE_KIND ||
      this.normalizeText(fileAsset.organizationId) !== project.organizationId
    ) {
      throw projectAttachmentInvalid(
        'Current FileAsset truth is not aligned with the owner-private project attachment corridor.'
      );
    }
  }

  private ensureAttachmentMime(attachmentKind: ProjectAttachmentKind, mimeType: string) {
    const normalizedMimeType = this.normalizeMimeType(mimeType);
    const allowedMimes = ATTACHMENT_KIND_MIMES.get(attachmentKind);
    if (!allowedMimes?.has(normalizedMimeType)) {
      throw projectAttachmentInvalid(
        `Current mime type is not allowed for attachmentKind \`${attachmentKind}\`.`
      );
    }
  }

  private async resolveNextSortOrder(
    projectId: string,
    repository: Repository<ProjectAttachmentEntity>
  ) {
    const lastAttachment = await repository.findOne({
      where: { projectId },
      order: { sortOrder: 'DESC', createdAt: 'DESC' }
    });
    if (!lastAttachment) {
      return 0;
    }
    return lastAttachment.sortOrder + 1;
  }

  private toBindCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      fileAssetId: this.readRequiredString(source.fileAssetId, 'fileAssetId'),
      fileName: this.readRequiredString(source.fileName, 'fileName'),
      attachmentKind: this.readAttachmentKind(source.attachmentKind),
      sortOrder: this.readOptionalSortOrder(source.sortOrder)
    } satisfies AttachmentBindCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw projectAttachmentInvalid('Project attachment bind body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectAttachmentInvalid(`Field \`${field}\` is required for project attachment bind.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectAttachmentInvalid(`Field \`${field}\` is required for project attachment bind.`);
    }
    return normalized;
  }

  private readAttachmentKind(value: unknown) {
    const normalized = this.readRequiredString(value, 'attachmentKind') as ProjectAttachmentKind;
    if (!ATTACHMENT_KIND_MIMES.has(normalized)) {
      throw projectAttachmentInvalid('Current attachmentKind is not supported.');
    }
    return normalized;
  }

  private readOptionalSortOrder(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed < 0) {
      throw projectAttachmentInvalid('Field `sortOrder` must be a non-negative integer for project attachment bind.');
    }
    return parsed;
  }

  private readRouteId(value: string, field: string) {
    const normalized = value.trim();
    if (!normalized) {
      throw projectAttachmentInvalid(`Field \`${field}\` is required for project attachment routing.`);
    }
    return normalized;
  }

  private resolveCreatedBy(actorId: string, userId: string) {
    const createdBy = this.normalizeText(actorId) || this.normalizeText(userId);
    if (!createdBy) {
      throw projectAttachmentInvalid('Current project attachment bind is missing actor truth.');
    }
    return createdBy;
  }

  private normalizeMimeType(value: string) {
    return value.trim().toLowerCase();
  }

  private normalizeText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized;
  }

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

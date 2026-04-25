import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProjectAlbumPhotoEntity } from './entities/project-album-photo.entity';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import {
  projectAlbumForbidden,
  projectAlbumInvalid,
  projectAlbumLimitExceeded,
  projectAlbumUnavailable
} from './project-communication.errors';
import { ProjectCommunicationPresenter } from './project-communication.presenter';

type BindAlbumPhotoCommand = {
  fileAssetId: string;
  category: ProjectAlbumPhotoCategory;
  caption: string | null;
  sortOrder: number | null;
};

type ProjectAlbumPhotoCategory = 'contract' | 'progress' | 'final' | 'defect';

const PROJECT_ALBUM_LIMIT = 50;
const PROJECT_UPLOAD_BUSINESS_TYPE = 'project';
const PROJECT_ALBUM_FILE_KIND = 'project_album_photo';
const CATEGORY_SET = new Set<ProjectAlbumPhotoCategory>([
  'contract',
  'progress',
  'final',
  'defect'
]);

@Injectable()
export class ProjectAlbumPhotoService {
  constructor(
    @InjectRepository(ProjectAlbumPhotoEntity)
    private readonly photoRepository: Repository<ProjectAlbumPhotoEntity>,
    private readonly dataSource: DataSource,
    private readonly accessService: ProjectCommunicationAccessService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly presenter: ProjectCommunicationPresenter
  ) {}

  async list(projectId: string, context: RequestContext) {
    const actor = await this.accessService.requireProjectAlbumAccess(projectId, context);
    const photos = await this.photoRepository.find({
      where: {
        projectId: actor.project.id,
        photoState: 'active'
      },
      order: {
        category: 'ASC',
        sortOrder: 'ASC',
        createdAt: 'ASC',
        id: 'ASC'
      }
    });
    return this.presenter.toAlbumList(actor.project.id, photos);
  }

  async bind(projectId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toBindCommand(payload);
    return this.dataSource.transaction(async (manager) => {
      const actor = await this.accessService.requireProjectAlbumAccess(projectId, context, manager);
      const photoRepository = manager.getRepository(ProjectAlbumPhotoEntity);
      const fileAssetRepository = manager.getRepository(FileAssetEntity);
      await manager.query('SELECT id FROM project WHERE id = $1 FOR UPDATE', [actor.project.id]);
      const activeCount = await photoRepository.countBy({
        projectId: actor.project.id,
        photoState: 'active'
      });
      if (activeCount >= PROJECT_ALBUM_LIMIT) {
        throw projectAlbumLimitExceeded('Current project album already reached the 50 active photo limit.');
      }

      const fileAsset = await fileAssetRepository.findOneBy({ id: command.fileAssetId });
      if (!fileAsset) {
        throw projectAlbumUnavailable('Current FileAsset truth is unavailable for project album bind.');
      }
      this.ensureProjectAlbumFileAsset(fileAsset, actor.project.id, actor.organizationId);
      const duplicate = await photoRepository.findOneBy({
        projectId: actor.project.id,
        fileAssetId: fileAsset.id,
        photoState: 'active'
      });
      if (duplicate) {
        throw projectAlbumInvalid('Current FileAsset is already bound as an active project album photo.');
      }

      const photo = photoRepository.create({
        id: randomUUID(),
        projectId: actor.project.id,
        fileAssetId: fileAsset.id,
        category: command.category,
        caption: command.caption,
        mimeType: this.normalizeMimeType(fileAsset.mimeType),
        sortOrder: command.sortOrder ?? (await this.resolveNextSortOrder(actor.project.id, photoRepository)),
        photoState: 'active',
        uploadedByUserId: actor.currentSession.userId,
        uploadedByActorId: actor.currentSession.actorId || null,
        uploadedByOrganizationId: actor.organizationId,
        removedAt: null
      });

      try {
        await photoRepository.save(photo);
      } catch (error) {
        if (this.isUniqueViolation(error)) {
          throw projectAlbumInvalid('Current FileAsset is already bound as an active project album photo.');
        }
        throw error;
      }
      await this.auditService.record(
        {
          aggregateType: 'project_album_photo',
          aggregateId: photo.id,
          eventType: 'ProjectAlbumPhotoBound',
          payload: {
            projectId: photo.projectId,
            fileAssetId: photo.fileAssetId,
            category: photo.category,
            uploadedByOrganizationId: photo.uploadedByOrganizationId
          }
        },
        context,
        manager
      );
      return this.presenter.toAlbumPhoto(photo);
    });
  }

  async remove(projectId: string, photoId: string, context: RequestContext) {
    const normalizedPhotoId = this.readRequiredString(photoId, 'photoId');
    return this.dataSource.transaction(async (manager) => {
      const actor = await this.accessService.requireProjectAlbumAccess(projectId, context, manager);
      const repository = manager.getRepository(ProjectAlbumPhotoEntity);
      const photo = await repository.findOneBy({
        id: normalizedPhotoId,
        projectId: actor.project.id,
        photoState: 'active'
      });
      if (!photo) {
        throw projectAlbumUnavailable('Current project album photo is unavailable.');
      }
      if (!actor.isOwner && photo.uploadedByOrganizationId !== actor.organizationId) {
        throw projectAlbumForbidden('Only the project owner or uploading organization may remove this photo.', {
          projectId: actor.project.id,
          photoId: photo.id,
          organizationId: actor.organizationId
        });
      }
      photo.photoState = 'removed';
      photo.removedAt = new Date();
      await repository.save(photo);
      await this.auditService.record(
        {
          aggregateType: 'project_album_photo',
          aggregateId: photo.id,
          eventType: 'ProjectAlbumPhotoRemoved',
          payload: {
            projectId: photo.projectId,
            fileAssetId: photo.fileAssetId,
            removedByOrganizationId: actor.organizationId
          }
        },
        context,
        manager
      );
      return this.presenter.toAlbumPhoto(photo);
    });
  }

  private ensureProjectAlbumFileAsset(
    fileAsset: FileAssetEntity,
    projectId: string,
    organizationId: string
  ) {
    if (
      this.normalizeText(fileAsset.businessType) !== PROJECT_UPLOAD_BUSINESS_TYPE ||
      this.normalizeText(fileAsset.businessId) !== projectId ||
      this.normalizeText(fileAsset.fileKind) !== PROJECT_ALBUM_FILE_KIND ||
      this.normalizeText(fileAsset.organizationId) !== organizationId ||
      !this.normalizeMimeType(fileAsset.mimeType).startsWith('image/')
    ) {
      throw projectAlbumInvalid('Current FileAsset truth is not aligned with project album image binding.');
    }
  }

  private async resolveNextSortOrder(
    projectId: string,
    repository: Repository<ProjectAlbumPhotoEntity>
  ) {
    const last = await repository.findOne({
      where: {
        projectId,
        photoState: 'active'
      },
      order: {
        sortOrder: 'DESC',
        createdAt: 'DESC'
      }
    });
    return last ? last.sortOrder + 1 : 0;
  }

  private toBindCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      fileAssetId: this.readRequiredString(source.fileAssetId, 'fileAssetId'),
      category: this.readCategory(source.category),
      caption: this.readOptionalCaption(source.caption),
      sortOrder: this.readOptionalSortOrder(source.sortOrder)
    } satisfies BindAlbumPhotoCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw projectAlbumInvalid('Project album body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readCategory(value: unknown) {
    const normalized = this.readRequiredString(value, 'category') as ProjectAlbumPhotoCategory;
    if (!CATEGORY_SET.has(normalized)) {
      throw projectAlbumInvalid('Field `category` must be contract/progress/final/defect.');
    }
    return normalized;
  }

  private readOptionalCaption(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw projectAlbumInvalid('Field `caption` must be a string when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized.slice(0, 200) : null;
  }

  private readOptionalSortOrder(value: unknown) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed < 0) {
      throw projectAlbumInvalid('Field `sortOrder` must be a non-negative integer.');
    }
    return parsed;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectAlbumInvalid(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectAlbumInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private normalizeMimeType(value: string) {
    return value.trim().toLowerCase();
  }

  private normalizeText(value: string | null | undefined) {
    return value?.trim() ?? '';
  }

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

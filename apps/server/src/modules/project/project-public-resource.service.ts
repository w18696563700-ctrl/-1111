import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Not, IsNull, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProjectPublicResourceEntity } from './entities/project-public-resource.entity';
import { ProjectPublicResourcePresenter } from './project-public-resource.presenter';

const APP_SHARED_VISIBILITY = 'app_shared';
const RESOURCE_CATEGORIES = new Set(['contract_template', 'process_guide', 'other_resource']);
const ALLOWED_MIME_TYPES = new Set([
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
]);

@Injectable()
export class ProjectPublicResourceService {
  constructor(
    @InjectRepository(ProjectPublicResourceEntity)
    private readonly resourceRepository: Repository<ProjectPublicResourceEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectPublicResourcePresenter
  ) {}

  async list(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);

    const resources = await this.resourceRepository.find({
      where: {
        visibility: APP_SHARED_VISIBILITY,
        publishedAt: Not(IsNull())
      },
      order: {
        sortOrder: 'ASC',
        publishedAt: 'DESC',
        createdAt: 'DESC'
      }
    });
    const visibleResources = await this.filterReadableResources(resources);
    return this.presenter.toListResponse(visibleResources);
  }

  private async filterReadableResources(resources: ProjectPublicResourceEntity[]) {
    const candidates = resources.filter(
      (resource) =>
        resource.visibility === APP_SHARED_VISIBILITY &&
        resource.publishedAt instanceof Date &&
        !Number.isNaN(resource.publishedAt.getTime()) &&
        RESOURCE_CATEGORIES.has(resource.resourceCategory) &&
        ALLOWED_MIME_TYPES.has(this.normalizeMimeType(resource.mimeType))
    );
    if (!candidates.length) {
      return [];
    }

    const anchoredAssets = await this.fileAssetRepository.findBy({
      id: In(candidates.map((resource) => resource.fileAssetId))
    });
    const validFileAssetIds = new Set(anchoredAssets.map((item) => item.id));
    return candidates.filter((resource) => validFileAssetIds.has(resource.fileAssetId));
  }

  private normalizeMimeType(value: string) {
    return value.trim().toLowerCase();
  }
}

import { Injectable } from '@nestjs/common';
import { ProjectPublicResourceEntity } from './entities/project-public-resource.entity';

@Injectable()
export class ProjectPublicResourcePresenter {
  toReadModel(resource: ProjectPublicResourceEntity) {
    return {
      resourceId: resource.resourceId,
      resourceCategory: resource.resourceCategory,
      title: resource.title,
      summary: this.toNullableText(resource.summary),
      fileAssetId: resource.fileAssetId,
      fileName: resource.fileName,
      mimeType: resource.mimeType,
      visibility: resource.visibility,
      sortOrder: resource.sortOrder,
      publishedAt: resource.publishedAt.toISOString()
    };
  }

  toListResponse(resources: ProjectPublicResourceEntity[]) {
    return {
      resources: resources.map((resource) => this.toReadModel(resource))
    };
  }

  private toNullableText(value: string | null | undefined) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

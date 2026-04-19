import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';

@Injectable()
export class EnterpriseHubMediaProjectionService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly uploadPublicUrlService: UploadPublicUrlService,
    private readonly mediaTruthService: EnterpriseHubMediaTruthService,
  ) {}

  async buildDisplayUrlMap(fileAssetIds: Array<string | null | undefined>) {
    const normalizedIds = [
      ...new Set(
        fileAssetIds.flatMap((item) => {
          const fileAssetId = this.normalizeFileAssetId(item);
          return fileAssetId ? [fileAssetId] : [];
        }),
      ),
    ];
    if (!normalizedIds.length) {
      return new Map<string, string | null>();
    }

    const fileAssets = await this.fileAssetRepository.findBy({
      id: In(normalizedIds),
    });
    const fileAssetMap = new Map(fileAssets.map((item) => [item.id, item]));

    const resolvedEntries = await Promise.all(
      normalizedIds.map(async (fileAssetId) => [
        fileAssetId,
        await this.toDisplayUrl(fileAssetMap.get(fileAssetId) ?? null),
      ] as const),
    );

    return new Map(resolvedEntries);
  }

  readDisplayUrl(
    fileAssetId: string | null | undefined,
    displayUrlMap: Map<string, string | null>,
  ) {
    const normalizedId = this.normalizeFileAssetId(fileAssetId);
    if (!normalizedId) {
      return null;
    }
    return displayUrlMap.get(normalizedId) ?? null;
  }

  private normalizeFileAssetId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private async toDisplayUrl(fileAsset: FileAssetEntity | null) {
    if (!this.mediaTruthService.isEnterpriseDisplayImageFileAsset(fileAsset)) {
      return null;
    }
    return (
      (await this.uploadPublicUrlService.buildObjectAccessUrl(fileAsset.objectKey)) ??
      this.uploadPublicUrlService.buildObjectUrl(fileAsset.objectKey)
    );
  }
}

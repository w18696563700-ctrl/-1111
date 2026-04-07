import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PROFILE_AVATAR_MAX_BYTES } from '../content_safety/content-safety.constants';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { personalAvatarFileUnavailable, personalAvatarInvalid } from './profile.errors';

@Injectable()
export class ProfileSafetyAvatarFileService {
  constructor(
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly avatarUrlService: UploadPublicUrlService
  ) {}

  async loadProfileAvatarFileAsset(fileAssetId: string, userId: string) {
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: fileAssetId });
    if (!fileAsset) {
      throw personalAvatarFileUnavailable('Current avatar FileAsset is unavailable.');
    }
    this.assertProfileAvatarFileAsset(fileAsset, userId);
    return fileAsset;
  }

  assertProfileAvatarFileAsset(fileAsset: FileAssetEntity, userId: string) {
    if (
      fileAsset.businessType !== 'profile' ||
      fileAsset.fileKind !== 'avatar' ||
      fileAsset.businessId !== userId ||
      fileAsset.userId !== userId
    ) {
      throw personalAvatarInvalid('Current avatar FileAsset does not belong to the current user profile.');
    }
    if (!fileAsset.mimeType.toLowerCase().startsWith('image/')) {
      throw personalAvatarInvalid('Current avatar FileAsset only supports image mime types.');
    }
    if (fileAsset.size > PROFILE_AVATAR_MAX_BYTES) {
      throw personalAvatarInvalid('Current avatar FileAsset exceeds the P0 avatar size boundary.');
    }
  }

  buildAvatarUrl(fileAsset: FileAssetEntity) {
    return this.avatarUrlService.buildObjectUrl(fileAsset.objectKey);
  }

  requireAvatarUrl(fileAsset: FileAssetEntity) {
    const stableAvatarUrl = this.buildAvatarUrl(fileAsset);
    if (!stableAvatarUrl) {
      throw personalAvatarInvalid('Current avatar projection URL is unavailable.');
    }
    return stableAvatarUrl;
  }
}

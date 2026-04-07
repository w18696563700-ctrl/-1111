import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import {
  personalAvatarFileUnavailable,
  personalAvatarInvalid,
  personalNicknameInvalid
} from './profile.errors';
import { ProfilePresenter } from './profile.presenter';

const NICKNAME_PATTERN = /^[\p{Script=Han}]{1,10}$/u;

@Injectable()
export class ProfilePersonalWriteService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly avatarUrlService: UploadPublicUrlService,
    private readonly presenter: ProfilePresenter
  ) {}

  async updateNickname(payload: Record<string, unknown>, context: RequestContext) {
    const nickname = this.readNickname(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);

    user.nickname = nickname;
    await this.userRepository.save(user);

    return this.presenter.toPersonalUpdated({
      displayName: this.toDisplayName(user),
      avatarUrl: await this.readAvatarUrl(user),
      traceId: context.traceId
    });
  }

  async updateAvatar(payload: Record<string, unknown>, context: RequestContext) {
    const fileAssetId = this.readFileAssetId(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: fileAssetId });
    if (!fileAsset) {
      throw personalAvatarFileUnavailable('Current avatar FileAsset is unavailable.');
    }
    if (
      fileAsset.businessType !== 'profile' ||
      fileAsset.fileKind !== 'avatar' ||
      fileAsset.businessId !== user.id ||
      fileAsset.userId !== user.id
    ) {
      throw personalAvatarInvalid('Current avatar FileAsset does not belong to the current user profile.');
    }
    if (!fileAsset.mimeType.toLowerCase().startsWith('image/')) {
      throw personalAvatarInvalid('Current avatar FileAsset only supports image mime types.');
    }

    const stableAvatarUrl = this.avatarUrlService.buildObjectUrl(fileAsset.objectKey);
    if (!stableAvatarUrl) {
      throw personalAvatarInvalid('Current avatar projection URL is unavailable.');
    }

    user.avatarFileAssetId = fileAsset.id;
    user.avatarUrl = stableAvatarUrl;
    await this.userRepository.save(user);

    return this.presenter.toPersonalUpdated({
      displayName: this.toDisplayName(user),
      avatarUrl: (await this.avatarUrlService.buildObjectAccessUrl(fileAsset.objectKey)) ?? stableAvatarUrl,
      traceId: context.traceId
    });
  }

  private readNickname(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw personalNicknameInvalid('Personal nickname body must be an object.');
    }
    if (typeof payload.nickname !== 'string') {
      throw personalNicknameInvalid('Field `nickname` is required.');
    }
    const nickname = payload.nickname.trim();
    if (!NICKNAME_PATTERN.test(nickname)) {
      throw personalNicknameInvalid('Nickname must contain only 1 to 10 Chinese Han characters.');
    }
    return nickname;
  }

  private readFileAssetId(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw personalAvatarInvalid('Personal avatar body must be an object.');
    }
    if (typeof payload.fileAssetId !== 'string' || !payload.fileAssetId.trim()) {
      throw personalAvatarInvalid('Field `fileAssetId` is required.');
    }
    return payload.fileAssetId.trim();
  }

  private toDisplayName(user: UserEntity) {
    const nickname = user.nickname?.trim() ?? '';
    if (nickname) {
      return nickname;
    }
    const mobileSuffix = user.mobile.trim().slice(-4);
    return mobileSuffix ? `用户${mobileSuffix}` : `用户${user.id.slice(0, 6)}`;
  }

  private async readAvatarUrl(user: UserEntity) {
    const avatarUrl = user.avatarUrl?.trim() ?? '';
    if (!avatarUrl) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(avatarUrl)) ?? avatarUrl;
  }
}

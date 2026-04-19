import { Injectable } from '@nestjs/common';
import { EntityManager } from 'typeorm';
import { UserEntity } from '../identity/entities/user.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';
import { ProfileSafetyAvatarFileService } from './profile-safety-avatar-file.service';
import { personalAvatarFileUnavailable } from './profile.errors';

@Injectable()
export class ProfileSafetyApprovalService {
  constructor(private readonly avatarFileService: ProfileSafetyAvatarFileService) {}

  async applyApprovedSubmission(
    user: UserEntity,
    submission: ProfileSafetySubmissionEntity,
    manager: EntityManager
  ) {
    if (submission.fieldKey === 'nickname') {
      user.nickname = submission.proposedValue;
    } else if (submission.fieldKey === 'intro') {
      user.profileIntro = submission.proposedValue;
    } else if (submission.fieldKey === 'avatar') {
      await this.applyApprovedAvatarSubmission(user, submission, manager);
    }
    await manager.getRepository(UserEntity).save(user);
  }

  private async applyApprovedAvatarSubmission(
    user: UserEntity,
    submission: ProfileSafetySubmissionEntity,
    manager: EntityManager
  ) {
    const fileAsset = await manager.getRepository(FileAssetEntity).findOneBy({
      id: submission.proposedFileAssetId ?? ''
    });
    if (!fileAsset) {
      throw personalAvatarFileUnavailable('Current avatar FileAsset is unavailable for approval.');
    }
    this.avatarFileService.assertProfileAvatarFileAsset(fileAsset, user.id);
    user.avatarFileAssetId = fileAsset.id;
    user.avatarUrl = submission.proposedAvatarUrl ?? this.avatarFileService.buildAvatarUrl(fileAsset);
  }
}

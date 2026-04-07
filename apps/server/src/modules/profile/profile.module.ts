import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditModule } from '../audit/identity-audit.module';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { DeviceEntity } from '../identity/entities/device.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationModule } from '../organization/organization.module';
import { PrivateOperatingSystemReorganizationModule } from '../private_operating_system_reorganization/private-operating-system-reorganization.module';
import { UploadModule } from '../upload/upload.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProfileController } from './profile.controller';
import { UserBlockRelationEntity } from './entities/user-block-relation.entity';
import { ProfileBlockPresenter } from './profile-block.presenter';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCertificationWriteService } from './profile-certification-write.service';
import { ProfilePersonalWriteService } from './profile-personal.write.service';
import { ProfileOrganizationMembersQueryService } from './profile-organization-members.query.service';
import { ProfileOrganizationMembersWriteService } from './profile-organization-members.write.service';
import { ProfilePresenter } from './profile.presenter';
import { ProfileQueryService } from './profile-query.service';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';
import { ProfileSafetyAvatarFileService } from './profile-safety-avatar-file.service';
import { ProfileSafetyQueryService } from './profile-safety.query.service';
import { ProfileSafetyResponsePresenter } from './profile-safety-response.presenter';
import { ProfileSafetyReviewService } from './profile-safety-review.service';
import { ProfileSafetySubmitService } from './profile-safety-submit.service';
import { ProfileSafetyWriteService } from './profile-safety.write.service';
import { ProfileSecurityQueryService } from './profile-security.query.service';
import { ProfileSecurityWriteService } from './profile-security.write.service';

@Module({
  imports: [
    AuthModule,
    ContentSafetyModule,
    OrganizationModule,
    PrivateOperatingSystemReorganizationModule,
    UploadModule,
    IdentityAuditModule,
    TypeOrmModule.forFeature([
      OrganizationEntity,
      OrganizationMemberEntity,
      OrganizationCertificationEntity,
      FileAssetEntity,
      ProfileSafetySubmissionEntity,
      DeviceEntity,
      SessionEntity,
      UserEntity,
      UserBlockRelationEntity,
      IdentityAuditLogEntity
    ])
  ],
  controllers: [ProfileController],
  providers: [
    ProfilePresenter,
    ProfileBlockPresenter,
    ProfileBlockService,
    ProfileQueryService,
    ProfileCertificationWriteService,
    ProfilePersonalWriteService,
    ProfileSafetyAvatarFileService,
    ProfileSafetyResponsePresenter,
    ProfileSafetySubmitService,
    ProfileSafetyReviewService,
    ProfileSafetyWriteService,
    ProfileSafetyQueryService,
    ProfileOrganizationMembersQueryService,
    ProfileOrganizationMembersWriteService,
    ProfileSecurityQueryService,
    ProfileSecurityWriteService
  ]
})
export class ProfileModule {}

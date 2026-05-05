import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditModule } from '../audit/identity-audit.module';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { CreditConstraintsModule } from '../credit_constraints/credit-constraints.module';
import { GovernanceAppealCaseEntity } from '../governance/entities/governance-appeal-case.entity';
import { GovernancePenaltyEntity } from '../governance/entities/governance-penalty.entity';
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
import { OrganizationCreditScoringModule } from '../credit_scoring_shadow/organization-credit-scoring.module';
import { EnterpriseHubModule } from '../enterprise_hub/enterprise-hub.module';
import { ProfileController } from './profile.controller';
import { UserBlockRelationEntity } from './entities/user-block-relation.entity';
import { ProfileBlockPresenter } from './profile-block.presenter';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCertificationOcrService } from './profile-certification-ocr.service';
import { ProfileCertificationRevalidationService } from './profile-certification-revalidation.service';
import { ProfileCertificationWriteService } from './profile-certification-write.service';
import { ProfileGovernanceStatusQueryService } from './profile-governance-status.query.service';
import { PersonalCertificationEntity } from './entities/personal-certification.entity';
import { ProfilePersonalCertificationOcrService } from './profile-personal-certification-ocr.service';
import { ProfilePersonalCertificationWriteService } from './profile-personal-certification-write.service';
import { ProfilePersonalWriteService } from './profile-personal.write.service';
import { ProfileOrganizationMembersQueryService } from './profile-organization-members.query.service';
import { ProfileOrganizationMembersWriteService } from './profile-organization-members.write.service';
import { ProfileOrganizationSelfLeaveService } from './profile-organization-self-leave.service';
import { ProfilePresenter } from './profile.presenter';
import { ProfileQueryService } from './profile-query.service';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';
import { ProfileSafetyApprovalService } from './profile-safety-approval.service';
import { ProfileSafetyAutoDecisionService } from './profile-safety-auto-decision.service';
import { ProfileSafetyAvatarFileService } from './profile-safety-avatar-file.service';
import { ProfileSafetyQueryService } from './profile-safety.query.service';
import { ProfileSafetyResponsePresenter } from './profile-safety-response.presenter';
import { ProfileSafetyReviewService } from './profile-safety-review.service';
import { ProfileSafetySubmitService } from './profile-safety-submit.service';
import { ProfileSafetyWriteService } from './profile-safety.write.service';
import { ProfileSecurityQueryService } from './profile-security.query.service';
import { ProfileSecurityWriteService } from './profile-security.write.service';
import { OrganizationCertificationRevalidationAttemptEntity } from './entities/organization-certification-revalidation-attempt.entity';

@Module({
  imports: [
    AuthModule,
    ContentSafetyModule,
    CreditConstraintsModule,
    EnterpriseHubModule,
    OrganizationCreditScoringModule,
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
      OrganizationCertificationRevalidationAttemptEntity,
      PersonalCertificationEntity,
      IdentityAuditLogEntity,
      GovernanceAppealCaseEntity,
      GovernancePenaltyEntity
    ])
  ],
  controllers: [ProfileController],
  providers: [
    ProfilePresenter,
    ProfileBlockPresenter,
    ProfileBlockService,
    ProfileQueryService,
    ProfileCertificationOcrService,
    ProfileCertificationRevalidationService,
    ProfileCertificationWriteService,
    ProfilePersonalCertificationOcrService,
    ProfilePersonalCertificationWriteService,
    ProfilePersonalWriteService,
    ProfileSafetyApprovalService,
    ProfileSafetyAutoDecisionService,
    ProfileSafetyAvatarFileService,
    ProfileSafetyResponsePresenter,
    ProfileSafetySubmitService,
    ProfileSafetyReviewService,
    ProfileSafetyWriteService,
    ProfileSafetyQueryService,
    ProfileGovernanceStatusQueryService,
    ProfileOrganizationMembersQueryService,
    ProfileOrganizationMembersWriteService,
    ProfileOrganizationSelfLeaveService,
    ProfileSecurityQueryService,
    ProfileSecurityWriteService
  ],
  exports: [ProfileSafetyReviewService]
})
export class ProfileModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { IdentityModule } from '../identity/identity.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { OrganizationCertificationEntity } from './entities/organization-certification.entity';
import { OrganizationInvitationEntity } from './entities/organization-invitation.entity';
import { OrganizationMemberEntity } from './entities/organization-member.entity';
import { OrganizationEntity } from './entities/organization.entity';
import { CurrentActorEligibilityService } from './current-actor-eligibility.service';
import { OrganizationWritePresenter } from './organization-write.presenter';
import { OrganizationWriteService } from './organization-write.service';

@Module({
  imports: [
    AuthModule,
    IdentityModule,
    TypeOrmModule.forFeature([
      OrganizationEntity,
      OrganizationMemberEntity,
      OrganizationCertificationEntity,
      OrganizationInvitationEntity,
      FileAssetEntity
    ])
  ],
  providers: [CurrentActorEligibilityService, OrganizationWritePresenter, OrganizationWriteService],
  exports: [TypeOrmModule, CurrentActorEligibilityService, OrganizationWriteService]
})
export class OrganizationModule {}

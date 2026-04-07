import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationModule } from '../organization/organization.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { OrganizationReviewController } from './organization-review.controller';
import { OrganizationReviewPresenter } from './organization-review.presenter';
import { OrganizationReviewQueryService } from './organization-review-query.service';
import { OrganizationReviewWriteService } from './organization-review-write.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      OrganizationEntity,
      OrganizationCertificationEntity,
      FileAssetEntity,
      IdentityAuditLogEntity
    ])
  ],
  controllers: [OrganizationReviewController],
  providers: [
    OrganizationReviewPresenter,
    OrganizationReviewQueryService,
    OrganizationReviewWriteService
  ]
})
export class ReviewModule {}

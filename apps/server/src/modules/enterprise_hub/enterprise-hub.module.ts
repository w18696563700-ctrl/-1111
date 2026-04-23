import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { UploadModule } from '../upload/upload.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { EnterpriseHubAdminController } from './enterprise-hub-admin.controller';
import { EnterpriseHubApplicationReviewAdminQueryService } from './enterprise-hub-application-review-admin.query.service';
import { EnterpriseHubApplicationReviewAdminWriteService } from './enterprise-hub-application-review-admin.write.service';
import { EnterpriseHubAdminService } from './enterprise-hub-admin.service';
import { EnterpriseHubAutoSlotService } from './enterprise-hub-auto-slot.service';
import { EnterpriseHubCaseContinuationQueryService } from './enterprise-hub-case-continuation.query.service';
import { EnterpriseHubCaseContinuationSupportService } from './enterprise-hub-case-continuation-support.service';
import { EnterpriseHubCaseContinuationWriteService } from './enterprise-hub-case-continuation.write.service';
import { EnterpriseHubCertificationSyncService } from './enterprise-hub-certification-sync.service';
import { EnterpriseHubContactWriteService } from './enterprise-hub-contact-write.service';
import { EnterpriseHubAmapLocationProviderService } from './enterprise-hub-amap-location-provider.service';
import { EnterpriseHubFormalInfoQueryService } from './enterprise-hub-formal-info.query.service';
import { EnterpriseHubListingWriteSupportService } from './enterprise-hub-listing-write-support.service';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubMediaProjectionService } from './enterprise-hub-media-projection.service';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';
import { EnterpriseHubPublishedChangeAdminService } from './enterprise-hub-published-change-admin.service';
import { EnterpriseHubPublishedChangeAppService } from './enterprise-hub-published-change-app.service';
import { EnterpriseHubPublishedChangeLiveWriteService } from './enterprise-hub-published-change-live-write.service';
import { EnterpriseHubPublishedChangePresenter } from './enterprise-hub-published-change.presenter';
import { EnterpriseHubPublishedChangeSnapshotService } from './enterprise-hub-published-change-snapshot.service';
import { EnterpriseHubPublishedChangeSupportService } from './enterprise-hub-published-change-support.service';
import { EnterpriseHubPresenter } from './enterprise-hub.presenter';
import { EnterpriseHubPublicReadRepairService } from './enterprise-hub-public-read-repair.service';
import { EnterpriseHubQueryService } from './enterprise-hub-query.service';
import { EnterpriseHubTruthController } from './enterprise-hub-truth.controller';
import { EnterpriseHubWorkbenchPresenter } from './enterprise-hub-workbench.presenter';
import { EnterpriseHubWorkbenchQueryService } from './enterprise-hub-workbench.query.service';
import { EnterpriseHubWriteService } from './enterprise-hub-write.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseChangeRequestEntity } from './entities/enterprise-change-request.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseCertificationSnapshotEntity } from './entities/enterprise-certification-snapshot.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseMediaAssetRefEntity } from './entities/enterprise-media-asset-ref.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';
import { EnterpriseRecommendationSlotEntity } from './entities/enterprise-recommendation-slot.entity';
import { EnterpriseReviewSummaryEntity } from './entities/enterprise-review-summary.entity';
import { EnterpriseServiceAreaEntity } from './entities/enterprise-service-area.entity';

@Module({
  imports: [
    CoreModule,
    AuthModule,
    OrganizationModule,
    UploadModule,
    TypeOrmModule.forFeature([
      EnterpriseListingEntity,
      EnterpriseProfileCompanyEntity,
      EnterpriseProfileFactoryEntity,
      EnterpriseProfileSupplierEntity,
      EnterpriseCaseEntity,
      EnterpriseChangeRequestEntity,
      EnterpriseCertificationSnapshotEntity,
      EnterpriseServiceAreaEntity,
      EnterpriseContactEntity,
      EnterpriseApplicationEntity,
      EnterpriseReviewSummaryEntity,
      EnterpriseRecommendationSlotEntity,
      EnterpriseMediaAssetRefEntity,
      OrganizationCertificationEntity,
      FileAssetEntity,
    ])
  ],
  controllers: [EnterpriseHubTruthController, EnterpriseHubAdminController],
  providers: [
    EnterpriseHubPresenter,
    EnterpriseHubWorkbenchPresenter,
    EnterpriseHubContactWriteService,
    EnterpriseHubListingWriteSupportService,
    EnterpriseHubAmapLocationProviderService,
    EnterpriseHubFormalInfoQueryService,
    EnterpriseHubLocationService,
    EnterpriseHubMediaProjectionService,
    EnterpriseHubMediaTruthService,
    EnterpriseHubApplicationReviewAdminQueryService,
    EnterpriseHubApplicationReviewAdminWriteService,
    EnterpriseHubAutoSlotService,
    EnterpriseHubPublishedChangePresenter,
    EnterpriseHubPublishedChangeSnapshotService,
    EnterpriseHubPublishedChangeSupportService,
    EnterpriseHubPublishedChangeAppService,
    EnterpriseHubPublishedChangeAdminService,
    EnterpriseHubPublishedChangeLiveWriteService,
    EnterpriseHubPublicReadRepairService,
    EnterpriseHubCaseContinuationSupportService,
    EnterpriseHubCaseContinuationQueryService,
    EnterpriseHubCaseContinuationWriteService,
    EnterpriseHubQueryService,
    EnterpriseHubWorkbenchQueryService,
    EnterpriseHubCertificationSyncService,
    EnterpriseHubWriteService,
    EnterpriseHubAdminService
  ],
  exports: [EnterpriseHubCertificationSyncService, EnterpriseHubMediaProjectionService]
})
export class EnterpriseHubModule {}

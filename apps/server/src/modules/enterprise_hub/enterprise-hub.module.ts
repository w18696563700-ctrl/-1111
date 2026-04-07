import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EnterpriseHubAdminController } from './enterprise-hub-admin.controller';
import { EnterpriseHubAdminService } from './enterprise-hub-admin.service';
import { EnterpriseHubPresenter } from './enterprise-hub.presenter';
import { EnterpriseHubQueryService } from './enterprise-hub-query.service';
import { EnterpriseHubTruthController } from './enterprise-hub-truth.controller';
import { EnterpriseHubWriteService } from './enterprise-hub-write.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
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
    TypeOrmModule.forFeature([
      EnterpriseListingEntity,
      EnterpriseProfileCompanyEntity,
      EnterpriseProfileFactoryEntity,
      EnterpriseProfileSupplierEntity,
      EnterpriseCaseEntity,
      EnterpriseCertificationSnapshotEntity,
      EnterpriseServiceAreaEntity,
      EnterpriseContactEntity,
      EnterpriseApplicationEntity,
      EnterpriseReviewSummaryEntity,
      EnterpriseRecommendationSlotEntity,
      EnterpriseMediaAssetRefEntity
    ])
  ],
  controllers: [EnterpriseHubTruthController, EnterpriseHubAdminController],
  providers: [
    EnterpriseHubPresenter,
    EnterpriseHubQueryService,
    EnterpriseHubWriteService,
    EnterpriseHubAdminService
  ]
})
export class EnterpriseHubModule {}

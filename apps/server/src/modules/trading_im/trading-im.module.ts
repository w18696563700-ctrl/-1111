import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { EnterpriseHubModule } from '../enterprise_hub/enterprise-hub.module';
import { EnterpriseListingEntity } from '../enterprise_hub/entities/enterprise-listing.entity';
import { EnterpriseReviewSummaryEntity } from '../enterprise_hub/entities/enterprise-review-summary.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { BidThreadConfirmationCardEntity } from './entities/bid-thread-confirmation-card.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from './entities/project-clarification.entity';
import { TradingImController } from './trading-im.controller';
import { BidSubmittedSeedService } from './bid-submitted-seed.service';
import { TradingImParticipantCardQueryService } from './trading-im-participant-card.query.service';
import { TradingImPresenter } from './trading-im.presenter';
import { TradingImService } from './trading-im.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ProjectClarificationEntity,
      BidPrivateThreadEntity,
      BidThreadMessageEntity,
      BidThreadConfirmationCardEntity,
      ProjectEntity,
      BidEntity,
      FileAssetEntity,
      IdentityAuditLogEntity,
      EnterpriseListingEntity,
      EnterpriseReviewSummaryEntity,
      OrganizationCertificationEntity
    ]),
    AuthModule,
    OrganizationModule,
    EnterpriseHubModule
  ],
  controllers: [TradingImController],
  providers: [
    TradingImPresenter,
    TradingImService,
    TradingImParticipantCardQueryService,
    BidSubmittedSeedService
  ],
  exports: [BidSubmittedSeedService]
})
export class TradingImModule {}

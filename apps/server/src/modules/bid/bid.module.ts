import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { BidParticipationRequestModule } from '../bid_participation_request/bid-participation-request.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectCommunicationModule } from '../project_communication/project-communication.module';
import { TradingImModule } from '../trading_im/trading-im.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { BidController } from './bid.controller';
import { BidPackageCompletenessQueryService } from './bid-package-completeness.query.service';
import { BidPackageController } from './bid-package.controller';
import { BidSeatMigrationService } from './bid-seat-migration.service';
import { BidSeatService } from './bid-seat.service';
import { BidSubmissionAttachmentTruthService } from './bid-submission-attachment-truth.service';
import { BidPresenter } from './bid.presenter';
import { BidWriteService } from './bid-write.service';
import { BidEntity } from './entities/bid.entity';
import { BidSeatEntity } from './entities/bid-seat.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      BidEntity,
      BidSeatEntity,
      ProjectEntity,
      IdentityAuditLogEntity,
      FileAssetEntity,
    ]),
    AuthModule,
    BidParticipationRequestModule,
    OrganizationModule,
    ProjectPublishAuditModule,
    ProjectCommunicationModule,
    TradingImModule
  ],
  controllers: [BidController, BidPackageController],
  providers: [
    BidPresenter,
    BidSubmissionAttachmentTruthService,
    BidWriteService,
    BidSeatMigrationService,
    BidSeatService,
    BidPackageCompletenessQueryService
  ]
})
export class BidModule {}

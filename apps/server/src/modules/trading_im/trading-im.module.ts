import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { BidThreadConfirmationCardEntity } from './entities/bid-thread-confirmation-card.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from './entities/project-clarification.entity';
import { TradingImController } from './trading-im.controller';
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
      IdentityAuditLogEntity
    ]),
    AuthModule,
    OrganizationModule
  ],
  controllers: [TradingImController],
  providers: [TradingImPresenter, TradingImService]
})
export class TradingImModule {}

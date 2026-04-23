import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import { BidSubmissionSnapshotController, MyBidController } from './my-bid.controller';
import { MyBidPresenter } from './my-bid.presenter';
import { MyBidQueryService } from './my-bid.query.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      BidEntity,
      ProjectEntity,
      BidPrivateThreadEntity,
      OrganizationEntity
    ]),
    AuthModule,
    OrganizationModule
  ],
  controllers: [MyBidController, BidSubmissionSnapshotController],
  providers: [MyBidPresenter, MyBidQueryService]
})
export class MyBidModule {}

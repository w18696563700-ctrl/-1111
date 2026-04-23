import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidThreadMessageEntity } from '../trading_im/entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import { MessageInteractionController } from './message-interaction.controller';
import { MessageInteractionPresenter } from './message-interaction.presenter';
import { MessageInteractionQueryService } from './message-interaction.query.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      BidPrivateThreadEntity,
      BidThreadMessageEntity,
      BidEntity,
      ProjectEntity,
      OrganizationEntity,
      UserEntity,
    ]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [MessageInteractionController],
  providers: [MessageInteractionPresenter, MessageInteractionQueryService],
})
export class MessageInteractionModule {}

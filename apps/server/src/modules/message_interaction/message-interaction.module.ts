import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { InquiryQuoteDepositEntity } from '../p0_pay/entities/inquiry-quote-deposit.entity';
import { PlatformServiceFeeAuthorizationEntity } from '../p0_pay/entities/platform-service-fee-authorization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessModule } from '../project_name_access/project-name-access.module';
import { ProjectNameAccessRequestEntity } from '../project_name_access/entities/project-name-access-request.entity';
import { BidThreadMessageEntity } from '../trading_im/entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from '../trading_im/entities/project-clarification.entity';
import { UploadModule } from '../upload/upload.module';
import { CounterpartConversationAvatarService } from './counterpart-conversation-avatar.service';
import { CounterpartConversationBidThreadSource } from './counterpart-conversation.bid-thread-source';
import { CounterpartConversationClarificationSource } from './counterpart-conversation.clarification-source';
import { CounterpartConversationProjectionService } from './counterpart-conversation.projection.service';
import { CounterpartConversationProjectNameAccessSource } from './counterpart-conversation.project-name-access-source';
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
      PlatformServiceFeeAuthorizationEntity,
      InquiryQuoteDepositEntity,
      ProjectNameAccessRequestEntity,
      ProjectClarificationEntity,
      OrganizationEntity,
      UserEntity,
    ]),
    AuthModule,
    OrganizationModule,
    ProjectNameAccessModule,
    UploadModule,
  ],
  controllers: [MessageInteractionController],
  providers: [
    CounterpartConversationAvatarService,
    CounterpartConversationBidThreadSource,
    CounterpartConversationClarificationSource,
    CounterpartConversationProjectionService,
    CounterpartConversationProjectNameAccessSource,
    MessageInteractionPresenter,
    MessageInteractionQueryService,
  ],
})
export class MessageInteractionModule {}

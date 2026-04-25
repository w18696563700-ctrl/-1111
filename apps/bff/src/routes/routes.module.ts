import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { BidModule } from './bid/bid.module';
import { EnterpriseHubModule } from './enterprise_hub/enterprise-hub.module';
import { ExhibitionHomeModule } from './exhibition_home/exhibition-home.module';
import { ExhibitionP0PayModule } from './exhibition_p0_pay/exhibition-p0-pay.module';
import { FileUploadModule } from './file/file-upload.module';
import { ForumModule } from './forum/forum.module';
import { MessageInteractionModule } from './message_interaction/message-interaction.module';
import { MyBidModule } from './my_bid/my-bid.module';
import { MyProjectModule } from './my_project/my-project.module';
import { OrderRouteModule } from './order/order.module';
import { ProfileReadModule } from './profile/profile-read.module';
import { ProjectCounterpartyRatingModule } from './project_counterparty_rating/project-counterparty-rating.module';
import { ProjectModule } from './project/project.module';
import { RatingModule } from './rating/rating.module';
import { ShellModule } from './shell/shell.module';
import { TradingReadCorridorModule } from './trading_read_corridor/trading-read-corridor.module';
import { TradingShellHandoffModule } from './trading_shell_handoff/trading-shell-handoff.module';
import { TradingImModule } from './trading_im/trading-im.module';

@Module({
  // Keep the local source graph aligned with the currently frozen app-facing surfaces in this workspace slice.
  imports: [
    AuthModule,
    BidModule,
    EnterpriseHubModule,
    ExhibitionHomeModule,
    ExhibitionP0PayModule,
    ForumModule,
    MessageInteractionModule,
    MyBidModule,
    MyProjectModule,
    OrderRouteModule,
    ShellModule,
    ProfileReadModule,
    ProjectModule,
    ProjectCounterpartyRatingModule,
    RatingModule,
    TradingReadCorridorModule,
    TradingShellHandoffModule,
    TradingImModule,
    FileUploadModule,
  ],
})
export class RoutesModule {}

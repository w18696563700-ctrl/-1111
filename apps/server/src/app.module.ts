import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from './core/core.module';
import { RuntimeConfigService } from './core/runtime-config.service';
import { BidModule } from './modules/bid/bid.module';
import { BidAwardModule } from './modules/bid_award/bid-award.module';
import { AuthModule } from './modules/auth/auth.module';
import { AuditAdminModule } from './modules/audit/audit-admin.module';
import { CreditConstraintsModule } from './modules/credit_constraints/credit-constraints.module';
import { ContentSafetyAdminModule } from './modules/content_safety/content-safety-admin.module';
import { AiReviewGatewayModule } from './modules/ai_review_gateway/ai-review-gateway.module';
import { ExhibitionHomeModule } from './modules/exhibition_home/exhibition-home.module';
import { ExhibitionReportCaseModule } from './modules/exhibition_report_cases/exhibition-report-case.module';
import { EnterpriseHubModule } from './modules/enterprise_hub/enterprise-hub.module';
import { ForumModule } from './modules/forum/forum.module';
import { GovernanceModule } from './modules/governance/governance.module';
import { MembershipModule } from './modules/membership/membership.module';
import { MyProjectModule } from './modules/my_project/my-project.module';
import { PaymentBillingModule } from './modules/payment_billing/payment-billing.module';
import { ProfileModule } from './modules/profile/profile.module';
import { ProjectModule } from './modules/project/project.module';
import { RatingModule } from './modules/rating/rating.module';
import { ReviewModule } from './modules/review/review.module';
import { ShellModule } from './modules/shell/shell.module';
import { TemplateConfigModule } from './modules/template_config/template-config.module';
import { TradingReadCorridorModule } from './modules/trading_read_corridor/trading-read-corridor.module';
import { TradingShellHandoffModule } from './modules/trading_shell_handoff/trading-shell-handoff.module';
import { TradingImModule } from './modules/trading_im/trading-im.module';
import { UploadModule } from './modules/upload/upload.module';

@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forRootAsync({
      imports: [CoreModule],
      inject: [RuntimeConfigService],
      useFactory: (config: RuntimeConfigService) => ({
        type: 'postgres' as const,
        host: config.postgresHost,
        port: config.postgresPort,
        username: config.postgresUser,
        password: config.postgresPassword,
        database: config.postgresDatabase,
        autoLoadEntities: true,
        synchronize: false
      })
    }),
    AiReviewGatewayModule,
    AuthModule,
    AuditAdminModule,
    BidModule,
    BidAwardModule,
    ContentSafetyAdminModule,
    CreditConstraintsModule,
    ExhibitionHomeModule,
    ExhibitionReportCaseModule,
    EnterpriseHubModule,
    ForumModule,
    GovernanceModule,
    MembershipModule,
    PaymentBillingModule,
    MyProjectModule,
    RatingModule,
    ShellModule,
    TemplateConfigModule,
    ProfileModule,
    ReviewModule,
    ProjectModule,
    TradingReadCorridorModule,
    TradingShellHandoffModule,
    TradingImModule,
    UploadModule
  ]
})
export class AppModule {}

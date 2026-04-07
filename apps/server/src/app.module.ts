import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from './core/core.module';
import { RuntimeConfigService } from './core/runtime-config.service';
import { AuthModule } from './modules/auth/auth.module';
import { CreditConstraintsModule } from './modules/credit_constraints/credit-constraints.module';
import { ExhibitionHomeModule } from './modules/exhibition_home/exhibition-home.module';
import { ExhibitionWorkbenchModule } from './modules/exhibition_workbench/exhibition-workbench.module';
import { EnterpriseHubModule } from './modules/enterprise_hub/enterprise-hub.module';
import { ForumModule } from './modules/forum/forum.module';
import { MembershipModule } from './modules/membership/membership.module';
import { MyProjectModule } from './modules/my_project/my-project.module';
import { PaymentBillingModule } from './modules/payment_billing/payment-billing.module';
import { ProfileModule } from './modules/profile/profile.module';
import { ProjectModule } from './modules/project/project.module';
import { ReviewModule } from './modules/review/review.module';
import { ShellModule } from './modules/shell/shell.module';
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
    AuthModule,
    CreditConstraintsModule,
    ExhibitionHomeModule,
    ExhibitionWorkbenchModule,
    EnterpriseHubModule,
    ForumModule,
    MembershipModule,
    PaymentBillingModule,
    MyProjectModule,
    ShellModule,
    ProfileModule,
    ReviewModule,
    ProjectModule,
    UploadModule
  ]
})
export class AppModule {}

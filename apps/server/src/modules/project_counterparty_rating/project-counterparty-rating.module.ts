import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { CreditScoringShadowModule } from '../credit_scoring_shadow/credit-scoring-shadow.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectCounterpartyRatingEntity } from './entities/project-counterparty-rating.entity';
import { ProjectCounterpartyRatingController } from './project-counterparty-rating.controller';
import { ProjectCounterpartyRatingPresenter } from './project-counterparty-rating.presenter';
import { ProjectCounterpartyRatingService } from './project-counterparty-rating.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectCounterpartyRatingEntity]),
    AuthModule,
    CreditScoringShadowModule,
    OrganizationModule,
    ProjectPublishAuditModule
  ],
  controllers: [ProjectCounterpartyRatingController],
  providers: [ProjectCounterpartyRatingPresenter, ProjectCounterpartyRatingService],
  exports: [ProjectCounterpartyRatingService]
})
export class ProjectCounterpartyRatingModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ContentSafetySnapshotEntity } from '../content_safety/entities/content-safety-snapshot.entity';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { GovernanceAppealAdminController } from './governance-appeal-admin.controller';
import { GovernanceAppealPresenter } from './governance-appeal.presenter';
import { GovernanceAppealService } from './governance-appeal.service';
import { GovernanceAppealCaseEntity } from './entities/governance-appeal-case.entity';
import { GovernancePenaltyEntity } from './entities/governance-penalty.entity';
import { GovernanceAdminController } from './governance-admin.controller';
import { GovernanceRescanAdminController } from './governance-rescan-admin.controller';
import { GovernanceRescanJobEntity } from './entities/governance-rescan-job.entity';
import { GovernanceRescanJobPresenter } from './governance-rescan-job.presenter';
import { GovernanceRescanJobService } from './governance-rescan-job.service';
import { GovernancePenaltyPresenter } from './governance-penalty.presenter';
import { GovernancePenaltyService } from './governance-penalty.service';

@Module({
  imports: [
    AuthModule,
    ContentSafetyModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      ContentSafetySnapshotEntity,
      GovernanceAppealCaseEntity,
      GovernanceRescanJobEntity,
      GovernancePenaltyEntity,
      ForumReportTicketEntity,
      OrganizationEntity,
      OrganizationMemberEntity
    ])
  ],
  controllers: [
    GovernanceAdminController,
    GovernanceAppealAdminController,
    GovernanceRescanAdminController
  ],
  providers: [
    GovernancePenaltyPresenter,
    GovernancePenaltyService,
    GovernanceAppealPresenter,
    GovernanceAppealService,
    GovernanceRescanJobPresenter,
    GovernanceRescanJobService
  ]
})
export class GovernanceModule {}

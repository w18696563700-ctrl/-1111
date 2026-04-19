import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { OrganizationModule } from '../organization/organization.module';
import { ProfileModule } from '../profile/profile.module';
import { ProfileSafetySubmissionEntity } from '../profile/entities/profile-safety-submission.entity';
import { ContentSafetyAdminController } from './content-safety-admin.controller';
import { ContentSafetyReviewTaskPresenter } from './content-safety-review-task.presenter';
import { ContentSafetyReviewTaskQueryService } from './content-safety-review-task.query.service';
import { ContentSafetyReviewTaskWriteService } from './content-safety-review-task.write.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    ProfileModule,
    TypeOrmModule.forFeature([ProfileSafetySubmissionEntity, ForumReportTicketEntity])
  ],
  controllers: [ContentSafetyAdminController],
  providers: [
    ContentSafetyReviewTaskPresenter,
    ContentSafetyReviewTaskQueryService,
    ContentSafetyReviewTaskWriteService
  ]
})
export class ContentSafetyAdminModule {}

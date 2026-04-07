import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ForumController } from './forum.controller';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumReportTicketEntity } from './entities/forum-report-ticket.entity';
import { ForumPresenter } from './forum.presenter';
import { ForumReportPresenter } from './forum-report.presenter';
import { ForumReportQueryService } from './forum-report.query.service';
import { ForumReportService } from './forum-report.service';
import { ForumQueryService } from './forum.query.service';
import { ForumWriteService } from './forum.write.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ForumCommentEntity,
      ForumDraftEntity,
      ForumPostEntity,
      ForumReportTicketEntity,
      UserEntity,
      OrganizationEntity,
      FileAssetEntity
    ]),
    AuthModule,
    ContentSafetyModule,
    OrganizationModule
  ],
  controllers: [ForumController],
  providers: [
    ForumPresenter,
    ForumReportPresenter,
    ForumReportQueryService,
    ForumReportService,
    ForumQueryService,
    ForumWriteService
  ]
})
export class ForumModule {}

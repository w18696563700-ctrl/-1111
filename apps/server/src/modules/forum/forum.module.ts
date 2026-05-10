import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyModule } from '../content_safety/content-safety.module';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { NotificationModule } from '../notifications/notification.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadModule } from '../upload/upload.module';
import { ForumController } from './forum.controller';
import { ForumAuthorProjectionService } from './forum-author-projection.service';
import { ForumAuthorQueryService } from './forum-author.query.service';
import { ForumCommentService } from './forum-comment.service';
import { ForumInteractionInboxPresenter } from './forum-interaction-inbox.presenter';
import { ForumInteractionInboxQueryService } from './forum-interaction-inbox.query.service';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostBookmarkEntity } from './entities/forum-post-bookmark.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumPostLikeEntity } from './entities/forum-post-like.entity';
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
      ForumAuthorFollowEntity,
      ForumPostBookmarkEntity,
      ForumPostEntity,
      ForumPostLikeEntity,
      ForumReportTicketEntity,
      UserEntity,
      OrganizationEntity,
      FileAssetEntity
    ]),
    AuthModule,
    ContentSafetyModule,
    NotificationModule,
    OrganizationModule,
    UploadModule
  ],
  controllers: [ForumController],
  providers: [
    ForumPresenter,
    ForumAuthorProjectionService,
    ForumAuthorQueryService,
    ForumCommentService,
    ForumInteractionInboxPresenter,
    ForumInteractionInboxQueryService,
    ForumReportPresenter,
    ForumReportQueryService,
    ForumReportService,
    ForumQueryService,
    ForumWriteService
  ]
})
export class ForumModule {}

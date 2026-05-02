import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { BidEntity } from '../bid/entities/bid.entity';
import { OrganizationModule } from '../organization/organization.module';
import { NotificationModule } from '../notifications/notification.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectAttachmentEntity } from '../project/entities/project-attachment.entity';
import { ProjectNameAccessRequestEntity } from '../project_name_access/entities/project-name-access-request.entity';
import { ProjectClarificationEntity } from '../trading_im/entities/project-clarification.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadModule } from '../upload/upload.module';
import { ProjectAlbumController } from './project-album.controller';
import { ProjectAlbumPhotoEntity } from './entities/project-album-photo.entity';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectAlbumPhotoService } from './project-album-photo.service';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import { ProjectCommunicationController } from './project-communication.controller';
import { ProjectCommunicationFilePreviewService } from './project-communication-file-preview.service';
import { ProjectCommunicationMessageService } from './project-communication-message.service';
import { ProjectCommunicationPreviewController } from './project-communication-preview.controller';
import { ProjectCommunicationPresenter } from './project-communication.presenter';
import { ProjectCommunicationRealtimeEventService } from './project-communication-realtime-event.service';
import { ProjectCommunicationSoftLinkService } from './project-communication-softlink.service';
import { ProjectCommunicationUnreadQueryService } from './project-communication-unread.query.service';
import { ProjectCommunicationWorkbenchController } from './project-communication-workbench.controller';
import { ProjectCommunicationWorkbenchPresenter } from './project-communication-workbench.presenter';
import { ProjectCommunicationWorkbenchService } from './project-communication-workbench.service';

@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forFeature([
      ProjectEntity,
      ProjectAttachmentEntity,
      BidEntity,
      BidParticipationRequestEntity,
      ProjectNameAccessRequestEntity,
      ProjectClarificationEntity,
      ProjectCommunicationThreadEntity,
      ProjectCommunicationMessageEntity,
      ProjectCommunicationReadCursorEntity,
      ProjectCommunicationMaterialReviewEntity,
      ProjectAlbumPhotoEntity,
      FileAssetEntity
    ]),
    AuthModule,
    OrganizationModule,
    ProjectPublishAuditModule,
    NotificationModule,
    UploadModule
  ],
  controllers: [
    ProjectCommunicationController,
    ProjectCommunicationWorkbenchController,
    ProjectCommunicationPreviewController,
    ProjectAlbumController
  ],
  providers: [
    ProjectCommunicationAccessService,
    ProjectCommunicationFilePreviewService,
    ProjectCommunicationPresenter,
    ProjectCommunicationWorkbenchPresenter,
    ProjectCommunicationWorkbenchService,
    ProjectCommunicationRealtimeEventService,
    ProjectCommunicationMessageService,
    ProjectCommunicationSoftLinkService,
    ProjectCommunicationUnreadQueryService,
    ProjectAlbumPhotoService
  ],
  exports: [
    ProjectCommunicationMessageService,
    ProjectCommunicationSoftLinkService,
    ProjectCommunicationUnreadQueryService,
    ProjectAlbumPhotoService
  ]
})
export class ProjectCommunicationModule {}

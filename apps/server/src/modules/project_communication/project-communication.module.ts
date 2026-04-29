import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { BidEntity } from '../bid/entities/bid.entity';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from '../project_name_access/entities/project-name-access-request.entity';
import { ProjectClarificationEntity } from '../trading_im/entities/project-clarification.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProjectAlbumController } from './project-album.controller';
import { ProjectAlbumPhotoEntity } from './entities/project-album-photo.entity';
import { ProjectCommunicationMessageEntity } from './entities/project-communication-message.entity';
import { ProjectCommunicationReadCursorEntity } from './entities/project-communication-read-cursor.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import { ProjectAlbumPhotoService } from './project-album-photo.service';
import { ProjectCommunicationAccessService } from './project-communication-access.service';
import { ProjectCommunicationController } from './project-communication.controller';
import { ProjectCommunicationMessageService } from './project-communication-message.service';
import { ProjectCommunicationPresenter } from './project-communication.presenter';
import { ProjectCommunicationRealtimeEventService } from './project-communication-realtime-event.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ProjectEntity,
      BidEntity,
      BidParticipationRequestEntity,
      ProjectNameAccessRequestEntity,
      ProjectClarificationEntity,
      ProjectCommunicationThreadEntity,
      ProjectCommunicationMessageEntity,
      ProjectCommunicationReadCursorEntity,
      ProjectAlbumPhotoEntity,
      FileAssetEntity
    ]),
    AuthModule,
    OrganizationModule,
    ProjectPublishAuditModule
  ],
  controllers: [ProjectCommunicationController, ProjectAlbumController],
  providers: [
    ProjectCommunicationAccessService,
    ProjectCommunicationPresenter,
    ProjectCommunicationRealtimeEventService,
    ProjectCommunicationMessageService,
    ProjectAlbumPhotoService
  ],
  exports: [ProjectCommunicationMessageService, ProjectAlbumPhotoService]
})
export class ProjectCommunicationModule {}

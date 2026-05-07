import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { BidParticipationRequestModule } from '../bid_participation_request/bid-participation-request.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectNameAccessModule } from '../project_name_access/project-name-access.module';
import { ProjectCommunicationModule } from '../project_communication/project-communication.module';
import { ProjectCommunicationThreadEntity } from '../project_communication/entities/project-communication-thread.entity';
import { UploadModule } from '../upload/upload.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { BidEntity } from '../bid/entities/bid.entity';
import { ProjectOrderEntity } from '../order/entities/project-order.entity';
import { InquiryQuoteDepositEntity } from '../p0_pay/entities/inquiry-quote-deposit.entity';
import { PlatformServiceFeeAuthorizationEntity } from '../p0_pay/entities/platform-service-fee-authorization.entity';
import { ProjectAuthenticitySincerityFreezeFeedbackEntity } from '../p0_pay/entities/project-authenticity-sincerity-freeze-feedback.entity';
import { ForumPostEntity } from '../forum/entities/forum-post.entity';
import { ProjectAttachmentFileAccessController } from './project-attachment-file-access.controller';
import { ProjectAttachmentFileAccessService } from './project-attachment-file-access.service';
import { ProjectAttachmentController } from './project-attachment.controller';
import { ProjectAttachmentPresenter } from './project-attachment.presenter';
import { ProjectAttachmentService } from './project-attachment.service';
import { ProjectBidMaterialController } from './project-bid-material.controller';
import { ProjectBidMaterialPresenter } from './project-bid-material.presenter';
import { ProjectBidMaterialService } from './project-bid-material.service';
import { ProjectPublicResourceController } from './project-public-resource.controller';
import { ProjectPublicResourcePresenter } from './project-public-resource.presenter';
import { ProjectPublicResourceService } from './project-public-resource.service';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectExitCaseEntity } from './entities/project-exit-case.entity';
import { ProjectPublicResourceEntity } from './entities/project-public-resource.entity';
import { ProjectEntity } from './entities/project.entity';
import { ProjectController } from './project.controller';
import { ProjectExitGovernanceService } from './project-exit-governance.service';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectPublishGateService } from './project-publish-gate.service';
import { ProjectPresenter } from './project.presenter';
import { ProjectQueryService } from './project-query.service';
import { ProjectWriteService } from './project-write.service';

@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forFeature([
      ProjectEntity,
      ProjectAttachmentEntity,
      ProjectPublicResourceEntity,
      ProjectExitCaseEntity,
      FileAssetEntity,
      ForumPostEntity,
      ProjectCommunicationThreadEntity,
      BidEntity,
      ProjectOrderEntity,
      InquiryQuoteDepositEntity,
      PlatformServiceFeeAuthorizationEntity,
      ProjectAuthenticitySincerityFreezeFeedbackEntity
    ]),
    ProjectPublishAuditModule,
    AuthModule,
    OrganizationModule,
    BidParticipationRequestModule,
    ProjectNameAccessModule,
    ProjectCommunicationModule,
    UploadModule
  ],
  controllers: [
    ProjectPublicResourceController,
    ProjectAttachmentFileAccessController,
    ProjectController,
    ProjectAttachmentController,
    ProjectBidMaterialController
  ],
  providers: [
    ProjectPresenter,
    ProjectAttachmentPresenter,
    ProjectBidMaterialPresenter,
    ProjectPublicResourcePresenter,
    ProjectQueryService,
    ProjectPublishGateService,
    ProjectLifecycleService,
    ProjectExitGovernanceService,
    ProjectWriteService,
    ProjectAttachmentService,
    ProjectAttachmentFileAccessService,
    ProjectBidMaterialService,
    ProjectPublicResourceService
  ],
  exports: [TypeOrmModule, ProjectQueryService]
})
export class ProjectModule {}

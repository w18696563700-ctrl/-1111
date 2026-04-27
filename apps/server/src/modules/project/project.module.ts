import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectNameAccessModule } from '../project_name_access/project-name-access.module';
import { UploadModule } from '../upload/upload.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
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
import { ProjectPublicResourceEntity } from './entities/project-public-resource.entity';
import { ProjectEntity } from './entities/project.entity';
import { ProjectController } from './project.controller';
import { ProjectLifecycleService } from './project-lifecycle.service';
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
      FileAssetEntity
    ]),
    ProjectPublishAuditModule,
    AuthModule,
    OrganizationModule,
    ProjectNameAccessModule,
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
    ProjectLifecycleService,
    ProjectWriteService,
    ProjectAttachmentService,
    ProjectAttachmentFileAccessService,
    ProjectBidMaterialService,
    ProjectPublicResourceService
  ],
  exports: [TypeOrmModule, ProjectQueryService]
})
export class ProjectModule {}

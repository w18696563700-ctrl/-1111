import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppProjectAlbumController } from './app-project-album.controller';
import { AppProjectController } from './app-project.controller';
import { AppProjectNameAccessController } from '../project_name_access/app-project-name-access.controller';
import { ProjectAlbumService } from './project-album.service';
import { ProjectBidMaterialService } from './project-bid-material.service';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectNameAccessService } from '../project_name_access/project-name-access.service';
import { ProjectController } from './project.controller';
import { ProjectPublicResourceService } from './project-public-resource.service';
import { ProjectService } from './project.service';

@Module({
  imports: [CoreModule],
  controllers: [
    ProjectController,
    AppProjectController,
    AppProjectAlbumController,
    AppProjectNameAccessController,
  ],
  providers: [
    ProjectService,
    ProjectAlbumService,
    ProjectLifecycleService,
    ProjectPublicResourceService,
    ProjectBidMaterialService,
    ProjectNameAccessService,
  ],
})
export class ProjectModule {}

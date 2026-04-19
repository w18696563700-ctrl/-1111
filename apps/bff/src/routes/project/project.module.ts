import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppProjectController } from './app-project.controller';
import { ProjectBidMaterialService } from './project-bid-material.service';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectController } from './project.controller';
import { ProjectPublicResourceService } from './project-public-resource.service';
import { ProjectService } from './project.service';

@Module({
  imports: [CoreModule],
  controllers: [ProjectController, AppProjectController],
  providers: [
    ProjectService,
    ProjectLifecycleService,
    ProjectPublicResourceService,
    ProjectBidMaterialService
  ],
})
export class ProjectModule {}

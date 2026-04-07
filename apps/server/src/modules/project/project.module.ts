import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from './entities/project.entity';
import { ProjectController } from './project.controller';
import { ProjectPresenter } from './project.presenter';
import { ProjectQueryService } from './project-query.service';
import { ProjectWriteService } from './project-write.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectEntity]),
    ProjectPublishAuditModule,
    AuthModule,
    OrganizationModule
  ],
  controllers: [ProjectController],
  providers: [ProjectPresenter, ProjectQueryService, ProjectWriteService],
  exports: [TypeOrmModule, ProjectQueryService]
})
export class ProjectModule {}

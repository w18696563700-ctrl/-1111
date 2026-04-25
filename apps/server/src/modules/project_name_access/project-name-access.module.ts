import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from './entities/project-name-access-request.entity';
import { ProjectNameAccessController } from './project-name-access.controller';
import { ProjectNameAccessPresenter } from './project-name-access.presenter';
import { ProjectNameAccessProjectionService } from './project-name-access-projection.service';
import { ProjectNameAccessQueryService } from './project-name-access.query.service';
import { ProjectNameAccessWriteService } from './project-name-access.write.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ProjectNameAccessRequestEntity,
      ProjectEntity,
      OrganizationEntity,
      UserEntity,
      IdentityAuditLogEntity,
    ]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [ProjectNameAccessController],
  providers: [
    ProjectNameAccessPresenter,
    ProjectNameAccessProjectionService,
    ProjectNameAccessQueryService,
    ProjectNameAccessWriteService,
  ],
  exports: [ProjectNameAccessProjectionService],
})
export class ProjectNameAccessModule {}


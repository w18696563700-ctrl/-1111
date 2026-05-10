import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ContentSafetyAuditLogEntity } from '../content_safety/entities/content-safety-audit-log.entity';
import { OrganizationModule } from '../organization/organization.module';
import { AuditAdminController } from './audit-admin.controller';
import { AuditLogPresenter } from './audit-log.presenter';
import { AuditLogQueryService } from './audit-log-query.service';
import { IdentityAuditLogEntity } from './identity-audit-log.entity';
import { ProjectPublishAuditLogEntity } from './project-publish-audit-log.entity';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      IdentityAuditLogEntity,
      ProjectPublishAuditLogEntity,
      ContentSafetyAuditLogEntity
    ])
  ],
  controllers: [AuditAdminController],
  providers: [AuditLogPresenter, AuditLogQueryService]
})
export class AuditAdminModule {}

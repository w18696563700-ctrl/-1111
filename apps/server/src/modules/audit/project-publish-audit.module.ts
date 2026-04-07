import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProjectPublishAuditLogEntity } from './project-publish-audit-log.entity';
import { ProjectPublishAuditService } from './project-publish-audit.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProjectPublishAuditLogEntity])],
  providers: [ProjectPublishAuditService],
  exports: [ProjectPublishAuditService]
})
export class ProjectPublishAuditModule {}

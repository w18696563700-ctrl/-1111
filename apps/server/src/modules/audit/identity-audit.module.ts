import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from './identity-audit-log.entity';
import { IdentityAuditService } from './identity-audit.service';

@Module({
  imports: [TypeOrmModule.forFeature([IdentityAuditLogEntity])],
  providers: [IdentityAuditService],
  exports: [IdentityAuditService]
})
export class IdentityAuditModule {}

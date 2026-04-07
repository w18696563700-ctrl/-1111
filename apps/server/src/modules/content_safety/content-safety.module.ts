import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ContentSafetyAuditService } from './content-safety-audit.service';
import { ContentSafetyRuleEngine } from './content-safety-rule.engine';
import { ContentSafetySnapshotService } from './content-safety-snapshot.service';
import { ContentSafetyAuditLogEntity } from './entities/content-safety-audit-log.entity';
import { ContentSafetyRuleEntity } from './entities/content-safety-rule.entity';
import { ContentSafetySnapshotEntity } from './entities/content-safety-snapshot.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ContentSafetyAuditLogEntity,
      ContentSafetyRuleEntity,
      ContentSafetySnapshotEntity
    ])
  ],
  providers: [ContentSafetyAuditService, ContentSafetyRuleEngine, ContentSafetySnapshotService],
  exports: [ContentSafetyAuditService, ContentSafetyRuleEngine, ContentSafetySnapshotService]
})
export class ContentSafetyModule {}

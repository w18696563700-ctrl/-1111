import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { ContentSafetyAuditService } from './content-safety-audit.service';
import { ContentSafetyOcrService } from './content-safety-ocr.service';
import { ContentSafetyRuleEngine } from './content-safety-rule.engine';
import { ContentSafetySnapshotService } from './content-safety-snapshot.service';
import { ContentSafetyAuditLogEntity } from './entities/content-safety-audit-log.entity';
import { ContentSafetyRuleEntity } from './entities/content-safety-rule.entity';
import { ContentSafetySnapshotEntity } from './entities/content-safety-snapshot.entity';

@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forFeature([
      ContentSafetyAuditLogEntity,
      ContentSafetyRuleEntity,
      ContentSafetySnapshotEntity
    ])
  ],
  providers: [
    ContentSafetyAuditService,
    ContentSafetyOcrService,
    ContentSafetyRuleEngine,
    ContentSafetySnapshotService
  ],
  exports: [
    ContentSafetyAuditService,
    ContentSafetyOcrService,
    ContentSafetyRuleEngine,
    ContentSafetySnapshotService
  ]
})
export class ContentSafetyModule {}

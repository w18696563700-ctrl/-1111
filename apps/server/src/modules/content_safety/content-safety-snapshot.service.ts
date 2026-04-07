import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import {
  ContentSafetyForumReportReasonCode,
  ContentSafetyForumReportTargetType,
  ContentSafetyProfileField
} from './content-safety.constants';
import { ContentSafetySnapshotEntity } from './entities/content-safety-snapshot.entity';

@Injectable()
export class ContentSafetySnapshotService {
  constructor(
    @InjectRepository(ContentSafetySnapshotEntity)
    private readonly snapshotRepository: Repository<ContentSafetySnapshotEntity>
  ) {}

  async captureProfileSubmission(
    input: {
      submissionId: string;
      userId: string;
      fieldKey: ContentSafetyProfileField;
      currentValue: string | null;
      proposedValue: string | null;
      fileAssetId?: string | null;
      metadata?: Record<string, unknown>;
    },
    manager?: EntityManager
  ) {
    const repository = manager?.getRepository(ContentSafetySnapshotEntity) ?? this.snapshotRepository;
    const snapshot = repository.create({
      id: randomUUID(),
      subjectType: 'profile_safety_submission',
      subjectId: input.submissionId,
      userId: input.userId,
      contentType: `profile_${input.fieldKey}`,
      fieldKey: input.fieldKey,
      currentValue: input.currentValue,
      proposedValue: input.proposedValue,
      fileAssetId: input.fileAssetId ?? null,
      metadata: input.metadata ?? {}
    });
    await repository.save(snapshot);
    return snapshot;
  }

  async captureForumReportTarget(
    input: {
      reportTicketId: string;
      reporterUserId: string;
      targetType: ContentSafetyForumReportTargetType;
      targetId: string;
      reasonCode: ContentSafetyForumReportReasonCode;
      reasonDetail: string | null;
      targetSnapshot: Record<string, unknown>;
    },
    manager?: EntityManager
  ) {
    const repository = manager?.getRepository(ContentSafetySnapshotEntity) ?? this.snapshotRepository;
    const snapshot = repository.create({
      id: randomUUID(),
      subjectType: 'forum_report_ticket',
      subjectId: input.reportTicketId,
      userId: input.reporterUserId,
      contentType: `forum_${input.targetType}`,
      fieldKey: input.targetType,
      currentValue: JSON.stringify(input.targetSnapshot),
      proposedValue: input.reasonDetail,
      fileAssetId: null,
      metadata: {
        targetType: input.targetType,
        targetId: input.targetId,
        reasonCode: input.reasonCode
      }
    });
    await repository.save(snapshot);
    return snapshot;
  }
}

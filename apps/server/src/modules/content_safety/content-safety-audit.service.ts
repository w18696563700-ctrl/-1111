import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ContentSafetyEngineType } from './content-safety.constants';
import { ContentSafetyAuditLogEntity } from './entities/content-safety-audit-log.entity';

@Injectable()
export class ContentSafetyAuditService {
  constructor(
    @InjectRepository(ContentSafetyAuditLogEntity)
    private readonly auditRepository: Repository<ContentSafetyAuditLogEntity>
  ) {}

  async record(
    input: {
      subjectType: string;
      subjectId: string;
      userId: string | null;
      actorId: string | null;
      actorRole?: string;
      action: string;
      engineType: ContentSafetyEngineType;
      decision: string;
      reasonCode?: string | null;
      reason?: string | null;
      matchedRuleIds?: string[];
      metadata?: Record<string, unknown>;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    const repository = manager?.getRepository(ContentSafetyAuditLogEntity) ?? this.auditRepository;
    const log = repository.create({
      id: randomUUID(),
      subjectType: input.subjectType,
      subjectId: input.subjectId,
      userId: input.userId,
      actorId: input.actorId,
      actorRole: input.actorRole?.trim() ?? '',
      action: input.action,
      engineType: input.engineType,
      decision: input.decision,
      reasonCode: input.reasonCode ?? null,
      reason: input.reason ?? null,
      matchedRuleIds: input.matchedRuleIds ?? [],
      metadata: input.metadata ?? {},
      requestId: context.requestId,
      traceId: context.traceId
    });
    await repository.save(log);
    return log;
  }
}

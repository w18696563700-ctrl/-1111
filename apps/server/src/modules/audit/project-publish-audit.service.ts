import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditLogEntity } from './project-publish-audit-log.entity';

type RecordAuditInput = {
  aggregateType: string;
  aggregateId: string;
  eventType: string;
  payload?: Record<string, unknown>;
};

@Injectable()
export class ProjectPublishAuditService {
  constructor(
    @InjectRepository(ProjectPublishAuditLogEntity)
    private readonly auditRepository: Repository<ProjectPublishAuditLogEntity>
  ) {}

  async record(input: RecordAuditInput, context: RequestContext, manager?: EntityManager) {
    const repository = manager?.getRepository(ProjectPublishAuditLogEntity) ?? this.auditRepository;
    const entry = repository.create({
      id: randomUUID(),
      aggregateType: input.aggregateType,
      aggregateId: input.aggregateId,
      eventType: input.eventType,
      actorId: this.nullable(context.actorId),
      userId: this.nullable(context.userId),
      organizationId: context.organizationId ?? '',
      requestId: context.requestId ?? '',
      traceId: context.traceId ?? '',
      payload: input.payload ?? {}
    });
    await repository.save(entry);
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

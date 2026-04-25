import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';

type P0PayAuditInput = {
  objectType: string;
  objectId: string;
  objectNo: string;
  action: string;
  beforeState: string;
  afterState: string;
  reason: string;
  actorRole?: string;
  actorId?: string | null;
};

@Injectable()
export class P0PayAuditService {
  constructor(
    @InjectRepository(IdentityAuditLogEntity)
    private readonly auditRepository: Repository<IdentityAuditLogEntity>
  ) {}

  async record(input: P0PayAuditInput, context: RequestContext, manager?: EntityManager) {
    const repository = manager?.getRepository(IdentityAuditLogEntity) ?? this.auditRepository;
    await repository.save({
      id: randomUUID(),
      objectType: input.objectType,
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: input.action,
      actorId: input.actorId ?? this.nullable(context.userId),
      actorRole: input.actorRole ?? context.actorRole.trim(),
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: context.requestId,
      traceId: context.traceId,
      occurredAt: new Date()
    });
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

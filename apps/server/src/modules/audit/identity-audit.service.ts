import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from './identity-audit-log.entity';

type IdentityAuditInput = {
  objectType: string;
  objectId: string;
  objectNo: string;
  action: 'OrganizationCertificationSubmitted' | 'OrganizationCertificationApproved' | 'OrganizationCertificationRejected';
  beforeState: string;
  afterState: string;
  reason: string;
};

@Injectable()
export class IdentityAuditService {
  constructor(
    @InjectRepository(IdentityAuditLogEntity)
    private readonly auditRepository: Repository<IdentityAuditLogEntity>
  ) {}

  async record(input: IdentityAuditInput, context: RequestContext, manager?: EntityManager) {
    const repository = manager?.getRepository(IdentityAuditLogEntity) ?? this.auditRepository;
    const entry = repository.create({
      id: randomUUID(),
      objectType: input.objectType,
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: input.action,
      actorId: this.nullable(context.userId),
      actorRole: context.actorRole.trim(),
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: context.requestId,
      traceId: context.traceId
    });
    await repository.save(entry);
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

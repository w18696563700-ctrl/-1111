import { Injectable } from '@nestjs/common';
import { IdentityAuditLogEntity } from './identity-audit-log.entity';
import { ProjectPublishAuditLogEntity } from './project-publish-audit-log.entity';
import type { AuditSourceFamily, NormalizedAuditLog } from './audit-log.types';

@Injectable()
export class AuditLogPresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total
    };
  }

  toAuditLogId(sourceFamily: AuditSourceFamily, rawId: string) {
    return `${sourceFamily}:${rawId}`;
  }

  parseAuditLogId(value: string) {
    const [sourceFamily, ...rest] = value.trim().split(':');
    const rawId = rest.join(':').trim();
    if (
      (sourceFamily !== 'identity' && sourceFamily !== 'project_publish') ||
      !rawId
    ) {
      return null;
    }
    return {
      sourceFamily,
      rawId
    } as const;
  }

  fromIdentity(entry: IdentityAuditLogEntity): NormalizedAuditLog {
    return {
      auditLogId: this.toAuditLogId('identity', entry.id),
      sourceFamily: 'identity',
      objectType: entry.objectType,
      objectId: entry.objectId,
      objectNo: this.toNullable(entry.objectNo),
      action: entry.action,
      actorId: this.toNullable(entry.actorId),
      actorRole: this.toNullable(entry.actorRole),
      requestId: this.toNullable(entry.requestId),
      traceId: this.toNullable(entry.traceId),
      occurredAt: entry.occurredAt.toISOString(),
      beforeState: this.toNullable(entry.beforeState),
      afterState: this.toNullable(entry.afterState),
      reason: this.toNullable(entry.reason),
      payload: {}
    };
  }

  fromProjectPublish(entry: ProjectPublishAuditLogEntity): NormalizedAuditLog {
    return {
      auditLogId: this.toAuditLogId('project_publish', entry.id),
      sourceFamily: 'project_publish',
      objectType: entry.aggregateType,
      objectId: entry.aggregateId,
      objectNo: null,
      action: entry.eventType,
      actorId: this.toNullable(entry.actorId),
      actorRole: null,
      requestId: this.toNullable(entry.requestId),
      traceId: this.toNullable(entry.traceId),
      occurredAt: entry.createdAt.toISOString(),
      beforeState: null,
      afterState: null,
      reason: null,
      payload: entry.payload ?? {}
    };
  }

  toListItem(item: NormalizedAuditLog) {
    return {
      auditLogId: item.auditLogId,
      sourceFamily: item.sourceFamily,
      objectType: item.objectType,
      objectId: item.objectId,
      objectNo: item.objectNo,
      action: item.action,
      actorId: item.actorId,
      actorRole: item.actorRole,
      requestId: item.requestId,
      traceId: item.traceId,
      occurredAt: item.occurredAt
    };
  }

  toDetail(item: NormalizedAuditLog) {
    return {
      ...this.toListItem(item),
      beforeState: item.beforeState,
      afterState: item.afterState,
      reason: item.reason,
      payload: item.payload
    };
  }

  private toNullable(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

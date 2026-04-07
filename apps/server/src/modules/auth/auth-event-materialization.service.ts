import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthSecurityEventEntity } from './entities/auth-security-event.entity';

type AuditAction =
  | 'otp_send_attempt'
  | 'login_success'
  | 'login_failure'
  | 'session_refresh'
  | 'logout';

@Injectable()
export class AuthEventMaterializationService {
  constructor(
    @InjectRepository(IdentityAuditLogEntity)
    private readonly auditRepository: Repository<IdentityAuditLogEntity>,
    @InjectRepository(AuthSecurityEventEntity)
    private readonly securityEventRepository: Repository<AuthSecurityEventEntity>
  ) {}

  async recordOtpSendAttempt(
    input: {
      mobile: string;
      scene: string;
      deviceId: string | null;
      ip: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'otp_send_attempt',
        objectType: 'auth_otp',
        objectId: input.mobile,
        objectNo: input.scene,
        beforeState: 'null',
        afterState: 'sent',
        actorId: null,
        actorRole: '',
        reason: this.buildReason({
          scene: input.scene,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip
        })
      },
      context,
      manager
    );
  }

  async recordLoginSuccess(
    input: {
      userId: string;
      sessionId: string;
      mobile: string;
      deviceId: string;
      ip: string | null;
      shellBootstrapState: 'authenticated' | 'no_organization';
      organizationId: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'login_success',
        objectType: 'auth_login',
        objectId: input.mobile,
        objectNo: input.deviceId,
        beforeState: 'unauthenticated',
        afterState: 'authenticated',
        actorId: input.userId,
        actorRole: '',
        reason: this.buildReason({
          sessionId: input.sessionId,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip,
          shellBootstrapState: input.shellBootstrapState,
          organizationId: input.organizationId
        })
      },
      context,
      manager
    );
  }

  async recordLoginFailure(
    input: {
      mobile: string;
      deviceId: string;
      ip: string | null;
      reason: string;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'login_failure',
        objectType: 'auth_login',
        objectId: input.mobile,
        objectNo: input.deviceId,
        beforeState: 'unauthenticated',
        afterState: 'unauthenticated',
        actorId: null,
        actorRole: '',
        reason: this.buildReason({
          failureReason: input.reason,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip
        })
      },
      context,
      manager
    );
  }

  async recordSessionRefresh(
    input: {
      sessionId: string;
      userId: string;
      deviceId: string | null;
      organizationId: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'session_refresh',
        objectType: 'auth_session',
        objectId: input.sessionId,
        objectNo: input.userId,
        beforeState: 'valid',
        afterState: 'valid',
        actorId: input.userId,
        actorRole: '',
        reason: this.buildReason({
          deviceId: input.deviceId,
          organizationId: input.organizationId
        })
      },
      context,
      manager
    );
  }

  async recordLogout(
    input: {
      sessionId: string;
      userId: string;
      targetDeviceId: string | null;
      revokeAllOtherDevices: boolean;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'logout',
        objectType: 'auth_session',
        objectId: input.sessionId,
        objectNo: input.userId,
        beforeState: 'valid',
        afterState: 'revoked',
        actorId: input.userId,
        actorRole: '',
        reason: this.buildReason({
          targetDeviceId: input.targetDeviceId,
          revokeAllOtherDevices: input.revokeAllOtherDevices
        })
      },
      context,
      manager
    );
  }

  async recordOtpRateLimitBreach(
    input: {
      mobile: string;
      deviceId: string | null;
      ip: string | null;
      scene: string;
      dimension: string;
      threshold: number;
      windowSeconds: number;
      route: 'otp_send' | 'otp_login';
      organizationId?: string | null;
      userId?: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    const repository =
      manager?.getRepository(AuthSecurityEventEntity) ?? this.securityEventRepository;
    await repository.save(
      repository.create({
        id: randomUUID(),
        userId: this.nullable(input.userId ?? null),
        organizationId: this.nullable(input.organizationId ?? null),
        eventType: 'otp_rate_limit_breach',
        riskLevel: input.route === 'otp_login' ? 'high' : 'medium',
        detailJson: {
          route: input.route,
          scene: input.scene,
          dimension: input.dimension,
          threshold: input.threshold,
          windowSeconds: input.windowSeconds,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip,
          requestId: context.requestId,
          traceId: context.traceId
        }
      })
    );
  }

  private async recordAudit(
    input: {
      action: AuditAction;
      objectType: string;
      objectId: string;
      objectNo: string;
      beforeState: string;
      afterState: string;
      actorId: string | null;
      actorRole: string;
      reason: string;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    const repository =
      manager?.getRepository(IdentityAuditLogEntity) ?? this.auditRepository;
    await repository.save(
      repository.create({
        id: randomUUID(),
        objectType: input.objectType,
        objectId: input.objectId,
        objectNo: input.objectNo,
        action: input.action,
        actorId: input.actorId,
        actorRole: input.actorRole,
        beforeState: input.beforeState,
        afterState: input.afterState,
        reason: input.reason,
        requestId: context.requestId,
        traceId: context.traceId
      })
    );
  }

  private buildReason(detail: Record<string, unknown>) {
    return Object.entries(detail)
      .filter(([, value]) => value !== null && value !== undefined && `${value}`.trim().length > 0)
      .map(([key, value]) => `${key}=${value}`)
      .join('; ');
  }

  private nullable(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

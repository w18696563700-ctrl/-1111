import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthSecurityEventEntity } from './entities/auth-security-event.entity';

type AuditAction =
  | 'otp_send_attempt'
  | 'password_login_success'
  | 'password_login_failure'
  | 'password_set'
  | 'password_set_failure'
  | 'password_reset_requested'
  | 'password_reset_success'
  | 'password_reset_failure'
  | 'login_success'
  | 'login_failure'
  | 'session_refresh'
  | 'logout'
  | 'whitelist_test_session_issue';

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
      agreementVersion: string;
      privacyVersion: string;
      agreedAt: Date;
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
          agreementVersion: input.agreementVersion,
          privacyVersion: input.privacyVersion,
          agreedAt: input.agreedAt.toISOString(),
          shellBootstrapState: input.shellBootstrapState,
          organizationId: input.organizationId
        })
      },
      context,
      manager
    );
  }

  async recordPasswordLoginSuccess(
    input: {
      userId: string;
      sessionId: string;
      mobile: string;
      deviceId: string | null;
      ip: string | null;
      agreementVersion: string;
      privacyVersion: string;
      agreedAt: Date;
      shellBootstrapState: 'authenticated' | 'no_organization';
      organizationId: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_login_success',
        objectType: 'auth_password',
        objectId: input.userId,
        objectNo: input.mobile,
        beforeState: 'unauthenticated',
        afterState: 'authenticated',
        actorId: input.userId,
        actorRole: '',
        reason: this.buildReason({
          sessionId: input.sessionId,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip,
          agreementVersion: input.agreementVersion,
          privacyVersion: input.privacyVersion,
          agreedAt: input.agreedAt.toISOString(),
          shellBootstrapState: input.shellBootstrapState,
          organizationId: input.organizationId
        })
      },
      context,
      manager
    );
  }

  async recordPasswordLoginFailure(
    input: {
      mobile: string;
      deviceId: string | null;
      ip: string | null;
      failureReason: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_login_failure',
        objectType: 'auth_password',
        objectId: input.mobile,
        objectNo: input.deviceId ?? '',
        beforeState: 'unauthenticated',
        afterState: 'unauthenticated',
        actorId: null,
        actorRole: '',
        reason: this.buildReason({
          failureReason: input.failureReason,
          mobile: input.mobile,
          deviceId: input.deviceId,
          ip: input.ip
        })
      },
      context,
      manager
    );
  }

  async recordPasswordResetRequested(
    input: {
      mobile: string;
      scene: string;
      deviceId: string | null;
      ip: string | null;
      traceId?: string;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_reset_requested',
        objectType: 'auth_password_reset',
        objectId: input.mobile,
        objectNo: input.scene,
        beforeState: 'unauthenticated',
        afterState: 'unauthenticated',
        actorId: null,
        actorRole: '',
        reason: this.buildReason({
          scene: input.scene,
          deviceId: input.deviceId,
          ip: input.ip,
          traceId: input.traceId ?? context.traceId
        })
      },
      context,
      manager
    );
  }

  async recordPasswordResetSuccess(
    input: {
      actorUserId: string;
      targetUserId: string;
      mobile: string;
      deviceId: string | null;
      ip: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_reset_success',
        objectType: 'auth_password_reset',
        objectId: input.targetUserId,
        objectNo: input.mobile,
        beforeState: 'unauthenticated',
        afterState: 'unauthenticated',
        actorId: input.actorUserId,
        actorRole: '',
        reason: this.buildReason({
          actorUserId: input.actorUserId,
          mobile: input.mobile,
          targetUserId: input.targetUserId,
          deviceId: input.deviceId,
          ip: input.ip
        })
      },
      context,
      manager
    );
  }

  async recordPasswordResetFailure(
    input: {
      mobile: string;
      targetUserId: string | null;
      deviceId: string | null;
      ip: string | null;
      failureReason: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_reset_failure',
        objectType: 'auth_password_reset',
        objectId: input.targetUserId ?? input.mobile,
        objectNo: input.mobile,
        beforeState: 'unauthenticated',
        afterState: 'unauthenticated',
        actorId: input.targetUserId,
        actorRole: '',
        reason: this.buildReason({
          mobile: input.mobile,
          targetUserId: input.targetUserId,
          deviceId: input.deviceId,
          ip: input.ip,
          failureReason: input.failureReason
        })
      },
      context,
      manager
    );
  }

  async recordPasswordSet(
    input: {
      actorUserId: string;
      targetUserId: string;
      mobile: string;
      sessionId: string;
      deviceId: string | null;
      ip: string | null;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_set',
        objectType: 'auth_password',
        objectId: input.targetUserId,
        objectNo: input.mobile,
        beforeState: 'unset',
        afterState: 'set',
        actorId: input.actorUserId,
        actorRole: '',
        reason: this.buildReason({
          actorUserId: input.actorUserId,
          targetUserId: input.targetUserId,
          mobile: input.mobile,
          sessionId: input.sessionId,
          deviceId: input.deviceId,
          ip: input.ip
        })
      },
      context,
      manager
    );
  }

  async recordPasswordSetFailure(
    input: {
      actorUserId: string;
      targetUserId: string;
      mobile: string;
      sessionId: string;
      deviceId: string | null;
      ip: string | null;
      failureReason: string;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'password_set_failure',
        objectType: 'auth_password',
        objectId: input.targetUserId,
        objectNo: input.mobile,
        beforeState: 'set',
        afterState: 'set',
        actorId: input.actorUserId,
        actorRole: '',
        reason: this.buildReason({
          actorUserId: input.actorUserId,
          targetUserId: input.targetUserId,
          mobile: input.mobile,
          sessionId: input.sessionId,
          deviceId: input.deviceId,
          ip: input.ip,
          failureReason: input.failureReason
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

  async recordWhitelistTestSessionIssued(
    input: {
      userId: string;
      sessionId: string;
      mobile: string;
      organizationId: string;
      roleKey: string;
      certificationStatus: string;
      expiresAt: Date;
      reason: string;
    },
    context: RequestContext,
    manager?: EntityManager
  ) {
    await this.recordAudit(
      {
        action: 'whitelist_test_session_issue',
        objectType: 'auth_session',
        objectId: input.sessionId,
        objectNo: input.userId,
        beforeState: 'unauthenticated',
        afterState: 'valid',
        actorId: input.userId,
        actorRole: input.roleKey,
        reason: this.buildReason({
          mobile: input.mobile,
          organizationId: input.organizationId,
          roleKey: input.roleKey,
          certificationStatus: input.certificationStatus,
          expiresAt: input.expiresAt.toISOString(),
          issueReason: input.reason,
          authMode: 'whitelist_test'
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

import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { DeviceEntity } from '../identity/entities/device.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authSessionInvalid } from '../organization/organization-auth.errors';
import { ProfilePresenter } from './profile.presenter';
import { securityDeviceRevokeInvalid, securityDeviceUnavailable } from './profile.errors';

type DeviceRevokeCommand = {
  deviceId: string;
};

@Injectable()
export class ProfileSecurityWriteService {
  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepository: Repository<DeviceEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfilePresenter
  ) {}

  async revokeDevice(pathDeviceId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toRevokeCommand(pathDeviceId, payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);

    const currentSessionRecord = await this.sessionRepository.findOneBy({ id: currentSession.sessionId });
    if (!currentSessionRecord) {
      throw authSessionInvalid('Current session is invalid because no matching session truth is available.');
    }

    const device = await this.deviceRepository.findOneBy({
      id: command.deviceId,
      userId: currentSession.userId
    });
    if (!device) {
      throw securityDeviceUnavailable('Current device is unavailable for revoke.');
    }
    if ((currentSessionRecord.deviceId?.trim() ?? '') === device.id) {
      throw securityDeviceRevokeInvalid('Current device cannot be revoked from the active session.');
    }

    return this.dataSource.transaction(async (manager) => {
      const sessionRepository = manager.getRepository(SessionEntity);
      const deviceRepository = manager.getRepository(DeviceEntity);
      const auditRepository = manager.getRepository(IdentityAuditLogEntity);
      const revocableSessions = await sessionRepository.find({
        where: {
          userId: currentSession.userId,
          deviceId: device.id,
          status: 'valid'
        },
        order: { createdAt: 'DESC' }
      });
      if (!revocableSessions.length) {
        throw securityDeviceRevokeInvalid('Current device has no revocable session truth.');
      }

      const revokedAt = new Date();
      for (const session of revocableSessions) {
        session.status = 'revoked';
        session.revokedAt = revokedAt;
      }
      await sessionRepository.save(revocableSessions);

      device.trustStatus = 'revoked';
      await deviceRepository.save(device);

      await auditRepository.save(
        revocableSessions.map((session) => ({
          id: randomUUID(),
          objectType: 'session',
          objectId: session.id,
          objectNo: device.id,
          action: 'LogoutSucceeded',
          actorId: currentSession.actorId,
          actorRole: context.actorRole.trim(),
          beforeState: 'valid',
          afterState: 'revoked',
          reason: `deviceId=${device.id}`,
          requestId: context.requestId,
          traceId: context.traceId,
          occurredAt: revokedAt
        }))
      );

      return this.presenter.toActionAck(context.traceId);
    });
  }

  private toRevokeCommand(pathDeviceId: string, payload: Record<string, unknown>) {
    const pathNormalized = this.readRequiredString(
      pathDeviceId,
      'deviceId',
      'Current device path parameter is required for revoke.'
    );
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw securityDeviceRevokeInvalid('Security device revoke body must be an object.');
    }
    const bodyDeviceId = this.readRequiredString(
      payload.deviceId,
      'deviceId',
      'Field `deviceId` is required for device revoke.'
    );
    if (bodyDeviceId !== pathNormalized) {
      throw securityDeviceRevokeInvalid('Current device revoke request must keep path and body deviceId aligned.');
    }
    return {
      deviceId: pathNormalized
    } satisfies DeviceRevokeCommand;
  }

  private readRequiredString(value: unknown, field: string, message: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw securityDeviceRevokeInvalid(field === 'deviceId' ? message : `Field \`${field}\` is required.`);
    }
    return value.trim();
  }
}

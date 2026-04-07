import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { DeviceEntity } from '../identity/entities/device.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProfilePresenter } from './profile.presenter';

@Injectable()
export class ProfileSecurityQueryService {
  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepository: Repository<DeviceEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfilePresenter
  ) {}

  async getDevices(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);

    const devices = await this.deviceRepository.find({
      where: { userId: currentSession.userId },
      order: { lastSeenAt: 'DESC' }
    });
    if (!devices.length) {
      return this.presenter.toSecurityDevices([]);
    }

    const deviceIds = devices.map((device) => device.id);
    const sessions = await this.sessionRepository.find({
      where: {
        userId: currentSession.userId,
        deviceId: In(deviceIds)
      },
      order: { createdAt: 'DESC' }
    });
    const sessionMap = new Map<string, SessionEntity[]>();
    for (const session of sessions) {
      const deviceId = session.deviceId?.trim() ?? '';
      if (!deviceId) {
        continue;
      }
      const bucket = sessionMap.get(deviceId) ?? [];
      bucket.push(session);
      sessionMap.set(deviceId, bucket);
    }

    const currentSessionRecord = await this.sessionRepository.findOneBy({ id: currentSession.sessionId });
    const currentDeviceId = currentSessionRecord?.deviceId?.trim() ?? null;

    return this.presenter.toSecurityDevices(
      devices.map((device) => {
        const deviceSessions = sessionMap.get(device.id) ?? [];
        const revokedAt = this.resolveRevokedAt(deviceSessions);
        return {
          deviceId: device.id,
          deviceName: device.deviceName,
          osType: device.osType,
          appVersion: device.appVersion,
          currentDevice: currentDeviceId === device.id,
          trustStatus: this.normalizeTrustStatus(device.trustStatus),
          lastSeenAt: device.lastSeenAt,
          revokedAt
        };
      })
    );
  }

  private resolveRevokedAt(sessions: SessionEntity[]) {
    let latest: Date | null = null;
    for (const session of sessions) {
      if (!session.revokedAt) {
        continue;
      }
      if (!latest || latest.getTime() < session.revokedAt.getTime()) {
        latest = session.revokedAt;
      }
    }
    return latest;
  }

  private normalizeTrustStatus(status: string | null) {
    const normalized = status?.trim() ?? '';
    switch (normalized) {
      case 'trusted':
      case 'untrusted':
      case 'revoked':
      case 'unknown':
        return normalized;
      case 'active':
        return 'trusted';
      default:
        return 'unknown';
    }
  }
}

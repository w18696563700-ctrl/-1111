import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import {
  CurrentSessionResolver,
  CurrentSessionVerificationResult,
  readBearerTransportCarrier
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { AccessCarrierService } from './access-carrier.service';

@Injectable()
export class CurrentSessionVerificationService implements CurrentSessionResolver {
  constructor(
    @InjectRepository(SessionEntity)
    private readonly sessionRepository: Repository<SessionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly accessCarrierService: AccessCarrierService,
    private readonly config: RuntimeConfigService
  ) {}

  async verifyCurrentSessionContext(context: RequestContext): Promise<CurrentSessionVerificationResult> {
    const transportCarrier = readBearerTransportCarrier(context.authorization);
    if (!context.authorization.trim()) {
      return this.failed('missing_current_session_carrier', context);
    }
    if (!transportCarrier) {
      return this.failed('authorization_carrier_malformed', context);
    }

    const carrier = this.accessCarrierService.verify(transportCarrier);
    if (carrier.outcome === 'failed') {
      return this.failed(this.accessCarrierService.mapFailureReason(carrier), context);
    }

    const session = await this.sessionRepository.findOneBy({ id: carrier.payload.sessionId });
    if (!session) {
      return this.failed('current_session_not_found', context);
    }
    if (session.status !== 'valid' || session.revokedAt || session.expiresAt.getTime() <= Date.now()) {
      return this.failed('current_session_revoked', context);
    }

    const user = await this.userRepository.findOneBy({ id: session.userId });
    if (!user || user.status !== 'active') {
      return this.failed('current_actor_inactive', context);
    }
    if (!(await this.isAllowedWhitelistTestSession(session, user.mobile))) {
      await this.revokeWhitelistTestSession(session);
      return this.failed('current_session_revoked', context);
    }

    const organizationId = await this.resolveCurrentOrganizationScopeId(session, carrier.payload.organizationId);

    return {
      outcome: 'verified',
      currentSession: {
        sessionId: session.id,
        actorId: user.id,
        userId: user.id,
        organizationId,
        requestId: context.requestId,
        traceId: context.traceId
      }
    };
  }

  private failed(
    reason: Extract<CurrentSessionVerificationResult, { outcome: 'failed' }>['reason'],
    context: RequestContext
  ) {
    return {
      outcome: 'failed' as const,
      reason,
      requestId: context.requestId,
      traceId: context.traceId
    };
  }

  private async resolveCurrentOrganizationScopeId(
    session: SessionEntity,
    carrierOrganizationId: string | null
  ) {
    const currentOrganizationId = this.readOptionalId(session.organizationId);
    if (currentOrganizationId) {
      return currentOrganizationId;
    }
    const normalizedCarrierOrganizationId = this.readOptionalId(carrierOrganizationId);
    if (!normalizedCarrierOrganizationId) {
      return null;
    }
    session.organizationId = normalizedCarrierOrganizationId;
    await this.sessionRepository.save(session);
    return normalizedCarrierOrganizationId;
  }

  private readOptionalId(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private async isAllowedWhitelistTestSession(session: SessionEntity, mobile: string) {
    if (session.authMode !== 'whitelist_test') {
      return true;
    }
    if (!this.config.authWhitelistTestSessionEnabled) {
      return false;
    }
    return this.config.authWhitelistTestSessionMobiles.includes(mobile.trim());
  }

  private async revokeWhitelistTestSession(session: SessionEntity) {
    if (session.status !== 'valid') {
      return;
    }
    session.status = 'revoked';
    session.revokedAt = new Date();
    await this.sessionRepository.save(session);
  }
}

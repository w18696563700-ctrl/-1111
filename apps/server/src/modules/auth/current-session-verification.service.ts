import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
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
    private readonly accessCarrierService: AccessCarrierService
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

    return {
      outcome: 'verified',
      currentSession: {
        sessionId: session.id,
        actorId: user.id,
        userId: user.id,
        organizationId: this.resolveOrganizationScopeId(context.organizationId, carrier.payload.organizationId),
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

  private resolveOrganizationScopeId(
    hintedOrganizationId: string,
    carrierOrganizationId: string | null
  ) {
    const normalizedHint = hintedOrganizationId.trim();
    if (normalizedHint) {
      return normalizedHint;
    }
    return carrierOrganizationId;
  }
}

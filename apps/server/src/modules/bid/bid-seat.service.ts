import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { RequestContext } from '../../shared/request-context';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidEntity } from './entities/bid.entity';
import { BidSeatEntity } from './entities/bid-seat.entity';
import { BidPresenter } from './bid.presenter';
import {
  bidSeatConflict,
  bidSeatInvalid,
  bidSeatInvalidState,
  bidSeatTimeout
} from './bid.errors';

const SEAT_TTL_MS = 30 * 60 * 1000;
const BUYER_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const SUPPLIER_ROLE_KEYS = new Set(['supplier_admin', 'supplier_member(scoped)']);

type SeatCommand = {
  projectId: string;
  bidId: string;
};

type SeatAccessContext = {
  currentSession: {
    sessionId: string;
    actorId: string;
    userId: string;
    organizationId: string | null;
    requestId: string;
    traceId: string;
  };
  scope: {
    organization: { id: string };
    membership: { roleKey: string };
    certification: { certificationStatus: string };
    roleKeys: string[];
  };
  project: ProjectEntity;
  bid: BidEntity;
};

@Injectable()
export class BidSeatService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly presenter: BidPresenter
  ) {}

  async lock(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSeatCommand(payload);
    const seatAccessContext = await this.resolveSeatAccessContext(command, context);

    return this.dataSource.transaction(async (manager) => {
      const seatRepository = manager.getRepository(BidSeatEntity);
      const auditContext = this.buildAuditContext(context, seatAccessContext);
      const now = new Date();
      let seat = await seatRepository.findOneBy({
        projectId: seatAccessContext.project.id,
        bidId: seatAccessContext.bid.id
      });
      let lockPreviousState = seat?.state ?? 'available';

      if (seat && this.isActiveLockedSeat(seat, now)) {
        throw bidSeatConflict('Current bid seat is locked.');
      }

      if (seat && this.isExpiredLockedSeat(seat, now)) {
        await this.timeoutSeat(seat, seatAccessContext, now, manager, auditContext, lockPreviousState);
        lockPreviousState = seat.state;
      }

      if (!seat) {
        seat = seatRepository.create({
          seatId: randomUUID(),
          projectId: seatAccessContext.project.id,
          bidId: seatAccessContext.bid.id,
          state: 'locked',
          lockedAt: now,
          expiresAt: this.buildExpiresAt(now),
          releasedAt: null
        });
      } else {
        seat.state = 'locked';
        seat.lockedAt = now;
        seat.expiresAt = this.buildExpiresAt(now);
        seat.releasedAt = null;
      }

      await seatRepository.save(seat);
      await this.auditService.record(
        {
          aggregateType: 'bid_seat',
          aggregateId: seat.seatId,
          eventType: 'seat_locked',
          payload: {
            projectId: seatAccessContext.project.id,
            bidId: seatAccessContext.bid.id,
            seatId: seat.seatId,
            actorUserId: seatAccessContext.currentSession.userId,
            actorOrgId: seatAccessContext.scope.organization.id,
            result: 'locked',
            beforeState: lockPreviousState,
            afterState: seat.state,
            lockedAt: seat.lockedAt.toISOString(),
            expiresAt: seat.expiresAt.toISOString()
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toSeatLockResponse(seat);
    });
  }

  async release(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSeatCommand(payload);
    const seatAccessContext = await this.resolveSeatAccessContext(command, context);

    return this.dataSource.transaction(async (manager) => {
      const seatRepository = manager.getRepository(BidSeatEntity);
      const auditContext = this.buildAuditContext(context, seatAccessContext);
      const now = new Date();
      const seat = await seatRepository.findOneBy({
        projectId: seatAccessContext.project.id,
        bidId: seatAccessContext.bid.id
      });
      if (!seat) {
        throw bidSeatInvalidState('Current bid seat is not locked.');
      }

      if (seat.state === 'timed_out') {
        throw bidSeatTimeout('Current bid seat has timed out.');
      }
      if (seat.state === 'released') {
        throw bidSeatInvalidState('Current bid seat has already been released.');
      }
      if (this.isExpiredLockedSeat(seat, now)) {
        await this.timeoutSeat(seat, seatAccessContext, now, manager, auditContext, seat.state);
        throw bidSeatTimeout('Current bid seat has timed out.');
      }

      const previousState = seat.state;
      seat.state = 'released';
      seat.releasedAt = now;
      await seatRepository.save(seat);
      await this.auditService.record(
        {
          aggregateType: 'bid_seat',
          aggregateId: seat.seatId,
          eventType: 'seat_released',
          payload: {
            projectId: seatAccessContext.project.id,
            bidId: seatAccessContext.bid.id,
            seatId: seat.seatId,
            actorUserId: seatAccessContext.currentSession.userId,
            actorOrgId: seatAccessContext.scope.organization.id,
            result: 'released',
            beforeState: previousState,
            afterState: seat.state,
            releasedAt: seat.releasedAt.toISOString()
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toSeatReleaseResponse(seat);
    });
  }

  async status(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSeatCommand(payload);
    const seatAccessContext = await this.resolveSeatAccessContext(command, context);

    return this.dataSource.transaction(async (manager) => {
      const seatRepository = manager.getRepository(BidSeatEntity);
      const now = new Date();
      const seat = await seatRepository.findOneBy({
        projectId: seatAccessContext.project.id,
        bidId: seatAccessContext.bid.id
      });
      if (!seat) {
        return this.presenter.toSeatStatusResponse({
          seatId: null,
          projectId: seatAccessContext.project.id,
          bidId: seatAccessContext.bid.id,
          state: 'available',
          expiresAt: null,
          releasedAt: null
        });
      }

      if (this.isExpiredLockedSeat(seat, now)) {
        const auditContext = this.buildAuditContext(context, seatAccessContext);
        await this.timeoutSeat(seat, seatAccessContext, now, manager, auditContext, seat.state);
      }

      return this.presenter.toSeatStatusResponse({
        seatId: seat.seatId,
        projectId: seat.projectId,
        bidId: seat.bidId,
        state: seat.state,
        expiresAt: seat.expiresAt,
        releasedAt: seat.releasedAt
      });
    });
  }

  private async resolveSeatAccessContext(command: SeatCommand, context: RequestContext) {
    const verification = await this.currentSessionVerificationService.verifyCurrentSessionContext(context);
    if (verification.outcome !== 'verified') {
      throw bidSeatInvalid('Current bid seat is unavailable.');
    }

    await this.eligibilityService.requireAuthenticatedActor(verification.currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(verification.currentSession);
    if (!scope) {
      throw bidSeatInvalid('Current bid seat is unavailable.');
    }

    const canReadBuyer = scope.roleKeys.some((roleKey) => BUYER_ROLE_KEYS.has(roleKey));
    const canReadSupplier = scope.roleKeys.some((roleKey) => SUPPLIER_ROLE_KEYS.has(roleKey));
    if (!canReadBuyer && !canReadSupplier) {
      throw bidSeatInvalid('Current bid seat is unavailable.');
    }

    const buyerCandidate = canReadBuyer
      ? await this.loadBuyerCandidate(command, scope.organization.id)
      : null;
    const candidate =
      buyerCandidate ??
      (canReadSupplier ? await this.loadSupplierCandidate(command, scope.organization.id) : null);
    if (!candidate) {
      throw bidSeatInvalidState('Current bid seat is not in a valid submitted state.');
    }

    return {
      currentSession: verification.currentSession,
      scope,
      project: candidate.project,
      bid: candidate.bid
    } satisfies SeatAccessContext;
  }

  private async timeoutSeat(
    seat: BidSeatEntity,
    seatAccessContext: SeatAccessContext,
    now: Date,
    manager: EntityManager,
    auditContext: RequestContext,
    previousState: string
  ) {
    seat.state = 'timed_out';
    seat.releasedAt = now;
    await manager.getRepository(BidSeatEntity).save(seat);
    await this.auditService.record(
      {
        aggregateType: 'bid_seat',
        aggregateId: seat.seatId,
        eventType: 'seat_timeout_released',
        payload: {
          projectId: seatAccessContext.project.id,
          bidId: seatAccessContext.bid.id,
          seatId: seat.seatId,
          actorUserId: seatAccessContext.currentSession.userId,
          actorOrgId: seatAccessContext.scope.organization.id,
          result: 'timed_out',
          beforeState: previousState,
          afterState: seat.state,
          lockedAt: seat.lockedAt.toISOString(),
          expiresAt: seat.expiresAt.toISOString(),
          releasedAt: seat.releasedAt.toISOString()
        }
      },
      auditContext,
      manager
    );
  }

  private buildAuditContext(context: RequestContext, seatAccessContext: SeatAccessContext): RequestContext {
    return {
      ...context,
      actorId: seatAccessContext.currentSession.actorId,
      userId: seatAccessContext.currentSession.userId,
      organizationId: seatAccessContext.scope.organization.id,
      requestId: seatAccessContext.currentSession.requestId,
      traceId: seatAccessContext.currentSession.traceId
    };
  }

  private async loadBuyerCandidate(command: SeatCommand, organizationId: string) {
    const project = await this.projectRepository.findOneBy({
      id: command.projectId,
      organizationId
    });
    if (!project || project.state !== 'published' || project.publishedAt === null) {
      return null;
    }

    const bid = await this.bidRepository.findOneBy({
      id: command.bidId,
      projectId: project.id,
      state: 'submitted'
    });
    if (!bid) {
      return null;
    }

    return { project, bid } as const;
  }

  private async loadSupplierCandidate(command: SeatCommand, organizationId: string) {
    const bid = await this.bidRepository.findOneBy({
      id: command.bidId,
      projectId: command.projectId,
      organizationId,
      state: 'submitted'
    });
    if (!bid) {
      return null;
    }

    const project = await this.projectRepository.findOneBy({
      id: command.projectId
    });
    if (!project || project.state !== 'published' || project.publishedAt === null) {
      return null;
    }

    return { project, bid } as const;
  }

  private isActiveLockedSeat(seat: BidSeatEntity, now: Date) {
    return seat.state === 'locked' && seat.expiresAt.getTime() > now.getTime();
  }

  private isExpiredLockedSeat(seat: BidSeatEntity, now: Date) {
    return seat.state === 'locked' && seat.expiresAt.getTime() <= now.getTime();
  }

  private buildExpiresAt(now: Date) {
    return new Date(now.getTime() + SEAT_TTL_MS);
  }

  private toSeatCommand(payload: Record<string, unknown>): SeatCommand {
    const source = this.asRecord(payload);
    return {
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      bidId: this.readRequiredString(source.bidId, 'bidId')
    };
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw bidSeatInvalid('Seat body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw bidSeatInvalid(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw bidSeatInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }
}

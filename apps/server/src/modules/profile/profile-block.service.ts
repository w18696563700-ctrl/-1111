import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { UserBlockRelationEntity } from './entities/user-block-relation.entity';
import { governanceBlockInvalid, governanceBlockTargetUnavailable } from './profile-block.errors';
import { ProfileBlockPresenter } from './profile-block.presenter';

type TargetUserCommand = {
  targetUserId: string;
};

type ActiveBlockState = {
  blockedByMe: boolean;
  blockedMe: boolean;
};

@Injectable()
export class ProfileBlockService {
  constructor(
    @InjectRepository(UserBlockRelationEntity)
    private readonly blockRelationRepository: Repository<UserBlockRelationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfileBlockPresenter
  ) {}

  async block(payload: Record<string, unknown>, context: RequestContext) {
    const currentSession = await this.resolveCurrentSession(context);
    const command = await this.toTargetCommand(payload, currentSession.userId);
    await this.requireTargetAvailable(command.targetUserId);

    const existing = await this.loadActiveRelation(currentSession.userId, command.targetUserId);
    if (existing) {
      return this.presenter.toCommandResponse({
        targetUserId: command.targetUserId,
        blockedByMe: true,
        canInteract: false,
        effectiveAt: existing.createdAt
      });
    }

    const now = new Date();
    const relation = this.blockRelationRepository.create({
      id: randomUUID(),
      blockerUserId: currentSession.userId,
      blockedUserId: command.targetUserId,
      relationStatus: 'active',
      endedAt: null,
      createdAt: now,
      updatedAt: now
    });

    try {
      const saved = await this.blockRelationRepository.save(relation);
      return this.presenter.toCommandResponse({
        targetUserId: command.targetUserId,
        blockedByMe: true,
        canInteract: false,
        effectiveAt: saved.createdAt
      });
    } catch (error) {
      if (!this.isUniqueViolation(error)) {
        throw error;
      }
      const raced = await this.loadActiveRelation(currentSession.userId, command.targetUserId);
      if (!raced) {
        throw error;
      }
      return this.presenter.toCommandResponse({
        targetUserId: command.targetUserId,
        blockedByMe: true,
        canInteract: false,
        effectiveAt: raced.createdAt
      });
    }
  }

  async unblock(payload: Record<string, unknown>, context: RequestContext) {
    const currentSession = await this.resolveCurrentSession(context);
    const command = await this.toTargetCommand(payload, currentSession.userId);
    await this.requireTargetAvailable(command.targetUserId);

    const now = new Date();
    const existing = await this.loadActiveRelation(currentSession.userId, command.targetUserId);
    if (existing) {
      existing.relationStatus = 'inactive';
      existing.endedAt = now;
      existing.updatedAt = now;
      await this.blockRelationRepository.save(existing);
    }

    const state = await this.loadActiveState(currentSession.userId, command.targetUserId);
    return this.presenter.toCommandResponse({
      targetUserId: command.targetUserId,
      blockedByMe: state.blockedByMe,
      canInteract: !this.hasBlockedRelation(state),
      effectiveAt: now
    });
  }

  async getStatus(targetUserId: string | undefined, context: RequestContext) {
    const currentSession = await this.resolveCurrentSession(context);
    const command = await this.toTargetCommand({ targetUserId }, currentSession.userId);
    await this.requireTargetAvailable(command.targetUserId);

    const state = await this.loadActiveState(currentSession.userId, command.targetUserId);
    const blocked = this.hasBlockedRelation(state);
    return this.presenter.toStatusResponse({
      targetUserId: command.targetUserId,
      blockedByMe: state.blockedByMe,
      canInteract: !blocked,
      ...(blocked ? { interactionBlockedReason: 'blocked_relation' } : {})
    });
  }

  private async resolveCurrentSession(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    return currentSession;
  }

  private async requireTargetAvailable(targetUserId: string) {
    const target = await this.userRepository.findOneBy({ id: targetUserId });
    if (!target || target.status !== 'active') {
      throw governanceBlockTargetUnavailable('Target user is unavailable for block relation.');
    }
    return target;
  }

  private loadActiveRelation(blockerUserId: string, blockedUserId: string) {
    return this.blockRelationRepository.findOneBy({
      blockerUserId,
      blockedUserId,
      relationStatus: 'active'
    });
  }

  private async loadActiveState(currentUserId: string, targetUserId: string): Promise<ActiveBlockState> {
    const [blockedByMe, blockedMe] = await Promise.all([
      this.loadActiveRelation(currentUserId, targetUserId),
      this.loadActiveRelation(targetUserId, currentUserId)
    ]);
    return {
      blockedByMe: Boolean(blockedByMe),
      blockedMe: Boolean(blockedMe)
    };
  }

  private async toTargetCommand(payload: Record<string, unknown>, currentUserId: string) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw governanceBlockInvalid('Block target payload must be an object.');
    }
    const targetUserId = this.readTargetUserId(payload.targetUserId);
    if (targetUserId === currentUserId) {
      throw governanceBlockInvalid('Self block is not allowed.');
    }
    return { targetUserId } satisfies TargetUserCommand;
  }

  private readTargetUserId(value: unknown) {
    if (typeof value !== 'string') {
      throw governanceBlockInvalid('targetUserId is required.');
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > 64) {
      throw governanceBlockInvalid('targetUserId is invalid.');
    }
    return normalized;
  }

  private hasBlockedRelation(state: ActiveBlockState) {
    return state.blockedByMe || state.blockedMe;
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}

import { Injectable } from '@nestjs/common';

export type ProfileBlockProjection = {
  targetUserId: string;
  blockedByMe: boolean;
  canInteract: boolean;
  effectiveAt?: Date;
};

export type ProfileBlockStatusProjection = ProfileBlockProjection & {
  interactionBlockedReason?: 'blocked_relation';
};

@Injectable()
export class ProfileBlockPresenter {
  toCommandResponse(input: ProfileBlockProjection) {
    return {
      targetUserId: input.targetUserId,
      blockedByMe: input.blockedByMe,
      canInteract: input.canInteract,
      effectiveAt: (input.effectiveAt ?? new Date()).toISOString()
    };
  }

  toStatusResponse(input: ProfileBlockStatusProjection) {
    return {
      targetUserId: input.targetUserId,
      blockedByMe: input.blockedByMe,
      canInteract: input.canInteract,
      ...(input.interactionBlockedReason
        ? { interactionBlockedReason: input.interactionBlockedReason }
        : {})
    };
  }
}

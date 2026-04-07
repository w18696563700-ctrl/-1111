export type BlockRelationStatus = 'blocked' | 'not_blocked';

export type BlockActionAckViewModel = {
  ok: true;
  traceId: string;
  targetUserId?: string;
  blocked?: boolean;
  relationStatus?: BlockRelationStatus;
};

export type BlockStatusViewModel = {
  targetUserId: string;
  blocked: boolean;
  relationStatus: BlockRelationStatus;
  traceId: string | null;
};

export function readBlockRelationStatus(
  value: unknown,
  blocked: boolean | null,
  message: string,
): BlockRelationStatus {
  if (value === 'blocked') {
    return 'blocked';
  }
  if (value === 'not_blocked' || value === 'unblocked' || value === 'none') {
    return 'not_blocked';
  }
  if (blocked !== null) {
    return blocked ? 'blocked' : 'not_blocked';
  }
  throw new Error(message);
}

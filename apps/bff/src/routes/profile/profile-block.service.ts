import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type BlockActionAckViewModel,
  type BlockStatusViewModel,
  readBlockRelationStatus,
} from './profile-block.read-model';
import { ProfileBlockErrorService } from './profile-block-error.service';

@Injectable()
export class ProfileBlockService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly blockErrors: ProfileBlockErrorService,
  ) {}

  async block(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<BlockActionAckViewModel> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/block',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toActionAckView(
        this.requireRecord(result, 'Profile block response must be an object.'),
      );
    } catch (error) {
      throw this.blockErrors.normalizeBlockError(error);
    }
  }

  async unblock(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<BlockActionAckViewModel> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/unblock',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toActionAckView(
        this.requireRecord(result, 'Profile unblock response must be an object.'),
      );
    } catch (error) {
      throw this.blockErrors.normalizeUnblockError(error);
    }
  }

  async getStatus(
    query: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<BlockStatusViewModel> {
    try {
      const params = this.toStatusParams(query);
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/block/status',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params,
        },
      );
      return this.toStatusView(
        this.requireRecord(result, 'Profile block status response must be an object.'),
        params.targetUserId,
      );
    } catch (error) {
      throw this.blockErrors.normalizeStatusError(error);
    }
  }

  private toStatusParams(query: Record<string, unknown>) {
    const targetUserId = this.asString(query.targetUserId);
    return {
      targetUserId: targetUserId || undefined,
    };
  }

  private toActionAckView(result: Record<string, unknown>): BlockActionAckViewModel {
    const traceId = this.asString(result.traceId);
    if (result.ok !== true || !traceId) {
      throw new Error('Profile block response is missing required ack fields.');
    }
    const blocked = this.asOptionalBoolean(result.blocked ?? result.isBlocked);
    const relationStatus = blocked === null && result.relationStatus === undefined
      ? undefined
      : readBlockRelationStatus(
          result.relationStatus,
          blocked,
          'Profile block response contains an invalid relation status.',
        );

    return {
      ok: true,
      traceId,
      ...(this.asString(result.targetUserId) ? { targetUserId: this.asString(result.targetUserId) } : {}),
      ...(blocked === null ? {} : { blocked }),
      ...(relationStatus ? { relationStatus } : {}),
    };
  }

  private toStatusView(
    result: Record<string, unknown>,
    queryTargetUserId: string | undefined,
  ): BlockStatusViewModel {
    const targetUserId = this.asString(result.targetUserId) || queryTargetUserId || '';
    const blocked = this.asOptionalBoolean(result.blocked ?? result.isBlocked);
    const relationStatus = readBlockRelationStatus(
      result.relationStatus,
      blocked,
      'Profile block status response contains an invalid relation status.',
    );
    if (!targetUserId) {
      throw new Error('Profile block status response is missing targetUserId.');
    }

    return {
      targetUserId,
      blocked: relationStatus === 'blocked',
      relationStatus,
      traceId: this.asNullableString(result.traceId),
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    return this.asString(value) || null;
  }

  private asOptionalBoolean(value: unknown): boolean | null {
    return typeof value === 'boolean' ? value : null;
  }
}

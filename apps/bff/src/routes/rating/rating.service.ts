import { BadRequestException, ConflictException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { RatingErrorService } from './rating-error.service';

@Injectable()
export class RatingService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: RatingErrorService,
  ) {}

  async getRatingEntry(orderId: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/rating/entry',
        {
          headers: this.authContext.buildForwardHeaders(headers),
          params: {
            orderId: this.normalizeEntryOrderId(orderId),
          },
        },
      );
      return this.toEntryReadModel(
        this.requireRecord(result, 'Rating entry response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeEntryError(error);
    }
  }

  async submitRating(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/rating/submit',
        this.normalizeSubmitPayload(payload),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toSubmitAcceptedResponse(
        this.requireRecord(result, 'Rating submit accepted response must be an object.'),
      );
    } catch (error) {
      throw this.errors.normalizeSubmitError(error);
    }
  }

  private toEntryReadModel(result: Record<string, unknown>) {
    const ratingId = this.asString(result.ratingId);
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!ratingId || !orderId || !state || !summary) {
      throw new Error('Rating entry response is missing required fields.');
    }
    return {
      ratingId,
      orderId,
      state,
      summary,
    };
  }

  private toSubmitAcceptedResponse(result: Record<string, unknown>) {
    const ratingId = this.asString(result.ratingId);
    const orderId = this.asString(result.orderId);
    const state = this.asString(result.state);
    const summary = this.asRecordOrNull(result.summary);
    if (!ratingId || !orderId || !state || !summary) {
      throw new Error('Rating submit accepted response is missing required fields.');
    }
    return {
      ratingId,
      orderId,
      state,
      summary,
    };
  }

  private normalizeEntryOrderId(orderId: string | undefined) {
    const normalized = orderId?.trim() ?? '';
    if (!normalized) {
      throw new ConflictException({
        statusCode: 409,
        code: 'RATING_ENTRY_UNAVAILABLE',
        message: '当前评价入口暂不可用，请稍后再试。',
        source: 'bff',
      });
    }
    return normalized;
  }

  private normalizeSubmitPayload(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'RATING_SUBMIT_INVALID',
        message: '当前评价提交参数无效，请检查后再试。',
        source: 'bff',
      });
    }
    const orderId = this.asString(payload.orderId);
    if (!orderId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'RATING_SUBMIT_INVALID',
        message: '当前评价提交参数无效，请检查后再试。',
        source: 'bff',
      });
    }
    return { orderId };
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asRecordOrNull(value: unknown) {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }
}

import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readProjectCounterpartyRatingEntry,
  readProjectCounterpartyRatingSubmitAccepted
} from './project-counterparty-rating.read-model';

type EntryQuery = {
  orderId: string | undefined;
  projectId: string | undefined;
  rateeOrganizationId: string | undefined;
};

@Injectable()
export class ProjectCounterpartyRatingService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getEntry(query: EntryQuery, headers: IncomingHttpHeaders) {
    const path = '/server/project-counterparty-rating/entry';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          orderId: this.readRequiredParam(query.orderId, 'orderId'),
          projectId: this.readRequiredParam(query.projectId, 'projectId'),
          rateeOrganizationId: this.readRequiredParam(
            query.rateeOrganizationId,
            'rateeOrganizationId'
          )
        }
      });
      return readProjectCounterpartyRatingEntry(result);
    } catch (error) {
      throw this.normalizeRatingError(error, 'GET', path);
    }
  }

  async submit(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    const path = '/server/project-counterparty-rating/submit';
    try {
      const result = await this.serverClient.post<unknown>(
        path,
        this.toSubmitPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) }
      );
      return readProjectCounterpartyRatingSubmitAccepted(result);
    } catch (error) {
      throw this.normalizeRatingError(error, 'POST', path);
    }
  }

  private toSubmitPayload(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw this.invalid('Project counterparty rating submit body must be an object.');
    }
    return {
      orderId: this.readRequiredField(payload.orderId, 'orderId'),
      projectId: this.readRequiredField(payload.projectId, 'projectId'),
      rateeOrganizationId: this.readRequiredField(
        payload.rateeOrganizationId,
        'rateeOrganizationId'
      ),
      scoreLabel: this.readScoreLabel(payload.scoreLabel),
      commentText: this.readOptionalString(payload.commentText, 'commentText')
    };
  }

  private readRequiredParam(value: string | undefined, field: string) {
    return this.readRequiredField(value, field);
  }

  private readRequiredField(value: unknown, field: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw this.invalid(`Field \`${field}\` is required.`);
  }

  private readScoreLabel(value: unknown) {
    const normalized = this.readRequiredField(value, 'scoreLabel');
    if (!['very_satisfied', 'satisfied', 'passable', 'negative'].includes(normalized)) {
      throw this.invalid('Field `scoreLabel` must be very_satisfied/satisfied/passable/negative.');
    }
    return normalized;
  }

  private readOptionalString(value: unknown, field: string) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw this.invalid(`Field \`${field}\` must be a string when provided.`);
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private invalid(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_COUNTERPARTY_RATING_INVALID',
      message,
      source: 'bff'
    });
  }

  private normalizeRatingError(error: unknown, method: 'GET' | 'POST', path: string) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
      '当前双方互评入口暂不可用，请稍后再试。',
      {
        400: 'PROJECT_COUNTERPARTY_RATING_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_COUNTERPARTY_RATING_FORBIDDEN',
        404: 'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
        409: 'PROJECT_COUNTERPARTY_RATING_DUPLICATE'
      }
    );
    const payload = this.asRecord(normalized.getResponse());
    const message = this.asString(payload.message) ?? '';
    if (
      normalized.getStatus() === 404 &&
      message.includes(`Cannot ${method} ${path}`)
    ) {
      return new HttpException(
        {
          statusCode: normalized.getStatus(),
          code: 'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
          message: '当前双方互评入口暂不可用，请稍后再试。',
          source: payload.source === 'server' ? 'server' : 'bff'
        },
        normalized.getStatus()
      );
    }
    return normalized;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
  }

  private asString(value: unknown) {
    return typeof value === 'string' ? value : undefined;
  }
}

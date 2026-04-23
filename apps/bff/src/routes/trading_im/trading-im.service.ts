import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { readParticipantCardReadModel } from './trading-im-participant-card.read-model';
import { readBidThreadDetailReadModel } from './trading-im.read-model';

type TradingImPayload = Record<string, unknown>;

@Injectable()
export class TradingImService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async listProjectClarifications(projectId: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<TradingImPayload>(
        '/server/trading-im/project/clarification/list',
        {
          headers: this.buildScopedHeaders(headers),
          params: { projectId: this.readRequiredQuery(projectId, 'PROJECT_CLARIFICATION_UNAVAILABLE') }
        }
      );
      return this.requireRecord(result, 'Project clarification list response is invalid.');
    } catch (error) {
      throw this.normalizeProjectClarificationError(error);
    }
  }

  async createProjectClarification(payload: TradingImPayload, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<TradingImPayload>(
        '/server/trading-im/project/clarification/create',
        this.toClarificationCreatePayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return this.requireRecord(result, 'Project clarification create response is invalid.');
    } catch (error) {
      throw this.normalizeProjectClarificationError(error);
    }
  }

  async getBidThreadDetail(
    projectId: string | undefined,
    bidId: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    try {
      const result = await this.serverClient.get<TradingImPayload>(
        '/server/trading-im/bid/thread/detail',
        {
          headers: this.buildScopedHeaders(headers),
          params: {
            projectId: this.readRequiredQuery(projectId, 'BID_THREAD_UNAVAILABLE'),
            bidId: this.readRequiredQuery(bidId, 'BID_THREAD_UNAVAILABLE')
          }
        }
      );
      return readBidThreadDetailReadModel(result);
    } catch (error) {
      throw this.normalizeBidThreadError(error);
    }
  }

  async getParticipantCard(
    projectId: string | undefined,
    bidId: string | undefined,
    participantOrganizationId: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    try {
      const result = await this.serverClient.get<TradingImPayload>(
        '/server/trading-im/bid/thread/participant-card',
        {
          headers: this.buildScopedHeaders(headers),
          params: {
            projectId: this.readRequiredQuery(
              projectId,
              'THREAD_PARTICIPANT_CARD_INVALID'
            ),
            bidId: this.readRequiredQuery(bidId, 'THREAD_PARTICIPANT_CARD_INVALID'),
            participantOrganizationId: this.readRequiredQuery(
              participantOrganizationId,
              'THREAD_PARTICIPANT_CARD_INVALID'
            )
          }
        }
      );
      return readParticipantCardReadModel(result);
    } catch (error) {
      throw this.normalizeParticipantCardError(error);
    }
  }

  async sendThreadMessage(payload: TradingImPayload, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<TradingImPayload>(
        '/server/trading-im/bid/thread/message/send',
        this.toThreadMessagePayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return this.requireRecord(result, 'Bid thread message response is invalid.');
    } catch (error) {
      throw this.normalizeBidThreadError(error);
    }
  }

  async createConfirmation(payload: TradingImPayload, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<TradingImPayload>(
        '/server/trading-im/bid/thread/confirmation/create',
        this.toConfirmationPayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return this.requireRecord(result, 'Bid thread confirmation response is invalid.');
    } catch (error) {
      throw this.normalizeBidThreadError(error);
    }
  }

  private toClarificationCreatePayload(payload: TradingImPayload) {
    const source = this.requireRecord(payload, 'Project clarification create body must be an object.');
    return {
      projectId: this.readRequiredString(source.projectId, 'PROJECT_CLARIFICATION_UNAVAILABLE'),
      body: this.readRequiredString(source.body, 'THREAD_MESSAGE_INVALID'),
      attachmentFileAssetIds: this.readAttachmentFileAssetIds(source.attachmentFileAssetIds)
    };
  }

  private toThreadMessagePayload(payload: TradingImPayload) {
    const source = this.requireRecord(payload, 'Bid thread message body must be an object.');
    return {
      projectId: this.readRequiredString(source.projectId, 'BID_THREAD_UNAVAILABLE'),
      bidId: this.readRequiredString(source.bidId, 'BID_THREAD_UNAVAILABLE'),
      body: this.readRequiredString(source.body, 'THREAD_MESSAGE_INVALID'),
      attachmentFileAssetIds: this.readAttachmentFileAssetIds(source.attachmentFileAssetIds)
    };
  }

  private toConfirmationPayload(payload: TradingImPayload) {
    const source = this.requireRecord(payload, 'Bid thread confirmation body must be an object.');
    return {
      projectId: this.readRequiredString(source.projectId, 'BID_THREAD_UNAVAILABLE'),
      bidId: this.readRequiredString(source.bidId, 'BID_THREAD_UNAVAILABLE'),
      confirmationType: this.readRequiredString(source.confirmationType, 'THREAD_CONFIRMATION_INVALID'),
      summary: this.readRequiredString(source.summary, 'THREAD_CONFIRMATION_INVALID'),
      sourceMessageId: this.readRequiredString(source.sourceMessageId, 'THREAD_CONFIRMATION_INVALID')
    };
  }

  private readAttachmentFileAssetIds(value: unknown) {
    if (value === undefined || value === null) {
      return [];
    }
    if (!Array.isArray(value) || value.some((item) => typeof item !== 'string' || !item.trim())) {
      throw this.badRequest('THREAD_ATTACHMENT_INVALID', 'Attachment FileAssetIds must be a string array.');
    }
    return [...new Set(value.map((item) => item.trim()))];
  }

  private readRequiredQuery(value: string | undefined, code: string) {
    return this.readRequiredString(value, code);
  }

  private readRequiredString(value: unknown, code: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw this.badRequest(code, 'Required field is missing.');
    }
    return value.trim();
  }

  private requireRecord(value: unknown, message: string) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw this.badRequest('THREAD_MESSAGE_INVALID', message);
    }
    return value as TradingImPayload;
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders) {
    return {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers)
    };
  }

  private readOrganizationScopeHeaders(headers: IncomingHttpHeaders) {
    const result: Record<string, string> = {};
    this.assignIfPresent(result, 'x-organization-id', this.readHeader(headers, 'x-organization-id', 'x-org-id'));
    this.assignIfPresent(result, 'x-actor-role', this.readHeader(headers, 'x-actor-role', 'x-role'));
    return result;
  }

  private assignIfPresent(target: Record<string, string>, key: string, value: string | undefined) {
    if (value) {
      target[key] = value;
    }
  }

  private readHeader(headers: IncomingHttpHeaders, ...keys: string[]) {
    for (const key of keys) {
      const value = headers[key];
      if (Array.isArray(value)) {
        if (typeof value[0] === 'string' && value[0].length > 0) {
          return value[0];
        }
        continue;
      }
      if (typeof value === 'string' && value.length > 0) {
        return value;
      }
    }
    return undefined;
  }

  private normalizeProjectClarificationError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_CLARIFICATION_UNAVAILABLE',
      '当前项目澄清入口暂不可用，请稍后再试。',
      {
        400: 'THREAD_MESSAGE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_CLARIFICATION_FORBIDDEN',
        404: 'PROJECT_CLARIFICATION_UNAVAILABLE'
      }
    );
    return this.sanitizeProjectClarificationError(normalized);
  }

  private normalizeBidThreadError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'BID_THREAD_UNAVAILABLE',
      '当前投标沟通入口暂不可用，请稍后再试。',
      {
        400: 'THREAD_MESSAGE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'BID_THREAD_FORBIDDEN',
        404: 'BID_THREAD_UNAVAILABLE'
      }
    );
  }

  private normalizeParticipantCardError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'THREAD_PARTICIPANT_CARD_UNAVAILABLE',
      '当前合作方名片暂不可用，请稍后再试。',
      {
        400: 'THREAD_PARTICIPANT_CARD_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'THREAD_PARTICIPANT_CARD_FORBIDDEN',
        404: 'THREAD_PARTICIPANT_CARD_UNAVAILABLE'
      }
    );

    const status = normalized.getStatus();
    const response = this.readErrorResponse(normalized);
    const shouldHideUpstreamMessage =
      status === 404 || this.isRawParticipantCardRouteMessage(response.message);
    if (!shouldHideUpstreamMessage) {
      return normalized;
    }

    return new HttpException(
      {
        statusCode: typeof response.statusCode === 'number' ? response.statusCode : status,
        code:
          typeof response.code === 'string'
            ? response.code
            : 'THREAD_PARTICIPANT_CARD_UNAVAILABLE',
        message: '当前合作方名片暂不可用，请稍后再试。',
        source: response.source === 'bff' ? 'bff' : 'server'
      },
      status
    );
  }

  private badRequest(code: string, message: string) {
    return new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff'
    });
  }

  private sanitizeProjectClarificationError(error: HttpException) {
    const status = error.getStatus();
    const response = this.readErrorResponse(error);
    const shouldHideUpstreamMessage =
      status === 404 || this.isRawProjectClarificationRouteMessage(response.message);

    if (!shouldHideUpstreamMessage) {
      return error;
    }

    return new HttpException(
      {
        statusCode: typeof response.statusCode === 'number' ? response.statusCode : status,
        code: 'PROJECT_CLARIFICATION_UNAVAILABLE',
        message: '当前项目澄清入口暂不可用，请稍后再试。',
        source: response.source === 'bff' ? 'bff' : 'server'
      },
      status
    );
  }

  private readErrorResponse(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      code: 'PROJECT_CLARIFICATION_UNAVAILABLE',
      message: String(response),
      source: 'server'
    };
  }

  private isRawParticipantCardRouteMessage(message: unknown) {
    return (
      typeof message === 'string' &&
      (message.includes('Cannot GET /server/trading-im/bid/thread/participant-card') ||
        message.includes('/server/trading-im/bid/thread/participant-card'))
    );
  }

  private isRawProjectClarificationRouteMessage(message: unknown) {
    return (
      typeof message === 'string' &&
      (message.includes('Cannot GET /server/trading-im/project/clarification/list') ||
        message.includes('/server/trading-im/project/clarification/list'))
    );
  }
}

import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireErrorCode } from '../../shared/contracts';
import { readCounterpartConversationDetailReadModel } from './counterpart-conversation.read-model';
import { readMessageInteractionListReadModel } from './message-interaction.read-model';
import {
  readProjectCommunicationMessageListReadModel,
  readProjectCommunicationMessageReadModel,
  readProjectCommunicationReadCursorReadModel,
  readProjectCommunicationThreadReadModel
} from './project-communication.read-model';
import { readProjectCommunicationRealtimeEventListReadModel } from './project-communication-realtime.read-model';

type ProjectCommunicationMessageKind = 'text' | 'image' | 'file' | 'confirmation_card';

const PROJECT_COMMUNICATION_MESSAGE_KINDS = new Set<ProjectCommunicationMessageKind>([
  'text',
  'image',
  'file',
  'confirmation_card'
]);
const PROJECT_COMMUNICATION_ERROR_CODES = {
  invalid: 'PROJECT_COMMUNICATION_INVALID',
  unavailable: 'PROJECT_COMMUNICATION_UNAVAILABLE',
  forbidden: 'PROJECT_COMMUNICATION_FORBIDDEN',
  authSessionInvalid: requireErrorCode('AUTH_SESSION_INVALID')
} as const;

@Injectable()
export class MessageInteractionService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getInteractions(lane: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<unknown>('/server/message/interactions', {
        headers: this.buildScopedHeaders(headers),
        params: { lane: this.readLane(lane) }
      });
      return readMessageInteractionListReadModel(result);
    } catch (error) {
      throw this.sanitizeError(
        this.errors.toHttpException(
          error,
          'MESSAGE_INTERACTION_UNAVAILABLE',
          '当前项目沟通入口暂不可用，请稍后再试。',
          {
            400: 'MESSAGE_INTERACTION_UNAVAILABLE',
            401: 'AUTH_SESSION_INVALID',
            403: 'MESSAGE_INTERACTION_FORBIDDEN',
            404: 'MESSAGE_INTERACTION_UNAVAILABLE'
          }
        )
      );
    }
  }

  async getCounterpartConversationDetail(
    conversationId: string | undefined,
    projectId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.get<unknown>(
        '/server/message/counterpart-conversation/detail',
        {
          headers: this.buildScopedHeaders(headers),
          params: {
            conversationId: this.readConversationId(conversationId),
            projectId: this.readProjectId(projectId),
          },
        },
      );
      return readCounterpartConversationDetailReadModel(result);
    } catch (error) {
      throw this.sanitizeCounterpartConversationError(
        this.errors.toHttpException(
          error,
          'COUNTERPART_CONVERSATION_UNAVAILABLE',
          '当前对方沟通容器暂不可用，请稍后再试。',
          {
            400: 'COUNTERPART_CONVERSATION_INVALID',
            401: 'AUTH_SESSION_INVALID',
            403: 'COUNTERPART_CONVERSATION_FORBIDDEN',
            404: 'COUNTERPART_CONVERSATION_UNAVAILABLE',
          },
        ),
      );
    }
  }

  async getProjectCommunicationThread(
    projectId: string | undefined,
    counterpartOrganizationId: string | undefined,
    threadId: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/thread';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: this.toProjectCommunicationThreadParams(
          projectId,
          counterpartOrganizationId,
          threadId
        )
      });
      return readProjectCommunicationThreadReadModel(result);
    } catch (error) {
      throw this.sanitizeProjectCommunicationRouteDrift(
        this.normalizeProjectCommunicationError(error),
        'GET',
        path
      );
    }
  }

  async listProjectCommunicationMessages(
    threadId: string | undefined,
    projectId: string | undefined,
    cursor: string | undefined,
    limit: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/messages';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: {
          threadId: this.readRequiredProjectCommunicationParam(threadId),
          projectId: this.readRequiredProjectCommunicationParam(projectId),
          cursor: this.readOptionalParam(cursor),
          limit: this.readOptionalPositiveInt(limit)
        }
      });
      return readProjectCommunicationMessageListReadModel(result);
    } catch (error) {
      throw this.sanitizeProjectCommunicationRouteDrift(
        this.normalizeProjectCommunicationError(error),
        'GET',
        path
      );
    }
  }

  async sendProjectCommunicationMessage(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/messages';
    try {
      const result = await this.serverClient.post<unknown>(
        path,
        this.toProjectCommunicationMessagePayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return readProjectCommunicationMessageReadModel(result);
    } catch (error) {
      throw this.sanitizeProjectCommunicationRouteDrift(
        this.normalizeProjectCommunicationError(error),
        'POST',
        path
      );
    }
  }

  async markProjectCommunicationReadCursor(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/read-cursor';
    try {
      const result = await this.serverClient.post<unknown>(
        path,
        this.toProjectCommunicationReadCursorPayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return readProjectCommunicationReadCursorReadModel(result);
    } catch (error) {
      throw this.sanitizeProjectCommunicationRouteDrift(
        this.normalizeProjectCommunicationError(error),
        'POST',
        path
      );
    }
  }

  async listProjectCommunicationRealtimeEvents(
    threadId: string | undefined,
    projectId: string | undefined,
    afterEventId: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/realtime/events';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: {
          threadId: this.readRequiredProjectCommunicationParam(threadId),
          projectId: this.readRequiredProjectCommunicationParam(projectId),
          afterEventId: this.readOptionalParam(afterEventId)
        }
      });
      return readProjectCommunicationRealtimeEventListReadModel(result);
    } catch (error) {
      throw this.sanitizeProjectCommunicationRouteDrift(
        this.normalizeProjectCommunicationError(error),
        'GET',
        path
      );
    }
  }

  private sanitizeError(error: HttpException) {
    const payload = this.readErrorPayload(error);
    const message = String(payload.message ?? '');
    if (
      error.getStatus() !== 404 &&
      !message.includes('Cannot GET /server/message/interactions')
    ) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: 'MESSAGE_INTERACTION_UNAVAILABLE',
        message: '当前项目沟通入口暂不可用，请稍后再试。',
        source: payload.source === 'bff' ? 'bff' : 'server'
      },
      error.getStatus()
    );
  }

  private sanitizeCounterpartConversationError(error: HttpException) {
    const payload = this.readErrorPayload(error);
    const message = String(payload.message ?? '');
    if (
      error.getStatus() !== 404 &&
      !message.includes('Cannot GET /server/message/counterpart-conversation/detail')
    ) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: 'COUNTERPART_CONVERSATION_UNAVAILABLE',
        message: '当前对方沟通容器暂不可用，请稍后再试。',
        source: payload.source === 'bff' ? 'bff' : 'server'
      },
      error.getStatus()
    );
  }

  private readLane(lane: string | undefined) {
    const normalized = lane?.trim() ?? '';
    if (!normalized) {
      return 'project_communication';
    }
    if (normalized === 'project_communication') {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'MESSAGE_INTERACTION_INVALID',
      message: '当前项目沟通查询参数无效，请检查后重试。',
      source: 'bff'
    });
  }

  private readConversationId(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      return normalized;
    }
    throw new BadRequestException({
      statusCode: 400,
      code: 'COUNTERPART_CONVERSATION_INVALID',
      message: '当前对方沟通容器参数无效，请检查后重试。',
      source: 'bff'
    });
  }

  private readProjectId(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      return normalized;
    }
    throw new BadRequestException({
      statusCode: 400,
      code: 'COUNTERPART_CONVERSATION_INVALID',
      message: '当前对方沟通容器参数无效，请检查后重试。',
      source: 'bff'
    });
  }

  private toProjectCommunicationMessagePayload(payload: Record<string, unknown>) {
    const source = this.requireBodyRecord(payload);
    const messageKind = this.readProjectCommunicationMessageKind(source.messageKind);
    const result: Record<string, unknown> = {
      threadId: this.readRequiredProjectCommunicationField(source.threadId, 'threadId'),
      projectId: this.readRequiredProjectCommunicationField(source.projectId, 'projectId'),
      body: this.readProjectCommunicationMessageBody(source.body, messageKind),
      clientMessageId: this.readOptionalPayloadString(source.clientMessageId)
    };
    if (messageKind !== 'text') {
      result.messageKind = messageKind;
      result.payload = this.readProjectCommunicationPayload(source.payload);
    }
    return result;
  }

  private toProjectCommunicationReadCursorPayload(payload: Record<string, unknown>) {
    const source = this.requireBodyRecord(payload);
    const result: Record<string, unknown> = {
      threadId: this.readRequiredProjectCommunicationField(source.threadId, 'threadId'),
      projectId: this.readRequiredProjectCommunicationField(source.projectId, 'projectId'),
      lastReadMessageId: this.readRequiredProjectCommunicationField(
        source.lastReadMessageId,
        'lastReadMessageId'
      )
    };
    if (Object.prototype.hasOwnProperty.call(source, 'reader')) {
      result.reader = source.reader;
    }
    return result;
  }

  private requireBodyRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw this.badProjectCommunicationRequest('Project communication body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredProjectCommunicationField(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw this.badProjectCommunicationRequest(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readProjectCommunicationMessageKind(value: unknown): ProjectCommunicationMessageKind {
    if (value === undefined || value === null) {
      return 'text';
    }
    if (typeof value !== 'string' || !value.trim()) {
      throw this.badProjectCommunicationRequest('Project communication messageKind is invalid.');
    }
    const normalized = value.trim();
    if (PROJECT_COMMUNICATION_MESSAGE_KINDS.has(normalized as ProjectCommunicationMessageKind)) {
      return normalized as ProjectCommunicationMessageKind;
    }
    throw this.badProjectCommunicationRequest('Project communication messageKind is unsupported.');
  }

  private readProjectCommunicationMessageBody(
    value: unknown,
    messageKind: ProjectCommunicationMessageKind
  ) {
    if (messageKind === 'text') {
      return this.readRequiredProjectCommunicationField(value, 'body');
    }
    if (value === undefined || value === null) {
      return undefined;
    }
    if (typeof value !== 'string') {
      throw this.badProjectCommunicationRequest('Project communication body must be a string when provided.');
    }
    return value;
  }

  private readProjectCommunicationPayload(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw this.badProjectCommunicationRequest('Project communication payload must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredProjectCommunicationParam(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      return normalized;
    }
    throw this.badProjectCommunicationRequest('Project communication query params are invalid.');
  }

  private toProjectCommunicationThreadParams(
    projectId: string | undefined,
    counterpartOrganizationId: string | undefined,
    threadId: string | undefined
  ) {
    const params = {
      projectId: this.readRequiredProjectCommunicationParam(projectId),
      counterpartOrganizationId: this.readOptionalParam(counterpartOrganizationId),
      threadId: this.readOptionalParam(threadId)
    };
    if (!params.counterpartOrganizationId && !params.threadId) {
      throw this.badProjectCommunicationRequest(
        'Project communication thread query requires counterpartOrganizationId or threadId.'
      );
    }
    return params;
  }

  private readOptionalParam(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : undefined;
  }

  private readOptionalPayloadString(value: unknown) {
    if (value === undefined || value === null) {
      return undefined;
    }
    if (typeof value !== 'string') {
      throw this.badProjectCommunicationRequest('Optional project communication field must be a string.');
    }
    const normalized = value.trim();
    return normalized ? normalized : undefined;
  }

  private readOptionalPositiveInt(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return undefined;
    }
    const parsed = Number(normalized);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      throw this.badProjectCommunicationRequest('Project communication limit must be a positive integer.');
    }
    return parsed;
  }

  private badProjectCommunicationRequest(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: PROJECT_COMMUNICATION_ERROR_CODES.invalid,
      message,
      source: 'bff'
    });
  }

  private normalizeProjectCommunicationError(error: unknown) {
    return this.errors.toHttpException(
      error,
      PROJECT_COMMUNICATION_ERROR_CODES.unavailable,
      '当前项目沟通消息暂不可用，请稍后再试。',
      {
        400: PROJECT_COMMUNICATION_ERROR_CODES.invalid,
        401: PROJECT_COMMUNICATION_ERROR_CODES.authSessionInvalid,
        403: PROJECT_COMMUNICATION_ERROR_CODES.forbidden,
        404: PROJECT_COMMUNICATION_ERROR_CODES.unavailable
      }
    );
  }

  private sanitizeProjectCommunicationRouteDrift(
    error: HttpException,
    method: 'GET' | 'POST',
    path: string
  ) {
    const payload = this.readErrorPayload(error);
    const message = String(payload.message ?? '');
    if (error.getStatus() !== 404 && !message.includes(`Cannot ${method} ${path}`)) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: PROJECT_COMMUNICATION_ERROR_CODES.unavailable,
        message: '当前项目沟通消息暂不可用，请稍后再试。',
        source: payload.source === 'bff' ? 'bff' : 'server'
      },
      error.getStatus()
    );
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

  private readErrorPayload(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      code: 'MESSAGE_INTERACTION_UNAVAILABLE',
      message: String(response),
      source: 'server'
    };
  }
}

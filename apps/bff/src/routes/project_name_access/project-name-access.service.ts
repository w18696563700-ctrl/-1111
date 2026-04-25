import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readProjectNameAccessDecisionResponse,
  readProjectNameAccessPendingListReadModel,
  readProjectNameAccessRequestAcceptedResponse,
  readProjectNameAccessThreadDetailReadModel,
} from './project-name-access.read-model';

type ProjectNameAccessOperation =
  | 'request'
  | 'pending'
  | 'approve'
  | 'reject'
  | 'thread_detail';

@Injectable()
export class ProjectNameAccessService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async requestAccess(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<unknown>(
        '/server/projects/name-access/request',
        this.toRequestPayload(payload),
        {
          headers: this.buildScopedHeaders(headers),
        },
      );
      return readProjectNameAccessRequestAcceptedResponse(result);
    } catch (error) {
      throw this.normalizeError(error, 'request');
    }
  }

  async getThreadDetail(threadId: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<unknown>(
        '/server/projects/name-access/thread/detail',
        {
          headers: this.buildScopedHeaders(headers),
          params: {
            threadId: this.readThreadId(threadId),
          },
        },
      );
      return readProjectNameAccessThreadDetailReadModel(result);
    } catch (error) {
      throw this.normalizeError(error, 'thread_detail');
    }
  }

  async getPendingRequests(projectId: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<unknown>(
        `/server/my/projects/${encodeURIComponent(this.readProjectId(projectId))}/name-access/pending`,
        {
          headers: this.buildScopedHeaders(headers),
        },
      );
      return readProjectNameAccessPendingListReadModel(result);
    } catch (error) {
      throw this.normalizeError(error, 'pending');
    }
  }

  async approveRequest(
    projectId: string | undefined,
    requestId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        this.toDecisionPath(projectId, requestId, 'approve'),
        payload,
        {
          headers: this.buildScopedHeaders(headers),
        },
      );
      return readProjectNameAccessDecisionResponse(result, 'approved');
    } catch (error) {
      throw this.normalizeError(error, 'approve');
    }
  }

  async rejectRequest(
    projectId: string | undefined,
    requestId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(
        this.toDecisionPath(projectId, requestId, 'reject'),
        payload,
        {
          headers: this.buildScopedHeaders(headers),
        },
      );
      return readProjectNameAccessDecisionResponse(result, 'rejected');
    } catch (error) {
      throw this.normalizeError(error, 'reject');
    }
  }

  private normalizeError(error: unknown, operation: ProjectNameAccessOperation) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_NAME_ACCESS_UNAVAILABLE',
      this.readFallbackMessage(operation),
      {
        400: 'PROJECT_NAME_ACCESS_UNAVAILABLE',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_NAME_ACCESS_FORBIDDEN',
        404: 'PROJECT_NAME_ACCESS_UNAVAILABLE',
        409:
          operation === 'request'
            ? 'PROJECT_NAME_ACCESS_CONFLICT'
            : 'PROJECT_NAME_ACCESS_INVALID_STATE',
      },
    );
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const statusCode = normalized.getStatus();
    const code = this.asString(payload.code) || this.readDefaultCode(operation, statusCode);
    const message =
      this.rewriteErrorMessage(statusCode, code, payload, operation) ??
      this.readFallbackMessage(operation);

    return new HttpException(
      {
        ...payload,
        statusCode,
        code,
        source: payload.source === 'server' ? 'server' : 'bff',
        message,
      },
      statusCode,
    );
  }

  private rewriteErrorMessage(
    statusCode: number,
    code: string,
    payload: Record<string, unknown>,
    operation: ProjectNameAccessOperation,
  ) {
    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }

    if (statusCode === 403 && code === 'PROJECT_NAME_ACCESS_FORBIDDEN') {
      if (operation === 'approve' || operation === 'reject' || operation === 'pending') {
        return '当前主体暂无项目名称查看审批权限。';
      }
      return '当前主体暂无项目名称查看权限。';
    }

    if (statusCode === 404 && code === 'PROJECT_NAME_ACCESS_UNAVAILABLE') {
      return this.readUnavailableMessage(operation);
    }

    if (statusCode === 409 && code === 'PROJECT_NAME_ACCESS_CONFLICT') {
      return '当前项目名称查看申请已存在，请勿重复提交。';
    }

    if (statusCode === 409 && code === 'PROJECT_NAME_ACCESS_INVALID_STATE') {
      return '当前项目名称查看申请状态暂不允许执行该操作。';
    }

    const upstreamMessage = this.asString(payload.message);
    return upstreamMessage || null;
  }

  private toRequestPayload(payload: Record<string, unknown>) {
    const record = this.requireRecord(
      payload,
      '当前项目名称查看申请参数无效，请检查后再试。',
    );
    return {
      projectId: this.readRequiredString(
        record.projectId,
        '当前项目名称查看申请参数无效，请检查后再试。',
      ),
    };
  }

  private toDecisionPath(
    projectId: string | undefined,
    requestId: string | undefined,
    decision: 'approve' | 'reject',
  ) {
    return `/server/my/projects/${encodeURIComponent(this.readProjectId(projectId))}/name-access/${encodeURIComponent(this.readRequestId(requestId))}/${decision}`;
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders) {
    return {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers),
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

  private readProjectId(value: string | undefined) {
    return this.readRequiredString(value, '当前项目名称查看入口暂不可用，请稍后再试。');
  }

  private readRequestId(value: string | undefined) {
    return this.readRequiredString(value, '当前项目名称查看入口暂不可用，请稍后再试。');
  }

  private readThreadId(value: string | undefined) {
    return this.readRequiredString(value, '当前项目名称查看会话暂不可用，请稍后再试。');
  }

  private readRequiredString(value: unknown, message: string) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }
    throw new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_NAME_ACCESS_UNAVAILABLE',
      message,
      source: 'bff',
    });
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_NAME_ACCESS_UNAVAILABLE',
      message,
      source: 'bff',
    });
  }

  private readDefaultCode(operation: ProjectNameAccessOperation, statusCode: number) {
    if (statusCode === 401) {
      return 'AUTH_SESSION_INVALID';
    }
    if (statusCode === 403) {
      return 'PROJECT_NAME_ACCESS_FORBIDDEN';
    }
    if (statusCode === 409) {
      return operation === 'request'
        ? 'PROJECT_NAME_ACCESS_CONFLICT'
        : 'PROJECT_NAME_ACCESS_INVALID_STATE';
    }
    return 'PROJECT_NAME_ACCESS_UNAVAILABLE';
  }

  private readFallbackMessage(operation: ProjectNameAccessOperation) {
    if (operation === 'request') {
      return '当前项目名称查看申请入口暂不可用，请稍后再试。';
    }
    if (operation === 'thread_detail') {
      return '当前项目名称查看会话暂不可用，请稍后再试。';
    }
    if (operation === 'pending') {
      return '当前项目名称查看审批列表暂不可用，请稍后再试。';
    }
    return '当前项目名称查看审批入口暂不可用，请稍后再试。';
  }

  private readUnavailableMessage(operation: ProjectNameAccessOperation) {
    if (operation === 'thread_detail') {
      return '当前项目名称查看会话暂不可用，请稍后再试。';
    }
    if (operation === 'pending') {
      return '当前项目名称查看审批列表暂不可用，请稍后再试。';
    }
    if (operation === 'approve' || operation === 'reject') {
      return '当前项目名称查看审批入口暂不可用，请稍后再试。';
    }
    return '当前项目名称查看申请入口暂不可用，请稍后再试。';
  }

  private asOptionalRecord(value: unknown) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    return null;
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }
}

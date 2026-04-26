import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

type ProjectLifecycleAction = 'withdraw' | 'archive' | 'close';
type ProjectLifecycleInvalidCode =
  | 'PROJECT_WITHDRAW_INVALID'
  | 'PROJECT_ARCHIVE_INVALID'
  | 'PROJECT_CLOSE_INVALID';

type ProjectLifecycleAcceptedResponse = {
  projectId: string;
  state: string;
};

@Injectable()
export class ProjectLifecycleService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async withdrawProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/withdraw',
      payload,
      headers,
      'withdraw',
      'PROJECT_WITHDRAW_INVALID',
      '当前项目撤回参数无效，请检查后再试。'
    );
  }

  async archiveProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/archive',
      payload,
      headers,
      'archive',
      'PROJECT_ARCHIVE_INVALID',
      '当前项目作废归档参数无效，请检查后再试。'
    );
  }

  async closeProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/close',
      payload,
      headers,
      'close',
      'PROJECT_CLOSE_INVALID',
      '当前项目下架关闭参数无效，请检查后再试。'
    );
  }

  private async executeLifecycleCommand(
    path: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    action: ProjectLifecycleAction,
    invalidCode: ProjectLifecycleInvalidCode,
    invalidMessage: string
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        path,
        this.toProjectActionPayload(payload, invalidCode, invalidMessage),
        {
          headers: this.authContext.buildForwardHeaders(headers)
        }
      );
      return this.toAcceptedResponse(result, action);
    } catch (error) {
      throw this.normalizeLifecycleError(error, action, invalidCode, invalidMessage);
    }
  }

  private normalizeLifecycleError(
    error: unknown,
    action: ProjectLifecycleAction,
    invalidCode: ProjectLifecycleInvalidCode,
    invalidMessage: string
  ) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目操作入口暂不可用，请稍后再试。',
      {
        400: invalidCode,
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'PROJECT_INVALID_STATE'
      }
    );
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const message = this.rewriteLifecycleMessage(
      normalized.getStatus(),
      code,
      payload,
      action,
      invalidCode,
      invalidMessage
    );

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        code: code || (normalized.getStatus() === 409 ? 'PROJECT_INVALID_STATE' : invalidCode),
        message
      },
      normalized.getStatus()
    );
  }

  private rewriteLifecycleMessage(
    statusCode: number,
    code: string,
    payload: Record<string, unknown>,
    action: ProjectLifecycleAction,
    invalidCode: ProjectLifecycleInvalidCode,
    invalidMessage: string
  ) {
    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }

    if (statusCode === 404 && code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前项目不可用。';
    }

    if (statusCode === 403 && code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return this.rewritePermissionMessage(payload, action);
    }

    if (statusCode === 409 && code === 'PROJECT_INVALID_STATE') {
      return this.rewriteInvalidStateMessage(payload, action);
    }

    if (statusCode === 400 && code === invalidCode) {
      return invalidMessage;
    }

    return this.asString(payload.message) || '当前项目操作入口暂不可用，请稍后再试。';
  }

  private rewritePermissionMessage(payload: Record<string, unknown>, action: ProjectLifecycleAction) {
    const details = this.asOptionalRecord(payload.details);
    const reason = this.asString(details?.reason);
    const suffix = this.readActionSuffix(action);

    if (reason === 'organization_scope_missing') {
      return `当前组织身份不可用，请先进入可发布项目的组织后再${suffix}。`;
    }
    if (reason === 'organization_type_not_allowed') {
      return `当前主体不是发布方类型，请切换到可发布项目的组织后再${suffix}。`;
    }
    if (reason === 'buyer_role_not_allowed') {
      return `当前组织角色不具备项目发布资格，请切换到买方侧可发布角色后再${suffix}。`;
    }
    if (reason === 'certification_not_approved') {
      return `当前组织认证尚未通过，暂不可${suffix}项目。`;
    }
    return '当前组织不具备项目发布资格，请确认组织身份后再试。';
  }

  private rewriteInvalidStateMessage(payload: Record<string, unknown>, action: ProjectLifecycleAction) {
    const message = this.asString(payload.message).toLowerCase();
    if (action === 'withdraw') {
      return '当前项目尚未提交，暂不支持撤回到草稿。';
    }
    if (action === 'archive') {
      return '当前项目尚未提交，暂不支持作废归档。';
    }
    if (message.includes('order continuation')) {
      return '当前项目已进入业务继续链，暂不支持从这里下架关闭。';
    }
    return '当前项目状态暂不支持下架关闭。';
  }

  private toAcceptedResponse(
    result: Record<string, unknown>,
    action: ProjectLifecycleAction
  ): ProjectLifecycleAcceptedResponse {
    const projectId = this.asString(result.projectId);
    const state = this.asString(result.state);
    const expectedState = action === 'withdraw' ? 'draft' : 'archived';
    if (!projectId || state !== expectedState) {
      throw new Error('Project lifecycle accepted response is missing required fields.');
    }
    return { projectId, state };
  }

  private toProjectActionPayload(
    payload: Record<string, unknown>,
    code: ProjectLifecycleInvalidCode,
    message: string
  ) {
    const source = this.requireRecord(payload, code, message);
    return {
      projectId: this.readRequiredString(source.projectId, code, message)
    };
  }

  private readActionSuffix(action: ProjectLifecycleAction) {
    if (action === 'withdraw') {
      return '撤回到草稿';
    }
    if (action === 'archive') {
      return '作废归档';
    }
    return '下架关闭';
  }

  private requireRecord(
    value: unknown,
    code: ProjectLifecycleInvalidCode,
    message: string
  ): Record<string, unknown> {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff'
    });
  }

  private readRequiredString(
    value: unknown,
    code: ProjectLifecycleInvalidCode,
    message: string
  ) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }
    throw new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff'
    });
  }

  private asOptionalRecord(value: unknown) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
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

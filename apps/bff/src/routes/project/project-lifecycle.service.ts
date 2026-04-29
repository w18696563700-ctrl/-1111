import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

type ProjectLifecycleAction =
  | 'withdraw'
  | 'archive'
  | 'close'
  | 'withdrawPublished'
  | 'discardSubmitted'
  | 'cancellationRequest'
  | 'cancellationRespond'
  | 'publisherBreach'
  | 'factoryBreach';
type ProjectLifecycleInvalidCode =
  | 'PROJECT_WITHDRAW_INVALID'
  | 'PROJECT_ARCHIVE_INVALID'
  | 'PROJECT_CLOSE_INVALID'
  | 'PROJECT_WITHDRAW_PUBLISHED_INVALID'
  | 'PROJECT_SUBMITTED_DISCARD_INVALID'
  | 'PROJECT_CANCELLATION_REQUEST_INVALID'
  | 'PROJECT_CANCELLATION_RESPONSE_INVALID'
  | 'PROJECT_BREACH_RECORD_INVALID';

type ProjectLifecycleAcceptedResponse = {
  projectId: string;
  state?: string;
  exitCaseId?: string;
  projectState?: string;
  caseStatus?: string;
  [key: string]: unknown;
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

  async withdrawPublishedProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/withdraw-published',
      payload,
      headers,
      'withdrawPublished',
      'PROJECT_WITHDRAW_PUBLISHED_INVALID',
      '竞标中撤回参数无效，请检查后再试。'
    );
  }

  async discardSubmittedProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/discard-submitted',
      payload,
      headers,
      'discardSubmitted',
      'PROJECT_SUBMITTED_DISCARD_INVALID',
      '预发布作废删除参数无效，请检查后再试。'
    );
  }

  async requestCancellation(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/cancellation/request',
      payload,
      headers,
      'cancellationRequest',
      'PROJECT_CANCELLATION_REQUEST_INVALID',
      '取消申请参数无效，请检查后再试。'
    );
  }

  async respondCancellation(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/cancellation/respond',
      payload,
      headers,
      'cancellationRespond',
      'PROJECT_CANCELLATION_RESPONSE_INVALID',
      '取消响应参数无效，请检查后再试。'
    );
  }

  async recordPublisherBreach(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/breach/record-publisher',
      payload,
      headers,
      'publisherBreach',
      'PROJECT_BREACH_RECORD_INVALID',
      '发布方违约记录参数无效，请检查后再试。'
    );
  }

  async recordFactoryBreach(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    return this.executeLifecycleCommand(
      '/server/projects/breach/record-factory',
      payload,
      headers,
      'factoryBreach',
      'PROJECT_BREACH_RECORD_INVALID',
      '工厂违约记录参数无效，请检查后再试。'
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
        409: 'PROJECT_EXIT_INVALID_STATE'
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
        code: code || (normalized.getStatus() === 409 ? 'PROJECT_EXIT_INVALID_STATE' : invalidCode),
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

    if (statusCode === 409 && (code === 'PROJECT_INVALID_STATE' || code === 'PROJECT_EXIT_INVALID_STATE')) {
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
    if (action === 'withdrawPublished') {
      return message.includes('authorization')
        ? '当前项目存在竞标服务费预授权额度记录，需先完成释放或平台处理后再撤回。'
        : '当前项目状态暂不支持撤回到预发布列表。';
    }
    if (action === 'archive') {
      return '当前项目尚未提交，暂不支持作废归档。';
    }
    if (action === 'discardSubmitted') {
      return '当前项目状态暂不支持作废删除。';
    }
    if (action === 'cancellationRequest' || action === 'cancellationRespond') {
      return '当前项目暂不支持从这里推进取消申请。';
    }
    if (action === 'publisherBreach' || action === 'factoryBreach') {
      return '当前项目暂不支持从这里记录违约。';
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
    if (!projectId) {
      throw new Error('Project lifecycle accepted response is missing required fields.');
    }
    if (action === 'cancellationRequest' || action === 'cancellationRespond') {
      const exitCaseId = this.asString(result.exitCaseId);
      const caseStatus = this.asString(result.caseStatus);
      const projectState = this.asString(result.projectState);
      if (!exitCaseId || !caseStatus || !projectState) {
        throw new Error('Project cancellation accepted response is missing required fields.');
      }
      return { ...result, projectId, exitCaseId, caseStatus, projectState };
    }
    if (action === 'publisherBreach' || action === 'factoryBreach') {
      const exitCaseId = this.asString(result.exitCaseId);
      const caseStatus = this.asString(result.caseStatus);
      const projectState = this.asString(result.projectState);
      if (!exitCaseId || caseStatus !== 'recorded' || !projectState) {
        throw new Error('Project breach accepted response is missing required fields.');
      }
      return { ...result, projectId, exitCaseId, caseStatus, projectState };
    }

    const expectedState = this.expectedLifecycleState(action);
    if (state !== expectedState) {
      throw new Error('Project lifecycle accepted response is missing required fields.');
    }
    return { ...result, projectId, state };
  }

  private toProjectActionPayload(
    payload: Record<string, unknown>,
    code: ProjectLifecycleInvalidCode,
    message: string
  ) {
    const source = this.requireRecord(payload, code, message);
    return {
      ...source,
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
    if (action === 'withdrawPublished') {
      return '撤回到预发布列表';
    }
    if (action === 'discardSubmitted') {
      return '作废删除';
    }
    if (action === 'cancellationRequest') {
      return '发起取消申请';
    }
    if (action === 'cancellationRespond') {
      return '响应取消申请';
    }
    if (action === 'publisherBreach') {
      return '记录发布方违约';
    }
    if (action === 'factoryBreach') {
      return '记录工厂违约';
    }
    return '下架关闭';
  }

  private expectedLifecycleState(action: ProjectLifecycleAction) {
    if (action === 'withdraw') return 'draft';
    if (action === 'withdrawPublished') return 'submitted';
    return 'archived';
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

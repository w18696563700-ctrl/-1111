import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type ProfileMembersAction = 'members_list' | 'member_role_patch' | 'member_disable';

@Injectable()
export class ProfileMembersErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeMembersListError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前组织成员列表暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteError(normalized, 'members_list');
  }

  normalizeMemberRolePatchError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_MEMBER_ROLE_INVALID',
      '当前成员角色调整暂不可用，请稍后再试。',
      {
        400: 'ORG_MEMBER_ROLE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteError(normalized, 'member_role_patch');
  }

  normalizeMemberDisableError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_MEMBER_DISABLE_INVALID',
      '当前成员禁用暂不可用，请稍后再试。',
      {
        400: 'ORG_MEMBER_DISABLE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteError(normalized, 'member_disable');
  }

  private rewriteError(exception: HttpException, action: ProfileMembersAction): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse());
    const upstreamCode = this.asString(payload.code) ?? 'UNKNOWN_ERROR';
    const code = this.normalizeCode(action, statusCode, upstreamCode);
    const originalMessage = this.asString(payload.message) ?? '';
    const translatedMessage = this.translateMessage(action, code, originalMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(payload.details, originalMessage, translatedMessage),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(action: ProfileMembersAction, statusCode: number, code: string) {
    if (code === 'AUTH_SESSION_INVALID' || code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return code;
    }
    if (statusCode === 404 || code === 'ORG_MEMBER_UNAVAILABLE') {
      return 'AUTH_RESOURCE_UNAVAILABLE';
    }
    if (action === 'member_role_patch' && statusCode === 400) {
      return 'ORG_MEMBER_ROLE_INVALID';
    }
    if (action === 'member_disable' && statusCode === 400) {
      return 'ORG_MEMBER_DISABLE_INVALID';
    }
    if (action === 'members_list') {
      return 'AUTH_RESOURCE_UNAVAILABLE';
    }
    return code;
  }

  private translateMessage(action: ProfileMembersAction, code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      if (action === 'members_list') {
        return '当前无权限查看当前组织成员列表。';
      }
      if (action === 'member_role_patch') {
        return '当前无权限调整该成员角色。';
      }
      return '当前无权限禁用该成员。';
    }
    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      if (action === 'members_list') {
        return '当前组织成员列表暂不可用，请稍后再试。';
      }
      return '当前成员资源不可用，请刷新后再试。';
    }
    if (action === 'member_role_patch') {
      return this.translateRolePatchMessage(message);
    }
    return this.translateDisableMessage(message);
  }

  private translateRolePatchMessage(message: string) {
    if (message.includes('Field `memberId` is required.')) {
      return '请先选择要调整角色的成员后再试。';
    }
    if (message.includes('Organization member role patch body must be an object.')) {
      return '当前成员角色调整参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `roleKey` is required.')) {
      return '请先选择成员角色后再试。';
    }
    if (message.includes('Optional organization member fields must be strings when provided.')) {
      return '当前成员角色调整参数格式无效，请检查后再试。';
    }
    if (message.includes('outside the current organization role boundary')) {
      return '当前成员角色不在本轮允许范围内，请重新选择后再试。';
    }
    if (message.includes('can only be patched while the membership is active')) {
      return '当前成员仅在启用状态下可调整角色。';
    }
    if (message.includes('already holds the requested role')) {
      return '当前成员已是所选角色，无需重复调整。';
    }
    if (message.includes('leave the organization without an active admin')) {
      return '当前调整会导致组织缺少可用管理员，暂不可执行。';
    }
    return '当前成员角色调整请求无效，请检查后再试。';
  }

  private translateDisableMessage(message: string) {
    if (message.includes('Field `memberId` is required.')) {
      return '请先选择要禁用的成员后再试。';
    }
    if (message.includes('Organization member disable body must be an object.')) {
      return '当前成员禁用参数格式无效，请检查后再试。';
    }
    if (message.includes('Optional organization member fields must be strings when provided.')) {
      return '当前成员禁用参数格式无效，请检查后再试。';
    }
    if (message.includes('disable only applies to active memberships')) {
      return '当前成员仅在启用状态下可被禁用。';
    }
    if (message.includes('cannot disable the active membership bound to the current session')) {
      return '当前正在使用的成员身份无法直接禁用。';
    }
    if (message.includes('leave the organization without an active admin')) {
      return '当前禁用会导致组织缺少可用管理员，暂不可执行。';
    }
    return '当前成员禁用请求无效，请检查后再试。';
  }

  private buildDetails(
    rawDetails: unknown,
    originalMessage: string,
    translatedMessage: string,
  ): Record<string, unknown> | undefined {
    const details = this.asRecord(rawDetails);
    if (translatedMessage !== originalMessage && originalMessage.trim().length > 0) {
      details.originalMessage = originalMessage;
    }
    return Object.keys(details).length > 0 ? details : undefined;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}

import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type ProfileCommandAction =
  | 'organization_create'
  | 'organization_join_by_code'
  | 'organization_switch'
  | 'certification_submit'
  | 'certification_resubmit'
  | 'personal_nickname'
  | 'personal_avatar';

@Injectable()
export class ProfileCommandErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeOrganizationCreateError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_CREATE_INVALID',
      '当前组织创建暂不可用，请稍后再试。',
      {
        400: 'ORG_CREATE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'organization_create');
  }

  normalizeOrganizationJoinError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_JOIN_INVALID',
      '当前组织加入暂不可用，请稍后再试。',
      {
        400: 'ORG_JOIN_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'ORG_JOIN_DUPLICATE',
      },
    );
    return this.rewriteMessage(normalized, 'organization_join_by_code');
  }

  normalizeOrganizationJoinReadbackError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前组织加入结果暂时不可回读，请稍后刷新后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const code = this.asString(payload.code) ?? 'AUTH_RESOURCE_UNAVAILABLE';
    const originalMessage = this.asString(payload.message) ?? '';
    const translatedMessage =
      code === 'AUTH_SESSION_INVALID'
        ? '当前登录态不可用，请重新登录或刷新后再试。'
        : code === 'AUTH_PERMISSION_INSUFFICIENT'
          ? '当前无权限回读组织加入结果。'
          : '当前组织加入结果暂时不可回读，请稍后刷新后再试。';

    return new HttpException(
      {
        statusCode,
        code,
        message: translatedMessage,
        details: this.buildDetails(payload.details, originalMessage, translatedMessage),
        source: this.asErrorSource(payload.source),
      },
      statusCode,
    );
  }

  normalizeOrganizationSwitchError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_SWITCH_INVALID',
      '当前组织切换暂不可用，请稍后再试。',
      {
        400: 'ORG_SWITCH_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'organization_switch');
  }

  normalizeCertificationSubmitError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'CERTIFICATION_SUBMIT_INVALID',
      '当前认证提交暂不可用，请稍后再试。',
      {
        400: 'CERTIFICATION_SUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'CERTIFICATION_DUPLICATE_SUBMIT',
      },
    );
    return this.rewriteMessage(normalized, 'certification_submit');
  }

  normalizeCertificationResubmitError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'CERTIFICATION_RESUBMIT_INVALID',
      '当前认证重提暂不可用，请稍后再试。',
      {
        400: 'CERTIFICATION_RESUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'CERTIFICATION_DUPLICATE_SUBMIT',
      },
    );
    return this.rewriteMessage(normalized, 'certification_resubmit');
  }

  normalizePersonalNicknameError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'PERSONAL_NICKNAME_INVALID',
      '当前昵称保存暂不可用，请稍后再试。',
      {
        400: 'PERSONAL_NICKNAME_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'personal_nickname');
  }

  normalizePersonalAvatarError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'PERSONAL_AVATAR_INVALID',
      '当前头像保存暂不可用，请稍后再试。',
      {
        400: 'PERSONAL_AVATAR_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'PERSONAL_AVATAR_FILE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'personal_avatar');
  }

  private rewriteMessage(
    exception: HttpException,
    action: ProfileCommandAction,
  ): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse());
    const code = this.asString(payload.code) ?? 'UNKNOWN_ERROR';
    const source = this.asErrorSource(payload.source);
    const originalMessage = this.asString(payload.message) ?? '';
    const translatedMessage = this.translateMessage(action, code, originalMessage);
    const details = this.buildDetails(payload.details, originalMessage, translatedMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details,
      source,
    };
    return new HttpException(body, statusCode);
  }

  private translateMessage(
    action: ProfileCommandAction,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }

    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return this.translateForbiddenMessage(action);
    }

    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return this.translateUnavailableMessage(action);
    }

    if (action === 'organization_create') {
      return this.translateOrganizationCreateMessage(code, message);
    }

    if (action === 'organization_join_by_code') {
      return this.translateOrganizationJoinMessage(code, message);
    }

    if (action === 'organization_switch') {
      return this.translateOrganizationSwitchMessage(code, message);
    }

    if (action === 'certification_submit') {
      return this.translateCertificationSubmitMessage(code, message);
    }

    if (action === 'personal_nickname') {
      return this.translatePersonalNicknameMessage(code, message);
    }

    if (action === 'personal_avatar') {
      return this.translatePersonalAvatarMessage(code, message);
    }

    return this.translateCertificationResubmitMessage(code, message);
  }

  private translateForbiddenMessage(action: ProfileCommandAction): string {
    if (action === 'organization_create') {
      return '当前无权限创建组织。';
    }
    if (action === 'organization_join_by_code') {
      return '当前无权限加入该组织。';
    }
    if (action === 'organization_switch') {
      return '当前无权限切换组织。';
    }
    if (action === 'certification_submit') {
      return '当前无权限提交企业认证。';
    }
    if (action === 'personal_nickname') {
      return '当前无权限修改昵称。';
    }
    if (action === 'personal_avatar') {
      return '当前无权限修改头像。';
    }
    return '当前无权限重新提交企业认证。';
  }

  private translateUnavailableMessage(action: ProfileCommandAction): string {
    if (action === 'organization_create') {
      return '当前组织创建依赖资源不可用，请稍后再试。';
    }
    if (action === 'organization_join_by_code') {
      return '当前组织加入目标不可用，请稍后再试。';
    }
    if (action === 'organization_switch') {
      return '当前组织切换目标不可用，请稍后再试。';
    }
    if (action === 'certification_submit') {
      return '当前认证提交目标不可用，请稍后再试。';
    }
    if (action === 'personal_nickname') {
      return '当前昵称保存目标不可用，请稍后再试。';
    }
    if (action === 'personal_avatar') {
      return '当前头像保存目标不可用，请稍后再试。';
    }
    return '当前认证重提目标不可用，请稍后再试。';
  }

  private translateOrganizationCreateMessage(code: string, message: string): string {
    if (code !== 'ORG_CREATE_INVALID') {
      return '当前组织创建暂不可用，请稍后再试。';
    }

    if (message.includes('Organization create body must be an object.')) {
      return '当前组织创建参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `name` is required')) {
      return '请先填写组织名称后再提交。';
    }
    if (message.includes('Field `organizationType` is required')) {
      return '请选择组织类型后再提交。';
    }
    if (message.includes('organizationType') && message.includes('outside the current minimum organization boundary')) {
      return '当前组织类型不在本轮允许范围内，请重新选择后再试。';
    }
    if (message.includes('Field `provinceCode` is required')) {
      return '请选择组织所在省份后再提交。';
    }
    if (message.includes('Field `cityCode` is required')) {
      return '请选择组织所在城市后再提交。';
    }
    if (message.includes('Field `contactName` is required')) {
      return '请先填写联系人姓名后再提交。';
    }
    if (message.includes('Field `contactMobile` is required')) {
      return '请先填写联系人手机号后再提交。';
    }
    if (message.includes('Optional organization fields')) {
      return '当前组织资料格式无效，请检查后再试。';
    }
    if (message.includes('license file truth')) {
      return '当前营业执照文件不可用，请重新上传后再试。';
    }
    return '当前组织创建参数无效，请检查后再试。';
  }

  private translateOrganizationJoinMessage(code: string, message: string): string {
    if (code === 'ORG_JOIN_DUPLICATE') {
      return '你已加入当前组织，请勿重复加入。';
    }

    if (code !== 'ORG_JOIN_INVALID') {
      return '当前组织加入暂不可用，请稍后再试。';
    }

    if (message.includes('Organization join body must be an object.')) {
      return '当前组织加入参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `inviteCode` is required')) {
      return '请先填写组织邀请码后再加入。';
    }
    if (message.includes('invite code is unavailable')) {
      return '当前邀请码不可用，请检查后再试。';
    }
    if (message.includes('unsupported organization role')) {
      return '当前邀请码暂不支持加入该组织。';
    }
    if (message.includes('invite code has expired')) {
      return '当前邀请码已过期，请联系组织管理员重新获取。';
    }
    if (message.includes('invite code has already been used')) {
      return '当前邀请码已失效，请联系组织管理员重新获取。';
    }
    if (message.includes('does not reference an available organization')) {
      return '当前目标组织不可用，请联系组织管理员重新获取邀请码。';
    }
    return '当前组织加入请求无效，请检查后再试。';
  }

  private translateOrganizationSwitchMessage(code: string, message: string): string {
    if (code !== 'ORG_SWITCH_INVALID') {
      return '当前组织切换暂不可用，请稍后再试。';
    }

    if (message.includes('Organization switch body must be an object.')) {
      return '当前组织切换参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `organizationId` is required')) {
      return '请选择要切换的组织后再试。';
    }
    if (message.includes('switch target is unavailable')) {
      return '当前目标组织不可用，请刷新后再试。';
    }
    if (message.includes('cannot switch to the requested organization')) {
      return '你当前不能切换到该组织。';
    }
    return '当前组织切换请求无效，请检查后再试。';
  }

  private translateCertificationSubmitMessage(code: string, message: string): string {
    if (code === 'CERTIFICATION_DUPLICATE_SUBMIT') {
      return '当前认证已在审核中，请勿重复提交。';
    }

    if (code !== 'CERTIFICATION_SUBMIT_INVALID') {
      return '当前认证提交暂不可用，请稍后再试。';
    }

    if (message.includes('Certification submit body must be an object.')) {
      return '当前认证提交参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `organizationId` is required')) {
      return '请先选择要提交认证的组织。';
    }
    if (message.includes('Field `legalName` is required')) {
      return '请先填写企业名称后再提交认证。';
    }
    if (message.includes('Field `uscc` is required')) {
      return '请先填写统一社会信用代码后再提交认证。';
    }
    if (message.includes('Field `licenseFileId` is required')) {
      return '请先上传营业执照后再提交认证。';
    }
    if (message.includes('license file truth')) {
      return '当前营业执照文件不可用，请重新上传后再试。';
    }
    if (message.includes('does not belong to the current organization')) {
      return '当前营业执照文件不属于当前组织，请重新上传后再试。';
    }
    if (message.includes('organization is unavailable for certification submit')) {
      return '当前组织暂不可提交认证，请稍后再试。';
    }
    if (message.includes('state does not allow submit')) {
      return '当前认证状态不允许再次提交，请刷新后再试。';
    }
    return '当前认证提交参数无效，请检查后再试。';
  }

  private translateCertificationResubmitMessage(code: string, message: string): string {
    if (code === 'CERTIFICATION_DUPLICATE_SUBMIT') {
      return '当前认证已在审核中，请勿重复提交。';
    }

    if (code !== 'CERTIFICATION_RESUBMIT_INVALID') {
      return '当前认证重提暂不可用，请稍后再试。';
    }

    if (message.includes('Certification resubmit body must be an object.')) {
      return '当前认证重提参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `organizationId` is required')) {
      return '请先选择要重新提交认证的组织。';
    }
    if (message.includes('Field `legalName` is required')) {
      return '请先填写企业名称后再重新提交认证。';
    }
    if (message.includes('Field `uscc` is required')) {
      return '请先填写统一社会信用代码后再重新提交认证。';
    }
    if (message.includes('Field `licenseFileId` is required')) {
      return '请先上传营业执照后再重新提交认证。';
    }
    if (message.includes('Optional certification fields must be strings')) {
      return '当前补充说明格式无效，请检查后再试。';
    }
    if (message.includes('license file truth')) {
      return '当前营业执照文件不可用，请重新上传后再试。';
    }
    if (message.includes('does not belong to the current organization')) {
      return '当前营业执照文件不属于当前组织，请重新上传后再试。';
    }
    if (message.includes('certification is unavailable for resubmit')) {
      return '当前认证记录不可用，请刷新后再试。';
    }
    if (message.includes('state does not allow resubmit')) {
      return '当前认证状态不允许重新提交，请刷新后再试。';
    }
    return '当前认证重提参数无效，请检查后再试。';
  }

  private translatePersonalNicknameMessage(code: string, message: string): string {
    if (code !== 'PERSONAL_NICKNAME_INVALID') {
      return '当前昵称保存暂不可用，请稍后再试。';
    }

    if (message.includes('Field `nickname` is required')) {
      return '请先填写昵称后再保存。';
    }
    if (message.includes('1 to 10 Chinese Han characters')) {
      return '昵称仅支持 1 到 10 个中文汉字。';
    }
    if (message.includes('body must be an object')) {
      return '当前昵称参数格式无效，请检查后再试。';
    }
    return '当前昵称参数无效，请检查后再试。';
  }

  private translatePersonalAvatarMessage(code: string, message: string): string {
    if (code === 'PERSONAL_AVATAR_FILE_UNAVAILABLE') {
      return '当前头像文件不可用，请重新上传后再试。';
    }

    if (code !== 'PERSONAL_AVATAR_INVALID') {
      return '当前头像保存暂不可用，请稍后再试。';
    }

    if (message.includes('Field `fileAssetId` is required')) {
      return '请先选择要提交的头像文件。';
    }
    if (message.includes('body must be an object')) {
      return '当前头像提交参数格式无效，请检查后再试。';
    }
    if (message.includes('does not belong to the current user profile')) {
      return '当前头像文件不属于当前账号，请重新上传后再试。';
    }
    if (message.includes('only supports image mime types')) {
      return '当前头像文件只支持图片格式。';
    }
    if (message.includes('projection URL is unavailable')) {
      return '当前头像地址暂不可用，请稍后再试。';
    }
    return '当前头像提交参数无效，请检查后再试。';
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
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}

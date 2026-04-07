import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type ProfileSafetyAction = 'nickname' | 'avatar' | 'bio' | 'status';

@Injectable()
export class ProfileSafetyErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeNicknameError(error: unknown): HttpException {
    return this.normalizeSubmitError(error, 'nickname');
  }

  normalizeAvatarError(error: unknown): HttpException {
    return this.normalizeSubmitError(error, 'avatar');
  }

  normalizeBioError(error: unknown): HttpException {
    return this.normalizeSubmitError(error, 'bio');
  }

  normalizeStatusError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'PROFILE_SAFETY_SUBMISSION_UNAVAILABLE',
      '当前资料审核状态暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'PROFILE_SAFETY_SUBMISSION_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'status');
  }

  private normalizeSubmitError(
    error: unknown,
    action: Exclude<ProfileSafetyAction, 'status'>,
  ): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'PROFILE_SAFETY_SUBMISSION_INVALID',
      '当前资料提交暂不可用，请稍后再试。',
      {
        400: 'PROFILE_SAFETY_SUBMISSION_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'PROFILE_SAFETY_SUBMISSION_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, action);
  }

  private rewriteMessage(
    exception: HttpException,
    action: ProfileSafetyAction,
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
    action: ProfileSafetyAction,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return this.translateForbiddenMessage(action);
    }
    if (code === 'PROFILE_SAFETY_SUBMISSION_UNAVAILABLE') {
      return this.translateUnavailableMessage(action);
    }
    if (code === 'PERSONAL_AVATAR_FILE_UNAVAILABLE') {
      return '当前头像文件不可用，请重新上传后再试。';
    }
    if (code === 'PERSONAL_AVATAR_INVALID') {
      return this.translateAvatarInvalidMessage(message);
    }
    if (code === 'PROFILE_SAFETY_RULE_BLOCKED') {
      return message || '当前资料内容未通过安全规则，请修改后再提交。';
    }
    if (code === 'PROFILE_SAFETY_REVIEW_STATE_INVALID') {
      return '当前资料审核状态不允许执行该操作，请刷新后再试。';
    }
    if (code !== 'PROFILE_SAFETY_SUBMISSION_INVALID') {
      return action === 'status'
        ? '当前资料审核状态暂不可用，请稍后再试。'
        : '当前资料提交暂不可用，请稍后再试。';
    }
    return this.translateSubmissionInvalidMessage(action, message);
  }

  private translateForbiddenMessage(action: ProfileSafetyAction) {
    if (action === 'status') {
      return '当前无权限查看资料审核状态。';
    }
    return '当前无权限提交资料审核。';
  }

  private translateUnavailableMessage(action: ProfileSafetyAction) {
    if (action === 'status') {
      return '当前资料审核状态暂不可用，请稍后再试。';
    }
    return '当前资料审核提交目标暂不可用，请稍后再试。';
  }

  private translateAvatarInvalidMessage(message: string) {
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
    if (message.includes('exceeds the P0 avatar size boundary')) {
      return '当前头像文件超过本轮大小限制，请重新选择后再试。';
    }
    if (message.includes('projection URL is unavailable')) {
      return '当前头像地址暂不可用，请稍后再试。';
    }
    return '当前头像提交参数无效，请检查后再试。';
  }

  private translateSubmissionInvalidMessage(
    action: ProfileSafetyAction,
    message: string,
  ) {
    if (message.includes('body must be an object')) {
      return '当前资料提交参数格式无效，请检查后再试。';
    }
    if (message.includes('Field `nickname` is required')) {
      return '请先填写昵称后再提交审核。';
    }
    if (message.includes('1 to 10 Chinese Han characters')) {
      return '昵称仅支持 1 到 10 个中文汉字。';
    }
    if (message.includes('Field `intro` is required') || message.includes('Field `bio` is required')) {
      return '请先填写简介后再提交审核。';
    }
    if (message.includes('Personal intro exceeds the P0 length boundary')) {
      return '简介最多支持 100 个字符。';
    }
    if (action === 'nickname') {
      return '当前昵称提交参数无效，请检查后再试。';
    }
    if (action === 'avatar') {
      return '当前头像提交参数无效，请检查后再试。';
    }
    return '当前简介提交参数无效，请检查后再试。';
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

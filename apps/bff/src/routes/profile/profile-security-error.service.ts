import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type ProfileSecurityAction = 'devices_list' | 'device_revoke';

@Injectable()
export class ProfileSecurityErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeDevicesListError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'SECURITY_DEVICE_UNAVAILABLE',
      '当前设备列表暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'SECURITY_DEVICE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'devices_list');
  }

  normalizeDeviceRevokeError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'SECURITY_DEVICE_REVOKE_INVALID',
      '当前设备撤销暂不可用，请稍后再试。',
      {
        400: 'SECURITY_DEVICE_REVOKE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'SECURITY_DEVICE_UNAVAILABLE',
      },
    );
    return this.rewriteMessage(normalized, 'device_revoke');
  }

  private rewriteMessage(
    exception: HttpException,
    action: ProfileSecurityAction,
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
    action: ProfileSecurityAction,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }

    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return action === 'devices_list'
        ? '当前无权限查看设备列表。'
        : '当前无权限撤销该设备。';
    }

    if (code === 'SECURITY_DEVICE_UNAVAILABLE') {
      return action === 'devices_list'
        ? '当前设备列表暂不可用，请稍后再试。'
        : '当前设备不可用，请刷新后再试。';
    }

    return this.translateDeviceRevokeMessage(code, message);
  }

  private translateDeviceRevokeMessage(code: string, message: string): string {
    if (code !== 'SECURITY_DEVICE_REVOKE_INVALID') {
      return '当前设备撤销暂不可用，请稍后再试。';
    }

    if (message.includes('Security device revoke body must be an object.')) {
      return '当前设备撤销参数格式无效，请检查后再试。';
    }
    if (message.includes('Current device path parameter is required for revoke.')) {
      return '请先选择要撤销的设备后再试。';
    }
    if (message.includes('Field `deviceId` is required for device revoke.')) {
      return '请先选择要撤销的设备后再试。';
    }
    if (message.includes('Current device revoke request must keep path and body deviceId aligned.')) {
      return '当前设备撤销目标不一致，请刷新后再试。';
    }
    if (message.includes('Current device cannot be revoked from the active session.')) {
      return '当前设备正在使用中，无法直接撤销。';
    }
    if (message.includes('Current device has no revocable session truth.')) {
      return '当前设备暂无可撤销会话，请刷新后再试。';
    }

    return '当前设备撤销请求无效，请检查后再试。';
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

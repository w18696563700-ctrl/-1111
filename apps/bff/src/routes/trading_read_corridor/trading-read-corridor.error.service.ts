import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type TradingReadAction =
  | 'order_detail'
  | 'contract_detail'
  | 'milestone_list'
  | 'inspection_detail';

const ROUTE_DRIFT_PREFIXES = {
  order_detail: 'Cannot GET /server/order/detail',
  contract_detail: 'Cannot GET /server/contract/detail',
  milestone_list: 'Cannot GET /server/milestone/list',
  inspection_detail: 'Cannot GET /server/inspection/detail',
} as const;

@Injectable()
export class TradingReadCorridorErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeOrderDetailError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'order_detail',
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前订单详情暂不可用，请稍后再试。',
      {
        400: 'ORDER_DETAIL_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
  }

  normalizeContractDetailError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'contract_detail',
      'CONTRACT_ENTRY_UNAVAILABLE',
      '当前合同详情暂不可用，请稍后再试。',
      {
        400: 'CONTRACT_DETAIL_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'CONTRACT_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeMilestoneListError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'milestone_list',
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前里程碑列表暂不可用，请稍后再试。',
      {
        400: 'MILESTONE_LIST_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
  }

  normalizeInspectionDetailError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'inspection_detail',
      'INSPECTION_ENTRY_UNAVAILABLE',
      '当前验收详情暂不可用，请稍后再试。',
      {
        400: 'INSPECTION_DETAIL_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'INSPECTION_ENTRY_UNAVAILABLE',
      },
    );
  }

  private normalizeReadError(
    error: unknown,
    action: TradingReadAction,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>>,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      statusCodeMap,
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(
      this.asString(payload.code) ?? fallbackCode,
      originalMessage,
      action,
      statusCode,
      statusCodeMap,
      fallbackCode,
    );
    const translatedMessage = this.translateMessage(action, code);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(
        action,
        code,
        payload.details,
        originalMessage,
        translatedMessage,
      ),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    code: string,
    originalMessage: string,
    action: TradingReadAction,
    statusCode: number,
    statusCodeMap: Partial<Record<number, string>>,
    fallbackCode: string,
  ) {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIXES[action])) {
      return fallbackCode;
    }

    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'ORDER_DETAIL_INVALID' ||
      code === 'CONTRACT_DETAIL_INVALID' ||
      code === 'CONTRACT_ENTRY_UNAVAILABLE' ||
      code === 'MILESTONE_LIST_INVALID' ||
      code === 'INSPECTION_DETAIL_INVALID' ||
      code === 'INSPECTION_ENTRY_UNAVAILABLE'
    ) {
      return code;
    }

    if (statusCode === 400 || statusCode === 404 || statusCode === 409) {
      return statusCodeMap[statusCode] ?? fallbackCode;
    }

    return fallbackCode;
  }

  private translateMessage(action: TradingReadAction, code: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限查看该履约信息。';
    }
    if (code === 'ORDER_DETAIL_INVALID') {
      return '当前订单详情参数无效，请检查后再试。';
    }
    if (code === 'CONTRACT_DETAIL_INVALID') {
      return '当前合同详情参数无效，请检查后再试。';
    }
    if (code === 'MILESTONE_LIST_INVALID') {
      return '当前里程碑列表参数无效，请检查后再试。';
    }
    if (code === 'INSPECTION_DETAIL_INVALID') {
      return '当前验收详情参数无效，请检查后再试。';
    }
    if (code === 'CONTRACT_ENTRY_UNAVAILABLE') {
      return '当前合同详情暂不可用，请稍后再试。';
    }
    if (code === 'INSPECTION_ENTRY_UNAVAILABLE') {
      return '当前验收详情暂不可用，请稍后再试。';
    }
    if (action === 'order_detail') {
      return '当前订单详情暂不可用，请稍后再试。';
    }
    if (action === 'contract_detail') {
      return '当前合同详情暂不可用，请稍后再试。';
    }
    if (action === 'milestone_list') {
      return '当前里程碑列表暂不可用，请稍后再试。';
    }
    return '当前验收详情暂不可用，请稍后再试。';
  }

  private buildDetails(
    action: TradingReadAction,
    code: string,
    rawDetails: unknown,
    originalMessage: string,
    translatedMessage: string,
  ): Record<string, unknown> | undefined {
    if (
      action === 'order_detail' ||
      action === 'contract_detail' ||
      action === 'milestone_list' ||
      action === 'inspection_detail'
    ) {
      return undefined;
    }

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

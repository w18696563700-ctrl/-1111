import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type TradingShellAction =
  | 'contract_amend'
  | 'contract_confirm'
  | 'dispute_withdraw'
  | 'inspection_pass'
  | 'inspection_recheck'
  | 'milestone_submit'
  | 'inspection_submit'
  | 'dispute_open';

const ROUTE_DRIFT_PREFIXES = {
  contract_amend: 'Cannot POST /server/contract/amend',
  contract_confirm: 'Cannot POST /server/contract/confirm',
  dispute_withdraw: 'Cannot POST /server/dispute/withdraw',
  inspection_pass: 'Cannot POST /server/inspection/pass',
  inspection_recheck: 'Cannot POST /server/inspection/recheck',
  milestone_submit: 'Cannot POST /server/milestone/submit',
  inspection_submit: 'Cannot POST /server/inspection/submit',
  dispute_open: 'Cannot POST /server/dispute/open',
} as const;

@Injectable()
export class TradingShellHandoffErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeMilestoneSubmitError(error: unknown) {
    return this.normalizeError(
      error,
      'milestone_submit',
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前里程碑提交入口暂不可用，请稍后再试。',
      {
        400: 'MILESTONE_SUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'MILESTONE_INVALID_STATE',
      },
    );
  }

  normalizeContractConfirmError(error: unknown) {
    return this.normalizeError(
      error,
      'contract_confirm',
      'CONTRACT_ENTRY_UNAVAILABLE',
      '当前合同确认入口暂不可用，请稍后再试。',
      {
        400: 'CONTRACT_CONFIRM_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'CONTRACT_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeContractAmendError(error: unknown) {
    return this.normalizeError(
      error,
      'contract_amend',
      'CONTRACT_ENTRY_UNAVAILABLE',
      '当前合同改单入口暂不可用，请稍后再试。',
      {
        400: 'CONTRACT_AMEND_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'CONTRACT_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeInspectionSubmitError(error: unknown) {
    return this.normalizeError(
      error,
      'inspection_submit',
      'INSPECTION_ENTRY_UNAVAILABLE',
      '当前验收提交入口暂不可用，请稍后再试。',
      {
        400: 'INSPECTION_SUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'INSPECTION_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeInspectionRecheckError(error: unknown) {
    return this.normalizeError(
      error,
      'inspection_recheck',
      'INSPECTION_ENTRY_UNAVAILABLE',
      '当前验收复检入口暂不可用，请稍后再试。',
      {
        400: 'INSPECTION_RECHECK_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'INSPECTION_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeInspectionPassError(error: unknown) {
    return this.normalizeError(
      error,
      'inspection_pass',
      'INSPECTION_ENTRY_UNAVAILABLE',
      '当前验收通过入口暂不可用，请稍后再试。',
      {
        400: 'INSPECTION_PASS_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'INSPECTION_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeDisputeOpenError(error: unknown) {
    return this.normalizeError(
      error,
      'dispute_open',
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前争议开启入口暂不可用，请稍后再试。',
      {
        400: 'DISPUTE_OPEN_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'DISPUTE_INVALID_STATE',
      },
    );
  }

  normalizeDisputeWithdrawError(error: unknown) {
    return this.normalizeError(
      error,
      'dispute_withdraw',
      'DISPUTE_INVALID_STATE',
      '当前争议撤回入口暂不可用，请稍后再试。',
      {
        400: 'DISPUTE_WITHDRAW_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'DISPUTE_INVALID_STATE',
      },
    );
  }

  private normalizeError(
    error: unknown,
    action: TradingShellAction,
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
      fallbackCode,
    );
    const message = this.translateMessage(action, code, originalMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message,
      details: this.buildDetails(
        action,
        payload.details,
        originalMessage,
        message,
      ),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    code: string,
    originalMessage: string,
    action: TradingShellAction,
    statusCode: number,
    fallbackCode: string,
  ) {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIXES[action])) {
      return fallbackCode;
    }
    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'CONTRACT_AMEND_INVALID' ||
      code === 'CONTRACT_CONFIRM_INVALID' ||
      code === 'CONTRACT_ENTRY_UNAVAILABLE' ||
      code === 'CONTRACT_INVALID_STATE' ||
      code === 'MILESTONE_SUBMIT_INVALID' ||
      code === 'MILESTONE_INVALID_STATE' ||
      code === 'INSPECTION_RECHECK_INVALID' ||
      code === 'INSPECTION_PASS_INVALID' ||
      code === 'INSPECTION_SUBMIT_INVALID' ||
      code === 'INSPECTION_ENTRY_UNAVAILABLE' ||
      code === 'INSPECTION_INVALID_STATE' ||
      code === 'DISPUTE_OPEN_INVALID' ||
      code === 'DISPUTE_WITHDRAW_INVALID' ||
      code === 'DISPUTE_INVALID_STATE'
    ) {
      return code;
    }
    if (statusCode === 400 || statusCode === 404 || statusCode === 409) {
      return fallbackCode;
    }
    return fallbackCode;
  }

  private translateMessage(
    action: TradingShellAction,
    code: string,
    originalMessage: string,
  ) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限继续该承接入口。';
    }
    if (code === 'CONTRACT_AMEND_INVALID') {
      return '当前合同改单参数无效，请检查后再试。';
    }
    if (code === 'CONTRACT_CONFIRM_INVALID') {
      return '当前合同确认参数无效，请检查后再试。';
    }
    if (code === 'CONTRACT_ENTRY_UNAVAILABLE') {
      return action === 'contract_amend'
        ? '当前合同改单入口暂不可用，请稍后再试。'
        : '当前合同确认入口暂不可用，请稍后再试。';
    }
    if (code === 'CONTRACT_INVALID_STATE') {
      return action === 'contract_amend'
        ? '当前合同状态暂不支持改单。'
        : '当前合同状态暂不支持确认。';
    }
    if (code === 'MILESTONE_SUBMIT_INVALID') {
      return '当前里程碑提交参数无效，请检查后再试。';
    }
    if (code === 'MILESTONE_INVALID_STATE') {
      return originalMessage || '当前里程碑暂时不能继续提交承接。';
    }
    if (code === 'INSPECTION_RECHECK_INVALID') {
      return '当前验收复检参数无效，请检查后再试。';
    }
    if (code === 'INSPECTION_PASS_INVALID') {
      return '当前验收通过参数无效，请检查后再试。';
    }
    if (code === 'INSPECTION_SUBMIT_INVALID') {
      return '当前验收提交参数无效，请检查后再试。';
    }
    if (code === 'INSPECTION_ENTRY_UNAVAILABLE') {
      return '当前验收提交入口暂不可用，请稍后再试。';
    }
    if (code === 'INSPECTION_INVALID_STATE') {
      if (action === 'inspection_recheck') {
        return originalMessage ? '当前验收状态暂不支持复检。' : '当前验收暂时不能继续复检承接。';
      }
      if (action === 'inspection_pass') {
        return originalMessage ? '当前验收状态暂不支持通过。' : '当前验收暂时不能继续通过承接。';
      }
      return originalMessage || '当前验收暂时不能继续提交承接。';
    }
    if (code === 'DISPUTE_OPEN_INVALID') {
      return '当前争议开启参数无效，请检查后再试。';
    }
    if (code === 'DISPUTE_WITHDRAW_INVALID') {
      return '当前争议撤回参数无效，请检查后再试。';
    }
    if (code === 'DISPUTE_INVALID_STATE') {
      if (action === 'dispute_withdraw') {
        return originalMessage ? '当前争议状态暂不支持撤回。' : '当前争议暂时不能继续撤回承接。';
      }
      return originalMessage || '当前订单暂时不能继续争议开启承接。';
    }
    return action === 'dispute_withdraw'
      ? '当前争议撤回入口暂不可用，请稍后再试。'
      : action === 'dispute_open'
      ? '当前争议开启入口暂不可用，请稍后再试。'
      : action === 'contract_amend'
      ? '当前合同改单入口暂不可用，请稍后再试。'
      : action === 'contract_confirm'
      ? '当前合同确认入口暂不可用，请稍后再试。'
      : action === 'inspection_recheck'
      ? '当前验收复检入口暂不可用，请稍后再试。'
      : action === 'inspection_pass'
      ? '当前验收通过入口暂不可用，请稍后再试。'
      : action === 'inspection_submit'
      ? '当前验收提交入口暂不可用，请稍后再试。'
      : '当前里程碑提交入口暂不可用，请稍后再试。';
  }

  private buildDetails(
    action: TradingShellAction,
    rawDetails: unknown,
    originalMessage: string,
    translatedMessage: string,
  ) {
    if (
      action === 'contract_amend' ||
      action === 'contract_confirm' ||
      action === 'dispute_withdraw' ||
      action === 'inspection_recheck' ||
      action === 'inspection_pass' ||
      action === 'milestone_submit' ||
      action === 'inspection_submit'
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

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}

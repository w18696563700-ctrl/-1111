import { HttpException, Injectable } from '@nestjs/common';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type Operation =
  | 'create_task'
  | 'task_detail'
  | 'authenticity_materials'
  | 'fixed_price_bid'
  | 'service_fee_authorization_create'
  | 'service_fee_authorization_init'
  | 'service_fee_authorization_status'
  | 'inquiry_deposit_create'
  | 'inquiry_deposit_pay_init'
  | 'inquiry_deposit_status'
  | 'inquiry_quotation'
  | 'inquiry_result'
  | 'contract_confirmation'
  | 'p0_pay_summary'
  | 'pricing_summary'
  | 'project_authenticity_sincerity_create'
  | 'project_authenticity_sincerity_pay_init'
  | 'project_authenticity_sincerity_refund'
  | 'project_authenticity_sincerity_freeze_feedback'
  | 'project_authenticity_sincerity_status'
  | 'bid_service_fee_authorization_create'
  | 'bid_service_fee_authorization_freeze_init'
  | 'bid_service_fee_authorization_status'
  | 'bid_service_fee_authorization_release'
  | 'deal_confirmation'
  | 'deal_confirmation_detail'
  | 'release_non_winning'
  | 'publisher_breach_release'
  | 'factory_refusal_breach_hold';

const OPERATION_CODES: Record<Operation, string> = {
  create_task: 'TRADE_TASK_CREATE_REJECTED',
  task_detail: 'TRADE_TASK_NOT_FOUND',
  authenticity_materials: 'TRADE_TASK_AUTHENTICITY_MATERIAL_REQUIRED',
  fixed_price_bid: 'FIXED_PRICE_BID_CREATE_REJECTED',
  service_fee_authorization_create: 'SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED',
  service_fee_authorization_init: 'SERVICE_FEE_AUTHORIZATION_INIT_REJECTED',
  service_fee_authorization_status: 'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE',
  inquiry_deposit_create: 'INQUIRY_DEPOSIT_ORDER_CREATE_REJECTED',
  inquiry_deposit_pay_init: 'INQUIRY_DEPOSIT_PAY_INIT_REJECTED',
  inquiry_deposit_status: 'INQUIRY_DEPOSIT_RESULT_UNAVAILABLE',
  inquiry_quotation: 'INQUIRY_QUOTATION_CREATE_REJECTED',
  inquiry_result: 'INQUIRY_RESULT_PROCESSING_REJECTED',
  contract_confirmation: 'CONTRACT_CONFIRMATION_REJECTED',
  p0_pay_summary: 'P0_PAY_SUMMARY_UNAVAILABLE',
  pricing_summary: 'PROJECT_PRICING_SUMMARY_UNAVAILABLE',
  project_authenticity_sincerity_create: 'PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED',
  project_authenticity_sincerity_pay_init: 'PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED',
  project_authenticity_sincerity_refund: 'PROJECT_AUTHENTICITY_SINCERITY_REFUND_REJECTED',
  project_authenticity_sincerity_freeze_feedback: 'PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED',
  project_authenticity_sincerity_status: 'PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND',
  bid_service_fee_authorization_create: 'BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED',
  bid_service_fee_authorization_freeze_init: 'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED',
  bid_service_fee_authorization_status: 'BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND',
  bid_service_fee_authorization_release: 'BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED',
  deal_confirmation: 'DEAL_CONFIRMATION_INVALID',
  deal_confirmation_detail: 'DEAL_CONFIRMATION_INVALID',
  release_non_winning: 'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE',
  publisher_breach_release: 'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE',
  factory_refusal_breach_hold: 'TRADE_TASK_INVALID_STATE',
};

@Injectable()
export class ExhibitionP0PayErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalize(error: unknown, operation: Operation, method: 'GET' | 'POST', serverPath: string) {
    const normalized = this.errors.toHttpException(
      error,
      this.fallbackCode(operation),
      this.fallbackMessage(operation),
      {
        400: this.badRequestCode(operation),
        401: 'AUTH_SESSION_INVALID',
        403: this.forbiddenCode(operation),
        404: this.notFoundCode(operation),
        409: this.conflictCode(operation),
        422: this.badRequestCode(operation),
        424: 'PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION',
        502: 'PAYMENT_CHANNEL_UNAVAILABLE',
        503: 'PAYMENT_CHANNEL_UNAVAILABLE',
      },
    );
    return this.sanitizeRouteDrift(normalized, operation, method, serverPath);
  }

  private sanitizeRouteDrift(
    error: HttpException,
    operation: Operation,
    method: 'GET' | 'POST',
    serverPath: string,
  ) {
    const payload = this.readPayload(error);
    const message = String(payload.message ?? '');
    if (error.getStatus() !== 404 && !message.includes(`Cannot ${method} ${serverPath}`)) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: this.fallbackCode(operation),
        message: this.fallbackMessage(operation),
        source: payload.source === 'bff' ? 'bff' : 'server',
      },
      error.getStatus(),
    );
  }

  private badRequestCode(operation: Operation) {
    if (operation === 'inquiry_quotation') {
      return 'INQUIRY_QUOTE_SEAT_FULL';
    }
    return this.fallbackCode(operation);
  }

  private forbiddenCode(operation: Operation) {
    if (operation === 'create_task') {
      return 'ORGANIZATION_CERTIFICATION_REQUIRED';
    }
    return 'AUTH_PERMISSION_INSUFFICIENT';
  }

  private notFoundCode(operation: Operation) {
    if (operation === 'task_detail') {
      return 'TRADE_TASK_NOT_FOUND';
    }
    return this.fallbackCode(operation);
  }

  private conflictCode(operation: Operation) {
    if (operation === 'bid_service_fee_authorization_freeze_init') {
      return 'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED';
    }
    if (
      operation === 'create_task' ||
      operation === 'service_fee_authorization_create' ||
      operation === 'service_fee_authorization_init' ||
      operation === 'inquiry_deposit_create' ||
      operation === 'inquiry_deposit_pay_init' ||
      operation === 'project_authenticity_sincerity_create' ||
      operation === 'project_authenticity_sincerity_pay_init' ||
      operation === 'project_authenticity_sincerity_refund' ||
      operation === 'project_authenticity_sincerity_freeze_feedback' ||
      operation === 'bid_service_fee_authorization_create' ||
      operation === 'bid_service_fee_authorization_release' ||
      operation === 'contract_confirmation' ||
      operation === 'deal_confirmation' ||
      operation === 'release_non_winning' ||
      operation === 'publisher_breach_release' ||
      operation === 'factory_refusal_breach_hold'
    ) {
      return 'IDEMPOTENCY_KEY_CONFLICT';
    }
    if (operation === 'project_authenticity_sincerity_status') {
      return 'PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE';
    }
    if (operation === 'bid_service_fee_authorization_status') {
      return 'BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE';
    }
    if (operation === 'deal_confirmation_detail') {
      return 'DEAL_CONFIRMATION_INVALID_STATE';
    }
    return 'TRADE_TASK_INVALID_STATE';
  }

  private fallbackCode(operation: Operation) {
    return OPERATION_CODES[operation];
  }

  private fallbackMessage(operation: Operation) {
    switch (operation) {
      case 'task_detail':
        return '当前交易任务详情暂不可用，请稍后再试。';
      case 'p0_pay_summary':
      case 'pricing_summary':
        return '当前交易资金状态暂不可用，请稍后再试。';
      case 'project_authenticity_sincerity_create':
        return '当前项目真实性诚意金订单暂不可创建，请稍后再试。';
      case 'project_authenticity_sincerity_pay_init':
        return '当前项目真实性诚意金支付暂不可拉起，请稍后再试。';
      case 'project_authenticity_sincerity_refund':
        return '当前项目真实性诚意金退款暂不可发起，请稍后再试。';
      case 'project_authenticity_sincerity_freeze_feedback':
        return '当前项目真实性诚意金反馈暂不可提交，请稍后再试。';
      case 'project_authenticity_sincerity_status':
        return '当前项目真实性诚意金状态暂不可用，请稍后再试。';
      case 'bid_service_fee_authorization_create':
        return '当前竞标服务费预授权额度暂不可创建，请稍后再试。';
      case 'bid_service_fee_authorization_freeze_init':
        return '当前竞标服务费预授权额度冻结暂不可拉起，请稍后再试。';
      case 'bid_service_fee_authorization_status':
        return '当前竞标服务费预授权额度状态暂不可用，请稍后再试。';
      case 'bid_service_fee_authorization_release':
        return '当前竞标服务费预授权额度暂不可释放，请稍后再试。';
      case 'deal_confirmation':
      case 'deal_confirmation_detail':
        return '当前成交确认暂不可用，请稍后再试。';
      case 'service_fee_authorization_status':
        return '当前平台服务费预授权状态暂不可用，请稍后再试。';
      case 'inquiry_deposit_status':
        return '当前发单诚意金状态暂不可用，请稍后再试。';
      case 'release_non_winning':
        return '当前未中标预授权释放暂不可用，请稍后再试。';
      case 'publisher_breach_release':
        return '当前发布方毁约释放暂不可用，请稍后再试。';
      case 'factory_refusal_breach_hold':
        return '当前工厂拒签挂起暂不可用，请稍后再试。';
      default:
        return '当前 P0-Pay 交易入口暂不可用，请稍后再试。';
    }
  }

  private readPayload(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      message: String(response),
      source: 'server',
    };
  }
}

import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { ExhibitionP0PayErrorService } from './exhibition-p0-pay-error.service';
import { ExhibitionP0PayPayloadService } from './exhibition-p0-pay-payload.service';
import {
  readAuthenticityMaterialsReadModel,
  readBidServiceFeeAuthorizationCreateReadModel,
  readBidServiceFeeAuthorizationFreezeInitReadModel,
  readBidServiceFeeAuthorizationReleaseReadModel,
  readBidServiceFeeAuthorizationStatusReadModel,
  readContractConfirmationReadModel,
  readDealConfirmationAcceptedReadModel,
  readDealConfirmationReadModel,
  readFixedPriceBidReadModel,
  readInquiryDepositOrderReadModel,
  readInquiryDepositPayInitReadModel,
  readInquiryDepositStatusReadModel,
  readInquiryQuotationReadModel,
  readInquiryResultReadModel,
  readPricingSummaryReadModel,
  readProjectAuthenticitySincerityOrderReadModel,
  readProjectAuthenticitySincerityPayInitReadModel,
  readProjectAuthenticitySincerityRefundReadModel,
  readProjectAuthenticitySincerityStatusReadModel,
  readProjectSettlementSummaryReadModel,
  readP0PayStateActionReadModel,
  readServiceFeeAuthorizationCreateReadModel,
  readServiceFeeAuthorizationStatusReadModel,
  readServiceFeeAuthorizeInitReadModel,
  readTradeTaskCreateReadModel,
  readTradeTaskDetailReadModel,
} from './exhibition-p0-pay.read-model';

type ReadModelMapper = (value: unknown) => Record<string, unknown>;

@Injectable()
export class ExhibitionP0PayService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly payloads: ExhibitionP0PayPayloadService,
    private readonly errors: ExhibitionP0PayErrorService,
  ) {}

  createTradeTask(payload: Record<string, unknown>, headers: IncomingHttpHeaders, idempotencyKey?: string) {
    const body = this.payloads.toCreateTradeTaskPayload(payload, idempotencyKey);
    return this.post('/server/exhibition/trade-tasks', body, headers, 'create_task', readTradeTaskCreateReadModel);
  }

  getTradeTaskDetail(taskId: string | undefined, headers: IncomingHttpHeaders) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}`;
    return this.get(path, headers, 'task_detail', readTradeTaskDetailReadModel);
  }

  bindAuthenticityMaterials(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/authenticity-materials`;
    const body = this.payloads.toAuthenticityMaterialsPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'authenticity_materials', readAuthenticityMaterialsReadModel);
  }

  submitFixedPriceBid(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/fixed-price-bids`;
    const body = this.payloads.toFixedPriceBidPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'fixed_price_bid', readFixedPriceBidReadModel);
  }

  createServiceFeeAuthorization(
    taskId: string | undefined,
    bidId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = this.authorizationPath(taskId, bidId);
    const body = this.payloads.toServiceFeeAuthorizationPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'service_fee_authorization_create', readServiceFeeAuthorizationCreateReadModel);
  }

  authorizeServiceFee(
    taskId: string | undefined,
    bidId: string | undefined,
    authorizationId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.authorizationPath(taskId, bidId)}/${this.id(authorizationId, 'authorizationId')}/authorize-init`;
    const body = this.payloads.toPayInitPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'service_fee_authorization_init', readServiceFeeAuthorizeInitReadModel);
  }

  getServiceFeeAuthorization(
    taskId: string | undefined,
    bidId: string | undefined,
    authorizationId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `${this.authorizationPath(taskId, bidId)}/${this.id(authorizationId, 'authorizationId')}`;
    return this.get(path, headers, 'service_fee_authorization_status', readServiceFeeAuthorizationStatusReadModel);
  }

  createInquiryDepositOrder(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = this.inquiryDepositPath(taskId);
    const body = this.payloads.toInquiryDepositOrderPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'inquiry_deposit_create', readInquiryDepositOrderReadModel);
  }

  createProjectAuthenticitySincerityOrder(
    projectId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = this.inquiryDepositPath(projectId);
    const body = this.payloads.toInquiryDepositOrderPayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'project_authenticity_sincerity_create',
      readProjectAuthenticitySincerityOrderReadModel,
    );
  }

  initInquiryDepositPay(
    taskId: string | undefined,
    depositOrderId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.inquiryDepositPath(taskId)}/${this.id(depositOrderId, 'depositOrderId')}/pay-init`;
    const body = this.payloads.toPayInitPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'inquiry_deposit_pay_init', readInquiryDepositPayInitReadModel);
  }

  initProjectAuthenticitySincerityPayment(
    projectId: string | undefined,
    orderId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.inquiryDepositPath(projectId)}/${this.id(orderId, 'orderId')}/pay-init`;
    const body = this.payloads.toPayInitPayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'project_authenticity_sincerity_pay_init',
      readProjectAuthenticitySincerityPayInitReadModel,
    );
  }

  getInquiryDepositOrder(
    taskId: string | undefined,
    depositOrderId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `${this.inquiryDepositPath(taskId)}/${this.id(depositOrderId, 'depositOrderId')}`;
    return this.get(path, headers, 'inquiry_deposit_status', readInquiryDepositStatusReadModel);
  }

  getProjectAuthenticitySincerityOrder(
    projectId: string | undefined,
    orderId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `${this.inquiryDepositPath(projectId)}/${this.id(orderId, 'orderId')}`;
    return this.get(
      path,
      headers,
      'project_authenticity_sincerity_status',
      readProjectAuthenticitySincerityStatusReadModel,
    );
  }

  initProjectAuthenticitySincerityRefund(
    projectId: string | undefined,
    orderId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.inquiryDepositPath(projectId)}/${this.id(orderId, 'orderId')}/refund-init`;
    const body = this.payloads.toProjectAuthenticitySincerityRefundPayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'project_authenticity_sincerity_refund',
      readProjectAuthenticitySincerityRefundReadModel,
    );
  }

  getProjectAuthenticitySincerityRefund(
    projectId: string | undefined,
    orderId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `${this.inquiryDepositPath(projectId)}/${this.id(orderId, 'orderId')}/refund`;
    return this.get(
      path,
      headers,
      'project_authenticity_sincerity_status',
      readProjectAuthenticitySincerityRefundReadModel,
    );
  }

  createBidServiceFeeAuthorization(
    projectId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = this.bidServiceFeeAuthorizationPath(projectId);
    const body = this.payloads.toBidServiceFeeAuthorizationPayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'bid_service_fee_authorization_create',
      readBidServiceFeeAuthorizationCreateReadModel,
    );
  }

  initBidServiceFeeAuthorizationFreeze(
    projectId: string | undefined,
    authorizationId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.bidServiceFeeAuthorizationPath(projectId)}/${this.id(authorizationId, 'authorizationId')}/freeze-init`;
    const body = this.payloads.toPayInitPayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'bid_service_fee_authorization_freeze_init',
      readBidServiceFeeAuthorizationFreezeInitReadModel,
    );
  }

  getBidServiceFeeAuthorization(
    projectId: string | undefined,
    authorizationId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `${this.bidServiceFeeAuthorizationPath(projectId)}/${this.id(authorizationId, 'authorizationId')}`;
    return this.get(
      path,
      headers,
      'bid_service_fee_authorization_status',
      readBidServiceFeeAuthorizationStatusReadModel,
    );
  }

  releaseBidServiceFeeAuthorization(
    projectId: string | undefined,
    authorizationId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.bidServiceFeeAuthorizationPath(projectId)}/${this.id(authorizationId, 'authorizationId')}/release`;
    const body = this.payloads.toBidServiceFeeAuthorizationReleasePayload(payload, idempotencyKey);
    return this.post(
      path,
      body,
      headers,
      'bid_service_fee_authorization_release',
      readBidServiceFeeAuthorizationReleaseReadModel,
    );
  }

  submitInquiryQuotation(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/inquiry-quotations`;
    const body = this.payloads.toInquiryQuotationPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'inquiry_quotation', readInquiryQuotationReadModel);
  }

  processInquiryResult(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/inquiry-result`;
    const body = this.payloads.toInquiryResultPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'inquiry_result', readInquiryResultReadModel);
  }

  createContractConfirmation(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/contract-confirmations`;
    const body = this.payloads.toContractConfirmationPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'contract_confirmation', readContractConfirmationReadModel);
  }

  createDealConfirmation(
    projectId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `/server/projects/${this.id(projectId, 'projectId')}/deal-confirmations`;
    const body = this.payloads.toDealConfirmationPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'deal_confirmation', readDealConfirmationAcceptedReadModel);
  }

  getDealConfirmation(
    projectId: string | undefined,
    dealConfirmationId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `/server/projects/${this.id(projectId, 'projectId')}/deal-confirmations/${this.id(
      dealConfirmationId,
      'dealConfirmationId',
    )}`;
    return this.get(path, headers, 'deal_confirmation_detail', readDealConfirmationReadModel);
  }

  getP0PaySummary(taskId: string | undefined, headers: IncomingHttpHeaders) {
    return this.getProjectPricingSummary(taskId, headers);
  }

  getProjectPricingSummary(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const path = `/server/project/${this.id(projectId, 'projectId')}/pricing-summary`;
    return this.get(path, headers, 'pricing_summary', readPricingSummaryReadModel);
  }

  getProjectSettlementSummary(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const path = `/server/project/${this.id(projectId, 'projectId')}/settlement/summary`;
    return this.get(path, headers, 'pricing_summary', readProjectSettlementSummaryReadModel);
  }

  createProjectSettlementBatchDraft(
    projectId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const path = `/server/project/${this.id(projectId, 'projectId')}/settlement/batch-draft`;
    return this.post(path, {}, headers, 'pricing_summary', readProjectSettlementSummaryReadModel);
  }

  getProjectSettlementReconciliation(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const path = `/server/project/${this.id(projectId, 'projectId')}/settlement/reconciliation`;
    return this.get(path, headers, 'pricing_summary', readProjectSettlementSummaryReadModel);
  }

  releaseNonWinning(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.stateActionPath(taskId)}/release-non-winning`;
    const body = this.payloads.toReleaseNonWinningPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'release_non_winning', readP0PayStateActionReadModel);
  }

  releasePublisherBreach(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.stateActionPath(taskId)}/publisher-breach-release`;
    const body = this.payloads.toPublisherBreachReleasePayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'publisher_breach_release', readP0PayStateActionReadModel);
  }

  holdFactoryRefusal(
    taskId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    idempotencyKey?: string,
  ) {
    const path = `${this.stateActionPath(taskId)}/factory-refusal-breach-hold`;
    const body = this.payloads.toFactoryRefusalBreachHoldPayload(payload, idempotencyKey);
    return this.post(path, body, headers, 'factory_refusal_breach_hold', readP0PayStateActionReadModel);
  }

  private async post(
    path: string,
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    operation: Parameters<ExhibitionP0PayErrorService['normalize']>[1],
    mapper: ReadModelMapper,
  ) {
    try {
      const result = await this.serverClient.post<unknown>(path, body, {
        headers: this.buildScopedHeaders(headers, body.idempotencyKey),
      });
      return mapper(result);
    } catch (error) {
      throw this.errors.normalize(error, operation, 'POST', path);
    }
  }

  private async get(
    path: string,
    headers: IncomingHttpHeaders,
    operation: Parameters<ExhibitionP0PayErrorService['normalize']>[1],
    mapper: ReadModelMapper,
  ) {
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
      });
      return mapper(result);
    } catch (error) {
      throw this.errors.normalize(error, operation, 'GET', path);
    }
  }

  private authorizationPath(taskId: string | undefined, bidId: string | undefined) {
    return `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/fixed-price-bids/${this.id(
      bidId,
      'bidId',
    )}/service-fee-authorizations`;
  }

  private inquiryDepositPath(taskId: string | undefined) {
    return `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/inquiry-deposit/orders`;
  }

  private bidServiceFeeAuthorizationPath(projectId: string | undefined) {
    return `/server/projects/${this.id(projectId, 'projectId')}/bid-service-fee-authorizations`;
  }

  private stateActionPath(taskId: string | undefined) {
    return `/server/exhibition/trade-tasks/${this.id(taskId, 'taskId')}/p0-pay-actions`;
  }

  private id(value: string | undefined, field: string) {
    return encodeURIComponent(this.payloads.readPathId(value, field));
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders, idempotencyKey?: unknown) {
    const result = this.authContext.buildForwardHeaders(headers);
    if (typeof idempotencyKey === 'string' && idempotencyKey.trim()) {
      result['x-idempotency-key'] = idempotencyKey.trim();
    }
    return result;
  }
}

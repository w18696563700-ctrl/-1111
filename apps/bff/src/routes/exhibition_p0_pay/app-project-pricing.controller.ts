import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { rcFeatureDisabled } from '../../core/rc/rc-feature-disabled';
import { ExhibitionP0PayService } from './exhibition-p0-pay.service';

@Controller('api/app/project')
export class AppProjectPricingController {
  constructor(private readonly service: ExhibitionP0PayService) {}

  @Get(':projectId/pricing-summary')
  getProjectPricingSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getProjectPricingSummary(projectId, headers);
  }

  @Post(':projectId/authenticity-sincerity/orders')
  @HttpCode(HttpStatus.ACCEPTED)
  createProjectAuthenticitySincerityOrder(
    @Param('projectId') projectId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_order');
    return this.service.createProjectAuthenticitySincerityOrder(
      projectId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Post(':projectId/authenticity-sincerity/orders/:orderId/pay-init')
  @HttpCode(HttpStatus.ACCEPTED)
  initProjectAuthenticitySincerityPayment(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_payment');
    return this.service.initProjectAuthenticitySincerityPayment(
      projectId,
      orderId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Post(':projectId/authenticity-sincerity/freeze-feedback')
  @HttpCode(HttpStatus.ACCEPTED)
  submitProjectAuthenticitySincerityFreezeFeedback(
    @Param('projectId') projectId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_freeze_feedback');
    return this.service.submitProjectAuthenticitySincerityFreezeFeedback(
      projectId,
      payload,
      headers,
    );
  }

  @Get(':projectId/authenticity-sincerity/orders/:orderId')
  getProjectAuthenticitySincerityOrder(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_order_detail');
    return this.service.getProjectAuthenticitySincerityOrder(projectId, orderId, headers);
  }

  @Post(':projectId/authenticity-sincerity/orders/:orderId/refund-init')
  @HttpCode(HttpStatus.ACCEPTED)
  initProjectAuthenticitySincerityRefund(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_refund');
    return this.service.initProjectAuthenticitySincerityRefund(
      projectId,
      orderId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Get(':projectId/authenticity-sincerity/orders/:orderId/refund')
  getProjectAuthenticitySincerityRefund(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_authenticity_sincerity_refund_detail');
    return this.service.getProjectAuthenticitySincerityRefund(projectId, orderId, headers);
  }

  @Post(':projectId/bid-service-fee-authorizations')
  @HttpCode(HttpStatus.ACCEPTED)
  createBidServiceFeeAuthorization(
    @Param('projectId') projectId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('bid_service_fee_authorization');
    return this.service.createBidServiceFeeAuthorization(
      projectId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Post(':projectId/bid-service-fee-authorizations/:authorizationId/freeze-init')
  @HttpCode(HttpStatus.ACCEPTED)
  initBidServiceFeeAuthorizationFreeze(
    @Param('projectId') projectId: string,
    @Param('authorizationId') authorizationId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('bid_service_fee_authorization_freeze');
    return this.service.initBidServiceFeeAuthorizationFreeze(
      projectId,
      authorizationId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Get(':projectId/bid-service-fee-authorizations/:authorizationId')
  getBidServiceFeeAuthorization(
    @Param('projectId') projectId: string,
    @Param('authorizationId') authorizationId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('bid_service_fee_authorization_detail');
    return this.service.getBidServiceFeeAuthorization(projectId, authorizationId, headers);
  }

  @Post(':projectId/bid-service-fee-authorizations/:authorizationId/release')
  @HttpCode(HttpStatus.ACCEPTED)
  releaseBidServiceFeeAuthorization(
    @Param('projectId') projectId: string,
    @Param('authorizationId') authorizationId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('bid_service_fee_authorization_release');
    return this.service.releaseBidServiceFeeAuthorization(
      projectId,
      authorizationId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Post(':projectId/deal-confirmations')
  @HttpCode(HttpStatus.ACCEPTED)
  createDealConfirmation(
    @Param('projectId') projectId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.createDealConfirmation(projectId, payload, headers, idempotencyKey);
  }

  @Get(':projectId/deal-confirmations/:dealConfirmationId')
  getDealConfirmation(
    @Param('projectId') projectId: string,
    @Param('dealConfirmationId') dealConfirmationId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getDealConfirmation(projectId, dealConfirmationId, headers);
  }

  @Get(':projectId/settlement/summary')
  getProjectSettlementSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_settlement_summary');
    return this.service.getProjectSettlementSummary(projectId, headers);
  }

  @Post(':projectId/settlement/batch-draft')
  @HttpCode(HttpStatus.ACCEPTED)
  createProjectSettlementBatchDraft(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_settlement_batch_draft');
    return this.service.createProjectSettlementBatchDraft(projectId, headers);
  }

  @Get(':projectId/settlement/reconciliation')
  getProjectSettlementReconciliation(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('project_settlement_reconciliation');
    return this.service.getProjectSettlementReconciliation(projectId, headers);
  }
}

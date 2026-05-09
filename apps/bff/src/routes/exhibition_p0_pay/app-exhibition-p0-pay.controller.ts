import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { rcFeatureDisabled } from '../../core/rc/rc-feature-disabled';
import { ExhibitionP0PayService } from './exhibition-p0-pay.service';

@Controller('api/app/exhibition/trade-tasks')
export class AppExhibitionP0PayController {
  constructor(private readonly service: ExhibitionP0PayService) {}

  @Post()
  @HttpCode(HttpStatus.ACCEPTED)
  createTradeTask(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('exhibition_trade_task_create');
    return this.service.createTradeTask(payload, headers, idempotencyKey);
  }

  @Get(':taskId')
  getTradeTaskDetail(
    @Param('taskId') taskId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getTradeTaskDetail(taskId, headers);
  }

  @Post(':taskId/authenticity-materials')
  @HttpCode(HttpStatus.ACCEPTED)
  bindAuthenticityMaterials(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.bindAuthenticityMaterials(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/fixed-price-bids')
  @HttpCode(HttpStatus.ACCEPTED)
  submitFixedPriceBid(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.submitFixedPriceBid(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/fixed-price-bids/:bidId/service-fee-authorizations')
  @HttpCode(HttpStatus.ACCEPTED)
  createServiceFeeAuthorization(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('legacy_service_fee_authorization');
    return this.service.createServiceFeeAuthorization(
      taskId,
      bidId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Post(':taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId/authorize-init')
  @HttpCode(HttpStatus.ACCEPTED)
  authorizeServiceFee(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Param('authorizationId') authorizationId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('legacy_service_fee_authorization_init');
    return this.service.authorizeServiceFee(
      taskId,
      bidId,
      authorizationId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Get(':taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId')
  getServiceFeeAuthorization(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Param('authorizationId') authorizationId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('legacy_service_fee_authorization_detail');
    return this.service.getServiceFeeAuthorization(taskId, bidId, authorizationId, headers);
  }

  @Post(':taskId/inquiry-deposit/orders')
  @HttpCode(HttpStatus.ACCEPTED)
  createInquiryDepositOrder(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('inquiry_deposit_order');
    return this.service.createInquiryDepositOrder(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/inquiry-deposit/orders/:depositOrderId/pay-init')
  @HttpCode(HttpStatus.ACCEPTED)
  initInquiryDepositPay(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('inquiry_deposit_payment');
    return this.service.initInquiryDepositPay(
      taskId,
      depositOrderId,
      payload,
      headers,
      idempotencyKey,
    );
  }

  @Get(':taskId/inquiry-deposit/orders/:depositOrderId')
  getInquiryDepositOrder(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('inquiry_deposit_order_detail');
    return this.service.getInquiryDepositOrder(taskId, depositOrderId, headers);
  }

  @Post(':taskId/inquiry-quotations')
  @HttpCode(HttpStatus.ACCEPTED)
  submitInquiryQuotation(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.submitInquiryQuotation(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/inquiry-result')
  @HttpCode(HttpStatus.ACCEPTED)
  processInquiryResult(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.processInquiryResult(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/contract-confirmations')
  @HttpCode(HttpStatus.ACCEPTED)
  createContractConfirmation(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.createContractConfirmation(taskId, payload, headers, idempotencyKey);
  }

  @Get(':taskId/p0-pay-summary')
  getP0PaySummary(
    @Param('taskId') taskId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    rcFeatureDisabled('p0_pay_summary');
    return this.service.getP0PaySummary(taskId, headers);
  }

  @Post(':taskId/p0-pay-actions/release-non-winning')
  @HttpCode(HttpStatus.ACCEPTED)
  releaseNonWinning(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('p0_pay_release_non_winning');
    return this.service.releaseNonWinning(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/p0-pay-actions/publisher-breach-release')
  @HttpCode(HttpStatus.ACCEPTED)
  releasePublisherBreach(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('p0_pay_publisher_breach_release');
    return this.service.releasePublisherBreach(taskId, payload, headers, idempotencyKey);
  }

  @Post(':taskId/p0-pay-actions/factory-refusal-breach-hold')
  @HttpCode(HttpStatus.ACCEPTED)
  holdFactoryRefusal(
    @Param('taskId') taskId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    rcFeatureDisabled('p0_pay_factory_refusal_breach_hold');
    return this.service.holdFactoryRefusal(taskId, payload, headers, idempotencyKey);
  }
}

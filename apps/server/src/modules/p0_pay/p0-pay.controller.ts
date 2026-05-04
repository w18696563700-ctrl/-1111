import { Body, Controller, Get, Headers, HttpCode, Param, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { P0PayCallbackService } from './p0-pay-callback.service';
import { P0PayContractConfirmationService } from './p0-pay-contract-confirmation.service';
import { P0PayInternalTestNoFreezeService } from './p0-pay-internal-test-no-freeze.service';
import { P0PayInquiryDepositService } from './p0-pay-inquiry-deposit.service';
import { P0PayRefundService } from './p0-pay-refund.service';
import { P0PayServiceFeeAuthorizationService } from './p0-pay-service-fee-authorization.service';
import { P0PaySettlementService } from './p0-pay-settlement.service';
import { P0PayTradeTaskService } from './p0-pay-trade-task.service';

@Controller()
export class P0PayController {
  constructor(
    private readonly authorizationService: P0PayServiceFeeAuthorizationService,
    private readonly tradeTaskService: P0PayTradeTaskService,
    private readonly inquiryDepositService: P0PayInquiryDepositService,
    private readonly internalTestNoFreezeService: P0PayInternalTestNoFreezeService,
    private readonly contractConfirmationService: P0PayContractConfirmationService,
    private readonly refundService: P0PayRefundService,
    private readonly settlementService: P0PaySettlementService,
    private readonly callbackService: P0PayCallbackService
  ) {}

  @Post('server/exhibition/trade-tasks')
  @HttpCode(202)
  createTradeTask(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.createTradeTask(body, this.context(headers, request));
  }

  @Get('server/exhibition/trade-tasks/:taskId')
  getTradeTaskDetail(
    @Param('taskId') taskId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.getTradeTaskDetail(taskId, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/authenticity-materials')
  @HttpCode(202)
  bindAuthenticityMaterials(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.bindAuthenticityMaterials(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/fixed-price-bids')
  @HttpCode(202)
  submitFixedPriceBid(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.submitFixedPriceBid(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations')
  @HttpCode(201)
  createAuthorizationOrder(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.authorizationService.createAuthorizationOrder(
      taskId,
      bidId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId/authorize-init')
  @HttpCode(202)
  authorizeInit(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Param('authorizationId') authorizationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.authorizationService.authorizeInit(
      taskId,
      bidId,
      authorizationId,
      body,
      this.context(headers, request)
    );
  }

  @Get('server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId')
  getAuthorization(
    @Param('taskId') taskId: string,
    @Param('bidId') bidId: string,
    @Param('authorizationId') authorizationId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.authorizationService.getAuthorization(
      taskId,
      bidId,
      authorizationId,
      this.context(headers, request)
    );
  }

  @Post('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders')
  @HttpCode(201)
  createInquiryDepositOrder(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.createOrder(
      taskId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/projects/:projectId/authenticity-sincerity/orders')
  @HttpCode(201)
  createProjectAuthenticitySincerityOrder(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.createOrder(
      projectId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/pay-init')
  @HttpCode(202)
  inquiryDepositPayInit(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.payInit(
      taskId,
      depositOrderId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/projects/:projectId/authenticity-sincerity/orders/:orderId/pay-init')
  @HttpCode(202)
  projectAuthenticitySincerityPayInit(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.payInit(
      projectId,
      orderId,
      body,
      this.context(headers, request)
    );
  }

  @Get('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId')
  getInquiryDepositOrder(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.getOrder(
      taskId,
      depositOrderId,
      this.context(headers, request)
    );
  }

  @Get('server/projects/:projectId/authenticity-sincerity/orders/:orderId')
  getProjectAuthenticitySincerityOrder(
    @Param('projectId') projectId: string,
    @Param('orderId') orderId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.inquiryDepositService.getOrder(
      projectId,
      orderId,
      this.context(headers, request)
    );
  }

  @Post('server/projects/:projectId/authenticity-sincerity/freeze-feedback')
  @HttpCode(202)
  submitProjectAuthenticitySincerityFreezeFeedback(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.internalTestNoFreezeService.submitFeedback(
      projectId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/refund-init')
  @HttpCode(202)
  refundInquiryDeposit(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.refundService.requestProjectAuthenticitySincerityRefund(
      taskId,
      depositOrderId,
      body,
      this.context(headers, request)
    );
  }

  @Get('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/refund')
  getInquiryDepositRefund(
    @Param('taskId') taskId: string,
    @Param('depositOrderId') depositOrderId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.refundService.getProjectAuthenticitySincerityRefund(
      taskId,
      depositOrderId,
      this.context(headers, request)
    );
  }

  @Post('server/exhibition/trade-tasks/:taskId/inquiry-quotations')
  @HttpCode(202)
  submitInquiryQuotation(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.submitInquiryQuotation(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/inquiry-result')
  @HttpCode(202)
  processInquiryResult(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.processInquiryResult(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/contract-confirmations')
  @HttpCode(202)
  createContractConfirmation(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.contractConfirmationService.createConfirmation(
      taskId,
      body,
      this.context(headers, request)
    );
  }

  @Post('server/projects/:projectId/deal-confirmations')
  @HttpCode(200)
  createProjectDealConfirmation(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.contractConfirmationService.createProjectDealConfirmation(
      projectId,
      body,
      this.context(headers, request)
    );
  }

  @Get('server/projects/:projectId/deal-confirmations/:dealConfirmationId')
  getProjectDealConfirmation(
    @Param('projectId') projectId: string,
    @Param('dealConfirmationId') dealConfirmationId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.contractConfirmationService.getProjectDealConfirmation(
      projectId,
      dealConfirmationId,
      this.context(headers, request)
    );
  }

  @Get('server/exhibition/trade-tasks/:taskId/p0-pay-summary')
  getP0PaySummary(
    @Param('taskId') taskId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.getP0PaySummary(taskId, this.context(headers, request));
  }

  @Get('server/project/:projectId/pricing-summary')
  getProjectPricingSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.getP0PaySummary(projectId, this.context(headers, request));
  }

  @Get('server/projects/:projectId/pricing-summary')
  getCanonicalProjectPricingSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.getP0PaySummary(projectId, this.context(headers, request));
  }

  @Get('server/project/:projectId/settlement/summary')
  getProjectSettlementSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.settlementService.getProjectSettlementSummary(projectId, this.context(headers, request));
  }

  @Post('server/project/:projectId/settlement/batch-draft')
  @HttpCode(202)
  createProjectSettlementBatchDraft(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.settlementService.createProjectSettlementBatchDraft(projectId, this.context(headers, request));
  }

  @Get('server/project/:projectId/settlement/reconciliation')
  getProjectReconciliationSummary(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.settlementService.getProjectReconciliationSummary(projectId, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/release-non-winning')
  @HttpCode(202)
  releaseNonWinning(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.releaseNonWinning(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/publisher-breach-release')
  @HttpCode(202)
  releasePublisherBreach(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.releasePublisherBreach(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/factory-refusal-breach-hold')
  @HttpCode(202)
  holdFactoryRefusal(
    @Param('taskId') taskId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.tradeTaskService.holdFactoryRefusal(taskId, body, this.context(headers, request));
  }

  @Post('server/exhibition/p0-pay/payment-callbacks/:paymentChannel')
  @HttpCode(200)
  handlePaymentCallback(
    @Param('paymentChannel') paymentChannel: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.callbackService.handleCallback(
      paymentChannel,
      body,
      this.readHeader(headers, 'x-p0-pay-signature'),
      this.context(headers, request)
    ).then((result) => {
      if (paymentChannel === 'alipay' && body && typeof body === 'object' && 'sign' in body) {
        return result.verificationStatus === 'verified' ? 'success' : 'failure';
      }
      return result;
    });
  }

  private context(headers: HeaderBag, request: Request) {
    return resolveRequestContext(headers, {
      userAgent: request.get('user-agent') ?? '',
      remoteIp: request.ip
    });
  }

  private readHeader(headers: HeaderBag, key: string) {
    const direct = headers[key] ?? headers[key.toLowerCase()];
    if (typeof direct === 'string') {
      return direct.trim();
    }
    if (Array.isArray(direct)) {
      return (direct[0] ?? '').trim();
    }
    return '';
  }
}

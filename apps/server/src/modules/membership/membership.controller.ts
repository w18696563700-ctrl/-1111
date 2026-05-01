import { Body, Controller, Get, Headers, HttpCode, Param, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MembershipPurchaseService } from './membership.purchase.service';
import { MembershipQueryService } from './membership.query.service';

@Controller('server/profile/membership')
export class MembershipController {
  constructor(
    private readonly queryService: MembershipQueryService,
    private readonly purchaseService: MembershipPurchaseService
  ) {}

  @Get('current')
  getCurrent(@Headers() headers: HeaderBag) {
    return this.queryService.getCurrent(resolveRequestContext(headers));
  }

  @Get('explanation')
  getExplanation(@Headers() headers: HeaderBag) {
    return this.queryService.getExplanation(resolveRequestContext(headers));
  }

  @Get('quota')
  getQuota(@Headers() headers: HeaderBag) {
    return this.queryService.getQuota(resolveRequestContext(headers));
  }

  @Get('upgrade-guide')
  getUpgradeGuide(@Headers() headers: HeaderBag) {
    return this.queryService.getUpgradeGuide(resolveRequestContext(headers));
  }

  @Get('purchase-offers')
  getPurchaseOffers(@Headers() headers: HeaderBag) {
    return this.purchaseService.getPurchaseOffers(resolveRequestContext(headers));
  }

  @Post('orders')
  @HttpCode(201)
  createOrder(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.purchaseService.createOrder(body, resolveRequestContext(headers));
  }

  @Post('orders/:membershipOrderId/pay-init')
  @HttpCode(202)
  payInit(
    @Param('membershipOrderId') membershipOrderId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.purchaseService.payInit(
      membershipOrderId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Get('orders/:membershipOrderId')
  getOrder(
    @Param('membershipOrderId') membershipOrderId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.purchaseService.getOrder(
      membershipOrderId,
      resolveRequestContext(headers)
    );
  }
}

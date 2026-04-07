import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { PaymentBillingQueryService } from './payment-billing.query.service';

@Controller('server/profile/payment-and-billing-status')
export class PaymentBillingController {
  constructor(private readonly queryService: PaymentBillingQueryService) {}

  @Get('status')
  getStatus(@Headers() headers: HeaderBag) {
    return this.queryService.getStatus(resolveRequestContext(headers));
  }

  @Get('explanation')
  getExplanation(@Headers() headers: HeaderBag) {
    return this.queryService.getExplanation(resolveRequestContext(headers));
  }

  @Get('handoff')
  getHandoff(@Headers() headers: HeaderBag) {
    return this.queryService.getHandoff(resolveRequestContext(headers));
  }
}

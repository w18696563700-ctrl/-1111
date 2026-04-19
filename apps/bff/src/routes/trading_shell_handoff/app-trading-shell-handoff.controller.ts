import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { TradingShellHandoffService } from './trading-shell-handoff.service';

@Controller('api/app')
export class AppTradingShellHandoffController {
  constructor(private readonly service: TradingShellHandoffService) {}

  @Post('milestone/submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitMilestone(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.submitMilestone(payload, headers);
  }

  @Post('inspection/submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitInspection(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.submitInspection(payload, headers);
  }

  @Post('inspection/recheck')
  @HttpCode(HttpStatus.ACCEPTED)
  recheckInspection(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.recheckInspection(payload, headers);
  }

  @Post('contract/confirm')
  @HttpCode(HttpStatus.ACCEPTED)
  confirmContract(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.confirmContract(payload, headers);
  }

  @Post('contract/amend')
  @HttpCode(HttpStatus.ACCEPTED)
  amendContract(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.amendContract(payload, headers);
  }

  @Post('dispute/open')
  @HttpCode(HttpStatus.ACCEPTED)
  openDispute(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.openDispute(payload, headers);
  }

  @Post('dispute/withdraw')
  @HttpCode(HttpStatus.ACCEPTED)
  withdrawDispute(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.withdrawDispute(payload, headers);
  }
}

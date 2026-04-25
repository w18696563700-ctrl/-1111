import { Body, Controller, Headers, HttpCode, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { TradingShellHandoffService } from './trading-shell-handoff.service';

@Controller('server')
export class TradingShellHandoffController {
  constructor(private readonly service: TradingShellHandoffService) {}

  @Post('milestone/submit')
  @HttpCode(202)
  submitMilestone(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.submitMilestone(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('inspection/submit')
  @HttpCode(202)
  submitInspection(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.submitInspection(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('inspection/recheck')
  @HttpCode(202)
  recheckInspection(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.recheckInspection(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('inspection/pass')
  @HttpCode(202)
  passInspection(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.passInspection(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('contract/confirm')
  @HttpCode(202)
  confirmContract(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.confirmContract(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('contract/amend')
  @HttpCode(202)
  amendContract(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.amendContract(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('dispute/open')
  @HttpCode(202)
  openDispute(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.openDispute(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('dispute/withdraw')
  @HttpCode(202)
  withdrawDispute(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.service.withdrawDispute(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }
}

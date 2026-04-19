import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { TradingImService } from './trading-im.service';

@Controller('api/app/project/clarification')
export class AppProjectClarificationController {
  constructor(private readonly service: TradingImService) {}

  @Get('list')
  listClarifications(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.listProjectClarifications(projectId, headers);
  }

  @Post('create')
  @HttpCode(HttpStatus.ACCEPTED)
  createClarification(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.createProjectClarification(payload, headers);
  }
}

@Controller('api/app/bid/thread')
export class AppBidThreadController {
  constructor(private readonly service: TradingImService) {}

  @Get('detail')
  getThreadDetail(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getBidThreadDetail(projectId, bidId, headers);
  }

  @Post('message/send')
  @HttpCode(HttpStatus.ACCEPTED)
  sendThreadMessage(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.sendThreadMessage(payload, headers);
  }

  @Post('confirmation/create')
  @HttpCode(HttpStatus.ACCEPTED)
  createConfirmation(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.createConfirmation(payload, headers);
  }
}

import { Body, Controller, Get, Headers, HttpCode, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { BidAwardQueryService } from './bid-award.query.service';
import { BidAwardWriteService } from './bid-award.write.service';

@Controller('server/bid')
export class BidAwardController {
  constructor(
    private readonly queryService: BidAwardQueryService,
    private readonly writeService: BidAwardWriteService
  ) {}

  @Post('award')
  @HttpCode(202)
  award(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.writeService.award(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip
      })
    );
  }

  @Get('result')
  getResult(@Query('projectId') projectId: string | undefined, @Headers() headers: HeaderBag) {
    return this.queryService.getResult(projectId, resolveRequestContext(headers));
  }
}

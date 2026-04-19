import { Body, Controller, Get, Headers, HttpCode, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { RatingQueryService } from './rating.query.service';
import { RatingWriteService } from './rating.write.service';

@Controller(['server/rating', 'api/app/rating'])
export class RatingController {
  constructor(
    private readonly queryService: RatingQueryService,
    private readonly writeService: RatingWriteService
  ) {}

  @Get('entry')
  getEntry(@Query('orderId') orderId: string | undefined, @Headers() headers: HeaderBag) {
    return this.queryService.getEntry(orderId, resolveRequestContext(headers));
  }

  @Post('submit')
  @HttpCode(202)
  submit(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.writeService.submit(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip
      })
    );
  }
}

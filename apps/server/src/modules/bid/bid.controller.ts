import { Body, Controller, Headers, HttpCode, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { BidWriteService } from './bid-write.service';

@Controller('server/bids')
export class BidController {
  constructor(private readonly writeService: BidWriteService) {}

  @Post()
  @HttpCode(202)
  submitBid(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.writeService.submitBid(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip
      })
    );
  }
}

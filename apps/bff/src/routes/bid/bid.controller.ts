import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { BidService } from './bid.service';

@Controller('bff/bid')
export class BidController {
  constructor(private readonly bidService: BidService) {}

  @Post('submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitBid(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.submitBid(payload, headers);
  }
}

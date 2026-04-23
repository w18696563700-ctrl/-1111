import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { MyBidService } from './my-bid.service';

@Controller('api/app/my/bids')
export class MyBidController {
  constructor(private readonly myBidService: MyBidService) {}

  @Get()
  getMyBids(
    @Query('state') state: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myBidService.getMyBids(state, headers);
  }
}

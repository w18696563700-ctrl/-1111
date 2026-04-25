import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { BidOrderSelectionService } from './bid-order-selection.service';

@Controller('api/app/bid')
export class AppBidOrderSelectionController {
  constructor(private readonly service: BidOrderSelectionService) {}

  @Post('select-bid-and-create-order')
  @HttpCode(HttpStatus.ACCEPTED)
  selectBidAndCreateOrder(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.selectBidAndCreateOrder(payload, headers);
  }
}

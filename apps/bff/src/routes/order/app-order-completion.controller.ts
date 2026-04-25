import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { OrderCompletionService } from './order-completion.service';

@Controller('api/app/order/complete')
export class AppOrderCompletionController {
  constructor(private readonly service: OrderCompletionService) {}

  @Post('request')
  @HttpCode(HttpStatus.ACCEPTED)
  requestCompletion(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.requestCompletion(payload, headers);
  }

  @Post('confirm')
  @HttpCode(HttpStatus.ACCEPTED)
  confirmCompletion(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.confirmCompletion(payload, headers);
  }

  @Post('reject')
  @HttpCode(HttpStatus.ACCEPTED)
  rejectCompletion(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.rejectCompletion(payload, headers);
  }
}

import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { RatingService } from './rating.service';

@Controller('bff/rating')
export class RatingController {
  constructor(private readonly service: RatingService) {}

  @Get('entry')
  getRatingEntry(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getRatingEntry(orderId, headers);
  }

  @Post('submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitRating(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.submitRating(payload, headers);
  }
}

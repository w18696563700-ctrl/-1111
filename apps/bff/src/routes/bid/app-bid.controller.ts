import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { BidService } from './bid.service';

@Controller('api/app/bid')
export class AppBidController {
  constructor(private readonly bidService: BidService) {}

  @Post('seat/lock')
  @HttpCode(HttpStatus.ACCEPTED)
  lockSeat(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.bidService.lockSeat(payload, headers, idempotencyKey);
  }

  @Post('seat/release')
  @HttpCode(HttpStatus.ACCEPTED)
  releaseSeat(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.bidService.releaseSeat(payload, headers, idempotencyKey);
  }

  @Get('seat/status')
  getSeatStatus(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.getSeatStatus(projectId, bidId, headers);
  }

  @Get('package-completeness')
  getPackageCompleteness(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.getPackageCompleteness(projectId, bidId, headers);
  }

  @Post('submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitBid(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.submitBid(payload, headers);
  }

  @Post('submission/supplement')
  @HttpCode(HttpStatus.ACCEPTED)
  supplementBidSubmission(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.supplementBidSubmission(payload, headers);
  }

  @Get('submission/snapshot')
  getBidSubmissionSnapshot(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.getBidSubmissionSnapshot(projectId, bidId, headers);
  }

  @Post('award')
  @HttpCode(HttpStatus.ACCEPTED)
  awardBid(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.awardBid(payload, headers);
  }

  @Get('result')
  getBidResult(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.bidService.getBidResult(projectId, headers);
  }
}

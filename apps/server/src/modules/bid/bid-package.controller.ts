import { Body, Controller, Get, Headers, HttpCode, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { BidPackageCompletenessQueryService } from './bid-package-completeness.query.service';
import { BidSeatService } from './bid-seat.service';

@Controller('server/bid')
export class BidPackageController {
  constructor(
    private readonly seatService: BidSeatService,
    private readonly completenessQueryService: BidPackageCompletenessQueryService
  ) {}

  @Post('seat/lock')
  @HttpCode(200)
  lockSeat(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.seatService.lock(body, resolveRequestContext(headers, this.readRequestMeta(request)));
  }

  @Post('seat/release')
  @HttpCode(200)
  releaseSeat(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.seatService.release(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Get('seat/status')
  @HttpCode(200)
  seatStatus(
    @Query() query: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.seatService.status(
      query,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Get('package-completeness')
  @HttpCode(200)
  packageCompleteness(
    @Query() query: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.completenessQueryService.getPackageCompleteness(
      query,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  private readRequestMeta(request: Request) {
    const forwardedFor = request.get('x-forwarded-for') ?? request.get('x-real-ip') ?? '';
    const remoteIp = forwardedFor
      .split(',')
      .map((item) => item.trim())
      .find(Boolean);
    return {
      remoteIp: remoteIp ?? request.ip,
      userAgent: request.get('user-agent') ?? ''
    };
  }
}

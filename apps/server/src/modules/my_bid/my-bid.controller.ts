import { Controller, Get, Headers, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MyBidQueryService } from './my-bid.query.service';

@Controller('server/my')
export class MyBidController {
  constructor(private readonly queryService: MyBidQueryService) {}

  @Get('bids')
  listMyBids(
    @Query('state') state: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.queryService.listMyBids(
      state,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }
}

@Controller('server')
export class BidSubmissionSnapshotController {
  constructor(private readonly queryService: MyBidQueryService) {}

  @Get('trading-im/bid/submission/snapshot')
  getTradingImSnapshot(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.queryService.getSubmissionSnapshot(
      { projectId, bidId },
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Get('bid/submission/snapshot')
  getCanonicalSnapshot(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.getTradingImSnapshot(projectId, bidId, headers, request);
  }
}

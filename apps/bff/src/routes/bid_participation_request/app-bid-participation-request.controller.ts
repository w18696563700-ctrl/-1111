import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { BidParticipationRequestService } from './bid-participation-request.service';

@Controller('api/app')
export class AppBidParticipationRequestController {
  constructor(private readonly service: BidParticipationRequestService) {}

  @Post('project/bid-participation/request')
  @HttpCode(HttpStatus.ACCEPTED)
  requestParticipation(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.requestParticipation(payload, headers);
  }

  @Get('project/bid-participation/thread/detail')
  getThreadDetail(
    @Query('threadId') threadId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getThreadDetail(threadId, headers);
  }

  @Get('my/projects/:projectId/bid-participation/pending')
  getPendingRequests(
    @Param('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getPendingRequests(projectId, headers);
  }

  @Post('my/projects/:projectId/bid-participation/:requestId/approve')
  @HttpCode(HttpStatus.ACCEPTED)
  approveRequest(
    @Param('projectId') projectId: string | undefined,
    @Param('requestId') requestId: string | undefined,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.approveRequest(projectId, requestId, payload, headers);
  }

  @Post('my/projects/:projectId/bid-participation/:requestId/reject')
  @HttpCode(HttpStatus.ACCEPTED)
  rejectRequest(
    @Param('projectId') projectId: string | undefined,
    @Param('requestId') requestId: string | undefined,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.rejectRequest(projectId, requestId, payload, headers);
  }
}

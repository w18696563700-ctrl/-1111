import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { BidParticipationRequestQueryService } from './bid-participation-request.query.service';
import { BidParticipationRequestWriteService } from './bid-participation-request.write.service';

@Controller('server')
export class BidParticipationRequestController {
  constructor(
    private readonly queryService: BidParticipationRequestQueryService,
    private readonly writeService: BidParticipationRequestWriteService,
  ) {}

  @Post('projects/bid-participation/request')
  @HttpCode(202)
  createRequest(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.createRequest(body, resolveRequestContext(headers));
  }

  @Get('projects/bid-participation/thread/detail')
  getThreadDetail(
    @Query('threadId') threadId: string | undefined,
    @Headers() headers: HeaderBag,
  ) {
    return this.queryService.getThreadDetail(threadId, resolveRequestContext(headers));
  }

  @Get('my/projects/:projectId/bid-participation/pending')
  listPendingRequests(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.queryService.listPendingRequests(projectId, resolveRequestContext(headers));
  }

  @Post('my/projects/:projectId/bid-participation/:requestId/approve')
  @HttpCode(202)
  approveRequest(
    @Param('projectId') projectId: string,
    @Param('requestId') requestId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.approveRequest(projectId, requestId, resolveRequestContext(headers));
  }

  @Post('my/projects/:projectId/bid-participation/:requestId/reject')
  @HttpCode(202)
  rejectRequest(
    @Param('projectId') projectId: string,
    @Param('requestId') requestId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.rejectRequest(projectId, requestId, resolveRequestContext(headers));
  }
}

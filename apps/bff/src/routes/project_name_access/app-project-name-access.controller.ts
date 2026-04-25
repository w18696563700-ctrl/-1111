import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectNameAccessService } from './project-name-access.service';

@Controller('api/app')
export class AppProjectNameAccessController {
  constructor(private readonly service: ProjectNameAccessService) {}

  @Post('project/name-access/request')
  @HttpCode(HttpStatus.ACCEPTED)
  requestAccess(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.requestAccess(payload, headers);
  }

  @Get('project/name-access/thread/detail')
  getThreadDetail(
    @Query('threadId') threadId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getThreadDetail(threadId, headers);
  }

  @Get('my/projects/:projectId/name-access/pending')
  getPendingRequests(
    @Param('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.getPendingRequests(projectId, headers);
  }

  @Post('my/projects/:projectId/name-access/:requestId/approve')
  @HttpCode(HttpStatus.ACCEPTED)
  approveRequest(
    @Param('projectId') projectId: string | undefined,
    @Param('requestId') requestId: string | undefined,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.approveRequest(projectId, requestId, payload, headers);
  }

  @Post('my/projects/:projectId/name-access/:requestId/reject')
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

import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectNameAccessQueryService } from './project-name-access.query.service';
import { ProjectNameAccessWriteService } from './project-name-access.write.service';

@Controller('server')
export class ProjectNameAccessController {
  constructor(
    private readonly queryService: ProjectNameAccessQueryService,
    private readonly writeService: ProjectNameAccessWriteService,
  ) {}

  @Post('projects/name-access/request')
  @HttpCode(202)
  createRequest(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.createRequest(body, resolveRequestContext(headers));
  }

  @Get('projects/name-access/thread/detail')
  getThreadDetail(
    @Query('threadId') threadId: string | undefined,
    @Headers() headers: HeaderBag,
  ) {
    return this.queryService.getThreadDetail(threadId, resolveRequestContext(headers));
  }

  @Get('my/projects/:projectId/name-access/pending')
  listPendingRequests(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.queryService.listPendingRequests(projectId, resolveRequestContext(headers));
  }

  @Post('my/projects/:projectId/name-access/:requestId/approve')
  @HttpCode(202)
  approveRequest(
    @Param('projectId') projectId: string,
    @Param('requestId') requestId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.approveRequest(projectId, requestId, resolveRequestContext(headers));
  }

  @Post('my/projects/:projectId/name-access/:requestId/reject')
  @HttpCode(202)
  rejectRequest(
    @Param('projectId') projectId: string,
    @Param('requestId') requestId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.rejectRequest(projectId, requestId, resolveRequestContext(headers));
  }
}

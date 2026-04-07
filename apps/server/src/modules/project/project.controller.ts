import { Body, Controller, Get, Headers, HttpCode, Param, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectQueryService } from './project-query.service';
import { ProjectWriteService } from './project-write.service';

@Controller('server/projects')
export class ProjectController {
  constructor(
    private readonly queryService: ProjectQueryService,
    private readonly writeService: ProjectWriteService
  ) {}

  @Get()
  listProjects(@Headers() headers: HeaderBag) {
    return this.queryService.listProjects(resolveRequestContext(headers));
  }

  @Post()
  @HttpCode(202)
  createProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.writeService.createProject(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip
      })
    );
  }

  @Get(':projectId')
  getProjectById(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.queryService.getProjectById(projectId, resolveRequestContext(headers));
  }
}

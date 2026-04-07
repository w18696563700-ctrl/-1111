import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectService } from './project.service';

@Controller('bff/project')
export class ProjectController {
  constructor(private readonly projectService: ProjectService) {}

  @Post('create')
  @HttpCode(HttpStatus.ACCEPTED)
  createProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.createProject(payload, headers);
  }

  @Get('detail')
  getProjectDetail(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.getProjectDetail(projectId, headers);
  }
}

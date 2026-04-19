import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectService } from './project.service';

@Controller('bff/project')
export class ProjectController {
  constructor(
    private readonly projectService: ProjectService,
    private readonly lifecycleService: ProjectLifecycleService
  ) {}

  @Get('list')
  getProjectList(
    @Query('provinceCode') provinceCode: string | undefined,
    @Query('cityCode') cityCode: string | undefined,
    @Query('areaBucket') areaBucket: string | undefined,
    @Query('budgetBucket') budgetBucket: string | undefined,
    @Query('page') page: string | undefined,
    @Query('pageSize') pageSize: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.getProjectList(headers, {
      provinceCode,
      cityCode,
      areaBucket,
      budgetBucket,
      page,
      pageSize,
    });
  }

  @Post('create')
  @HttpCode(HttpStatus.ACCEPTED)
  createProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.createProject(payload, headers);
  }

  @Get('edit/detail')
  getProjectEditDetail(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.getProjectEditDetail(projectId, headers);
  }

  @Post('save')
  @HttpCode(HttpStatus.ACCEPTED)
  saveProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.saveProject(payload, headers);
  }

  @Post('submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.submitProject(payload, headers);
  }

  @Post('publish')
  @HttpCode(HttpStatus.ACCEPTED)
  publishProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.publishProject(payload, headers);
  }

  @Post('withdraw')
  @HttpCode(HttpStatus.ACCEPTED)
  withdrawProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.withdrawProject(payload, headers);
  }

  @Post('archive')
  @HttpCode(HttpStatus.ACCEPTED)
  archiveProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.archiveProject(payload, headers);
  }

  @Post('close')
  @HttpCode(HttpStatus.ACCEPTED)
  closeProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.closeProject(payload, headers);
  }

  @Get('detail')
  getProjectDetail(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.getProjectDetail(projectId, headers);
  }
}

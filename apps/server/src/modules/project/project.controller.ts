import { Body, Controller, Delete, Get, Headers, HttpCode, Param, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectQueryService } from './project-query.service';
import { ProjectWriteService } from './project-write.service';

@Controller('server/projects')
export class ProjectController {
  constructor(
    private readonly queryService: ProjectQueryService,
    private readonly writeService: ProjectWriteService,
    private readonly lifecycleService: ProjectLifecycleService
  ) {}

  @Get()
  listProjects(
    @Query('provinceCode') provinceCode: string | undefined,
    @Query('cityCode') cityCode: string | undefined,
    @Query('areaBucket') areaBucket: string | undefined,
    @Query('budgetBucket') budgetBucket: string | undefined,
    @Query('page') page: string | undefined,
    @Query('pageSize') pageSize: string | undefined,
    @Headers() headers: HeaderBag
  ) {
    return this.queryService.listProjects(resolveRequestContext(headers), {
      provinceCode,
      cityCode,
      areaBucket,
      budgetBucket,
      page,
      pageSize
    });
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

  @Get(':projectId/edit')
  getEditableProjectById(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.queryService.getEditableProjectById(projectId, resolveRequestContext(headers));
  }

  @Post('save')
  @HttpCode(202)
  saveProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.saveProject(body, resolveRequestContext(headers));
  }

  @Post('submit')
  @HttpCode(202)
  submitProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.submitProject(body, resolveRequestContext(headers));
  }

  @Post('publish')
  @HttpCode(202)
  publishProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.publishProject(body, resolveRequestContext(headers));
  }

  @Post('withdraw')
  @HttpCode(202)
  withdrawProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.lifecycleService.withdrawProject(body, resolveRequestContext(headers));
  }

  @Post('archive')
  @HttpCode(202)
  archiveProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.lifecycleService.archiveProject(body, resolveRequestContext(headers));
  }

  @Post('close')
  @HttpCode(202)
  closeProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.lifecycleService.closeProject(body, resolveRequestContext(headers));
  }

  @Get(':projectId')
  getProjectById(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.queryService.getProjectById(projectId, resolveRequestContext(headers));
  }

  @Delete(':projectId')
  @HttpCode(202)
  deleteProject(
    @Param('projectId') projectId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.deleteProject(projectId, resolveRequestContext(headers));
  }
}

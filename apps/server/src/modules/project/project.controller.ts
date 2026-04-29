import { Body, Controller, Delete, Get, Headers, HttpCode, Param, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectExitGovernanceService } from './project-exit-governance.service';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectQueryService } from './project-query.service';
import { ProjectWriteService } from './project-write.service';

@Controller('server/projects')
export class ProjectController {
  constructor(
    private readonly queryService: ProjectQueryService,
    private readonly writeService: ProjectWriteService,
    private readonly lifecycleService: ProjectLifecycleService,
    private readonly exitGovernanceService: ProjectExitGovernanceService
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

  @Post('withdraw-published')
  @HttpCode(202)
  withdrawPublishedProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.withdrawPublishedProject(body, resolveRequestContext(headers));
  }

  @Post('discard-submitted')
  @HttpCode(202)
  discardSubmittedProject(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.discardSubmittedProject(body, resolveRequestContext(headers));
  }

  @Post('cancellation/request')
  @HttpCode(202)
  requestProjectCancellation(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.requestCancellation(body, resolveRequestContext(headers));
  }

  @Post('cancellation/respond')
  @HttpCode(202)
  respondProjectCancellation(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.respondCancellation(body, resolveRequestContext(headers));
  }

  @Post('breach/record-publisher')
  @HttpCode(202)
  recordPublisherBreach(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.recordPublisherBreach(body, resolveRequestContext(headers));
  }

  @Post('breach/record-factory')
  @HttpCode(202)
  recordFactoryBreach(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.exitGovernanceService.recordFactoryBreach(body, resolveRequestContext(headers));
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

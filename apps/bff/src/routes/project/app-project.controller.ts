import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectBidMaterialService } from './project-bid-material.service';
import { ProjectLifecycleService } from './project-lifecycle.service';
import { ProjectPublicResourceService } from './project-public-resource.service';
import { ProjectService } from './project.service';

@Controller('api/app/project')
export class AppProjectController {
  constructor(
    private readonly projectService: ProjectService,
    private readonly lifecycleService: ProjectLifecycleService,
    private readonly publicResourceService: ProjectPublicResourceService,
    private readonly bidMaterialService: ProjectBidMaterialService
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

  @Post('withdraw-published')
  @HttpCode(HttpStatus.ACCEPTED)
  withdrawPublishedProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.withdrawPublishedProject(payload, headers);
  }

  @Post('discard-submitted')
  @HttpCode(HttpStatus.ACCEPTED)
  discardSubmittedProject(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.discardSubmittedProject(payload, headers);
  }

  @Post('cancellation/request')
  @HttpCode(HttpStatus.ACCEPTED)
  requestProjectCancellation(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.requestCancellation(payload, headers);
  }

  @Post('cancellation/respond')
  @HttpCode(HttpStatus.ACCEPTED)
  respondProjectCancellation(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.respondCancellation(payload, headers);
  }

  @Post('breach/record-publisher')
  @HttpCode(HttpStatus.ACCEPTED)
  recordPublisherBreach(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.recordPublisherBreach(payload, headers);
  }

  @Post('breach/record-factory')
  @HttpCode(HttpStatus.ACCEPTED)
  recordFactoryBreach(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.lifecycleService.recordFactoryBreach(payload, headers);
  }

  @Get('detail')
  getProjectDetail(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.projectService.getProjectDetail(projectId, headers);
  }

  @Get('bid-materials')
  getProjectBidMaterials(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.bidMaterialService.getBidMaterials(projectId, headers);
  }

  @Get('public-resources')
  getPublicResources(@Headers() headers: IncomingHttpHeaders) {
    return this.publicResourceService.getPublicResources(headers);
  }
}

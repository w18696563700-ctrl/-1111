import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectCommunicationWorkbenchBffService } from './project-communication-workbench.service';

@Controller('api/app/message/project-communication/workbench')
export class ProjectCommunicationWorkbenchController {
  constructor(private readonly service: ProjectCommunicationWorkbenchBffService) {}

  @Get()
  getWorkbench(
    @Query('projectId') projectId: string | undefined,
    @Query('threadId') threadId: string | undefined,
    @Query('counterpartOrganizationId') counterpartOrganizationId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getWorkbench(projectId, threadId, counterpartOrganizationId, bidId, headers);
  }

  @Post('material-review')
  @HttpCode(HttpStatus.ACCEPTED)
  reviewMaterial(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.reviewMaterial(payload, headers);
  }
}

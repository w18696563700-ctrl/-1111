import { Body, Controller, Get, Headers, HttpCode, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectCommunicationWorkbenchService } from './project-communication-workbench.service';

@Controller('server/project-communication/workbench')
export class ProjectCommunicationWorkbenchController {
  constructor(private readonly workbenchService: ProjectCommunicationWorkbenchService) {}

  @Get()
  getWorkbench(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.workbenchService.getWorkbench(query, resolveRequestContext(headers));
  }

  @Post('material-review')
  @HttpCode(202)
  reviewMaterial(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.workbenchService.reviewMaterial(body, resolveRequestContext(headers));
  }
}

import { Body, Controller, Delete, Get, Headers, HttpCode, Param, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectAttachmentService } from './project-attachment.service';

@Controller('server/projects/:projectId/attachments')
export class ProjectAttachmentController {
  constructor(private readonly attachmentService: ProjectAttachmentService) {}

  @Get()
  list(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.attachmentService.list(projectId, resolveRequestContext(headers));
  }

  @Post()
  @HttpCode(202)
  bind(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.attachmentService.bind(projectId, body, resolveRequestContext(headers));
  }

  @Delete(':attachmentId')
  @HttpCode(202)
  remove(
    @Param('projectId') projectId: string,
    @Param('attachmentId') attachmentId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.attachmentService.remove(projectId, attachmentId, resolveRequestContext(headers));
  }
}

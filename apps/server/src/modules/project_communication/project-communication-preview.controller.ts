import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectCommunicationFilePreviewService } from './project-communication-file-preview.service';
import { ProjectCommunicationSoftLinkService } from './project-communication-softlink.service';

@Controller()
export class ProjectCommunicationPreviewController {
  constructor(
    private readonly filePreviewService: ProjectCommunicationFilePreviewService,
    private readonly softLinkService: ProjectCommunicationSoftLinkService
  ) {}

  @Get('server/file/preview/access')
  getFilePreviewAccess(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.filePreviewService.getPreviewAccess(query, resolveRequestContext(headers));
  }

  @Get('server/confirmation/softlink/detail')
  getConfirmationSoftLink(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.softLinkService.getSoftLink(query, resolveRequestContext(headers));
  }
}

import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectAttachmentFileAccessService } from './project-attachment-file-access.service';

@Controller('server/file')
export class ProjectAttachmentFileAccessController {
  constructor(private readonly accessService: ProjectAttachmentFileAccessService) {}

  @Get('access')
  getAccess(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.accessService.getAccess(query, resolveRequestContext(headers));
  }
}

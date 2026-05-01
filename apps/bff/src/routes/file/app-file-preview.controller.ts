import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { FilePreviewService } from './file-preview.service';

@Controller('api/app/file')
export class AppFilePreviewController {
  constructor(private readonly service: FilePreviewService) {}

  @Get('preview/access')
  getPreviewAccess(
    @Headers() headers: IncomingHttpHeaders,
    @Query('projectId') projectId?: string,
    @Query('threadId') threadId?: string,
    @Query('fileAssetId') fileAssetId?: string
  ) {
    return this.service.getPreviewAccess(headers, projectId, threadId, fileAssetId);
  }
}

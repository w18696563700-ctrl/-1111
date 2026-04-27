import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { FileService } from './file.service';

@Controller('api/app/file')
export class AppFileUploadController {
  constructor(private readonly fileService: FileService) {}

  @Post('upload/init')
  @HttpCode(HttpStatus.OK)
  initUpload(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.fileService.initUpload(payload, headers, idempotencyKey);
  }

  @Post('upload/confirm')
  @HttpCode(HttpStatus.OK)
  confirmUpload(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
    @Headers('x-idempotency-key') idempotencyKey?: string,
  ) {
    return this.fileService.confirmUpload(payload, headers, idempotencyKey);
  }

  @Get('access')
  getAccess(
    @Headers() headers: IncomingHttpHeaders,
    @Query('fileAssetId') fileAssetId?: string,
    @Query('mode') mode?: string,
    @Query('projectId') projectId?: string,
    @Query('accessScope') accessScope?: string,
  ) {
    return this.fileService.getAccess(headers, fileAssetId, mode, projectId, accessScope);
  }
}

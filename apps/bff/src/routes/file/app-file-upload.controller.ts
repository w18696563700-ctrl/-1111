import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
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
}

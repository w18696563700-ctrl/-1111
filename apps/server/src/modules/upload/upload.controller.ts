import { Body, Controller, Headers, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { UploadWriteService } from './upload-write.service';

@Controller('server/uploads')
export class UploadController {
  constructor(private readonly writeService: UploadWriteService) {}

  @Post('init')
  initUpload(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.initUpload(body, resolveRequestContext(headers));
  }

  @Post('confirm')
  confirmUpload(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.confirmUpload(body, resolveRequestContext(headers));
  }
}

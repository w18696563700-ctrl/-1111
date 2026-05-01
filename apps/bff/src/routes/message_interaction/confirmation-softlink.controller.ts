import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ConfirmationSoftLinkService } from './confirmation-softlink.service';

@Controller('api/app/confirmation')
export class ConfirmationSoftLinkController {
  constructor(private readonly service: ConfirmationSoftLinkService) {}

  @Get('softlink/detail')
  getSoftLink(
    @Query('projectId') projectId: string | undefined,
    @Query('threadId') threadId: string | undefined,
    @Query('messageId') messageId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getSoftLink(projectId, threadId, messageId, headers);
  }
}

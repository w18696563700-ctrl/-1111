import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  Post,
} from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { MyProjectAttachmentService } from './my-project-attachment.service';

@Controller('api/app/my/projects')
export class MyProjectAttachmentController {
  constructor(
    private readonly myProjectAttachmentService: MyProjectAttachmentService,
  ) {}

  @Get(':projectId/attachments')
  getAttachments(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myProjectAttachmentService.getAttachments(projectId, headers);
  }

  @Post(':projectId/attachments')
  @HttpCode(HttpStatus.OK)
  bindAttachment(
    @Param('projectId') projectId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myProjectAttachmentService.bindAttachment(
      projectId,
      payload,
      headers,
    );
  }

  @Delete(':projectId/attachments/:attachmentId')
  @HttpCode(HttpStatus.OK)
  deleteAttachment(
    @Param('projectId') projectId: string,
    @Param('attachmentId') attachmentId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myProjectAttachmentService.deleteAttachment(
      projectId,
      attachmentId,
      headers,
    );
  }
}

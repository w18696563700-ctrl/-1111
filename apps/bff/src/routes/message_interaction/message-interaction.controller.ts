import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { MessageInteractionService } from './message-interaction.service';

@Controller('api/app/message')
export class MessageInteractionController {
  constructor(private readonly service: MessageInteractionService) {}

  @Get('interactions')
  getInteractions(
    @Query('lane') lane: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getInteractions(lane, headers);
  }

  @Get('counterpart-conversation/detail')
  getCounterpartConversationDetail(
    @Query('conversationId') conversationId: string | undefined,
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getCounterpartConversationDetail(
      conversationId,
      projectId,
      headers
    );
  }

  @Get('project-communication/thread')
  getProjectCommunicationThread(
    @Query('projectId') projectId: string | undefined,
    @Query('counterpartOrganizationId') counterpartOrganizationId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getProjectCommunicationThread(
      projectId,
      counterpartOrganizationId,
      headers
    );
  }

  @Get('project-communication/messages')
  listProjectCommunicationMessages(
    @Query('threadId') threadId: string | undefined,
    @Query('projectId') projectId: string | undefined,
    @Query('cursor') cursor: string | undefined,
    @Query('limit') limit: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.listProjectCommunicationMessages(
      threadId,
      projectId,
      cursor,
      limit,
      headers
    );
  }

  @Post('project-communication/messages')
  @HttpCode(HttpStatus.ACCEPTED)
  sendProjectCommunicationMessage(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.sendProjectCommunicationMessage(payload, headers);
  }

  @Post('project-communication/read-cursor')
  @HttpCode(HttpStatus.ACCEPTED)
  markProjectCommunicationReadCursor(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.markProjectCommunicationReadCursor(payload, headers);
  }
}

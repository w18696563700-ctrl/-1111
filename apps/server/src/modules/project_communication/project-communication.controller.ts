import { Body, Controller, Get, Headers, HttpCode, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectCommunicationMessageService } from './project-communication-message.service';

@Controller('server/project-communication')
export class ProjectCommunicationController {
  constructor(private readonly messageService: ProjectCommunicationMessageService) {}

  @Get('thread')
  getOrCreateThread(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.messageService.getOrCreateThread(query, resolveRequestContext(headers));
  }

  @Get('messages')
  listMessages(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.messageService.listMessages(query, resolveRequestContext(headers));
  }

  @Get('realtime/events')
  listRealtimeEvents(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.messageService.listRealtimeEvents(query, resolveRequestContext(headers));
  }

  @Post('messages')
  @HttpCode(202)
  sendMessage(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.messageService.sendMessage(body, resolveRequestContext(headers));
  }

  @Post('read-cursor')
  @HttpCode(202)
  markRead(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.messageService.markRead(body, resolveRequestContext(headers));
  }
}

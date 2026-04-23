import { Controller, Get, Headers, Query } from '@nestjs/common';
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
}

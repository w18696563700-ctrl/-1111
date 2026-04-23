import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MessageInteractionQueryService } from './message-interaction.query.service';

@Controller('server/message')
export class MessageInteractionController {
  constructor(private readonly queryService: MessageInteractionQueryService) {}

  @Get('interactions')
  listInteractions(
    @Query('lane') lane: string | undefined,
    @Headers() headers: HeaderBag,
  ) {
    return this.queryService.listInteractions(lane, resolveRequestContext(headers));
  }
}

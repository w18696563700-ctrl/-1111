import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectCounterpartyRatingService } from './project-counterparty-rating.service';

@Controller('api/app/project-counterparty-rating')
export class AppProjectCounterpartyRatingController {
  constructor(private readonly service: ProjectCounterpartyRatingService) {}

  @Get('entry')
  getEntry(
    @Query('orderId') orderId: string | undefined,
    @Query('projectId') projectId: string | undefined,
    @Query('rateeOrganizationId') rateeOrganizationId: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.getEntry({ orderId, projectId, rateeOrganizationId }, headers);
  }

  @Post('submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submit(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.submit(payload, headers);
  }
}

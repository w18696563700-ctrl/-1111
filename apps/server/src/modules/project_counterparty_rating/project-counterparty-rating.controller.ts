import { Body, Controller, Get, Headers, HttpCode, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectCounterpartyRatingService } from './project-counterparty-rating.service';

@Controller('server/project-counterparty-rating')
export class ProjectCounterpartyRatingController {
  constructor(private readonly ratingService: ProjectCounterpartyRatingService) {}

  @Get('entry')
  getEntry(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.ratingService.getEntry(query, resolveRequestContext(headers));
  }

  @Post('submit')
  @HttpCode(202)
  submit(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.ratingService.submit(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip
      })
    );
  }
}

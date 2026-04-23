import { Body, Controller, Get, Headers, HttpCode, Post, Query, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { TradingImParticipantCardQueryService } from './trading-im-participant-card.query.service';
import { TradingImService } from './trading-im.service';

@Controller('server/trading-im')
export class TradingImController {
  constructor(
    private readonly service: TradingImService,
    private readonly participantCardQueryService: TradingImParticipantCardQueryService
  ) {}

  @Get('project/clarification/list')
  listClarifications(
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.service.listProjectClarifications(
      projectId,
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  @Post('project/clarification/create')
  @HttpCode(201)
  createClarification(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.service.createProjectClarification(
      body,
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  @Get('bid/thread/detail')
  getThreadDetail(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.service.getBidThreadDetail(
      { projectId, bidId },
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  @Get('bid/thread/participant-card')
  getParticipantCard(
    @Query('projectId') projectId: string | undefined,
    @Query('bidId') bidId: string | undefined,
    @Query('participantOrganizationId') participantOrganizationId: string | undefined,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.participantCardQueryService.getParticipantCard(
      { projectId, bidId, participantOrganizationId },
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  @Post('bid/thread/message/send')
  @HttpCode(201)
  sendThreadMessage(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.service.sendBidThreadMessage(
      body,
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  @Post('bid/thread/confirmation/create')
  @HttpCode(201)
  createConfirmation(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.service.createConfirmationCard(
      body,
      resolveRequestContext(headers, this.toRequestExtras(request))
    );
  }

  private toRequestExtras(request: Request) {
    return {
      userAgent: request.get('user-agent') ?? '',
      remoteIp: request.ip
    };
  }
}

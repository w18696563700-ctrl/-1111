import { Body, Controller, Get, Headers, HttpCode, Param, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { P0PayProjectBidServiceFeeAuthorizationService } from './p0-pay-project-bid-service-fee-authorization.service';

@Controller('server/projects/:projectId')
export class P0PayProjectPricingController {
  constructor(private readonly bidAuthorizationService: P0PayProjectBidServiceFeeAuthorizationService) {}

  @Post('bid-service-fee-authorizations')
  @HttpCode(201)
  createBidServiceFeeAuthorization(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.bidAuthorizationService.createAuthorization(
      projectId,
      body,
      this.context(headers, request)
    );
  }

  @Post('bid-service-fee-authorizations/:authorizationId/freeze-init')
  @HttpCode(202)
  initBidServiceFeeAuthorizationFreeze(
    @Param('projectId') projectId: string,
    @Param('authorizationId') authorizationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.bidAuthorizationService.initFreeze(
      projectId,
      authorizationId,
      body,
      this.context(headers, request)
    );
  }

  @Get('bid-service-fee-authorizations/:authorizationId')
  getBidServiceFeeAuthorization(
    @Param('projectId') projectId: string,
    @Param('authorizationId') authorizationId: string,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.bidAuthorizationService.getAuthorization(
      projectId,
      authorizationId,
      this.context(headers, request)
    );
  }

  private context(headers: HeaderBag, request: Request) {
    return resolveRequestContext(headers, {
      userAgent: request.get('user-agent') ?? '',
      remoteIp: request.ip,
    });
  }
}

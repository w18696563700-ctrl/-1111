import { Body, Controller, Headers, HttpCode, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { AdminSessionCarrierIssuerService } from './admin-session-carrier-issuer.service';

@Controller('server/admin/auth')
export class AdminSessionCarrierIssuerController {
  constructor(private readonly issuerService: AdminSessionCarrierIssuerService) {}

  @Post('session-carrier/issue')
  @HttpCode(200)
  issueSessionCarrier(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.issuerService.issueWithPassword(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  private readRequestMeta(request: Request) {
    const forwardedFor = request.get('x-forwarded-for') ?? request.get('x-real-ip') ?? '';
    const remoteIp = forwardedFor
      .split(',')
      .map((item) => item.trim())
      .find(Boolean);
    return {
      remoteIp: remoteIp ?? request.ip,
      userAgent: request.get('user-agent') ?? ''
    };
  }
}

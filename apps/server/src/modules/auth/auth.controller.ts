import { Body, Controller, Headers, HttpCode, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { AuthOtpService } from './auth-otp.service';
import { AuthSessionService } from './auth-session.service';
import { AuthPasswordService } from './auth-password.service';
import { AuthWhitelistTestSessionService } from './auth-whitelist-test-session.service';

@Controller('server/auth')
export class AuthController {
  constructor(
    private readonly otpService: AuthOtpService,
    private readonly sessionService: AuthSessionService,
    private readonly passwordService: AuthPasswordService,
    private readonly whitelistTestSessionService: AuthWhitelistTestSessionService
  ) {}

  @Post('otp/send')
  @HttpCode(200)
  sendOtp(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.otpService.send(body, resolveRequestContext(headers, this.readRequestMeta(request)));
  }

  @Post('otp/login')
  @HttpCode(200)
  login(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.sessionService.login(body, resolveRequestContext(headers, this.readRequestMeta(request)));
  }

  @Post('refresh')
  @HttpCode(200)
  refresh(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.sessionService.refresh(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Post('whitelist-test-session')
  @HttpCode(200)
  issueWhitelistTestSession(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.whitelistTestSessionService.issue(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Post('logout')
  @HttpCode(200)
  logout(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.sessionService.logout(body, resolveRequestContext(headers, this.readRequestMeta(request)));
  }

  @Post('password/login')
  @HttpCode(200)
  passwordLogin(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.passwordService.login(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Post('password/set')
  @HttpCode(200)
  passwordSet(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.passwordService.set(
      body,
      resolveRequestContext(headers, this.readRequestMeta(request))
    );
  }

  @Post('password/reset')
  @HttpCode(200)
  passwordReset(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request
  ) {
    return this.passwordService.reset(
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

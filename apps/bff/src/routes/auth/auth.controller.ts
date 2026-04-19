import { Body, Controller, Headers, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthService } from './auth.service';

@Controller('api/app/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('otp/send')
  @HttpCode(HttpStatus.OK)
  sendOtp(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.sendOtp(payload, headers);
  }

  @Post('otp/login')
  @HttpCode(HttpStatus.OK)
  loginWithOtp(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.loginWithOtp(payload, headers);
  }

  @Post('password/login')
  @HttpCode(HttpStatus.OK)
  loginWithPassword(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.loginWithPassword(payload, headers);
  }

  @Post('password/set')
  @HttpCode(HttpStatus.OK)
  setPassword(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.setPassword(payload, headers);
  }

  @Post('password/reset')
  @HttpCode(HttpStatus.OK)
  resetPassword(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.resetPassword(payload, headers);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refreshSession(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.refreshSession(payload, headers);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.authService.logout(payload, headers);
  }
}

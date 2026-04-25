import { Body, Controller, Headers, HttpCode, Post, Req } from '@nestjs/common';
import type { Request } from 'express';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectOrderCompletionService } from './project-order-completion.service';

@Controller('server/order/complete')
export class ProjectOrderCompletionController {
  constructor(private readonly completionService: ProjectOrderCompletionService) {}

  @Post('request')
  @HttpCode(202)
  requestCompletion(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.completionService.requestCompletion(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('confirm')
  @HttpCode(202)
  confirmCompletion(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.completionService.confirmCompletion(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }

  @Post('reject')
  @HttpCode(202)
  rejectCompletion(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
    @Req() request: Request,
  ) {
    return this.completionService.rejectCompletion(
      body,
      resolveRequestContext(headers, {
        userAgent: request.get('user-agent') ?? '',
        remoteIp: request.ip,
      }),
    );
  }
}

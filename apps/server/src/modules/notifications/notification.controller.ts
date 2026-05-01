import { Body, Controller, Get, Headers, HttpCode, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { NotificationService } from './notification.service';

@Controller('server/notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post('device-token/register')
  @HttpCode(200)
  registerDeviceToken(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.notificationService.registerDeviceToken(body, resolveRequestContext(headers));
  }

  @Get('list')
  listNotifications(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.notificationService.listNotifications(query, resolveRequestContext(headers));
  }

  @Post('read')
  @HttpCode(200)
  markRead(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.notificationService.markRead(body, resolveRequestContext(headers));
  }
}

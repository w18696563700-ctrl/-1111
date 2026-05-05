import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { NotificationRouteService } from './notification.service';

@Controller('api/app/notifications')
export class AppNotificationController {
  constructor(private readonly service: NotificationRouteService) {}

  @Post('device-token/register')
  @HttpCode(HttpStatus.OK)
  registerDeviceToken(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.service.registerDeviceToken(payload, headers);
  }

  @Get('list')
  listNotifications(
    @Query('pageSize') pageSize: string | undefined,
    @Query('cursor') cursor: string | undefined,
    @Query('source') source: string | undefined,
    @Query('lane') lane: string | undefined,
    @Headers() headers: IncomingHttpHeaders
  ) {
    return this.service.listNotifications({ pageSize, cursor, source, lane }, headers);
  }

  @Post('read')
  @HttpCode(HttpStatus.OK)
  markRead(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.service.markRead(payload, headers);
  }
}

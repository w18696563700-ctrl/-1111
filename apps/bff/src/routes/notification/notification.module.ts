import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppNotificationController } from './app-notification.controller';
import { NotificationRouteService } from './notification.service';

@Module({
  imports: [CoreModule],
  controllers: [AppNotificationController],
  providers: [NotificationRouteService]
})
export class NotificationRouteModule {}

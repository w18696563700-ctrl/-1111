import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ProjectCommunicationThreadEntity } from '../project_communication/entities/project-communication-thread.entity';
import { AppNotificationEntity } from './entities/app-notification.entity';
import { DevicePushTokenEntity } from './entities/device-push-token.entity';
import { PushDeliveryAttemptEntity } from './entities/push-delivery-attempt.entity';
import { NotificationController } from './notification.controller';
import { NotificationPresenter } from './notification.presenter';
import { NotificationService } from './notification.service';

@Module({
  imports: [
    AuthModule,
    TypeOrmModule.forFeature([
      AppNotificationEntity,
      DevicePushTokenEntity,
      PushDeliveryAttemptEntity,
      ProjectCommunicationThreadEntity
    ])
  ],
  controllers: [NotificationController],
  providers: [NotificationPresenter, NotificationService],
  exports: [NotificationService]
})
export class NotificationModule {}

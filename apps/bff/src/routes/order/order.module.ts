import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppOrderCompletionController } from './app-order-completion.controller';
import { OrderCompletionErrorService } from './order-completion.error.service';
import { OrderCompletionService } from './order-completion.service';

@Module({
  imports: [CoreModule],
  controllers: [AppOrderCompletionController],
  providers: [OrderCompletionService, OrderCompletionErrorService],
})
export class OrderRouteModule {}

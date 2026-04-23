import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { MessageInteractionController } from './message-interaction.controller';
import { MessageInteractionService } from './message-interaction.service';

@Module({
  imports: [CoreModule],
  controllers: [MessageInteractionController],
  providers: [MessageInteractionService]
})
export class MessageInteractionModule {}

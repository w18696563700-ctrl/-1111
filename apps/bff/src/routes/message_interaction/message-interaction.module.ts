import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { MessageInteractionController } from './message-interaction.controller';
import { MessageInteractionService } from './message-interaction.service';
import { ProjectCommunicationRealtimeGateway } from './project-communication-realtime.gateway';

@Module({
  imports: [CoreModule],
  controllers: [MessageInteractionController],
  providers: [MessageInteractionService, ProjectCommunicationRealtimeGateway]
})
export class MessageInteractionModule {}

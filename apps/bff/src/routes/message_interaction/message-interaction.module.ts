import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { ConfirmationSoftLinkController } from './confirmation-softlink.controller';
import { MessageInteractionController } from './message-interaction.controller';
import { ProjectCommunicationWorkbenchController } from './project-communication-workbench.controller';
import { ConfirmationSoftLinkService } from './confirmation-softlink.service';
import { MessageInteractionService } from './message-interaction.service';
import { ProjectCommunicationWorkbenchBffService } from './project-communication-workbench.service';
import { ProjectCommunicationRealtimeGateway } from './project-communication-realtime.gateway';

@Module({
  imports: [CoreModule],
  controllers: [
    MessageInteractionController,
    ProjectCommunicationWorkbenchController,
    ConfirmationSoftLinkController
  ],
  providers: [
    MessageInteractionService,
    ProjectCommunicationWorkbenchBffService,
    ConfirmationSoftLinkService,
    ProjectCommunicationRealtimeGateway
  ]
})
export class MessageInteractionModule {}

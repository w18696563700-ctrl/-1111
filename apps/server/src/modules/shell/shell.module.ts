import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { MembershipModule } from '../membership/membership.module';
import { MessageInteractionModule } from '../message_interaction/message-interaction.module';
import { OrganizationModule } from '../organization/organization.module';
import { PrivateOperatingSystemReorganizationModule } from '../private_operating_system_reorganization/private-operating-system-reorganization.module';
import { ProjectCommunicationModule } from '../project_communication/project-communication.module';
import { UploadModule } from '../upload/upload.module';
import { ShellController } from './shell.controller';
import { ShellPresenter } from './shell.presenter';
import { ShellQueryService } from './shell-query.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    MembershipModule,
    MessageInteractionModule,
    PrivateOperatingSystemReorganizationModule,
    ProjectCommunicationModule,
    UploadModule
  ],
  controllers: [ShellController],
  providers: [ShellPresenter, ShellQueryService]
})
export class ShellModule {}

import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { TemplateConfigAdminController } from './template-config-admin.controller';
import { TemplateConfigAdminService } from './template-config-admin.service';
import { TemplateConfigPresenter } from './template-config.presenter';
import { TemplateConfigStore } from './template-config.store';

@Module({
  imports: [AuthModule, OrganizationModule],
  controllers: [TemplateConfigAdminController],
  providers: [TemplateConfigStore, TemplateConfigPresenter, TemplateConfigAdminService]
})
export class TemplateConfigModule {}

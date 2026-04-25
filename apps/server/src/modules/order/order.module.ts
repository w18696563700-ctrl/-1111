import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectOrderEntity } from './entities/project-order.entity';
import { ProjectOrderCompletionController } from './project-order-completion.controller';
import { ProjectOrderCompletionPresenter } from './project-order-completion.presenter';
import { ProjectOrderCompletionService } from './project-order-completion.service';
import { ProjectOrderService } from './project-order.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectOrderEntity, IdentityAuditLogEntity]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [ProjectOrderCompletionController],
  providers: [
    ProjectOrderCompletionPresenter,
    ProjectOrderCompletionService,
    ProjectOrderService,
  ],
  exports: [ProjectOrderCompletionService, ProjectOrderService],
})
export class OrderModule {}

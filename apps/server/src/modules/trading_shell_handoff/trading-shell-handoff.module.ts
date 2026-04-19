import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { TradingShellHandoffController } from './trading-shell-handoff.controller';
import { TradingShellHandoffPresenter } from './trading-shell-handoff.presenter';
import { TradingShellHandoffService } from './trading-shell-handoff.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectEntity]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [TradingShellHandoffController],
  providers: [TradingShellHandoffPresenter, TradingShellHandoffService],
})
export class TradingShellHandoffModule {}

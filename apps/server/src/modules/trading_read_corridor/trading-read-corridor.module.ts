import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { TradingReadCorridorController } from './trading-read-corridor.controller';
import { TradingReadCorridorPresenter } from './trading-read-corridor.presenter';
import { TradingReadCorridorQueryService } from './trading-read-corridor.query.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectEntity]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [TradingReadCorridorController],
  providers: [TradingReadCorridorPresenter, TradingReadCorridorQueryService],
})
export class TradingReadCorridorModule {}

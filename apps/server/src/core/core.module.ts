import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { RuntimeConfigService } from './runtime-config.service';

@Module({
  controllers: [HealthController],
  providers: [RuntimeConfigService, HealthService],
  exports: [RuntimeConfigService]
})
export class CoreModule {}

import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { RuntimeConfigService } from './runtime-config.service';
import { ServerMigrationRunnerService } from './server-migration-runner.service';

@Module({
  controllers: [HealthController],
  providers: [RuntimeConfigService, HealthService, ServerMigrationRunnerService],
  exports: [RuntimeConfigService]
})
export class CoreModule {}

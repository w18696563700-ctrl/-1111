import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { RedisClientService } from './redis-client.service';
import { RuntimeConfigService } from './runtime-config.service';
import { ServerMigrationRunnerService } from './server-migration-runner.service';

@Module({
  controllers: [HealthController],
  providers: [
    RuntimeConfigService,
    HealthService,
    RedisClientService,
    ServerMigrationRunnerService,
  ],
  exports: [RuntimeConfigService, RedisClientService],
})
export class CoreModule {}

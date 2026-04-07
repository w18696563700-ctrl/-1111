import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { AuthContextService } from './auth/auth-context.service';
import { ErrorNormalizerService } from './errors/error-normalizer.service';
import { HealthController } from './health/health.controller';
import { HealthService } from './health/health.service';
import { ServerClientService } from './http/server-client.service';
import { IdempotencyService } from './idempotency/idempotency.service';
import { RuntimeConfigService } from './runtime/runtime-config.service';

@Module({
  imports: [HttpModule],
  controllers: [HealthController],
  providers: [
    RuntimeConfigService,
    ServerClientService,
    IdempotencyService,
    AuthContextService,
    ErrorNormalizerService,
    HealthService,
  ],
  exports: [
    RuntimeConfigService,
    ServerClientService,
    IdempotencyService,
    AuthContextService,
    ErrorNormalizerService,
  ],
})
export class CoreModule {}

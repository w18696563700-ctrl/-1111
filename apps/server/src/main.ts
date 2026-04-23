import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { RuntimeConfigService } from './core/runtime-config.service';
import { assertServerRuntimeBoundary } from './core/runtime-startup.guard';

async function bootstrap() {
  const config = new RuntimeConfigService();
  assertServerRuntimeBoundary(config);
  const app = await NestFactory.create(AppModule, { cors: true });
  await app.listen(config.port, '0.0.0.0');
}

void bootstrap();

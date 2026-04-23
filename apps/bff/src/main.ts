import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { RuntimeConfigService } from './core/runtime/runtime-config.service';
import { assertBffRuntimeBoundary } from './core/runtime/runtime-startup.guard';

async function bootstrap() {
  const config = new RuntimeConfigService();
  assertBffRuntimeBoundary(config);
  const app = await NestFactory.create(AppModule, { cors: true });
  await app.listen(config.port, '0.0.0.0');
}

void bootstrap();

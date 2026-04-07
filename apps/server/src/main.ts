import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { RuntimeConfigService } from './core/runtime-config.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  const config = app.get(RuntimeConfigService);
  await app.listen(config.port, '0.0.0.0');
}

void bootstrap();

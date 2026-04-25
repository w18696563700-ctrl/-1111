import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { RuntimeConfigService } from './core/runtime/runtime-config.service';
import { assertBffRuntimeBoundary } from './core/runtime/runtime-startup.guard';
import { ProjectCommunicationRealtimeGateway } from './routes/message_interaction/project-communication-realtime.gateway';

async function bootstrap() {
  const config = new RuntimeConfigService();
  assertBffRuntimeBoundary(config);
  const app = await NestFactory.create(AppModule, { cors: true });
  app.get(ProjectCommunicationRealtimeGateway).attach(app.getHttpServer());
  await app.listen(config.port, '0.0.0.0');
}

void bootstrap();

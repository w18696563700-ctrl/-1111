import { Module } from '@nestjs/common';
import { CoreModule } from './core/core.module';
import { RoutesModule } from './routes/routes.module';

@Module({
  imports: [CoreModule, RoutesModule],
})
export class AppModule {}

import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppProjectController } from './app-project.controller';
import { ProjectController } from './project.controller';
import { ProjectService } from './project.service';

@Module({
  imports: [CoreModule],
  controllers: [ProjectController, AppProjectController],
  providers: [ProjectService],
})
export class ProjectModule {}

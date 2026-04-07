import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { MyProjectController } from './my-project.controller';
import { MyProjectService } from './my-project.service';

@Module({
  imports: [CoreModule],
  controllers: [MyProjectController],
  providers: [MyProjectService],
})
export class MyProjectModule {}


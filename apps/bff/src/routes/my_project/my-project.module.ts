import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { MyProjectAttachmentController } from './my-project-attachment.controller';
import { MyProjectAttachmentService } from './my-project-attachment.service';
import { MyProjectController } from './my-project.controller';
import { MyProjectService } from './my-project.service';

@Module({
  imports: [CoreModule],
  controllers: [MyProjectController, MyProjectAttachmentController],
  providers: [MyProjectService, MyProjectAttachmentService],
})
export class MyProjectModule {}

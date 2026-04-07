import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { ForumCommandContextService } from '../forum/forum-command-context.service';
import { AppFileUploadController } from './app-file-upload.controller';
import { FileService } from './file.service';
import { FileUploadController } from './file-upload.controller';

@Module({
  imports: [CoreModule],
  controllers: [FileUploadController, AppFileUploadController],
  providers: [FileService, ForumCommandContextService],
})
export class FileUploadModule {}

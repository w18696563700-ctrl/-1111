import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { ForumCommandContextService } from '../forum/forum-command-context.service';
import { AppFilePreviewController } from './app-file-preview.controller';
import { AppFileUploadController } from './app-file-upload.controller';
import { FilePreviewService } from './file-preview.service';
import { FileService } from './file.service';
import { FileUploadController } from './file-upload.controller';

@Module({
  imports: [CoreModule],
  controllers: [FileUploadController, AppFileUploadController, AppFilePreviewController],
  providers: [FileService, FilePreviewService, ForumCommandContextService],
})
export class FileUploadModule {}

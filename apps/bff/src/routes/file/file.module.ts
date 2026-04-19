import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { ForumCommandContextService } from '../forum/forum-command-context.service';
import { AppFileUploadController } from './app-file-upload.controller';
import { FileController } from './file.controller';
import { FileService } from './file.service';

@Module({
  imports: [CoreModule],
  controllers: [FileController, AppFileUploadController],
  providers: [FileService, ForumCommandContextService],
})
export class FileModule {}

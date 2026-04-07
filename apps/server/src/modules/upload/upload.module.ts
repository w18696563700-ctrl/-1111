import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { ProjectPublishAuditModule } from '../audit/project-publish-audit.module';
import { AuthModule } from '../auth/auth.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';
import { UploadController } from './upload.controller';
import { UploadPresenter } from './upload.presenter';
import { UploadPublicUrlService } from './upload-public-url.service';
import { UploadStorageService } from './upload-storage.service';
import { UploadWriteService } from './upload-write.service';

@Module({
  imports: [
    CoreModule,
    AuthModule,
    TypeOrmModule.forFeature([UploadSessionEntity, FileAssetEntity, ProjectEntity]),
    ProjectPublishAuditModule
  ],
  controllers: [UploadController],
  providers: [UploadPresenter, UploadStorageService, UploadPublicUrlService, UploadWriteService],
  exports: [UploadPublicUrlService]
})
export class UploadModule {}

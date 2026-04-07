import { Injectable } from '@nestjs/common';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';

@Injectable()
export class UploadPresenter {
  toInitResponse(session: UploadSessionEntity) {
    return {
      uploadSessionId: session.id,
      directUpload: {
        url: session.directUploadUrl,
        method: session.directUploadMethod,
        headers: session.directUploadHeaders ?? {}
      },
      confirm: {
        endpoint: '/server/uploads/confirm'
      }
    };
  }

  toConfirmResponse(fileAsset: FileAssetEntity) {
    return {
      fileAssetId: fileAsset.id
    };
  }
}

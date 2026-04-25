import { Injectable } from '@nestjs/common';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';

@Injectable()
export class CounterpartConversationAvatarService {
  constructor(private readonly avatarUrlService: UploadPublicUrlService) {}

  async readAvatarUrl(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(normalized)) ?? normalized;
  }
}

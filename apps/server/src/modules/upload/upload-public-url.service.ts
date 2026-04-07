import { Injectable } from '@nestjs/common';
import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { RuntimeConfigService } from '../../core/runtime-config.service';

@Injectable()
export class UploadPublicUrlService {
  constructor(private readonly config: RuntimeConfigService) {}

  buildObjectUrl(objectKey: string) {
    const endpoint = this.config.uploadS3PublicEndpoint.trim();
    const bucket = this.config.uploadBucket.trim();
    const normalizedKey = this.normalizeObjectKey(objectKey);
    if (!endpoint || !bucket || !normalizedKey) {
      return null;
    }

    const encodedBucket = encodeURIComponent(bucket);
    const encodedKey = normalizedKey
      .split('/')
      .map((segment) => encodeURIComponent(segment))
      .join('/');
    const baseUrl = new URL(endpoint);

    if (this.config.uploadS3ForcePathStyle) {
      const pathnameBase = baseUrl.pathname.replace(/\/+$/, '');
      baseUrl.pathname = `${pathnameBase}/${encodedBucket}/${encodedKey}`.replace(/\/{2,}/g, '/');
      return baseUrl.toString();
    }

    baseUrl.hostname = `${bucket}.${baseUrl.hostname}`;
    baseUrl.pathname = `/${encodedKey}`;
    return baseUrl.toString();
  }

  async buildObjectAccessUrl(objectKey: string) {
    const normalizedKey = this.normalizeObjectKey(objectKey);
    if (!normalizedKey) {
      return null;
    }
    try {
      const command = new GetObjectCommand({
        Bucket: this.config.uploadBucket,
        Key: normalizedKey
      });
      return await getSignedUrl(this.createPresignClient(), command, {
        expiresIn: this.config.uploadSignedUrlExpiresSeconds
      });
    } catch {
      return null;
    }
  }

  async buildAccessUrlFromObjectUrl(objectUrl: string | null) {
    const objectKey = this.extractObjectKeyFromUrl(objectUrl);
    if (!objectKey) {
      return null;
    }
    return this.buildObjectAccessUrl(objectKey);
  }

  private normalizeObjectKey(objectKey: string) {
    const normalized = objectKey.trim().replace(/^\/+/, '');
    return normalized ? normalized : null;
  }

  private extractObjectKeyFromUrl(objectUrl: string | null) {
    const normalizedUrl = objectUrl?.trim() ?? '';
    if (!normalizedUrl) {
      return null;
    }
    try {
      const url = new URL(normalizedUrl);
      const bucket = this.config.uploadBucket.trim();
      const endpoint = new URL(this.config.uploadS3PublicEndpoint);
      const endpointHost = endpoint.hostname.toLowerCase();
      const avatarHost = `${bucket}.${endpointHost}`;
      const path = decodeURIComponent(url.pathname.replace(/^\/+/, ''));
      if (url.hostname.toLowerCase() === avatarHost) {
        return this.normalizeObjectKey(path);
      }
      if (path.startsWith(`${bucket}/`)) {
        return this.normalizeObjectKey(path.slice(bucket.length + 1));
      }
      return this.normalizeObjectKey(path);
    } catch {
      return this.normalizeObjectKey(normalizedUrl);
    }
  }

  private createPresignClient() {
    return new S3Client({
      endpoint: this.config.uploadS3PublicEndpoint,
      region: this.config.uploadS3Region,
      forcePathStyle: this.config.uploadS3ForcePathStyle,
      credentials: {
        accessKeyId: this.config.uploadS3AccessKeyId,
        secretAccessKey: this.config.uploadS3SecretAccessKey
      }
    });
  }
}

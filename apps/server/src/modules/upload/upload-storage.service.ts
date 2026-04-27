import { HeadObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { UploadSessionEntity } from './entities/upload-session.entity';
import { uploadInitInvalid, uploadSessionMissingFileAssetTruth } from './upload.errors';

type BuildDirectiveInput = {
  sessionId: string;
  businessType: string;
  fileKind: string;
  mimeType: string;
  checksum: string;
};

type UploadDirective = {
  objectKey: string;
  directUploadUrl: string;
  directUploadMethod: string;
  directUploadHeaders: Record<string, string>;
};

@Injectable()
export class UploadStorageService {
  constructor(private readonly config: RuntimeConfigService) {}

  async buildDirective(input: BuildDirectiveInput) {
    this.ensureSigningConfig();
    const publicEndpoint = this.ensureExternallyReachablePublicEndpoint();
    const objectKey = this.buildObjectKey(input.businessType, input.fileKind, input.mimeType);
    const directUploadHeaders = this.buildUploadHeaders(input);
    const signedHeaderNames = this.buildSignedHeaderNames(directUploadHeaders);
    const command = new PutObjectCommand({
      Bucket: this.config.uploadBucket,
      Key: objectKey,
      ContentType: input.mimeType,
      Metadata: this.buildObjectMetadata(input)
    });
    const directUploadUrl = await getSignedUrl(this.createPresignClient(publicEndpoint), command, {
      expiresIn: this.config.uploadSignedUrlExpiresSeconds,
      signableHeaders: signedHeaderNames,
      unhoistableHeaders: this.buildUnhoistableHeaderNames(signedHeaderNames)
    });

    return {
      objectKey,
      directUploadUrl,
      directUploadMethod: 'PUT',
      directUploadHeaders
    } satisfies UploadDirective;
  }

  async verifyTransportObject(session: UploadSessionEntity) {
    this.ensureSigningConfig();
    try {
      const result = await this.createTransportClient().send(
        new HeadObjectCommand({
          Bucket: this.config.uploadBucket,
          Key: session.objectKey
        })
      );
      const contentLength = result.ContentLength ?? null;
      const contentType = result.ContentType ?? null;
      const metadata = result.Metadata ?? {};
      if (contentLength !== session.size) {
        throw uploadSessionMissingFileAssetTruth('Upload transport object content length does not match upload session.');
      }
      if (contentType !== session.mimeType) {
        throw uploadSessionMissingFileAssetTruth('Upload transport object content type does not match upload session.');
      }
      if (metadata['checksum-sha256'] !== session.checksum) {
        throw uploadSessionMissingFileAssetTruth('Upload transport object checksum metadata does not match upload session.');
      }
      if (metadata['upload-session-id'] !== session.id) {
        throw uploadSessionMissingFileAssetTruth('Upload transport object upload session metadata does not match upload session.');
      }
      if (metadata['business-type'] !== session.businessType || metadata['file-kind'] !== session.fileKind) {
        throw uploadSessionMissingFileAssetTruth('Upload transport object binding metadata does not match upload session.');
      }
    } catch (error) {
      if (this.isControlledUploadError(error)) {
        throw error;
      }
      throw uploadSessionMissingFileAssetTruth('Upload transport object does not exist for upload confirm.');
    }
  }

  private buildObjectKey(businessType: string, fileKind: string, mimeType: string) {
    const now = new Date();
    const year = now.getUTCFullYear();
    const month = `${now.getUTCMonth() + 1}`.padStart(2, '0');
    const suffix = randomUUID().replace(/-/g, '');
    const extension = this.fileExtensionFromMimeType(mimeType);
    return `${businessType}/${fileKind}/${year}/${month}/${suffix}.${extension}`;
  }

  private buildUploadHeaders(input: BuildDirectiveInput) {
    return {
      'Content-Type': input.mimeType,
      'x-amz-meta-checksum-sha256': input.checksum,
      'x-amz-meta-upload-session-id': input.sessionId,
      'x-amz-meta-business-type': input.businessType,
      'x-amz-meta-file-kind': input.fileKind
    };
  }

  private buildObjectMetadata(input: BuildDirectiveInput) {
    return {
      'checksum-sha256': input.checksum,
      'upload-session-id': input.sessionId,
      'business-type': input.businessType,
      'file-kind': input.fileKind
    };
  }

  private buildSignedHeaderNames(headers: Record<string, string>) {
    return new Set(Object.keys(headers).map((header) => header.toLowerCase()));
  }

  private buildUnhoistableHeaderNames(headers: Set<string>) {
    return new Set(Array.from(headers).filter((header) => header.startsWith('x-amz-')));
  }

  private createPresignClient(endpoint: string) {
    return new S3Client({
      endpoint,
      region: this.config.uploadS3Region,
      forcePathStyle: this.config.uploadS3ForcePathStyle,
      credentials: {
        accessKeyId: this.config.uploadS3AccessKeyId,
        secretAccessKey: this.config.uploadS3SecretAccessKey
      }
    });
  }

  private createTransportClient() {
    return new S3Client({
      endpoint: this.config.uploadS3Endpoint,
      region: this.config.uploadS3Region,
      forcePathStyle: this.config.uploadS3ForcePathStyle,
      credentials: {
        accessKeyId: this.config.uploadS3AccessKeyId,
        secretAccessKey: this.config.uploadS3SecretAccessKey
      }
    });
  }

  private ensureSigningConfig() {
    if (!this.config.uploadBucket) {
      throw uploadInitInvalid('Upload transport bucket config is incomplete.');
    }
    if (!this.config.uploadS3AccessKeyId || !this.config.uploadS3SecretAccessKey) {
      throw uploadInitInvalid('Upload transport signing config is incomplete.');
    }
  }

  private ensureExternallyReachablePublicEndpoint() {
    const endpoint = this.config.uploadS3PublicEndpoint.trim();
    if (!endpoint) {
      throw uploadInitInvalid('Upload public endpoint config is missing.');
    }
    const parsed = new URL(endpoint);
    const host = parsed.hostname.trim().toLowerCase();
    if (host === '127.0.0.1' || host === 'localhost' || host === '::1') {
      throw uploadInitInvalid('Upload public endpoint must not use loopback host.');
    }
    return endpoint;
  }

  private fileExtensionFromMimeType(mimeType: string) {
    if (mimeType === 'image/png') return 'png';
    if (mimeType === 'image/jpeg') return 'jpg';
    if (mimeType === 'image/webp') return 'webp';
    if (mimeType === 'image/gif') return 'gif';
    if (mimeType === 'image/heic' || mimeType === 'image/heif') return 'heic';
    if (mimeType === 'application/pdf') return 'pdf';
    if (mimeType === 'application/msword') return 'doc';
    if (mimeType === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return 'docx';
    }
    if (mimeType === 'application/vnd.ms-excel') return 'xls';
    if (mimeType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return 'xlsx';
    }
    if (mimeType === 'text/csv' || mimeType === 'application/csv') return 'csv';
    return 'bin';
  }

  private isControlledUploadError(error: unknown) {
    return typeof error === 'object' && error !== null && 'getStatus' in error;
  }
}

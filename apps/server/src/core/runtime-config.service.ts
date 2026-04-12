import { Injectable } from '@nestjs/common';

@Injectable()
export class RuntimeConfigService {
  get appName() {
    return process.env.APP_NAME ?? 'exhibition-server';
  }

  get nodeEnv() {
    return process.env.NODE_ENV ?? 'development';
  }

  get isProduction() {
    return this.nodeEnv === 'production';
  }

  get isIsolatedRuntime() {
    return this.appName.toLowerCase().includes('isolated');
  }

  get allowsIsolatedAuthWhitelist() {
    return !this.isProduction || this.isIsolatedRuntime;
  }

  get port() {
    return Number.parseInt(process.env.PORT ?? '3001', 10);
  }

  get postgresHost() {
    return process.env.POSTGRES_HOST ?? '127.0.0.1';
  }

  get postgresPort() {
    return Number.parseInt(process.env.POSTGRES_PORT ?? '5432', 10);
  }

  get postgresDatabase() {
    return process.env.POSTGRES_DB ?? 'exhibition_app';
  }

  get postgresUser() {
    return process.env.POSTGRES_USER ?? 'exhibition';
  }

  get postgresPassword() {
    return process.env.POSTGRES_PASSWORD ?? 'exhibition_dev';
  }

  get minioPort() {
    return Number.parseInt(process.env.MINIO_PORT ?? '9000', 10);
  }

  get uploadBucket() {
    return process.env.UPLOAD_BUCKET ?? 'exhibition-uploads';
  }

  get uploadS3Endpoint() {
    return process.env.UPLOAD_S3_ENDPOINT ?? `http://127.0.0.1:${this.minioPort}`;
  }

  get uploadS3PublicEndpoint() {
    return process.env.UPLOAD_S3_PUBLIC_ENDPOINT ?? process.env.UPLOAD_DIRECT_BASE_URL ?? '';
  }

  get uploadS3Region() {
    return process.env.UPLOAD_S3_REGION ?? 'us-east-1';
  }

  get uploadS3AccessKeyId() {
    return process.env.UPLOAD_S3_ACCESS_KEY_ID ?? process.env.MINIO_ROOT_USER ?? '';
  }

  get uploadS3SecretAccessKey() {
    return process.env.UPLOAD_S3_SECRET_ACCESS_KEY ?? process.env.MINIO_ROOT_PASSWORD ?? '';
  }

  get uploadS3ForcePathStyle() {
    const value = process.env.UPLOAD_S3_FORCE_PATH_STYLE ?? 'true';
    return value === 'true' || value === '1';
  }

  get uploadSignedUrlExpiresSeconds() {
    return Number.parseInt(process.env.UPLOAD_SIGNED_URL_EXPIRES_SECONDS ?? '900', 10);
  }

  get aliyunSmsAccessKeyId() {
    return process.env.ALIYUN_SMS_ACCESS_KEY_ID ?? '';
  }

  get aliyunSmsAccessKeySecret() {
    return process.env.ALIYUN_SMS_ACCESS_KEY_SECRET ?? '';
  }

  get aliyunSmsRegionId() {
    return process.env.ALIYUN_SMS_REGION_ID ?? 'cn-hangzhou';
  }

  get aliyunSmsEndpoint() {
    return process.env.ALIYUN_SMS_ENDPOINT ?? '';
  }

  get aliyunSmsSignName() {
    return process.env.ALIYUN_SMS_SIGN_NAME ?? '';
  }

  get aliyunSmsTemplateCode() {
    return process.env.ALIYUN_SMS_TEMPLATE_CODE ?? '';
  }

  get aliyunSmsConnectTimeoutMs() {
    return Number.parseInt(process.env.ALIYUN_SMS_CONNECT_TIMEOUT_MS ?? '5000', 10);
  }

  get aliyunSmsReadTimeoutMs() {
    return Number.parseInt(process.env.ALIYUN_SMS_READ_TIMEOUT_MS ?? '10000', 10);
  }

  get authAccessTokenSecret() {
    return process.env.AUTH_ACCESS_TOKEN_SECRET ?? '';
  }

  get sessionSigningSecret() {
    return process.env.SESSION_SIGNING_SECRET ?? '';
  }

  get sessionOpaqueVerifierSecret() {
    return process.env.SESSION_OPAQUE_VERIFIER_SECRET ?? '';
  }

  get jwtAccessTokenSecret() {
    return process.env.JWT_ACCESS_TOKEN_SECRET ?? '';
  }

  get jwtRefreshTokenSecret() {
    return process.env.JWT_REFRESH_TOKEN_SECRET ?? '';
  }

  get sessionRefreshTokenPepper() {
    return process.env.SESSION_REFRESH_TOKEN_PEPPER ?? '';
  }

  get otpTestWhitelistEnabled() {
    return this.allowsIsolatedAuthWhitelist && this.readBoolean(process.env.OTP_TEST_WHITELIST_ENABLED);
  }

  get otpTestWhitelistMobiles() {
    return this.readCsv(process.env.OTP_TEST_WHITELIST_MOBILES);
  }

  get authDevOtpEnabled() {
    return this.allowsIsolatedAuthWhitelist && this.readBoolean(process.env.AUTH_DEV_OTP_ENABLED);
  }

  get authDevOtpCode() {
    return process.env.AUTH_DEV_OTP_CODE ?? '';
  }

  get authDevLoginWhitelistEnabled() {
    return this.allowsIsolatedAuthWhitelist && this.readBoolean(process.env.AUTH_DEV_LOGIN_WHITELIST_ENABLED);
  }

  get authDevLoginWhitelistMobile() {
    return process.env.AUTH_DEV_LOGIN_WHITELIST_MOBILE ?? '';
  }

  get authDevLoginWhitelistCode() {
    return process.env.AUTH_DEV_LOGIN_WHITELIST_CODE ?? '';
  }

  get authPublicOtpSendEnabled() {
    return this.readBoolean(process.env.AUTH_PUBLIC_OTP_SEND_ENABLED);
  }

  private readBoolean(value: string | undefined) {
    return value === 'true' || value === '1';
  }

  private readCsv(value: string | undefined) {
    return (value ?? '')
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean);
  }
}

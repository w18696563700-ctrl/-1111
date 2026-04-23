import { Injectable } from '@nestjs/common';

@Injectable()
export class RuntimeConfigService {
  get appName() {
    return process.env.APP_NAME ?? 'exhibition-server';
  }

  get nodeEnv() {
    return process.env.NODE_ENV ?? 'development';
  }

  get runtimeEntryLabel() {
    return process.env.RUNTIME_ENTRY_LABEL?.trim() || 'default';
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

  get redisEnabled() {
    const raw = process.env.REDIS_ENABLED;
    if (raw == null) {
      return true;
    }
    return this.readBoolean(raw);
  }

  get redisHost() {
    return process.env.REDIS_HOST ?? '127.0.0.1';
  }

  get redisPort() {
    return Number.parseInt(process.env.REDIS_PORT ?? '6379', 10);
  }

  get redisDatabase() {
    return Number.parseInt(process.env.REDIS_DB ?? '0', 10);
  }

  get redisPassword() {
    return process.env.REDIS_PASSWORD ?? '';
  }

  get redisUrl() {
    if (process.env.REDIS_URL?.trim()) {
      return process.env.REDIS_URL.trim();
    }

    const credentials = this.redisPassword
      ? `:${encodeURIComponent(this.redisPassword)}@`
      : '';
    return `redis://${credentials}${this.redisHost}:${this.redisPort}/${this.redisDatabase}`;
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

  get amapWebServiceEnabled() {
    return this.readBoolean(process.env.AMAP_WEB_SERVICE_ENABLED);
  }

  get amapWebServiceKey() {
    return process.env.AMAP_WEB_SERVICE_KEY ?? '';
  }

  get amapWebServiceBaseUrl() {
    return process.env.AMAP_WEB_SERVICE_BASE_URL ?? 'https://restapi.amap.com';
  }

  get amapWebServiceTimeoutMs() {
    return Number.parseInt(process.env.AMAP_WEB_SERVICE_TIMEOUT_MS ?? '5000', 10);
  }

  get qweatherEnabled() {
    return this.readBoolean(process.env.QWEATHER_ENABLED);
  }

  get qweatherApiHost() {
    return process.env.QWEATHER_API_HOST ?? 'https://devapi.qweather.com';
  }

  get qweatherApiKey() {
    return process.env.QWEATHER_API_KEY ?? '';
  }

  get qweatherTimeoutMs() {
    return Number.parseInt(process.env.QWEATHER_TIMEOUT_MS ?? '5000', 10);
  }

  get qweatherLanguage() {
    return process.env.QWEATHER_LANG ?? 'zh-hans';
  }

  get qweatherUnit() {
    return process.env.QWEATHER_UNIT ?? 'm';
  }

  get weatherCacheGeoTtlSeconds() {
    return Number.parseInt(process.env.WEATHER_CACHE_GEO_TTL_SECONDS ?? '86400', 10);
  }

  get weatherCacheCurrentTtlSeconds() {
    return Number.parseInt(process.env.WEATHER_CACHE_CURRENT_TTL_SECONDS ?? '600', 10);
  }

  get weatherCacheHourlyTtlSeconds() {
    return Number.parseInt(process.env.WEATHER_CACHE_HOURLY_TTL_SECONDS ?? '1800', 10);
  }

  get weatherCacheDailyTtlSeconds() {
    return Number.parseInt(process.env.WEATHER_CACHE_DAILY_TTL_SECONDS ?? '3600', 10);
  }

  get weatherCacheAlertTtlSeconds() {
    return Number.parseInt(process.env.WEATHER_CACHE_ALERT_TTL_SECONDS ?? '600', 10);
  }

  get aliyunOcrEnabled() {
    return this.readBoolean(process.env.ALIYUN_OCR_ENABLED);
  }

  get aliyunOcrAccessKeyId() {
    return process.env.ALIYUN_OCR_ACCESS_KEY_ID ?? '';
  }

  get aliyunOcrAccessKeySecret() {
    return process.env.ALIYUN_OCR_ACCESS_KEY_SECRET ?? '';
  }

  get aliyunOcrRegionId() {
    return process.env.ALIYUN_OCR_REGION_ID ?? 'cn-hangzhou';
  }

  get aliyunOcrEndpoint() {
    return process.env.ALIYUN_OCR_ENDPOINT ?? 'ocr-api.cn-hangzhou.aliyuncs.com';
  }

  get aliyunOcrConnectTimeoutMs() {
    return Number.parseInt(process.env.ALIYUN_OCR_CONNECT_TIMEOUT_MS ?? '5000', 10);
  }

  get aliyunOcrReadTimeoutMs() {
    return Number.parseInt(process.env.ALIYUN_OCR_READ_TIMEOUT_MS ?? '10000', 10);
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

  get authUserAgreementVersion() {
    return process.env.AUTH_USER_AGREEMENT_VERSION ?? 'v0.1-draft';
  }

  get authPrivacyPolicyVersion() {
    return process.env.AUTH_PRIVACY_POLICY_VERSION ?? 'v0.1-draft';
  }

  get authPasswordPepper() {
    return process.env.AUTH_PASSWORD_PEPPER ?? '';
  }

  get authWhitelistTestSessionEnabled() {
    return this.allowsIsolatedAuthWhitelist && this.readBoolean(process.env.AUTH_WHITELIST_TEST_SESSION_ENABLED);
  }

  get authWhitelistTestSessionMobiles() {
    return this.readCsv(process.env.AUTH_WHITELIST_TEST_SESSION_MOBILES);
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

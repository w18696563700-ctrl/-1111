import { Injectable } from '@nestjs/common';

function parsePositiveInt(value: string | undefined, fallback: number): number {
  const parsed = Number.parseInt(value ?? '', 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function parseBoolean(value: string | undefined, fallback: boolean): boolean {
  if (!value) {
    return fallback;
  }
  const normalized = value.trim().toLowerCase();
  if (normalized === '1' || normalized === 'true' || normalized === 'yes' || normalized === 'on') {
    return true;
  }
  if (normalized === '0' || normalized === 'false' || normalized === 'no' || normalized === 'off') {
    return false;
  }
  return fallback;
}

@Injectable()
export class RuntimeConfigService {
  get appName(): string {
    return process.env.APP_NAME?.trim() || 'exhibition-bff';
  }

  get nodeEnv(): string {
    return process.env.NODE_ENV?.trim() || 'development';
  }

  get isProduction(): boolean {
    return this.nodeEnv === 'production';
  }

  get runtimeEntryLabel(): string {
    return process.env.RUNTIME_ENTRY_LABEL?.trim() || 'default';
  }

  get port(): number {
    return parsePositiveInt(process.env.PORT, 3000);
  }

  get serverBaseUrl(): string {
    return process.env.SERVER_BASE_URL?.trim() || 'http://127.0.0.1:3001';
  }

  get hasExplicitServerBaseUrl(): boolean {
    return Boolean(process.env.SERVER_BASE_URL?.trim());
  }

  get serverGetTimeoutMs(): number {
    return parsePositiveInt(process.env.SERVER_GET_TIMEOUT_MS, 5000);
  }

  get serverPostTimeoutMs(): number {
    return parsePositiveInt(process.env.SERVER_POST_TIMEOUT_MS, 10000);
  }

  get serverKeepAliveEnabled(): boolean {
    return parseBoolean(process.env.SERVER_KEEPALIVE_ENABLED, true);
  }

  get serverMaxSockets(): number {
    return parsePositiveInt(process.env.SERVER_MAX_SOCKETS, 256);
  }

  get serverMaxFreeSockets(): number {
    return parsePositiveInt(process.env.SERVER_MAX_FREE_SOCKETS, 64);
  }

  get authWhitelistTestSessionEnabled(): boolean {
    return parseBoolean(process.env.AUTH_WHITELIST_TEST_SESSION_ENABLED, false);
  }
}

import { Logger } from '@nestjs/common';
import { RuntimeConfigService } from './runtime-config.service';

type HostKind = 'loopback' | 'private' | 'public' | 'invalid';

function readExplicitEnv(name: string): string | null {
  const value = process.env[name]?.trim();
  return value ? value : null;
}

function classifyHost(hostname: string): HostKind {
  const host = hostname.trim().toLowerCase();
  if (!host) {
    return 'invalid';
  }
  if (host === '127.0.0.1' || host === 'localhost' || host === '::1') {
    return 'loopback';
  }
  if (
    /^10\./.test(host) ||
    /^192\.168\./.test(host) ||
    /^172\.(1[6-9]|2\d|3[0-1])\./.test(host)
  ) {
    return 'private';
  }
  return 'public';
}

function classifyUrlHost(value: string, allowedProtocols: string[]): HostKind {
  try {
    const parsed = new URL(value);
    if (!allowedProtocols.includes(parsed.protocol)) {
      return 'invalid';
    }
    return classifyHost(parsed.hostname);
  } catch {
    return 'invalid';
  }
}

function isCompiledRuntime(): boolean {
  const entrypoint = (process.argv[1] ?? '').replace(/\\/g, '/');
  return /(^|\/)dist(\/|$)/.test(entrypoint);
}

export function assertServerRuntimeBoundary(
  config: RuntimeConfigService,
  logger = new Logger('ServerBootstrap'),
) {
  const bootSurface = isCompiledRuntime() ? 'compiled' : 'dev';
  const strictRuntime = bootSurface === 'compiled' || config.isProduction;
  const missing: string[] = [];

  const postgresSource = readExplicitEnv('POSTGRES_HOST') ? 'env' : 'implicit_default';
  const postgresHostKind = classifyHost(config.postgresHost);

  const redisSource = config.redisEnabled
    ? readExplicitEnv('REDIS_URL') || readExplicitEnv('REDIS_HOST')
      ? 'env'
      : 'implicit_default'
    : 'disabled';
  const redisHostKind = !config.redisEnabled
    ? 'disabled'
    : readExplicitEnv('REDIS_URL')
      ? classifyUrlHost(config.redisUrl, ['redis:', 'rediss:'])
      : classifyHost(config.redisHost);

  const uploadEndpointSource = readExplicitEnv('UPLOAD_S3_ENDPOINT') ? 'env' : 'implicit_default';
  const uploadEndpointHostKind = classifyUrlHost(config.uploadS3Endpoint, ['http:', 'https:']);
  const uploadPublicSource = readExplicitEnv('UPLOAD_S3_PUBLIC_ENDPOINT')
    ? 'env'
    : 'implicit_default';
  const uploadPublicHostKind = config.uploadS3PublicEndpoint.trim()
    ? classifyUrlHost(config.uploadS3PublicEndpoint, ['http:', 'https:'])
    : 'missing';

  if (postgresHostKind === 'invalid') {
    throw new Error(`Refusing to start Server with invalid POSTGRES_HOST: ${config.postgresHost}`);
  }
  if (config.redisEnabled && redisHostKind === 'invalid') {
    throw new Error('Refusing to start Server with invalid Redis runtime target.');
  }
  if (uploadEndpointHostKind === 'invalid') {
    throw new Error(
      `Refusing to start Server with invalid UPLOAD_S3_ENDPOINT: ${config.uploadS3Endpoint}`,
    );
  }
  if (uploadPublicHostKind === 'invalid') {
    throw new Error(
      `Refusing to start Server with invalid UPLOAD_S3_PUBLIC_ENDPOINT: ${config.uploadS3PublicEndpoint}`,
    );
  }
  if (strictRuntime && !config.isIsolatedRuntime && uploadPublicHostKind === 'loopback') {
    throw new Error(
      'Refusing to start compiled/production Server with loopback UPLOAD_S3_PUBLIC_ENDPOINT.',
    );
  }

  if (strictRuntime) {
    if (!readExplicitEnv('POSTGRES_HOST')) missing.push('POSTGRES_HOST');
    if (!readExplicitEnv('POSTGRES_DB')) missing.push('POSTGRES_DB');
    if (!readExplicitEnv('POSTGRES_USER')) missing.push('POSTGRES_USER');
    if (!readExplicitEnv('POSTGRES_PASSWORD')) missing.push('POSTGRES_PASSWORD');
    if (config.redisEnabled && !readExplicitEnv('REDIS_URL') && !readExplicitEnv('REDIS_HOST')) {
      missing.push('REDIS_URL or REDIS_HOST');
    }
    if (!readExplicitEnv('UPLOAD_S3_ENDPOINT')) missing.push('UPLOAD_S3_ENDPOINT');
    if (!config.isIsolatedRuntime && !readExplicitEnv('UPLOAD_S3_PUBLIC_ENDPOINT')) {
      missing.push('UPLOAD_S3_PUBLIC_ENDPOINT');
    }
    if (!readExplicitEnv('UPLOAD_BUCKET')) missing.push('UPLOAD_BUCKET');
    if (!readExplicitEnv('UPLOAD_S3_ACCESS_KEY_ID') && !readExplicitEnv('MINIO_ROOT_USER')) {
      missing.push('UPLOAD_S3_ACCESS_KEY_ID or MINIO_ROOT_USER');
    }
    if (!readExplicitEnv('UPLOAD_S3_SECRET_ACCESS_KEY') && !readExplicitEnv('MINIO_ROOT_PASSWORD')) {
      missing.push('UPLOAD_S3_SECRET_ACCESS_KEY or MINIO_ROOT_PASSWORD');
    }
  }

  if (missing.length > 0) {
    throw new Error(
      `Refusing to start compiled/production Server with implicit runtime fallbacks. ` +
        `Set explicit values for: ${missing.join(', ')}.`,
    );
  }

  const message =
    `runtime_boundary service=${config.appName} runtime_entry=${config.runtimeEntryLabel} ` +
    `boot_surface=${bootSurface} node_env=${config.nodeEnv} ` +
    `postgres=${config.postgresUser}@${config.postgresHost}:${config.postgresPort}/${config.postgresDatabase} ` +
    `postgres_source=${postgresSource} postgres_host_kind=${postgresHostKind} ` +
    `redis=${config.redisEnabled ? config.redisUrl : 'disabled'} redis_source=${redisSource} ` +
    `redis_host_kind=${redisHostKind} upload_transport=${config.uploadS3Endpoint} ` +
    `upload_transport_source=${uploadEndpointSource} upload_transport_host_kind=${uploadEndpointHostKind} ` +
    `upload_public=${config.uploadS3PublicEndpoint || 'missing'} upload_public_source=${uploadPublicSource} ` +
    `upload_public_host_kind=${uploadPublicHostKind}`;

  if (
    postgresSource === 'implicit_default' ||
    redisSource === 'implicit_default' ||
    uploadEndpointSource === 'implicit_default' ||
    uploadPublicSource === 'implicit_default'
  ) {
    logger.warn(message);
    return;
  }

  logger.log(message);
}

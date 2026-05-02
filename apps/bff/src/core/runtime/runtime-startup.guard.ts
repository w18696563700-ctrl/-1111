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

function classifyUrlHost(value: string): HostKind {
  try {
    const parsed = new URL(value);
    if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
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

export function assertBffRuntimeBoundary(
  config: RuntimeConfigService,
  logger = new Logger('BffBootstrap'),
) {
  const explicitServerBaseUrl = readExplicitEnv('SERVER_BASE_URL');
  const upstreamSource = explicitServerBaseUrl ? 'env' : 'implicit_default';
  const upstreamHostKind = classifyUrlHost(config.serverBaseUrl);
  const bootSurface = isCompiledRuntime() ? 'compiled' : 'dev';

  if (upstreamHostKind === 'invalid') {
    throw new Error(
      `Refusing to start BFF with invalid SERVER_BASE_URL: ${config.serverBaseUrl}`,
    );
  }

  if ((bootSurface === 'compiled' || config.isProduction) && !explicitServerBaseUrl) {
    throw new Error(
      'Refusing to start compiled/production BFF with implicit SERVER_BASE_URL fallback. ' +
        'Set SERVER_BASE_URL explicitly, including http://127.0.0.1:3001 if cloud-host loopback is intentional.',
    );
  }

  const message =
    `runtime_boundary service=${config.appName} runtime_entry=${config.runtimeEntryLabel} ` +
    `boot_surface=${bootSurface} node_env=${config.nodeEnv} ` +
    `server_upstream=${config.serverBaseUrl} server_upstream_source=${upstreamSource} ` +
    `server_upstream_host_kind=${upstreamHostKind}`;

  if (upstreamSource === 'implicit_default') {
    logger.warn(message);
    return;
  }

  logger.log(message);
}

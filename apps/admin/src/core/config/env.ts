import {
  getFormalCloudServerAdminBaseUrl,
  isConfiguredFormalCloudServerAdminBaseUrl
} from './formal-cloud-target';

const DEFAULT_SERVER_ADMIN_API_ENTRY_MODE = 'cloud';
const DEFAULT_LOGIN_MODE = 'server_session_carrier_only';

type ServerAdminApiKnownEntryMode = 'cloud' | 'ssh_tunnel' | 'local_dev';
type ServerAdminApiEntryMode = ServerAdminApiKnownEntryMode | 'custom';

let hasLoggedServerConfig = false;

export function getServerConfig() {
  const configuredBaseUrl = readEnv('SERVER_ADMIN_API_BASE_URL');
  const requestedEntryMode = parseServerAdminApiEntryMode(
    readEnv('SERVER_ADMIN_API_ENTRY_MODE')
  );
  if (requestedEntryMode === 'custom' && !configuredBaseUrl) {
    throw new Error(
      'SERVER_ADMIN_API_ENTRY_MODE=custom requires SERVER_ADMIN_API_BASE_URL.'
    );
  }

  const defaultedEntryMode =
    requestedEntryMode == null || requestedEntryMode === 'custom'
      ? DEFAULT_SERVER_ADMIN_API_ENTRY_MODE
      : requestedEntryMode;
  const resolvedBaseUrl =
    configuredBaseUrl ?? resolveServerAdminApiBaseUrl(defaultedEntryMode);
  const resolvedEntryMode =
    configuredBaseUrl == null
      ? defaultedEntryMode
      : inferServerAdminApiEntryMode(resolvedBaseUrl);
  if (
    configuredBaseUrl &&
    requestedEntryMode &&
    requestedEntryMode !== 'custom' &&
    requestedEntryMode !== resolvedEntryMode
  ) {
    throw new Error(
      `SERVER_ADMIN_API_ENTRY_MODE=${requestedEntryMode} conflicts with SERVER_ADMIN_API_BASE_URL=${resolvedBaseUrl}.`
    );
  }

  const config = {
    serverAdminApiBaseUrl: resolvedBaseUrl,
    serverAdminApiEntryMode: resolvedEntryMode,
    serverAdminApiConnectionLabel:
      toServerAdminApiConnectionLabel(resolvedEntryMode),
    loginMode: readEnv('NEXT_PUBLIC_ADMIN_LOGIN_MODE') ?? DEFAULT_LOGIN_MODE
  };
  logServerConfigOnce(config, configuredBaseUrl ? 'explicit_base_url' : 'mode');
  return config;
}

export function getClientConfig() {
  return {
    loginMode: readEnv('NEXT_PUBLIC_ADMIN_LOGIN_MODE') ?? DEFAULT_LOGIN_MODE
  };
}

function readEnv(name: string) {
  const value = process.env[name]?.trim();
  return value ? value : null;
}

function parseServerAdminApiEntryMode(
  raw: string | null
): ServerAdminApiEntryMode | null {
  switch (raw) {
    case 'cloud':
    case 'ssh_tunnel':
    case 'local_dev':
    case 'custom':
      return raw;
    default:
      return null;
  }
}

function inferServerAdminApiEntryMode(
  baseUrl: string
): ServerAdminApiEntryMode {
  try {
    if (isConfiguredFormalCloudServerAdminBaseUrl(baseUrl)) {
      return 'cloud';
    }

    const url = new URL(baseUrl);
    const host = url.hostname.toLowerCase();
    const port = url.port || null;
    if ((host === '127.0.0.1' || host === 'localhost') && port === '8080') {
      return 'ssh_tunnel';
    }
    if (host === '127.0.0.1' || host === 'localhost') {
      return 'local_dev';
    }
  } catch {
    return 'custom';
  }
  return 'custom';
}

function resolveServerAdminApiBaseUrl(entryMode: ServerAdminApiKnownEntryMode) {
  switch (entryMode) {
    case 'cloud':
      return getFormalCloudServerAdminBaseUrl();
    case 'ssh_tunnel':
      return 'http://127.0.0.1:8080/server/admin';
    case 'local_dev':
      return 'http://127.0.0.1:3001/server/admin';
  }
}

function toServerAdminApiConnectionLabel(entryMode: ServerAdminApiEntryMode) {
  switch (entryMode) {
    case 'cloud':
      return '正式云端';
    case 'ssh_tunnel':
      return 'SSH隧道';
    case 'local_dev':
      return '本地开发';
    case 'custom':
      return '自定义入口';
  }
}

function logServerConfigOnce(
  config: ReturnType<typeof getServerConfig>,
  source: 'explicit_base_url' | 'mode'
) {
  if (hasLoggedServerConfig || process.env.NODE_ENV === 'test') {
    return;
  }
  hasLoggedServerConfig = true;
  console.info(
    `[admin-env] Server Admin API ${config.serverAdminApiEntryMode} (${config.serverAdminApiConnectionLabel}) -> ${config.serverAdminApiBaseUrl} [source=${source}]`
  );
}

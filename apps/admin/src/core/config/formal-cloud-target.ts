type FormalCloudSettingName =
  | 'FORMAL_CLOUD_ORIGIN'
  | 'FORMAL_CLOUD_SCHEME'
  | 'FORMAL_CLOUD_HOST'
  | 'FORMAL_CLOUD_PORT'
  | 'FORMAL_CLOUD_SERVER_ADMIN_BASE_URL';

export function getFormalCloudServerAdminBaseUrl() {
  const configuredBaseUrl = readFormalCloudSetting(
    'FORMAL_CLOUD_SERVER_ADMIN_BASE_URL'
  );
  if (configuredBaseUrl) {
    return stripTrailingSlash(configuredBaseUrl);
  }

  return `${getFormalCloudOrigin()}/server/admin`;
}

export function isConfiguredFormalCloudServerAdminBaseUrl(baseUrl: string) {
  return (
    normalizeBaseUrl(baseUrl) === normalizeBaseUrl(getFormalCloudServerAdminBaseUrl())
  );
}

function getFormalCloudOrigin() {
  const configuredOrigin = readFormalCloudSetting('FORMAL_CLOUD_ORIGIN');
  if (configuredOrigin) {
    return stripTrailingSlash(configuredOrigin);
  }

  const scheme = readFormalCloudSetting('FORMAL_CLOUD_SCHEME') ?? 'http';
  const host = readFormalCloudSetting('FORMAL_CLOUD_HOST');
  const port = readFormalCloudSetting('FORMAL_CLOUD_PORT');
  if (!host) {
    throw new Error(
      'Formal cloud target is not configured. Update infra/env/formal_cloud_target.env or set FORMAL_CLOUD_HOST / FORMAL_CLOUD_ORIGIN.'
    );
  }

  return port ? `${scheme}://${host}:${port}` : `${scheme}://${host}`;
}

function readFormalCloudSetting(name: FormalCloudSettingName) {
  return readProcessEnv(name);
}

function readProcessEnv(name: FormalCloudSettingName) {
  const value = process.env[name]?.trim();
  return value ? value : null;
}

function stripTrailingSlash(value: string) {
  return value.replace(/\/+$/u, '');
}

function normalizeBaseUrl(value: string) {
  return stripTrailingSlash(value.trim().toLowerCase());
}

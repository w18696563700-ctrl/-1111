/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

test('admin env defaults login mode to server_session_carrier_only', () => {
  const previousFormalCloudHost = process.env.FORMAL_CLOUD_HOST;
  const previousApiBaseUrl = process.env.SERVER_ADMIN_API_BASE_URL;
  const previousApiEntryMode = process.env.SERVER_ADMIN_API_ENTRY_MODE;
  const previous = process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE;
  process.env.FORMAL_CLOUD_HOST = 'formal-cloud.test';
  delete process.env.SERVER_ADMIN_API_BASE_URL;
  delete process.env.SERVER_ADMIN_API_ENTRY_MODE;
  delete process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE;

  delete require.cache[require.resolve('../test-dist/core/config/env.js')];
  const env = require('../test-dist/core/config/env.js');

  assert.equal(
    env.getServerConfig().serverAdminApiBaseUrl,
    'http://formal-cloud.test/server/admin'
  );
  assert.equal(env.getServerConfig().serverAdminApiEntryMode, 'cloud');
  assert.equal(env.getServerConfig().loginMode, 'server_session_carrier_only');
  assert.equal(env.getClientConfig().loginMode, 'server_session_carrier_only');

  if (previousFormalCloudHost === undefined) {
    delete process.env.FORMAL_CLOUD_HOST;
  } else {
    process.env.FORMAL_CLOUD_HOST = previousFormalCloudHost;
  }
  if (previousApiBaseUrl === undefined) {
    delete process.env.SERVER_ADMIN_API_BASE_URL;
  } else {
    process.env.SERVER_ADMIN_API_BASE_URL = previousApiBaseUrl;
  }
  if (previousApiEntryMode === undefined) {
    delete process.env.SERVER_ADMIN_API_ENTRY_MODE;
  } else {
    process.env.SERVER_ADMIN_API_ENTRY_MODE = previousApiEntryMode;
  }
  if (previous === undefined) {
    delete process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE;
  } else {
    process.env.NEXT_PUBLIC_ADMIN_LOGIN_MODE = previous;
  }
});

test('admin env resolves explicit ssh tunnel mode without localhost server defaults', () => {
  const previousFormalCloudHost = process.env.FORMAL_CLOUD_HOST;
  const previousApiBaseUrl = process.env.SERVER_ADMIN_API_BASE_URL;
  const previousApiEntryMode = process.env.SERVER_ADMIN_API_ENTRY_MODE;
  process.env.FORMAL_CLOUD_HOST = 'formal-cloud.test';
  process.env.SERVER_ADMIN_API_ENTRY_MODE = 'ssh_tunnel';
  delete process.env.SERVER_ADMIN_API_BASE_URL;

  delete require.cache[require.resolve('../test-dist/core/config/env.js')];
  const env = require('../test-dist/core/config/env.js');

  assert.equal(
    env.getServerConfig().serverAdminApiBaseUrl,
    'http://127.0.0.1:8080/server/admin'
  );
  assert.equal(env.getServerConfig().serverAdminApiEntryMode, 'ssh_tunnel');
  assert.equal(env.getServerConfig().serverAdminApiConnectionLabel, 'SSH隧道');

  if (previousFormalCloudHost === undefined) {
    delete process.env.FORMAL_CLOUD_HOST;
  } else {
    process.env.FORMAL_CLOUD_HOST = previousFormalCloudHost;
  }
  if (previousApiBaseUrl === undefined) {
    delete process.env.SERVER_ADMIN_API_BASE_URL;
  } else {
    process.env.SERVER_ADMIN_API_BASE_URL = previousApiBaseUrl;
  }
  if (previousApiEntryMode === undefined) {
    delete process.env.SERVER_ADMIN_API_ENTRY_MODE;
  } else {
    process.env.SERVER_ADMIN_API_ENTRY_MODE = previousApiEntryMode;
  }
});

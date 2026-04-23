const test = require('node:test');
const assert = require('node:assert/strict');

function withEnv(patch, run) {
  const previous = new Map();
  for (const [key, value] of Object.entries(patch)) {
    previous.set(key, process.env[key]);
    if (value === undefined) {
      delete process.env[key];
      continue;
    }
    process.env[key] = value;
  }
  return Promise.resolve()
    .then(run)
    .finally(() => {
      for (const [key, value] of previous.entries()) {
        if (value === undefined) {
          delete process.env[key];
          continue;
        }
        process.env[key] = value;
      }
    });
}

function createLogger() {
  return {
    log() {},
    warn() {},
  };
}

test('server runtime guard rejects production implicit postgres fallback', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      APP_NAME: 'exhibition-server',
      RUNTIME_ENTRY_LABEL: 'cloud-host',
      POSTGRES_HOST: undefined,
      POSTGRES_DB: undefined,
      POSTGRES_USER: undefined,
      POSTGRES_PASSWORD: undefined,
      REDIS_ENABLED: 'false',
      UPLOAD_S3_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_PUBLIC_ENDPOINT: 'https://assets.example.com',
      UPLOAD_BUCKET: 'exhibition-uploads',
      UPLOAD_S3_ACCESS_KEY_ID: 'minioadmin',
      UPLOAD_S3_SECRET_ACCESS_KEY: 'minioadmin',
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
      const {
        assertServerRuntimeBoundary,
      } = require('../dist/core/runtime-startup.guard.js');

      assert.throws(
        () => assertServerRuntimeBoundary(new RuntimeConfigService(), createLogger()),
        /POSTGRES_HOST/,
      );
    },
  );
});

test('server runtime guard allows explicit cloud loopback internals in production', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      APP_NAME: 'exhibition-server',
      RUNTIME_ENTRY_LABEL: 'cloud-host',
      POSTGRES_HOST: '127.0.0.1',
      POSTGRES_DB: 'exhibition_app',
      POSTGRES_USER: 'exhibition',
      POSTGRES_PASSWORD: 'secret',
      REDIS_ENABLED: 'true',
      REDIS_HOST: '127.0.0.1',
      UPLOAD_S3_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_PUBLIC_ENDPOINT: 'https://assets.example.com',
      UPLOAD_BUCKET: 'exhibition-uploads',
      UPLOAD_S3_ACCESS_KEY_ID: 'minioadmin',
      UPLOAD_S3_SECRET_ACCESS_KEY: 'minioadmin',
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
      const {
        assertServerRuntimeBoundary,
      } = require('../dist/core/runtime-startup.guard.js');

      assert.doesNotThrow(() =>
        assertServerRuntimeBoundary(new RuntimeConfigService(), createLogger()),
      );
    },
  );
});

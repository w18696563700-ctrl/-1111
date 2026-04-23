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

test('bff runtime guard rejects production implicit server upstream fallback', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      APP_NAME: 'exhibition-bff',
      RUNTIME_ENTRY_LABEL: 'cloud-host',
      SERVER_BASE_URL: undefined,
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/apps/bff/src/core/runtime/runtime-config.service.js');
      const {
        assertBffRuntimeBoundary,
      } = require('../dist/apps/bff/src/core/runtime/runtime-startup.guard.js');

      assert.throws(
        () => assertBffRuntimeBoundary(new RuntimeConfigService(), createLogger()),
        /implicit SERVER_BASE_URL fallback/,
      );
    },
  );
});

test('bff runtime guard allows explicit loopback upstream when production makes it intentional', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      APP_NAME: 'exhibition-bff',
      RUNTIME_ENTRY_LABEL: 'cloud-host',
      SERVER_BASE_URL: 'http://127.0.0.1:3001',
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/apps/bff/src/core/runtime/runtime-config.service.js');
      const {
        assertBffRuntimeBoundary,
      } = require('../dist/apps/bff/src/core/runtime/runtime-startup.guard.js');

      assert.doesNotThrow(() =>
        assertBffRuntimeBoundary(new RuntimeConfigService(), createLogger()),
      );
    },
  );
});

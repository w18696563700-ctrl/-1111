const test = require('node:test');
const assert = require('node:assert/strict');
const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { dirname, join } = require('node:path');

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

function withArtifactTree(files, run) {
  const artifactRoot = mkdtempSync(join(tmpdir(), 'server-runtime-guard-'));
  for (const [relativePath, content] of Object.entries(files)) {
    const fullPath = join(artifactRoot, relativePath);
    mkdirSync(dirname(fullPath), { recursive: true });
    writeFileSync(fullPath, content);
  }
  return Promise.resolve()
    .then(() => run(artifactRoot))
    .finally(() => {
      rmSync(artifactRoot, { recursive: true, force: true });
    });
}

function createWeatherArtifactFiles(presenterContent) {
  return {
    'core/redis-client.service.js': 'exports.RedisClientService = class RedisClientService {};',
    'modules/weather/weather.module.js': 'exports.WeatherModule = class WeatherModule {};',
    'modules/weather/weather-lookup.service.js':
      'exports.WeatherLookupService = class WeatherLookupService {};',
    'modules/exhibition_home/exhibition-home-aggregation.service.js':
      'exports.ExhibitionHomeAggregationService = class ExhibitionHomeAggregationService {};',
    'modules/exhibition_home/exhibition-home.module.js':
      'const WeatherModule = {}; const ExhibitionHomeAggregationService = {};',
    'modules/exhibition_home/exhibition-home.presenter.js': presenterContent,
    'modules/exhibition_home/exhibition-home.types.js': 'exports.placeholder = false;',
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

test('server runtime guard rejects qweather-enabled runtime when compiled weather artifacts regress to placeholder output', async () => {
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
      QWEATHER_ENABLED: 'true',
      QWEATHER_API_HOST: 'https://weather.example.com',
      QWEATHER_API_KEY: 'weather-key',
    },
    async () => {
      await withArtifactTree(
        createWeatherArtifactFiles('exports.currentWeather = "待同步";'),
        async (artifactRoot) => {
          const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
          const {
            assertServerRuntimeBoundary,
          } = require('../dist/core/runtime-startup.guard.js');

          assert.throws(
            () =>
              assertServerRuntimeBoundary(new RuntimeConfigService(), createLogger(), {
                artifactRootOverride: artifactRoot,
              }),
            /placeholder marker "待同步"/,
          );
        },
      );
    },
  );
});

test('server runtime guard allows qweather-enabled runtime when compiled weather artifacts are intact', async () => {
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
      QWEATHER_ENABLED: 'true',
      QWEATHER_API_HOST: 'https://weather.example.com',
      QWEATHER_API_KEY: 'weather-key',
    },
    async () => {
      await withArtifactTree(
        createWeatherArtifactFiles('exports.currentWeather = "小雨"; exports.sourceLabel = "真实天气";'),
        async (artifactRoot) => {
          const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
          const {
            assertServerRuntimeBoundary,
          } = require('../dist/core/runtime-startup.guard.js');

          assert.doesNotThrow(() =>
            assertServerRuntimeBoundary(new RuntimeConfigService(), createLogger(), {
              artifactRootOverride: artifactRoot,
            }),
          );
        },
      );
    },
  );
});

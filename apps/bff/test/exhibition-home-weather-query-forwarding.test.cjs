const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { Module } = require('@nestjs/common');
const { NestFactory } = require('@nestjs/core');

const { AppExhibitionHomeController } = require('../src/routes/exhibition_home/app-exhibition-home.controller.ts');
const { ExhibitionHomeService } = require('../src/routes/exhibition_home/exhibition-home.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

test('app exhibition home controller forwards city and district query hints', async () => {
  const calls = [];
  const service = {
    getHome(headers, query) {
      calls.push({ headers, query });
      return {
        currentLocation: {
          displayName: '重庆市南岸区',
          provinceName: '重庆市',
          source: 'device_location',
          persisted: false,
        },
        selectionScope: 'request_only',
        isUsingDeviceLocation: true,
        currentWeather: '多云',
        currentTemperature: 24,
        highTemperature: 27,
        lowTemperature: 18,
        precipitationProbability: 30,
        constructionRiskLevel: 'low',
        constructionRiskSummary: '天气平稳。',
        riskTags: [],
        riskTimeLabel: null,
        nightRainExpected: false,
        nightRainTimeLabel: null,
        officialAlerts: [],
        constructionSuggestions: [],
        hourlyForecast: [],
        dailyForecast: [],
        updatedAt: '2026-04-24T09:00:00+08:00',
        sourceLabel: '当前首页按定位地区聚合真实天气',
        selectionNotice: '当前位置仅用于本次首页查看，可重新定位或手动切换。',
        canExpand: true,
        refreshable: true,
        modules: [],
        recommendationSections: [],
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [AppExhibitionHomeController],
    providers: [{ provide: ExhibitionHomeService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    const response = await fetch(
      `${url}/api/app/exhibition/home?provinceCode=500000&provinceName=%E9%87%8D%E5%BA%86%E5%B8%82&cityName=%E9%87%8D%E5%BA%86%E5%B8%82&districtName=%E5%8D%97%E5%B2%B8%E5%8C%BA&locationPermissionState=granted`,
    );
    assert.equal(response.status, 200);
  } finally {
    await app.close();
  }

  assert.equal(calls.length, 1);
  assert.deepEqual(calls[0].query, {
    latitude: undefined,
    longitude: undefined,
    provinceCode: '500000',
    provinceName: '重庆市',
    cityName: '重庆市',
    districtName: '南岸区',
    locationPermissionState: 'granted',
  });
});

test('exhibition home service forwards city and district to server path', async () => {
  const service = new ExhibitionHomeService(
    {
      async get(pathName, options) {
        assert.equal(pathName, '/server/exhibition/home');
        assert.deepEqual(options.params, {
          latitude: undefined,
          longitude: undefined,
          provinceCode: '500000',
          provinceName: '重庆市',
          cityName: '重庆市',
          districtName: '南岸区',
          locationPermissionState: 'granted',
        });
        return {
          currentLocation: {
            displayName: '重庆市南岸区',
            provinceName: '重庆市',
            source: 'device_location',
            persisted: false,
          },
          selectionScope: 'request_only',
          isUsingDeviceLocation: true,
          currentWeather: '多云',
          currentTemperature: 24,
          highTemperature: 27,
          lowTemperature: 18,
          precipitationProbability: 30,
          constructionRiskLevel: 'low',
          constructionRiskSummary: '天气平稳。',
          riskTags: [],
          riskTimeLabel: null,
          nightRainExpected: false,
          nightRainTimeLabel: null,
          officialAlerts: [],
          constructionSuggestions: [],
          hourlyForecast: [],
          dailyForecast: [],
          updatedAt: '2026-04-24T09:00:00+08:00',
          sourceLabel: '当前首页按定位地区聚合真实天气',
          selectionNotice: '当前位置仅用于本次首页查看，可重新定位或手动切换。',
          canExpand: true,
          refreshable: true,
          modules: [],
          recommendationSections: [],
        };
      },
    },
    {
      buildPublicHeadersWithOptionalActorHints() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getHome(
    {},
    {
      provinceCode: '500000',
      provinceName: '重庆市',
      cityName: '重庆市',
      districtName: '南岸区',
      locationPermissionState: 'granted',
    },
  );

  assert.equal(result.currentLocation.displayName, '重庆市南岸区');
});

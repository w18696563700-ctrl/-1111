const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');
const { Module, RequestMethod } = require('@nestjs/common');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const {
  AppTradingParticipantCardController,
} = require('../src/routes/trading_im/trading-im.controller.ts');
const { TradingImService } = require('../src/routes/trading_im/trading-im.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

function createAxiosResponseError(status, data, message = `Request failed with status code ${status}`) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

test('participant-card route is materialized and no longer router 404 locally', async () => {
  const calls = [];
  const service = {
    getParticipantCard(projectId, bidId, participantOrganizationId) {
      calls.push([projectId, bidId, participantOrganizationId]);
      return {
        projectId,
        bidId,
        participantOrganizationId,
        participantRole: 'bidder',
        enterpriseSummary: {
          enterpriseId: 'enterprise-1',
          displayName: '杭州搭建公司',
          logoUrl: null,
          primaryBoardType: 'supplier',
          provinceName: '浙江省',
          cityName: '杭州市',
          verificationStatus: 'approved',
        },
        reviewSummary: {
          avgScore: 4.8,
          reviewCount: 12,
          keywordTags: ['响应快'],
        },
        formalInfoSummary: {
          legalName: '杭州搭建展示有限公司',
          businessType: '有限责任公司',
          registeredCapital: '500 万人民币',
          establishedAt: '2020-04-09',
          businessScope: '展览搭建',
          certificationStatus: 'approved',
        },
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [AppTradingParticipantCardController],
    providers: [{ provide: TradingImService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppTradingParticipantCardController),
      'api/app/exhibition/trading',
    );
    assert.equal(
      Reflect.getMetadata(
        PATH_METADATA,
        AppTradingParticipantCardController.prototype.getParticipantCard,
      ),
      'participant-card',
    );
    assert.equal(
      Reflect.getMetadata(
        METHOD_METADATA,
        AppTradingParticipantCardController.prototype.getParticipantCard,
      ),
      RequestMethod.GET,
    );

    const response = await fetch(
      `${url}/api/app/exhibition/trading/participant-card?projectId=project-1&bidId=bid-1&participantOrganizationId=org-bidder-1`,
    );
    assert.equal(response.status, 200);
    assert.equal((await response.json()).participantRole, 'bidder');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [['project-1', 'bid-1', 'org-bidder-1']]);
});

test('participant-card service forwards frozen server path and normalizes raw 404 drift', async () => {
  const service = new TradingImService(
    {
      async get(pathName, options) {
        assert.equal(pathName, '/server/trading-im/bid/thread/participant-card');
        assert.deepEqual(options.params, {
          projectId: 'project-1',
          bidId: 'bid-1',
          participantOrganizationId: 'org-bidder-1',
        });
        return {
          projectId: 'project-1',
          bidId: 'bid-1',
          participantOrganizationId: 'org-bidder-1',
          participantRole: 'bidder',
          enterpriseSummary: {
            enterpriseId: 'enterprise-1',
            displayName: '杭州搭建公司',
            logoUrl: null,
            primaryBoardType: 'supplier',
            provinceName: '浙江省',
            cityName: '杭州市',
            verificationStatus: 'approved',
          },
          reviewSummary: {
            avgScore: 4.8,
            reviewCount: 12,
            keywordTags: ['响应快'],
          },
          formalInfoSummary: {
            legalName: '杭州搭建展示有限公司',
            businessType: '有限责任公司',
            registeredCapital: '500 万人民币',
            establishedAt: '2020-04-09',
            businessScope: '展览搭建',
            certificationStatus: 'approved',
          },
          trimmed: 'ignore-me',
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-organization-id': 'org-owner-1',
          'x-actor-role': 'buyer_admin',
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getParticipantCard(
    'project-1',
    'bid-1',
    'org-bidder-1',
    {},
  );
  assert.equal(result.enterpriseSummary.displayName, '杭州搭建公司');
  assert.equal(result.reviewSummary.reviewCount, 12);

  const brokenService = new TradingImService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: 'Cannot GET /server/trading-im/bid/thread/participant-card',
          source: 'server',
        });
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () =>
      brokenService.getParticipantCard(
        'project-1',
        'bid-1',
        'org-bidder-1',
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'THREAD_PARTICIPANT_CARD_UNAVAILABLE',
        message: '当前合作方名片暂不可用，请稍后再试。',
        source: 'server',
      });
      return true;
    },
  );
});

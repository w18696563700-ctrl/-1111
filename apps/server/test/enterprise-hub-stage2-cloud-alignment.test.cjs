const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');

test('enterprise presenter exposes company serviceItems on public list highlights', () => {
  const {
    EnterpriseHubPresenter,
  } = require('../dist/modules/enterprise_hub/enterprise-hub.presenter.js');

  const presenter = new EnterpriseHubPresenter({
    toReadModel() {
      return null;
    },
  });

  const item = presenter.toListItem(
    {
      id: 'enterprise-1',
      primaryBoardType: 'company',
      name: '示例公司',
      provinceName: '上海',
      cityName: '上海市',
      secondaryCapabilities: [],
      shortIntro: '简介',
      verificationStatusSnapshot: 'verified',
    },
    null,
    3,
    {
      exhibitionTypes: ['特装展台'],
      serviceItems: ['策划设计', '主场承建'],
      serviceCities: ['上海市'],
    },
    null,
    null,
    'https://cdn.example.com/logo.png',
  );

  assert.deepEqual(item.boardHighlights.company, {
    exhibitionTypes: ['特装展台'],
    serviceItems: ['策划设计', '主场承建'],
    serviceCities: ['上海市'],
  });
});

test('workbench presenter ignores legacy coverFileAssetId when returning albumImageFileAssetIds', () => {
  const {
    EnterpriseHubWorkbenchPresenter,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');

  const presenter = new EnterpriseHubWorkbenchPresenter({
    toReadModel(listing) {
      return {
        provinceName: listing.provinceName,
        cityName: listing.cityName,
      };
    },
  });

  const response = presenter.toResponse({
    organizationId: 'org-1',
    boardType: 'company',
    listing: {
      id: 'enterprise-1',
      primaryBoardType: 'company',
      name: '示例公司',
      logoFileAssetId: 'logo-1',
      coverFileAssetId: 'cover-1',
      albumImageFileAssetIds: ['album-1', 'album-2'],
      shortIntro: '简介',
      fullIntro: '正式介绍',
      provinceCode: '310000',
      provinceName: '上海',
      cityCode: '310100',
      cityName: '上海市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      contactVisible: true,
    },
    latestApplication: null,
    company: null,
    factory: null,
    supplier: null,
    cases: [],
    primaryContact: null,
    certification: null,
    readiness: {
      hasApplication: false,
      draftEditable: false,
      basicCompleted: false,
      profileCompleted: false,
      hasCase: false,
      hasContact: false,
      certificationApproved: false,
      submitReady: false,
      blockers: [],
    },
  });

  assert.deepEqual(response.basic.albumImageFileAssetIds, ['album-1', 'album-2']);
});

test('published change basic merge preserves albumImageFileAssetIds with the same limit as live basic writes', () => {
  const {
    EnterpriseHubPublishedChangeAppService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-app.service.js');

  const service = new EnterpriseHubPublishedChangeAppService(
    {},
    {},
    {
      normalizeWriteLocation(current) {
        return current;
      },
    },
  );

  const next = service.mergeBasic(
    {
      name: '示例公司',
      logoFileAssetId: 'logo-1',
      albumImageFileAssetIds: ['old-1'],
      shortIntro: '简介',
      fullIntro: '正式介绍',
      provinceCode: '310000',
      provinceName: '上海',
      cityCode: '310100',
      cityName: '上海市',
      address: null,
      location: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      contactVisible: true,
    },
    {
      albumImageFileAssetIds: ['album-1', 'album-2', 'album-3', 'album-4', 'album-5', 'album-6', 'album-7'],
    },
  );

  assert.deepEqual(next.albumImageFileAssetIds, [
    'album-1',
    'album-2',
    'album-3',
    'album-4',
    'album-5',
    'album-6',
  ]);
});

test('upload write service accepts enterprise_album as a valid enterprise display image kind', () => {
  const source = fs.readFileSync(
    `${__dirname}/../src/modules/upload/upload-write.service.ts`,
    'utf8',
  );

  assert.match(source, /fileKind === 'enterprise_album'/);
  assert.match(source, /businessType === 'enterprise_display'/);
});

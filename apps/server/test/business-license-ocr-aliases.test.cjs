const test = require('node:test');
const assert = require('node:assert/strict');

test('business license OCR parser accepts Aliyun official field aliases', async () => {
  const { ContentSafetyOcrService } = require('../dist/modules/content_safety/content-safety-ocr.service.js');

  const service = new ContentSafetyOcrService({
    aliyunOcrEnabled: false,
    aliyunOcrAccessKeyId: '',
    aliyunOcrAccessKeySecret: '',
    aliyunOcrEndpoint: '',
  });

  const parsed = service.parseBusinessLicenseData(
    JSON.stringify({
      companyName: '重庆坤特展览展示有限公司',
      creditCode: '91500105MA5U58K346',
      legalPerson: '王巍威',
      type: '有限责任公司',
      businessAddress: '重庆市江北区洋河二村73号1幢20-7（仅限用于行政办公）',
      registeredCapital: '壹佰万元整',
      RegistrationDate: '2016年03月30日',
      validPeriod: '2016年03月30日至永久',
      business: '展览展示服务；会议服务',
    }),
  );

  assert.equal(parsed.legalName, '重庆坤特展览展示有限公司');
  assert.equal(parsed.uscc, '91500105MA5U58K346');
  assert.equal(parsed.legalPerson, '王巍威');
  assert.equal(parsed.businessType, '有限责任公司');
  assert.equal(
    parsed.address,
    '重庆市江北区洋河二村73号1幢20-7（仅限用于行政办公）',
  );
  assert.equal(parsed.registeredCapital, '壹佰万元整');
  assert.equal(parsed.establishedAt, '2016年03月30日');
  assert.equal(parsed.businessTerm, '2016年03月30日至永久');
  assert.equal(parsed.businessScope, '展览展示服务；会议服务');
});

test('business license OCR service maps Aliyun official response keys into normalized fields', async () => {
  const { ContentSafetyOcrService } = require('../dist/modules/content_safety/content-safety-ocr.service.js');

  const service = new ContentSafetyOcrService({
    aliyunOcrEnabled: true,
    aliyunOcrAccessKeyId: 'ak',
    aliyunOcrAccessKeySecret: 'sk',
    aliyunOcrEndpoint: 'ocr-api.cn-hangzhou.aliyuncs.com',
    aliyunOcrRegionId: 'cn-hangzhou',
    aliyunOcrConnectTimeoutMs: 5000,
    aliyunOcrReadTimeoutMs: 10000,
  });

  service.getClient = () => ({
    recognizeBusinessLicense: async () => ({
      body: {
        code: '200',
        message: 'OK',
        requestId: 'aliyun-ocr-1',
        data: JSON.stringify({
          companyName: '重庆坤特展览展示有限公司',
          creditCode: '91500105MA5U58K346',
          legalPerson: '王巍威',
          type: '有限责任公司',
          businessAddress:
            '重庆市江北区洋河二村73号1幢20-7（仅限用于行政办公）',
          registeredCapital: '壹佰万元整',
          RegistrationDate: '2016年03月30日',
          validPeriod: '2016年03月30日至永久',
          business: '展览展示服务；会议服务',
        }),
      },
    }),
  });

  const result = await service.recognizeBusinessLicense(
    'https://oss.example.com/license.png',
  );

  assert.equal(result.status, 'succeeded');
  assert.equal(result.providerRequestId, 'aliyun-ocr-1');
  assert.equal(result.legalName, '重庆坤特展览展示有限公司');
  assert.equal(result.uscc, '91500105MA5U58K346');
  assert.equal(result.legalPerson, '王巍威');
  assert.equal(result.businessType, '有限责任公司');
  assert.equal(
    result.address,
    '重庆市江北区洋河二村73号1幢20-7（仅限用于行政办公）',
  );
  assert.equal(result.registeredCapital, '壹佰万元整');
  assert.equal(result.establishedAt, '2016年03月30日');
  assert.equal(result.businessTerm, '2016年03月30日至永久');
  assert.equal(result.businessScope, '展览展示服务；会议服务');
});

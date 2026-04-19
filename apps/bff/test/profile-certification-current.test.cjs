const test = require("node:test");
const assert = require("node:assert/strict");

const {
  ProfileReadService,
} = require("../dist/apps/bff/src/routes/profile/profile-read.service.js");
const {
  ErrorNormalizerService,
} = require("../dist/apps/bff/src/core/errors/error-normalizer.service.js");

function createService(serverPayload) {
  return new ProfileReadService(
    {
      get: async () => serverPayload,
    },
    {
      buildReadOnlyForwardHeaders: (headers) => headers,
    },
    new ErrorNormalizerService(),
  );
}

test("getCurrentCertification passes through the expanded formal certification fields when server returns them", async () => {
  const service = createService({
    organizationId: "org-1",
    certificationStatus: "approved",
    legalName: "示例企业",
    uscc: "91350000TEST00001",
    licenseFileId: "file-1",
    address: "上海市浦东新区测试路 88 号",
    establishedAt: "2020-05-01",
    legalPerson: "王巍威",
    businessType: "有限责任公司",
    registeredCapital: "壹佰万元整",
    businessTerm: "长期",
    businessScope: "展览展示服务",
    rejectReason: null,
    expiresAt: "2026-12-31T00:00:00.000Z",
    submittedAt: "2026-04-10T10:00:00.000Z",
  });

  const result = await service.getCurrentCertification({});
  assert.deepEqual(result, {
    organizationId: "org-1",
    certificationStatus: "approved",
    legalName: "示例企业",
    uscc: "91350000TEST00001",
    licenseFileId: "file-1",
    address: "上海市浦东新区测试路 88 号",
    establishedAt: "2020-05-01",
    legalPerson: "王巍威",
    businessType: "有限责任公司",
    registeredCapital: "壹佰万元整",
    businessTerm: "长期",
    businessScope: "展览展示服务",
    rejectReason: null,
    expiresAt: "2026-12-31T00:00:00.000Z",
    submittedAt: "2026-04-10T10:00:00.000Z",
  });
});

test("getCurrentCertification does not fabricate optional current fields when server omits them", async () => {
  const service = createService({
    organizationId: "org-2",
    certificationStatus: "not_submitted",
  });

  const result = await service.getCurrentCertification({});
  assert.deepEqual(result, {
    organizationId: "org-2",
    certificationStatus: "not_submitted",
  });
  assert.equal(Object.prototype.hasOwnProperty.call(result, "address"), false);
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "establishedAt"),
    false,
  );
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "legalPerson"),
    false,
  );
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "businessType"),
    false,
  );
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "registeredCapital"),
    false,
  );
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "businessTerm"),
    false,
  );
  assert.equal(
    Object.prototype.hasOwnProperty.call(result, "businessScope"),
    false,
  );
});

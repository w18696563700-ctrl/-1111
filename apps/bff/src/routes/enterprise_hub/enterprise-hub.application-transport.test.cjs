const test = require("node:test");
const assert = require("node:assert/strict");

const {
  EnterpriseHubService,
} = require("../../../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js");
const {
  ErrorNormalizerService,
} = require("../../../dist/apps/bff/src/core/errors/error-normalizer.service.js");

function createService(overrides = {}) {
  return new EnterpriseHubService(
    overrides.serverClient ?? {
      post: async () => {
        throw new Error("serverClient.post mock is required");
      },
      get: async () => {
        throw new Error("serverClient.get mock is required");
      },
    },
    overrides.authContext ?? {},
    overrides.errors ?? new ErrorNormalizerService(),
    overrides.forumCommandContext ?? {
      buildCommandHeaders: async (headers) => headers,
    },
  );
}

function upstreamError(status, code, message) {
  return {
    isAxiosError: true,
    code: status >= 500 ? "ERR_BAD_RESPONSE" : "ERR_BAD_REQUEST",
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        source: "server",
      },
    },
  };
}

test("createApplication normalizes permission denied to stable Chinese message", async () => {
  const service = createService({
    serverClient: {
      post: async () => {
        throw upstreamError(
          403,
          "ENTERPRISE_HUB_PERMISSION_DENIED",
          "Current actor must carry organization context for enterprise hub write truth.",
        );
      },
    },
  });

  await assert.rejects(
    () =>
      service.createApplication(
        {
          applyBoardType: "factory",
          applicantName: "张三",
          applicantMobile: "13800000000",
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.deepEqual(error.getResponse(), {
        statusCode: 403,
        code: "ENTERPRISE_HUB_PERMISSION_DENIED",
        message: "当前组织身份不可用，暂时无法创建企业展示申请。",
        details: {
          transportCode: "ERR_BAD_REQUEST",
          upstreamMessage: "Request failed with status code 403",
          originalMessage:
            "Current actor must carry organization context for enterprise hub write truth.",
        },
        source: "server",
      });
      return true;
    },
  );
});

test("submitApplication preserves submit-blocked code and normalizes to stable Chinese message", async () => {
  const service = createService({
    serverClient: {
      post: async () => {
        throw upstreamError(
          400,
          "ENTERPRISE_HUB_CASE_REQUIRED",
          "Current enterprise display submit requires at least one approved case.",
        );
      },
    },
  });

  await assert.rejects(
    () => service.submitApplication("app-1", { confirm: true }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.deepEqual(error.getResponse(), {
        statusCode: 400,
        code: "ENTERPRISE_HUB_CASE_REQUIRED",
        message: "当前企业展示案例未完善，请先补齐案例后再提交。",
        details: {
          transportCode: "ERR_BAD_REQUEST",
          upstreamMessage: "Request failed with status code 400",
          originalMessage:
            "Current enterprise display submit requires at least one approved case.",
        },
        source: "server",
      });
      return true;
    },
  );
});

test("submitApplication treats confirm=false as missing required fields before forwarding", async () => {
  let forwarded = false;
  const service = createService({
    serverClient: {
      post: async () => {
        forwarded = true;
        throw new Error("submit should not be forwarded when confirm is false");
      },
    },
  });

  await assert.rejects(
    () => service.submitApplication("app-1", { confirm: false }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.deepEqual(error.getResponse(), {
        statusCode: 400,
        code: "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        message: "请先确认提交入驻申请后再继续。",
        source: "bff",
      });
      assert.equal(forwarded, false);
      return true;
    },
  );
});

test("getApplicationStatus normalizes application unavailable to stable Chinese message", async () => {
  const service = createService({
    serverClient: {
      get: async () => {
        throw upstreamError(
          404,
          "ENTERPRISE_HUB_APPLICATION_NOT_FOUND",
          "Enterprise hub application is unavailable.",
        );
      },
    },
  });

  await assert.rejects(
    () => service.getApplicationStatus("app-1", {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: "ENTERPRISE_HUB_APPLICATION_NOT_FOUND",
        message: "当前企业展示申请不可用，请返回工作台后再试。",
        details: {
          transportCode: "ERR_BAD_REQUEST",
          upstreamMessage: "Request failed with status code 404",
          originalMessage: "Enterprise hub application is unavailable.",
        },
        source: "server",
      });
      return true;
    },
  );
});

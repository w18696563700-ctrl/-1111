import { BadRequestException, Injectable } from "@nestjs/common";
import type { IncomingHttpHeaders } from "http";
import { AuthContextService } from "../../core/auth/auth-context.service";
import { ErrorNormalizerService } from "../../core/errors/error-normalizer.service";
import { ServerClientService } from "../../core/http/server-client.service";
import { toEnterpriseHubTargetEnterpriseFormalInfoResponse } from "./enterprise-hub-formal-info.read-model";

const ENTERPRISE_FORMAL_INFO_ROUTE_CONTRACT = {
  appPath:
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info",
  errorCodes: [
    "AUTH_SESSION_INVALID",
    "ENTERPRISE_HUB_PERMISSION_DENIED",
    "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
  ],
} as const;

@Injectable()
export class EnterpriseHubFormalInfoService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getTargetEnterpriseFormalInfo(
    enterpriseId: string,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_FORMAL_INFO_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      "Enterprise id is required.",
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/formal-info`,
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return toEnterpriseHubTargetEnterpriseFormalInfoResponse(
        result,
        normalizedEnterpriseId,
      );
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        "当前企业正式信息暂不可用，请稍后再试。",
        {
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        },
      );
    }
  }

  private requireEntityId(value: unknown, message: string) {
    if (typeof value === "string" && value.trim().length > 0) {
      return value.trim();
    }
    throw new BadRequestException({
      statusCode: 400,
      code: "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
      message,
      source: "bff",
    });
  }
}

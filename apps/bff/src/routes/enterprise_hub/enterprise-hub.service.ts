import { BadRequestException, HttpException, Injectable } from "@nestjs/common";
import type { IncomingHttpHeaders } from "http";
import { isAxiosError } from "axios";
import { AuthContextService } from "../../core/auth/auth-context.service";
import { ErrorNormalizerService } from "../../core/errors/error-normalizer.service";
import { ServerClientService } from "../../core/http/server-client.service";
import { requireAppApiPath, requireErrorCode } from "../../shared/contracts";
import { ForumCommandContextService } from "../forum/forum-command-context.service";
import {
  toActionAckResponse,
  toEnterpriseHubApplicationStatusResponse,
  toEnterpriseHubCaseCreateResponse,
  toEnterpriseHubCaseDetailResponse,
  toEnterpriseHubCaseUpdateResponse,
  toEnterpriseHubCreateApplicationResponse,
  toEnterpriseHubDetailResponse,
  toEnterpriseHubEnsureShellResponse,
  toEnterpriseHubListResponse,
  toEnterpriseHubRecommendationListResponse,
} from "./enterprise-hub.read-model";

type EnterpriseHubBoardType = "company" | "factory" | "supplier";

type EnterpriseHubListQuery = {
  boardType?: string;
  keyword?: string;
  provinceCode?: string;
  cityCode?: string;
  plantAreaRange?: string;
  page?: string;
  pageSize?: string;
};

const ENTERPRISE_LIST_ROUTE_CONTRACT = {
  appPath: requireAppApiPath("/api/app/exhibition/enterprise-hub/enterprises"),
  errorCodes: [
    requireErrorCode("ENTERPRISE_HUB_INVALID_BOARD_TYPE"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_DETAIL_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}",
  ),
  errorCodes: [
    requireErrorCode("ENTERPRISE_HUB_INVALID_BOARD_TYPE"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_RECOMMENDATIONS_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/recommendations",
  ),
  errorCodes: [
    requireErrorCode("ENTERPRISE_HUB_INVALID_BOARD_TYPE"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_APPLICATION_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath("/api/app/exhibition/enterprise-hub/applications"),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_SHELL_ENSURE_ROUTE_CONTRACT = {
  appPath: "/api/app/exhibition/enterprise-hub/enterprises/ensure-shell",
  errorCodes: [
    "AUTH_SESSION_INVALID",
    "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
    "ENTERPRISE_HUB_PERMISSION_DENIED",
    "ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE",
  ],
} as const;

const ENTERPRISE_LOCATION_RESOLVE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/location/resolve",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_LOCATION_RESOLVE_INVALID"),
    requireErrorCode("ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE"),
    requireErrorCode("ENTERPRISE_LOCATION_RESOLVE_FAILED"),
    requireErrorCode("ENTERPRISE_LOCATION_WRITE_INVALID"),
    requireErrorCode("ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING"),
  ],
} as const;

const ENTERPRISE_BASIC_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
    requireErrorCode("ENTERPRISE_LOCATION_WRITE_INVALID"),
  ],
} as const;

const ENTERPRISE_COMPANY_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/company",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
  ],
} as const;

const ENTERPRISE_FACTORY_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
  ],
} as const;

const ENTERPRISE_SUPPLIER_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/supplier",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
  ],
} as const;

const ENTERPRISE_CASE_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
  ],
} as const;

const ENTERPRISE_CASE_DELETE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/cases/{caseId}",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_CASE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_CASE_DETAIL_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/cases/{caseId}",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_CASE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_PUBLIC_CASE_DETAIL_ROUTE_CONTRACT = {
  appPath: "/api/app/exhibition/enterprise-hub/public-cases/{caseId}",
  errorCodes: ["ENTERPRISE_HUB_CASE_NOT_FOUND"],
} as const;

const ENTERPRISE_CASE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/cases/{caseId}",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_CASE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
    requireErrorCode("ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED"),
    requireErrorCode("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS"),
  ],
} as const;

const ENTERPRISE_DELETE_ROUTE_CONTRACT = {
  appPath: "/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}",
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_APPLICATION_SUBMIT_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/applications/{applicationId}/submit",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_APPLICATION_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PROFILE_NOT_COMPLETED"),
    requireErrorCode("ENTERPRISE_HUB_CERTIFICATION_REQUIRED"),
    requireErrorCode("ENTERPRISE_HUB_CONTACT_REQUIRED"),
    requireErrorCode("ENTERPRISE_HUB_CASE_REQUIRED"),
    requireErrorCode("ENTERPRISE_HUB_INVALID_STATE_TRANSITION"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

const ENTERPRISE_APPLICATION_STATUS_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    "/api/app/exhibition/enterprise-hub/applications/{applicationId}",
  ),
  errorCodes: [
    requireErrorCode("AUTH_SESSION_INVALID"),
    requireErrorCode("ENTERPRISE_HUB_APPLICATION_NOT_FOUND"),
    requireErrorCode("ENTERPRISE_HUB_PERMISSION_DENIED"),
  ],
} as const;

@Injectable()
export class EnterpriseHubService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService,
  ) {}

  async listEnterprises(
    headers: IncomingHttpHeaders,
    query: EnterpriseHubListQuery,
  ) {
    void ENTERPRISE_LIST_ROUTE_CONTRACT;
    const boardType = this.requireBoardType(query.boardType);

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        "/server/exhibition/enterprise-hub/enterprises",
        {
          headers:
            this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
          params: this.buildListParams(query, boardType),
        },
      );
      return toEnterpriseHubListResponse(result, { boardType });
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        "Enterprise hub list aggregation failed.",
        {
          400: "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        },
      );
    }
  }

  async listEnterprisesForBoard(
    headers: IncomingHttpHeaders,
    boardType: EnterpriseHubBoardType,
    query: Omit<EnterpriseHubListQuery, 'boardType'>,
  ) {
    return this.listEnterprises(headers, {
      ...query,
      boardType,
    });
  }

  async getEnterpriseDetail(
    enterpriseId: string,
    boardType: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_DETAIL_ROUTE_CONTRACT;
    const normalizedBoardType = this.requireBoardType(boardType);
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      "Enterprise id is required.",
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}`,
        {
          headers:
            this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
          params: {
            boardType: normalizedBoardType,
          },
        },
      );
      return toEnterpriseHubDetailResponse(result, {
        boardType: normalizedBoardType,
      });
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        "Enterprise hub detail aggregation failed.",
        {
          400: "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        },
      );
    }
  }

  async getEnterpriseDetailForBoard(
    enterpriseId: string,
    boardType: EnterpriseHubBoardType,
    headers: IncomingHttpHeaders,
  ) {
    return this.getEnterpriseDetail(enterpriseId, boardType, headers);
  }

  async getRecommendations(
    headers: IncomingHttpHeaders,
    boardType: string | undefined,
  ) {
    void ENTERPRISE_RECOMMENDATIONS_ROUTE_CONTRACT;
    const normalizedBoardType = this.requireBoardType(boardType);

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        "/server/exhibition/enterprise-hub/recommendations",
        {
          headers:
            this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
          params: {
            boardType: normalizedBoardType,
          },
        },
      );
      return toEnterpriseHubRecommendationListResponse(result, {
        boardType: normalizedBoardType,
      });
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_PERMISSION_DENIED",
        "Enterprise hub recommendation aggregation failed.",
        {
          400: "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        },
      );
    }
  }

  async getRecommendationsForBoard(
    headers: IncomingHttpHeaders,
    boardType: EnterpriseHubBoardType,
  ) {
    return this.getRecommendations(headers, boardType);
  }

  async createApplication(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_APPLICATION_CREATE_ROUTE_CONTRACT;
    const command = this.normalizeCreateApplicationPayload(payload);

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        "/server/exhibition/enterprise-hub/applications",
        command,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubCreateApplicationResponse(result);
    } catch (error) {
      throw this.normalizeApplicationCreateError(
        error,
      );
    }
  }

  async createApplicationForBoard(
    boardType: EnterpriseHubBoardType,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    const record = this.asRecord(payload);
    this.assertFixedBoardIdentity(
      record.applyBoardType,
      boardType,
      `当前独立入口只允许 ${boardType} 板块申请。`,
    );
    return this.createApplication(
      {
        ...record,
        applyBoardType: boardType,
      },
      headers,
    );
  }

  async ensureShell(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_SHELL_ENSURE_ROUTE_CONTRACT;
    const command = this.normalizeEnsureShellPayload(payload);

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        "/server/exhibition/enterprise-hub/enterprises/ensure-shell",
        command,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubEnsureShellResponse(result);
    } catch (error) {
      throw this.normalizeEnsureShellError(error);
    }
  }

  async ensureShellForBoard(
    boardType: EnterpriseHubBoardType,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    const record = this.asRecord(payload);
    this.assertFixedBoardIdentity(
      record.boardType,
      boardType,
      `当前独立入口只允许 ${boardType} 板块建档。`,
    );
    return this.ensureShell(
      {
        ...record,
        boardType,
      },
      headers,
    );
  }

  async resolveLocation(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_LOCATION_RESOLVE_ROUTE_CONTRACT;
    const command = this.normalizeResolveLocationPayload(payload);
    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        "/server/exhibition/enterprise-hub/location/resolve",
        command,
        {
          headers: forwardHeaders,
        },
      );
      return this.requireRecord(
        result,
        "Enterprise hub location resolve response must be an object.",
      );
    } catch (error) {
      throw this.normalizeEnterpriseHubTransportError(
        error,
        "ENTERPRISE_LOCATION_RESOLVE_FAILED",
        "当前企业位置解析暂不可用，请稍后再试。",
        {
          400: "ENTERPRISE_LOCATION_RESOLVE_INVALID",
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          503: "ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE",
        },
        {
          AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
          ENTERPRISE_HUB_PERMISSION_DENIED:
            "当前组织身份不可执行企业位置解析，请重新进入我的楼后再试。",
          ENTERPRISE_LOCATION_RESOLVE_INVALID:
            "当前企业位置解析请求不完整，请检查位置输入后再试。",
          ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE:
            "当前企业位置解析 provider 暂不可用，请稍后再试。",
          ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING:
            "当前企业位置解析缺少高德运行态配置，请先完成配置后再试。",
          ENTERPRISE_LOCATION_RESOLVE_FAILED:
            "当前企业位置解析失败，请稍后再试。",
        },
      );
    }
  }

  async updateBasic(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_BASIC_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, "Enterprise id is required.")}/basic`,
      this.normalizeBasicPayload(payload),
      headers,
      "Enterprise hub basic profile update failed.",
    );
  }

  async updateCompanyProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_COMPANY_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, "Enterprise id is required.")}/profiles/company`,
      this.normalizeCompanyProfilePayload(payload),
      headers,
      "Enterprise hub company profile update failed.",
    );
  }

  async updateFactoryProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_FACTORY_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, "Enterprise id is required.")}/profiles/factory`,
      this.normalizeFactoryProfilePayload(payload),
      headers,
      "Enterprise hub factory profile update failed.",
    );
  }

  async updateSupplierProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_SUPPLIER_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, "Enterprise id is required.")}/profiles/supplier`,
      this.normalizeSupplierProfilePayload(payload),
      headers,
      "Enterprise hub supplier profile update failed.",
    );
  }

  async createCase(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_CASE_CREATE_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      "Enterprise id is required.",
    );
    const command = this.normalizeCreateCasePayload(payload);

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/cases`,
        command,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubCaseCreateResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        "Enterprise hub case create failed.",
        {
          400: "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        },
      );
    }
  }

  async createCaseForBoard(
    enterpriseId: string,
    boardType: EnterpriseHubBoardType,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    const record = this.asRecord(payload);
    this.assertFixedBoardIdentity(
      record.boardType,
      boardType,
      `当前独立入口只允许 ${boardType} 板块案例。`,
    );
    return this.createCase(
      enterpriseId,
      {
        ...record,
        boardType,
      },
      headers,
    );
  }

  async getCaseDetail(caseId: string, headers: IncomingHttpHeaders) {
    void ENTERPRISE_CASE_DETAIL_ROUTE_CONTRACT;
    const normalizedCaseId = this.requireEntityId(
      caseId,
      "Case id is required.",
    );

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/cases/${normalizedCaseId}`,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubCaseDetailResponse(result);
    } catch (error) {
      throw this.normalizeEnterpriseHubTransportError(
        error,
        "ENTERPRISE_HUB_CASE_NOT_FOUND",
        "当前案例不可用，请返回案例库后再试。",
        {
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_CASE_NOT_FOUND",
        },
        {
          AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
          ENTERPRISE_HUB_PERMISSION_DENIED:
            "当前组织身份不可读取该案例，请重新进入我的楼后再试。",
          ENTERPRISE_HUB_CASE_NOT_FOUND:
            "当前案例不可用，请返回案例库后再试。",
        },
      );
    }
  }

  async getPublicCaseDetail(caseId: string, headers: IncomingHttpHeaders) {
    void ENTERPRISE_PUBLIC_CASE_DETAIL_ROUTE_CONTRACT;
    const normalizedCaseId = this.requireEntityId(
      caseId,
      "Case id is required.",
    );

    try {
      const forwardHeaders =
        await this.authContext.buildPublicHeadersWithOptionalActorHints(headers);
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/public-cases/${normalizedCaseId}`,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubCaseDetailResponse(result);
    } catch (error) {
      throw this.normalizeEnterpriseHubTransportError(
        error,
        "ENTERPRISE_HUB_CASE_NOT_FOUND",
        "当前案例暂不可用，可能已下线或被移除。",
        {
          404: "ENTERPRISE_HUB_CASE_NOT_FOUND",
        },
        {
          ENTERPRISE_HUB_CASE_NOT_FOUND:
            "当前案例暂不可用，可能已下线或被移除。",
        },
      );
    }
  }

  async updateCase(
    caseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_CASE_UPDATE_ROUTE_CONTRACT;
    const normalizedCaseId = this.requireEntityId(
      caseId,
      "Case id is required.",
    );
    const command = this.normalizeUpdateCasePayload(payload);

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.put<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/cases/${normalizedCaseId}`,
        command,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubCaseUpdateResponse(result);
    } catch (error) {
      throw this.normalizeEnterpriseHubTransportError(
        error,
        "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        "当前案例信息不完整，请补齐标题和摘要后再继续保存。",
        {
          400: "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_CASE_NOT_FOUND",
        },
        {
          AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
          ENTERPRISE_HUB_PERMISSION_DENIED:
            "当前组织身份不可修改该案例，请重新进入我的楼后再试。",
          ENTERPRISE_HUB_CASE_NOT_FOUND:
            "当前案例不可用，请返回案例库后再试。",
          ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED:
            "当前案例已进入正式展示变更流程，请改走变更通道继续处理。",
          ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS:
            "当前案例信息不完整，请补齐标题和摘要后再继续保存。",
        },
      );
    }
  }

  async submitApplication(
    applicationId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_APPLICATION_SUBMIT_ROUTE_CONTRACT;
    const normalizedApplicationId = this.requireEntityId(
      applicationId,
      "Application id is required.",
    );
    const command = this.normalizeSubmitPayload(payload);

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/applications/${normalizedApplicationId}/submit`,
        command,
        {
          headers: forwardHeaders,
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.normalizeApplicationSubmitError(
        error,
      );
    }
  }

  async getApplicationStatus(
    applicationId: string,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_APPLICATION_STATUS_ROUTE_CONTRACT;
    const normalizedApplicationId = this.requireEntityId(
      applicationId,
      "Application id is required.",
    );

    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/applications/${normalizedApplicationId}`,
        {
          headers: forwardHeaders,
        },
      );
      return toEnterpriseHubApplicationStatusResponse(result);
    } catch (error) {
      throw this.normalizeApplicationStatusError(
        error,
      );
    }
  }

  async deleteCase(caseId: string, headers: IncomingHttpHeaders) {
    void ENTERPRISE_CASE_DELETE_ROUTE_CONTRACT;
    return this.sendDelete(
      `/server/exhibition/enterprise-hub/cases/${this.requireEntityId(caseId, "Case id is required.")}`,
      headers,
      "Enterprise hub case delete failed.",
      {
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        404: "ENTERPRISE_HUB_CASE_NOT_FOUND",
      },
    );
  }

  async deleteEnterprise(enterpriseId: string, headers: IncomingHttpHeaders) {
    void ENTERPRISE_DELETE_ROUTE_CONTRACT;
    return this.sendDelete(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, "Enterprise id is required.")}`,
      headers,
      "Enterprise hub listing delete failed.",
      {
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
      },
    );
  }

  private async sendPut(
    path: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    fallbackMessage: string,
  ) {
    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.put<Record<string, unknown>>(
        path,
        payload,
        {
          headers: forwardHeaders,
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        fallbackMessage,
        {
          400: "ENTERPRISE_LOCATION_WRITE_INVALID",
          401: "AUTH_SESSION_INVALID",
          403: "ENTERPRISE_HUB_PERMISSION_DENIED",
          404: "ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND",
        },
      );
    }
  }

  private async sendDelete(
    path: string,
    headers: IncomingHttpHeaders,
    fallbackMessage: string,
    statusMap: Record<number, string>,
  ) {
    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.delete<Record<string, unknown>>(
        path,
        {
          headers: forwardHeaders,
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        "ENTERPRISE_HUB_PERMISSION_DENIED",
        fallbackMessage,
        statusMap,
      );
    }
  }

  private buildListParams(
    query: EnterpriseHubListQuery,
    boardType: EnterpriseHubBoardType,
  ): Record<string, string | number | boolean | undefined> {
    return {
      boardType,
      keyword: this.asOptionalString(query.keyword),
      provinceCode: this.asOptionalString(query.provinceCode),
      cityCode: this.asOptionalString(query.cityCode),
      plantAreaRange: this.asOptionalString(query.plantAreaRange),
      page: this.asOptionalString(query.page),
      pageSize: this.asOptionalString(query.pageSize),
    };
  }

  private normalizeCreateApplicationPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return {
      applyBoardType: this.requireBoardType(record.applyBoardType),
      applicantName: this.requireString(
        record.applicantName,
        "Applicant name is required.",
      ),
      applicantMobile: this.requireString(
        record.applicantMobile,
        "Applicant mobile is required.",
      ),
    };
  }

  private normalizeEnsureShellPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return {
      boardType: this.requireBoardType(record.boardType),
    };
  }

  private normalizeBasicPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ["logoUrl"]);
    return this.compact({
      name: this.asNullableString(record.name),
      contactName: this.asNullableString(record.contactName),
      contactMobile: this.asNullableString(record.contactMobile),
      logoFileAssetId: this.asNullableString(record.logoFileAssetId),
      albumImageFileAssetIds: this.asOptionalStringArray(
        record.albumImageFileAssetIds,
      )?.slice(0, 6),
      shortIntro: this.asNullableString(record.shortIntro),
      fullIntro: this.asNullableString(record.fullIntro),
      provinceCode: this.asNullableString(record.provinceCode),
      provinceName: this.asNullableString(record.provinceName),
      cityCode: this.asNullableString(record.cityCode),
      cityName: this.asNullableString(record.cityName),
      address: this.asNullableString(record.address),
      location: this.normalizeLocationPayload(record.location),
      foundedAt: this.asNullableString(record.foundedAt),
      teamSizeRange: this.asNullableString(record.teamSizeRange),
      cooperationModes: this.asOptionalStringArray(record.cooperationModes),
      contactVisible: this.asNullableBoolean(record.contactVisible),
    });
  }

  private normalizeResolveLocationPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    const resolveMode = this.asNullableString(record.resolveMode);
    if (resolveMode !== "device_location" && resolveMode !== "manual_address") {
      throw this.badRequest(
        "ENTERPRISE_LOCATION_RESOLVE_INVALID",
        "Field `resolveMode` must be `device_location` or `manual_address`.",
      );
    }
    if (
      resolveMode === "device_location" &&
      (this.asNullableNumber(record.latitude) == null ||
        this.asNullableNumber(record.longitude) == null)
    ) {
      throw this.badRequest(
        "ENTERPRISE_LOCATION_RESOLVE_INVALID",
        "当前企业位置解析缺少 latitude / longitude。",
      );
    }
    if (
      resolveMode === "manual_address" &&
      this.asNullableString(record.addressText) == null
    ) {
      throw this.badRequest(
        "ENTERPRISE_LOCATION_RESOLVE_INVALID",
        "当前企业位置解析缺少 addressText。",
      );
    }
    return this.compact({
      resolveMode,
      addressText: this.asNullableString(record.addressText),
      provinceCode: this.asNullableString(record.provinceCode),
      provinceName: this.asNullableString(record.provinceName),
      cityCode: this.asNullableString(record.cityCode),
      cityName: this.asNullableString(record.cityName),
      districtCode: this.asNullableString(record.districtCode),
      districtName: this.asNullableString(record.districtName),
      latitude: this.asNullableNumber(record.latitude),
      longitude: this.asNullableNumber(record.longitude),
    });
  }

  private normalizeLocationPayload(value: unknown) {
    if (value === undefined || value === null || Array.isArray(value)) {
      return undefined;
    }
    const record = this.asRecord(value);
    return this.compact({
      addressText: this.asNullableString(record.addressText),
      publicDisplayAddress: this.asNullableString(record.publicDisplayAddress),
      provinceCode: this.asNullableString(record.provinceCode),
      provinceName: this.asNullableString(record.provinceName),
      cityCode: this.asNullableString(record.cityCode),
      cityName: this.asNullableString(record.cityName),
      districtCode: this.asNullableString(record.districtCode),
      districtName: this.asNullableString(record.districtName),
      latitude: this.asNullableNumber(record.latitude),
      longitude: this.asNullableNumber(record.longitude),
      geoSource: this.asNullableString(record.geoSource),
      geoStatus: this.asNullableString(record.geoStatus),
      lastGeocodedAt: this.asNullableString(record.lastGeocodedAt),
      mapProvider: this.asNullableString(record.mapProvider),
    });
  }

  private normalizeCompanyProfilePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return this.compact({
      exhibitionTypes: this.asRequiredStringArray(
        record.exhibitionTypes,
        "exhibitionTypes is required.",
      ),
      serviceItems: this.asRequiredStringArray(
        record.serviceItems,
        "serviceItems is required.",
      ),
      serviceCities: this.asRequiredStringArray(
        record.serviceCities,
        "serviceCities is required.",
      ),
      teamSize: this.asNullableNumber(record.teamSize),
      maxProjectScale: this.asNullableString(record.maxProjectScale),
      averageDeliveryCycleDays: this.asNullableNumber(
        record.averageDeliveryCycleDays,
      ),
      knownClients: this.asOptionalStringArray(record.knownClients),
      qualificationDesc: this.asNullableString(record.qualificationDesc),
      projectManagementCapability: this.asNullableString(
        record.projectManagementCapability,
      ),
      onsiteExecutionCapability: this.asNullableString(
        record.onsiteExecutionCapability,
      ),
    });
  }

  private normalizeFactoryProfilePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return this.compact({
      factoryName: this.asNullableString(record.factoryName),
      processTypes: this.asOptionalStringArray(record.processTypes),
      coreProducts: this.asOptionalStringArray(record.coreProducts),
      equipmentList: this.asOptionalStringArray(record.equipmentList),
      showcaseImageFileAssetIds: this.asOptionalStringArray(
        record.showcaseImageFileAssetIds,
      ),
      plantAreaSqm: this.asNullableNumber(record.plantAreaSqm),
      monthlyCapacityDesc: this.asNullableString(record.monthlyCapacityDesc),
      urgentOrderCapability: this.asNullableString(
        record.urgentOrderCapability,
      ),
      urgentCycleDesc: this.asNullableString(record.urgentCycleDesc),
      warehouseCapability: this.asNullableBoolean(record.warehouseCapability),
      transportCapability: this.asNullableString(record.transportCapability),
      maxOrderCapacityDesc: this.asNullableString(record.maxOrderCapacityDesc),
      productionQualificationDesc: this.asNullableString(
        record.productionQualificationDesc,
      ),
      deliveryRadiusDesc: this.asNullableString(record.deliveryRadiusDesc),
    });
  }

  private normalizeSupplierProfilePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return this.compact({
      supplyCategories: this.asRequiredStringArray(
        record.supplyCategories,
        "supplyCategories is required.",
      ),
      supplyMode: this.asRequiredStringArray(
        record.supplyMode,
        "supplyMode is required.",
      ),
      coreProductsOrServices: this.asRequiredStringArray(
        record.coreProductsOrServices,
        "coreProductsOrServices is required.",
      ),
      responseSlaDesc: this.asNullableString(record.responseSlaDesc),
      stockStatusDesc: this.asNullableString(record.stockStatusDesc),
      deliveryRange: this.asNullableString(record.deliveryRange),
      aftersalesPolicy: this.asNullableString(record.aftersalesPolicy),
      partnerCasesDesc: this.asNullableString(record.partnerCasesDesc),
      supplyQualificationDesc: this.asNullableString(
        record.supplyQualificationDesc,
      ),
    });
  }

  private normalizeCreateCasePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ["coverImageUrl", "caseCoverUrl"]);
    return this.compact({
      boardType: this.requireBoardType(record.boardType),
      title: this.requireString(record.title, "请填写案例标题。"),
      exhibitionType: this.asNullableString(record.exhibitionType),
      city: this.asNullableString(record.city),
      eventTime: this.asNullableString(record.eventTime),
      summary: this.requireString(record.summary, "请填写案例摘要。"),
      caseCoverFileAssetId: this.asNullableString(record.caseCoverFileAssetId),
      caseMediaFileAssetIds: this.asOptionalStringArray(
        record.caseMediaFileAssetIds,
      ),
      isFeatured: this.asNullableBoolean(record.isFeatured),
    });
  }

  private normalizeUpdateCasePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ["coverImageUrl", "caseCoverUrl"]);
    if (record.boardType !== undefined) {
      throw this.badRequest(
        "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        "当前继续编辑不接受 boardType，请直接编辑当前案例内容。",
      );
    }
    return this.compact({
      title: this.requireString(record.title, "请填写案例标题。"),
      exhibitionType: this.asNullableString(record.exhibitionType),
      city: this.asNullableString(record.city),
      eventTime: this.asNullableString(record.eventTime),
      summary: this.requireString(record.summary, "请填写案例摘要。"),
      caseCoverFileAssetId: this.asNullableString(record.caseCoverFileAssetId),
      caseMediaFileAssetIds: this.asOptionalStringArray(
        record.caseMediaFileAssetIds,
      ),
      isFeatured: this.asNullableBoolean(record.isFeatured),
    });
  }

  private normalizeSubmitPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    if (record.confirm !== true) {
      throw this.badRequest(
        "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        "请先确认提交入驻申请后再继续。",
      );
    }
    return {
      confirm: record.confirm,
    };
  }

  private normalizeApplicationCreateError(error: unknown) {
    return this.normalizeEnterpriseHubTransportError(
      error,
      "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
      "当前企业展示申请信息不完整，请补齐申请人姓名、联系电话和申请板块后再试。",
      {
        400: "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
      },
      {
        AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
        ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS:
          "当前企业展示申请信息不完整，请补齐申请人姓名、联系电话和申请板块后再试。",
        ENTERPRISE_HUB_PERMISSION_DENIED:
          "当前组织身份不可用，暂时无法创建企业展示申请。",
      },
    );
  }

  private normalizeEnsureShellError(error: unknown) {
    return this.normalizeEnterpriseHubTransportError(
      error,
      "ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE",
      "当前企业展示档暂时无法准备，请稍后再试。",
      {
        400: "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        503: "ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE",
      },
      {
        AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
        ENTERPRISE_HUB_INVALID_BOARD_TYPE:
          "板块类型只允许 company、factory、supplier。",
        ENTERPRISE_HUB_PERMISSION_DENIED:
          "当前组织身份不可用，暂时无法准备企业展示档。",
        ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE:
          "当前企业展示档暂时无法准备，请稍后再试。",
      },
    );
  }

  private normalizeApplicationSubmitError(error: unknown) {
    return this.normalizeEnterpriseHubTransportError(
      error,
      "ENTERPRISE_HUB_INVALID_STATE_TRANSITION",
      "当前企业展示申请暂时无法提交，请稍后再试。",
      {
        400: "ENTERPRISE_HUB_PROFILE_NOT_COMPLETED",
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        404: "ENTERPRISE_HUB_APPLICATION_NOT_FOUND",
        409: "ENTERPRISE_HUB_INVALID_STATE_TRANSITION",
      },
      {
        AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
        ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS:
          "请先确认提交入驻申请后再继续。",
        ENTERPRISE_HUB_PERMISSION_DENIED:
          "当前组织身份不可用，暂时无法提交企业展示申请。",
        ENTERPRISE_HUB_APPLICATION_NOT_FOUND:
          "当前企业展示申请不可用，请返回工作台后再试。",
        ENTERPRISE_HUB_PROFILE_NOT_COMPLETED:
          "当前企业展示资料未完成，请先补齐基础资料和板块画像后再提交。",
        ENTERPRISE_HUB_CONTACT_REQUIRED:
          "当前企业展示联系人未完善，请先补齐联系人后再提交。",
        ENTERPRISE_HUB_CASE_REQUIRED:
          "当前企业展示案例未完善，请先补齐案例后再提交。",
        ENTERPRISE_HUB_CERTIFICATION_REQUIRED:
          "当前企业认证尚未通过，暂时无法提交入驻申请。",
        ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
          "当前申请状态暂不支持提交，请刷新后再试。",
      },
    );
  }

  private normalizeApplicationStatusError(error: unknown) {
    return this.normalizeEnterpriseHubTransportError(
      error,
      "ENTERPRISE_HUB_APPLICATION_NOT_FOUND",
      "当前企业展示申请不可用，请返回工作台后再试。",
      {
        401: "AUTH_SESSION_INVALID",
        403: "ENTERPRISE_HUB_PERMISSION_DENIED",
        404: "ENTERPRISE_HUB_APPLICATION_NOT_FOUND",
      },
      {
        AUTH_SESSION_INVALID: "当前登录态不可用，请重新登录后再试。",
        ENTERPRISE_HUB_PERMISSION_DENIED:
          "当前组织身份不可读取该企业展示申请，请重新进入我的楼后再试。",
        ENTERPRISE_HUB_APPLICATION_NOT_FOUND:
          "当前企业展示申请不可用，请返回工作台后再试。",
      },
    );
  }

  private normalizeEnterpriseHubTransportError(
    error: unknown,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>>,
    messageByCode: Partial<Record<string, string>>,
  ) {
    if (error instanceof HttpException) {
      return error;
    }

    if (isAxiosError<Record<string, unknown>>(error) && error.response) {
      const statusCode = error.response.status;
      const payload = this.asRecord(error.response.data);
      const upstreamMessage =
        typeof payload.message === "string" ? payload.message : error.message;
      const code =
        typeof payload.code === "string"
          ? payload.code
          : statusCodeMap[statusCode] ?? fallbackCode;
      const message = messageByCode[code] ?? fallbackMessage;

      return new HttpException(
        {
          statusCode,
          code,
          message,
          details: {
            transportCode: error.code ?? "unknown",
            upstreamMessage: error.message,
            originalMessage: upstreamMessage,
            ...(payload.details && typeof payload.details === "object"
              ? (payload.details as Record<string, unknown>)
              : {}),
          },
          source:
            payload.source === "bff" || payload.source === "server"
              ? payload.source
              : "server",
        },
        statusCode,
      );
    }

    return this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      statusCodeMap,
    );
  }

  private requireBoardType(value: unknown): EnterpriseHubBoardType {
    if (value === "company" || value === "factory" || value === "supplier") {
      return value;
    }
      throw this.badRequest(
        "ENTERPRISE_HUB_INVALID_BOARD_TYPE",
        "板块类型只允许 company、factory、supplier。",
      );
  }

  private requireEntityId(value: unknown, message: string) {
    return this.requireString(value, message);
  }

  private requireString(value: unknown, message: string) {
    if (typeof value === "string" && value.length > 0) {
      return value;
    }
    throw this.badRequest("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS", message);
  }

  private asOptionalString(value: unknown) {
    return typeof value === "string" && value.length > 0 ? value : undefined;
  }

  private asNullableString(value: unknown) {
    if (typeof value === "string") {
      return value;
    }
    if (value === null) {
      return null;
    }
    return undefined;
  }

  private asNullableNumber(value: unknown) {
    if (typeof value === "number" && Number.isFinite(value)) {
      return value;
    }
    if (value === null) {
      return null;
    }
    return undefined;
  }

  private asNullableBoolean(value: unknown) {
    if (typeof value === "boolean") {
      return value;
    }
    if (value === null) {
      return null;
    }
    return undefined;
  }

  private asRequiredStringArray(value: unknown, message: string) {
    const normalized = this.asStringArray(value);
    if (normalized.length === 0) {
      throw this.badRequest("ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS", message);
    }
    return normalized;
  }

  private asOptionalStringArray(value: unknown) {
    if (value === undefined) {
      return undefined;
    }
    if (value === null) {
      return [] as string[];
    }
    return this.asStringArray(value);
  }

  private asStringArray(value: unknown) {
    if (!Array.isArray(value)) {
      return [] as string[];
    }
    return value.filter((item): item is string => typeof item === "string");
  }

  private assertFixedBoardIdentity(
    value: unknown,
    expectedBoardType: EnterpriseHubBoardType,
    message: string,
  ) {
    if (value === undefined) {
      return;
    }
    if (this.requireBoardType(value) !== expectedBoardType) {
      throw this.badRequest('ENTERPRISE_HUB_INVALID_BOARD_TYPE', message);
    }
  }

  private asRecord(value: unknown) {
    return value !== null && typeof value === "object"
      ? (value as Record<string, unknown>)
      : {};
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === "object" && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new BadRequestException({
      statusCode: 400,
      code: "ENTERPRISE_LOCATION_RESOLVE_INVALID",
      message,
      source: "bff",
    });
  }

  private compact(record: Record<string, unknown>) {
    return Object.fromEntries(
      Object.entries(record).filter(([, value]) => value !== undefined),
    );
  }

  private assertNoUrlTruth(record: Record<string, unknown>, keys: string[]) {
    for (const key of keys) {
      if (typeof record[key] === "string" && record[key] !== "") {
        throw this.badRequest(
          "ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS",
          `${key} is not accepted. Use file_asset_id fields instead.`,
        );
      }
    }
  }

  private badRequest(code: string, message: string) {
    return new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: "bff",
    });
  }

  private readTraceId(headers: IncomingHttpHeaders) {
    const traceId = headers["x-trace-id"];
    if (typeof traceId === "string" && traceId.length > 0) {
      return traceId;
    }

    const requestId = headers["x-request-id"];
    if (typeof requestId === "string" && requestId.length > 0) {
      return requestId;
    }

    return "missing";
  }
}

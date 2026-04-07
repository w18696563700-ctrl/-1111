import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import {
  toActionAckResponse,
  toEnterpriseHubApplicationStatusResponse,
  toEnterpriseHubCaseCreateResponse,
  toEnterpriseHubCreateApplicationResponse,
  toEnterpriseHubDetailResponse,
  toEnterpriseHubListResponse,
  toEnterpriseHubRecommendationListResponse,
} from './enterprise-hub.read-model';

type EnterpriseHubBoardType = 'company' | 'factory' | 'supplier';

type EnterpriseHubListQuery = {
  boardType?: string;
  keyword?: string;
  provinceCode?: string;
  cityCode?: string;
  certifiedOnly?: string;
  sortBy?: string;
  exhibitionType?: string;
  serviceCity?: string;
  caseCountRange?: string;
  reputationLevel?: string;
  processType?: string;
  plantAreaRange?: string;
  urgentCapability?: string;
  warehouseCapability?: string;
  supplyCategory?: string;
  supplyMode?: string;
  responseLevel?: string;
  page?: string;
  pageSize?: string;
};

const ENTERPRISE_LIST_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises'),
  errorCodes: [
    requireErrorCode('ENTERPRISE_HUB_INVALID_BOARD_TYPE'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

const ENTERPRISE_DETAIL_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}'),
  errorCodes: [
    requireErrorCode('ENTERPRISE_HUB_INVALID_BOARD_TYPE'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

const ENTERPRISE_RECOMMENDATIONS_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/recommendations'),
  errorCodes: [
    requireErrorCode('ENTERPRISE_HUB_INVALID_BOARD_TYPE'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

const ENTERPRISE_APPLICATION_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/applications'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

const ENTERPRISE_BASIC_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
  ],
} as const;

const ENTERPRISE_COMPANY_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/company'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
  ],
} as const;

const ENTERPRISE_FACTORY_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/factory'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
  ],
} as const;

const ENTERPRISE_SUPPLIER_PROFILE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/profiles/supplier'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
  ],
} as const;

const ENTERPRISE_CASE_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS'),
  ],
} as const;

const ENTERPRISE_APPLICATION_SUBMIT_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/applications/{applicationId}/submit'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_APPLICATION_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PROFILE_NOT_COMPLETED'),
    requireErrorCode('ENTERPRISE_HUB_CERTIFICATION_REQUIRED'),
    requireErrorCode('ENTERPRISE_HUB_CONTACT_REQUIRED'),
    requireErrorCode('ENTERPRISE_HUB_CASE_REQUIRED'),
    requireErrorCode('ENTERPRISE_HUB_INVALID_STATE_TRANSITION'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

const ENTERPRISE_APPLICATION_STATUS_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/applications/{applicationId}'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_APPLICATION_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

@Injectable()
export class EnterpriseHubService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async listEnterprises(headers: IncomingHttpHeaders, query: EnterpriseHubListQuery) {
    void ENTERPRISE_LIST_ROUTE_CONTRACT;
    const boardType = this.requireBoardType(query.boardType);

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/exhibition/enterprise-hub/enterprises',
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
          params: this.buildListParams(query, boardType),
        },
      );
      return toEnterpriseHubListResponse(result, { boardType });
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        'Enterprise hub list aggregation failed.',
        {
          400: 'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        },
      );
    }
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
      'Enterprise id is required.',
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}`,
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
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
        'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        'Enterprise hub detail aggregation failed.',
        {
          400: 'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        },
      );
    }
  }

  async getRecommendations(
    headers: IncomingHttpHeaders,
    boardType: string | undefined,
  ) {
    void ENTERPRISE_RECOMMENDATIONS_ROUTE_CONTRACT;
    const normalizedBoardType = this.requireBoardType(boardType);

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/exhibition/enterprise-hub/recommendations',
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
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
        'ENTERPRISE_HUB_PERMISSION_DENIED',
        'Enterprise hub recommendation aggregation failed.',
        {
          400: 'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
        },
      );
    }
  }

  async createApplication(
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_APPLICATION_CREATE_ROUTE_CONTRACT;
    const command = this.normalizeCreateApplicationPayload(payload);

    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/exhibition/enterprise-hub/applications',
        command,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return toEnterpriseHubCreateApplicationResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        'Enterprise hub application create failed.',
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
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
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/basic`,
      this.normalizeBasicPayload(payload),
      headers,
      'Enterprise hub basic profile update failed.',
    );
  }

  async updateCompanyProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_COMPANY_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/profiles/company`,
      this.normalizeCompanyProfilePayload(payload),
      headers,
      'Enterprise hub company profile update failed.',
    );
  }

  async updateFactoryProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_FACTORY_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/profiles/factory`,
      this.normalizeFactoryProfilePayload(payload),
      headers,
      'Enterprise hub factory profile update failed.',
    );
  }

  async updateSupplierProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_SUPPLIER_PROFILE_UPDATE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/profiles/supplier`,
      this.normalizeSupplierProfilePayload(payload),
      headers,
      'Enterprise hub supplier profile update failed.',
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
      'Enterprise id is required.',
    );
    const command = this.normalizeCreateCasePayload(payload);

    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/cases`,
        command,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return toEnterpriseHubCaseCreateResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        'Enterprise hub case create failed.',
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
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
      'Application id is required.',
    );
    const command = this.normalizeSubmitPayload(payload);

    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/applications/${normalizedApplicationId}/submit`,
        command,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        'Enterprise hub application submit failed.',
        {
          400: 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
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
      'Application id is required.',
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/applications/${normalizedApplicationId}`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return toEnterpriseHubApplicationStatusResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
        'Enterprise hub application status aggregation failed.',
        {
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
        },
      );
    }
  }

  private async sendPut(
    path: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
    fallbackMessage: string,
  ) {
    try {
      const result = await this.serverClient.put<Record<string, unknown>>(
        path,
        payload,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        fallbackMessage,
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        },
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
      certifiedOnly: this.asOptionalString(query.certifiedOnly),
      sortBy: this.asOptionalString(query.sortBy),
      exhibitionType: this.asOptionalString(query.exhibitionType),
      serviceCity: this.asOptionalString(query.serviceCity),
      caseCountRange: this.asOptionalString(query.caseCountRange),
      reputationLevel: this.asOptionalString(query.reputationLevel),
      processType: this.asOptionalString(query.processType),
      plantAreaRange: this.asOptionalString(query.plantAreaRange),
      urgentCapability: this.asOptionalString(query.urgentCapability),
      warehouseCapability: this.asOptionalString(query.warehouseCapability),
      supplyCategory: this.asOptionalString(query.supplyCategory),
      supplyMode: this.asOptionalString(query.supplyMode),
      responseLevel: this.asOptionalString(query.responseLevel),
      page: this.asOptionalString(query.page),
      pageSize: this.asOptionalString(query.pageSize),
    };
  }

  private normalizeCreateApplicationPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return {
      applyBoardType: this.requireBoardType(record.applyBoardType),
      applicantName: this.requireString(record.applicantName, 'Applicant name is required.'),
      applicantMobile: this.requireString(
        record.applicantMobile,
        'Applicant mobile is required.',
      ),
    };
  }

  private normalizeBasicPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ['logoUrl', 'coverImageUrl']);
    return this.compact({
      name: this.asNullableString(record.name),
      logoFileAssetId: this.asNullableString(record.logoFileAssetId),
      coverFileAssetId: this.asNullableString(record.coverFileAssetId),
      shortIntro: this.asNullableString(record.shortIntro),
      fullIntro: this.asNullableString(record.fullIntro),
      provinceCode: this.asNullableString(record.provinceCode),
      provinceName: this.asNullableString(record.provinceName),
      cityCode: this.asNullableString(record.cityCode),
      cityName: this.asNullableString(record.cityName),
      address: this.asNullableString(record.address),
      foundedAt: this.asNullableString(record.foundedAt),
      teamSizeRange: this.asNullableString(record.teamSizeRange),
      cooperationModes: this.asOptionalStringArray(record.cooperationModes),
      contactVisible: this.asNullableBoolean(record.contactVisible),
    });
  }

  private normalizeCompanyProfilePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    return this.compact({
      exhibitionTypes: this.asRequiredStringArray(
        record.exhibitionTypes,
        'exhibitionTypes is required.',
      ),
      serviceItems: this.asRequiredStringArray(
        record.serviceItems,
        'serviceItems is required.',
      ),
      serviceCities: this.asRequiredStringArray(
        record.serviceCities,
        'serviceCities is required.',
      ),
      teamSize: this.asNullableNumber(record.teamSize),
      maxProjectScale: this.asNullableString(record.maxProjectScale),
      averageDeliveryCycleDays: this.asNullableNumber(record.averageDeliveryCycleDays),
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
      processTypes: this.asRequiredStringArray(
        record.processTypes,
        'processTypes is required.',
      ),
      coreProducts: this.asRequiredStringArray(
        record.coreProducts,
        'coreProducts is required.',
      ),
      equipmentList: this.asOptionalStringArray(record.equipmentList),
      plantAreaSqm: this.asNullableNumber(record.plantAreaSqm),
      monthlyCapacityDesc: this.asNullableString(record.monthlyCapacityDesc),
      urgentOrderCapability: this.asNullableString(record.urgentOrderCapability),
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
        'supplyCategories is required.',
      ),
      supplyMode: this.asRequiredStringArray(
        record.supplyMode,
        'supplyMode is required.',
      ),
      coreProductsOrServices: this.asRequiredStringArray(
        record.coreProductsOrServices,
        'coreProductsOrServices is required.',
      ),
      responseSlaDesc: this.asNullableString(record.responseSlaDesc),
      stockStatusDesc: this.asNullableString(record.stockStatusDesc),
      deliveryRange: this.asNullableString(record.deliveryRange),
      aftersalesPolicy: this.asNullableString(record.aftersalesPolicy),
      partnerCasesDesc: this.asNullableString(record.partnerCasesDesc),
      supplyQualificationDesc: this.asNullableString(record.supplyQualificationDesc),
    });
  }

  private normalizeCreateCasePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ['coverImageUrl', 'caseCoverUrl']);
    return this.compact({
      boardType: this.requireBoardType(record.boardType),
      title: this.requireString(record.title, 'Case title is required.'),
      exhibitionType: this.asNullableString(record.exhibitionType),
      city: this.asNullableString(record.city),
      eventTime: this.asNullableString(record.eventTime),
      summary: this.requireString(record.summary, 'Case summary is required.'),
      caseCoverFileAssetId: this.requireString(
        record.caseCoverFileAssetId,
        'caseCoverFileAssetId is required.',
      ),
      caseMediaFileAssetIds: this.asOptionalStringArray(record.caseMediaFileAssetIds),
      isFeatured: this.asNullableBoolean(record.isFeatured),
    });
  }

  private normalizeSubmitPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    if (typeof record.confirm !== 'boolean') {
      throw this.badRequest(
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        'confirm must be a boolean.',
      );
    }
    return {
      confirm: record.confirm,
    };
  }

  private requireBoardType(value: unknown): EnterpriseHubBoardType {
    if (value === 'company' || value === 'factory' || value === 'supplier') {
      return value;
    }
    throw this.badRequest(
      'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
      'boardType must be one of company, factory, or supplier.',
    );
  }

  private requireEntityId(value: unknown, message: string) {
    return this.requireString(value, message);
  }

  private requireString(value: unknown, message: string) {
    if (typeof value === 'string' && value.length > 0) {
      return value;
    }
    throw this.badRequest('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS', message);
  }

  private asOptionalString(value: unknown) {
    return typeof value === 'string' && value.length > 0 ? value : undefined;
  }

  private asNullableString(value: unknown) {
    if (typeof value === 'string') {
      return value;
    }
    if (value === null) {
      return null;
    }
    return undefined;
  }

  private asNullableNumber(value: unknown) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (value === null) {
      return null;
    }
    return undefined;
  }

  private asNullableBoolean(value: unknown) {
    if (typeof value === 'boolean') {
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
      throw this.badRequest('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS', message);
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
    return value.filter((item): item is string => typeof item === 'string');
  }

  private asRecord(value: unknown) {
    return value !== null && typeof value === 'object'
      ? (value as Record<string, unknown>)
      : {};
  }

  private compact(record: Record<string, unknown>) {
    return Object.fromEntries(
      Object.entries(record).filter(([, value]) => value !== undefined),
    );
  }

  private assertNoUrlTruth(record: Record<string, unknown>, keys: string[]) {
    for (const key of keys) {
      if (typeof record[key] === 'string' && record[key] !== '') {
        throw this.badRequest(
          'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
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
      source: 'bff',
    });
  }

  private readTraceId(headers: IncomingHttpHeaders) {
    const traceId = headers['x-trace-id'];
    if (typeof traceId === 'string' && traceId.length > 0) {
      return traceId;
    }

    const requestId = headers['x-request-id'];
    if (typeof requestId === 'string' && requestId.length > 0) {
      return requestId;
    }

    return 'missing';
  }
}

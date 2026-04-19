import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import { isAxiosError } from 'axios';
import type { IncomingHttpHeaders } from 'http';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import { ForumCommandContextService } from '../forum/forum-command-context.service';
import { toActionAckResponse } from './enterprise-hub.read-model';
import {
  toEnterpriseHubPublishedChangeCaseCreateResponse,
  toEnterpriseHubPublishedChangeCaseUpdateResponse,
  toEnterpriseHubPublishedChangeStatusResponse,
  toEnterpriseHubPublishedChangeWorkbenchResponse,
} from './enterprise-hub-published-change.read-model';

const ENTERPRISE_PUBLISHED_CHANGE_CURRENT_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current',
  ),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
  ],
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_BASIC_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_COMPANY_PROFILE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_FACTORY_PROFILE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_SUPPLIER_PROFILE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_CASE_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_CASE_UPDATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_CASE_DELETE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_SUBMIT_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit',
  ),
} as const;

const ENTERPRISE_PUBLISHED_CHANGE_STATUS_ROUTE_CONTRACT = {
  appPath: requireAppApiPath(
    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status',
  ),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
    requireErrorCode('ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND'),
    requireErrorCode('ENTERPRISE_HUB_INVALID_STATE_TRANSITION'),
    'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
  ],
} as const;

@Injectable()
export class EnterpriseHubPublishedChangeService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService,
  ) {}

  async getCurrentChange(
    enterpriseId: string,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_CURRENT_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      'Enterprise id is required.',
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/changes/current`,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toEnterpriseHubPublishedChangeWorkbenchResponse(
        this.requireRecord(result, 'Published change current response must be an object.'),
      );
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
        '当前企业展示正式修改通道暂不可用，请稍后再试。',
        {
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          400: 'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可进入正式修改通道，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE:
            '当前企业展示暂不支持进入正式修改通道。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可编辑，请刷新后再试。',
        },
      );
    }
  }

  async updateCurrentBasic(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_BASIC_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/changes/current/basic`,
      this.normalizeBasicPayload(payload),
      headers,
      '当前企业展示正式修改基础资料保存失败，请稍后再试。',
    );
  }

  async updateCurrentCompanyProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_COMPANY_PROFILE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/changes/current/profiles/company`,
      this.normalizeCompanyProfilePayload(payload),
      headers,
      '当前企业展示正式修改公司画像保存失败，请稍后再试。',
    );
  }

  async updateCurrentFactoryProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_FACTORY_PROFILE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/changes/current/profiles/factory`,
      this.normalizeFactoryProfilePayload(payload),
      headers,
      '当前企业展示正式修改工厂画像保存失败，请稍后再试。',
    );
  }

  async updateCurrentSupplierProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_SUPPLIER_PROFILE_ROUTE_CONTRACT;
    return this.sendPut(
      `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/changes/current/profiles/supplier`,
      this.normalizeSupplierProfilePayload(payload),
      headers,
      '当前企业展示正式修改供应商画像保存失败，请稍后再试。',
    );
  }

  async createCurrentCase(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_CASE_CREATE_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      'Enterprise id is required.',
    );
    const command = this.normalizeChangeCreateCasePayload(payload);

    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/changes/current/cases`,
        command,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toEnterpriseHubPublishedChangeCaseCreateResponse(result);
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        '当前企业展示正式修改案例保存失败，请稍后再试。',
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可修改该企业展示案例，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可新增案例，请刷新后再试。',
        },
      );
    }
  }

  async updateCurrentCase(
    enterpriseId: string,
    caseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_CASE_UPDATE_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      'Enterprise id is required.',
    );
    const normalizedCaseId = this.requireEntityId(caseId, 'Case id is required.');
    const command = this.normalizeUpdateCasePayload(payload);

    try {
      const result = await this.serverClient.put<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/changes/current/cases/${normalizedCaseId}`,
        command,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toEnterpriseHubPublishedChangeCaseUpdateResponse(result);
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        '当前企业展示正式修改案例保存失败，请稍后再试。',
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可修改该企业展示案例，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可编辑该案例，请刷新后再试。',
        },
      );
    }
  }

  async deleteCurrentCase(
    enterpriseId: string,
    caseId: string,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_CASE_DELETE_ROUTE_CONTRACT;
    try {
      const result = await this.serverClient.delete<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${this.requireEntityId(enterpriseId, 'Enterprise id is required.')}/changes/current/cases/${this.requireEntityId(caseId, 'Case id is required.')}`,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
        '当前企业展示正式修改案例删除失败，请稍后再试。',
        {
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可删除该企业展示案例，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可删除案例，请刷新后再试。',
        },
      );
    }
  }

  async submitCurrentChange(
    enterpriseId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_SUBMIT_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      'Enterprise id is required.',
    );
    const command = this.normalizeSubmitPayload(payload);

    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/changes/current/submit`,
        command,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        '当前企业展示修改暂时无法提交，请稍后再试。',
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可提交该企业展示修改，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS:
            '当前企业展示修改资料未完成，请先补齐后再提交。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不支持提交，请刷新后再试。',
        },
      );
    }
  }

  async getCurrentChangeStatus(
    enterpriseId: string,
    headers: IncomingHttpHeaders,
  ) {
    void ENTERPRISE_PUBLISHED_CHANGE_STATUS_ROUTE_CONTRACT;
    const normalizedEnterpriseId = this.requireEntityId(
      enterpriseId,
      'Enterprise id is required.',
    );

    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/exhibition/enterprise-hub/enterprises/${normalizedEnterpriseId}/changes/current/status`,
        {
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toEnterpriseHubPublishedChangeStatusResponse(
        this.requireRecord(result, 'Published change status response must be an object.'),
      );
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
        '当前企业展示正式修改状态暂不可用，请稍后再试。',
        {
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          400: 'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可查看正式修改状态，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE:
            '当前企业展示暂不支持进入正式修改通道。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可查看，请刷新后再试。',
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
          headers: await this.forumCommandContext.buildCommandHeaders(headers),
        },
      );
      return toActionAckResponse(result, this.readTraceId(headers));
    } catch (error) {
      throw this.normalizePublishedChangeError(
        error,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        fallbackMessage,
        {
          400: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
          404: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
          409: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
        },
        {
          AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
          ENTERPRISE_HUB_PERMISSION_DENIED:
            '当前组织身份不可修改该企业展示，请重新进入我的楼后再试。',
          ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND:
            '当前企业展示不可用，请返回企业展示工作台后再试。',
          ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS:
            '当前企业展示修改资料不完整，请补齐后再试。',
          ENTERPRISE_HUB_INVALID_STATE_TRANSITION:
            '当前企业展示修改状态暂不可编辑，请刷新后再试。',
        },
      );
    }
  }

  private normalizeBasicPayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ['logoUrl']);
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
      supplyQualificationDesc: this.asNullableString(
        record.supplyQualificationDesc,
      ),
    });
  }

  private normalizeChangeCreateCasePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ['coverImageUrl', 'caseCoverUrl']);
    if (record.boardType !== undefined) {
      throw this.badRequest(
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        '当前正式修改通道新增案例不接受 boardType，请直接填写案例内容。',
      );
    }
    return this.compact({
      title: this.requireString(record.title, '请填写案例标题。'),
      exhibitionType: this.asNullableString(record.exhibitionType),
      city: this.asNullableString(record.city),
      eventTime: this.asNullableString(record.eventTime),
      summary: this.requireString(record.summary, '请填写案例摘要。'),
      caseCoverFileAssetId: this.asNullableString(record.caseCoverFileAssetId),
      caseMediaFileAssetIds: this.asOptionalStringArray(
        record.caseMediaFileAssetIds,
      ),
      isFeatured: this.asNullableBoolean(record.isFeatured),
    });
  }

  private normalizeUpdateCasePayload(payload: Record<string, unknown>) {
    const record = this.asRecord(payload);
    this.assertNoUrlTruth(record, ['coverImageUrl', 'caseCoverUrl']);
    if (record.boardType !== undefined) {
      throw this.badRequest(
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        '当前正式修改通道更新案例不接受 boardType，请直接编辑当前案例内容。',
      );
    }
    return this.compact({
      title: this.requireString(record.title, '请填写案例标题。'),
      exhibitionType: this.asNullableString(record.exhibitionType),
      city: this.asNullableString(record.city),
      eventTime: this.asNullableString(record.eventTime),
      summary: this.requireString(record.summary, '请填写案例摘要。'),
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
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
        '请先确认提交本次正式修改后再继续。',
      );
    }
    return {
      confirm: true,
    };
  }

  private normalizePublishedChangeError(
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
        typeof payload.message === 'string' ? payload.message : error.message;
      const code =
        typeof payload.code === 'string'
          ? payload.code
          : statusCodeMap[statusCode] ?? fallbackCode;
      const message = messageByCode[code] ?? fallbackMessage;

      return new HttpException(
        {
          statusCode,
          code,
          message,
          details: {
            transportCode: error.code ?? 'unknown',
            upstreamMessage: error.message,
            originalMessage: upstreamMessage,
            ...(payload.details && typeof payload.details === 'object'
              ? (payload.details as Record<string, unknown>)
              : {}),
          },
          source:
            payload.source === 'bff' || payload.source === 'server'
              ? payload.source
              : 'server',
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

  private requireEntityId(value: unknown, message: string) {
    return this.requireString(value, message);
  }

  private requireString(value: unknown, message: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw this.badRequest('ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS', message);
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
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

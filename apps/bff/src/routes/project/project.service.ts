import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readProjectDetailDisplayState,
  readProjectListDisplayState,
  type ProjectDetailNameAccessReadModel,
  type ProjectListNameAccessReadModel,
} from './project-display-state.read-model';

type ProjectSummary = Record<string, unknown>;

type ProjectViewerRelation = 'owner' | 'non_owner';

const PROJECT_VIEWER_RELATIONS = new Set<ProjectViewerRelation>([
  'owner',
  'non_owner',
]);

type ProjectListItemReadModel = {
  projectId: string;
  projectNo: string;
  title: string;
  displayTitle: string;
  exhibitionName: string | null;
  brandName: string | null;
  buildingType: string;
  budgetAmount: number;
  areaSqm: number | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  plannedStartAt: string | null;
  plannedEndAt: string | null;
  state: string;
  nameAccess: ProjectListNameAccessReadModel;
  summary: ProjectSummary;
};

type ProjectDetailReadModel = ProjectListItemReadModel & {
  areaSqm: number | null;
  buildingTypeRemark: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  districtCode: string | null;
  districtName: string | null;
  detailAddress: string | null;
  scopeSummary: string | null;
  plannedStartAt: string | null;
  plannedEndAt: string | null;
  scheduleDetail: string | null;
  viewerProjectRelation: ProjectViewerRelation;
  description: string | null;
  nameAccess: ProjectDetailNameAccessReadModel;
  bidCandidates: ProjectBidCandidateReadModel[];
  bidSelection: ProjectBidSelectionReadModel | null;
};

type ProjectBidCandidateReadModel = {
  bidId: string;
  bidNo: string | null;
  bidderOrganizationId: string | null;
  bidderOrganizationName: string | null;
  quoteAmount: number | null;
  proposalSummary: string | null;
  state: string | null;
  submittedAt: string | null;
};

type ProjectBidSelectionReadModel = {
  winningBidId: string | null;
  orderId: string | null;
  contractId: string | null;
};

type ProjectLifecycleAcceptedResponse = {
  projectId: string;
  state: string;
};

type ProjectListResponse = {
  items: ProjectListItemReadModel[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

type ProjectListQuery = {
  provinceCode?: string;
  cityCode?: string;
  areaBucket?: string;
  budgetBucket?: string;
  page?: string;
  pageSize?: string;
};

type ProjectLifecycleAction = 'edit' | 'save' | 'submit' | 'publish';

type ProjectLifecycleInvalidCode =
  | 'PROJECT_CREATE_INVALID'
  | 'PROJECT_SAVE_INVALID'
  | 'PROJECT_SUBMIT_INVALID'
  | 'PROJECT_PUBLISH_INVALID';

@Injectable()
export class ProjectService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async createProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const requestBody = this.toServerCreatePayload(
        this.requireRecord(payload, 'Project create body must be an object.'),
      );
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/projects',
        requestBody,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toCreateAcceptedResponse(result);
    } catch (error) {
      throw this.normalizeCreateError(error);
    }
  }

  async getProjectEditDetail(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}/edit`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toProjectDetailReadModel(result);
    } catch (error) {
      throw this.normalizeManagedProjectError(error, '当前项目不可用。', 'edit');
    }
  }

  async saveProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/projects/save',
        this.toServerSavePayload(
          this.requireCommandRecord(payload, 'PROJECT_SAVE_INVALID', 'Project save body must be an object.'),
        ),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toLifecycleAcceptedResponse(result, 'Project save response is missing required fields.');
    } catch (error) {
      throw this.normalizeLifecycleCommandError(
        error,
        'save',
        'PROJECT_SAVE_INVALID',
        '当前项目保存参数无效，请检查后再试。',
        '当前项目保存入口暂不可用，请稍后再试。',
      );
    }
  }

  async submitProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/projects/submit',
        this.toProjectActionPayload(
          this.requireCommandRecord(payload, 'PROJECT_SUBMIT_INVALID', 'Project submit body must be an object.'),
          'PROJECT_SUBMIT_INVALID',
          '当前项目提交参数无效，请检查后再试。',
        ),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toLifecycleAcceptedResponse(result, 'Project submit response is missing required fields.');
    } catch (error) {
      throw this.normalizeLifecycleCommandError(
        error,
        'submit',
        'PROJECT_SUBMIT_INVALID',
        '当前项目提交参数无效，请检查后再试。',
        '当前项目提交流程暂不可用，请稍后再试。',
      );
    }
  }

  async publishProject(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/projects/publish',
        this.toProjectActionPayload(
          this.requireCommandRecord(payload, 'PROJECT_PUBLISH_INVALID', 'Project publish body must be an object.'),
          'PROJECT_PUBLISH_INVALID',
          '当前项目发布参数无效，请检查后再试。',
        ),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toLifecycleAcceptedResponse(result, 'Project publish response is missing required fields.');
    } catch (error) {
      throw this.normalizeLifecycleCommandError(
        error,
        'publish',
        'PROJECT_PUBLISH_INVALID',
        '当前项目发布参数无效，请检查后再试。',
        '当前项目发布入口暂不可用，请稍后再试。',
      );
    }
  }

  async getProjectList(headers: IncomingHttpHeaders, query: ProjectListQuery) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/projects',
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(
            headers,
          ),
          params: this.toListQueryParams(query),
        },
      );
      return this.toProjectListResponse(result);
    } catch (error) {
      throw this.normalizeListError(error);
    }
  }

  async getProjectDetail(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}`,
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(
            headers,
          ),
        },
      );
      return this.toProjectDetailReadModel(result);
    } catch (error) {
      throw this.normalizeDetailError(error);
    }
  }

  private normalizeCreateError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目创建入口暂不可用，请稍后再试。',
      {
        400: 'PROJECT_CREATE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const message = this.asString(payload.message);
    const rewrittenMessage = this.rewriteCreateErrorMessage(
      statusCode,
      code,
      message,
      payload,
    );

    if (!rewrittenMessage || rewrittenMessage === message) {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode,
        code,
        source: payload.source === 'server' ? 'server' : 'bff',
        message: rewrittenMessage,
      },
      statusCode,
    );
  }

  private normalizeListError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目列表暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse());
    if (
      !payload ||
      normalized.getStatus() !== 401 ||
      this.asString(payload.code) !== 'AUTH_SESSION_INVALID'
    ) {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        message: '当前登录态不可用，请重新登录或刷新后再试。',
      },
      normalized.getStatus(),
    );
  }

  private normalizeDetailError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目不可用。',
      {
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    if (!code || code !== 'AUTH_RESOURCE_UNAVAILABLE') {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode,
        source: payload.source === 'server' ? 'server' : 'bff',
        message: '当前项目不可用。',
      },
      statusCode,
    );
  }

  private normalizeManagedProjectError(
    error: unknown,
    fallbackMessage: string,
    action?: ProjectLifecycleAction,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      fallbackMessage,
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const rewrittenMessage = this.rewriteLifecycleTransportMessage(
      normalized.getStatus(),
      this.asString(payload.code),
      this.asString(payload.message),
      payload,
      action,
      null,
      fallbackMessage,
    );

    if (
      !rewrittenMessage ||
      rewrittenMessage === this.asString(payload.message) ||
      rewrittenMessage.length === 0
    ) {
      if (normalized.getStatus() !== 404 || this.asString(payload.code) !== 'AUTH_RESOURCE_UNAVAILABLE') {
        return normalized;
      }
    }

    if (!rewrittenMessage) {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        message: rewrittenMessage,
      },
      normalized.getStatus(),
    );
  }

  private normalizeLifecycleCommandError(
    error: unknown,
    action: Exclude<ProjectLifecycleAction, 'edit'>,
    invalidCode: 'PROJECT_SAVE_INVALID' | 'PROJECT_SUBMIT_INVALID' | 'PROJECT_PUBLISH_INVALID',
    invalidMessage: string,
    fallbackMessage: string,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      fallbackMessage,
      {
        400: invalidCode,
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'PROJECT_INVALID_STATE',
      },
    );
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const message = this.rewriteLifecycleTransportMessage(
      normalized.getStatus(),
      this.asString(payload.code),
      this.asString(payload.message),
      payload,
      action,
      invalidMessage,
      fallbackMessage,
    );

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        code: this.asString(payload.code) || (normalized.getStatus() === 409 ? 'PROJECT_INVALID_STATE' : invalidCode),
        message: message || fallbackMessage,
      },
      normalized.getStatus(),
    );
  }

  private readProjectId(value: string | undefined) {
    const normalized = this.asString(value);
    if (!normalized) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'AUTH_RESOURCE_UNAVAILABLE',
        message: '当前项目不可用。',
        source: 'bff',
      });
    }
    return normalized;
  }

  private toProjectListResponse(result: Record<string, unknown>): ProjectListResponse {
    if (!Array.isArray(result.items)) {
      throw new Error('Project list response is missing items.');
    }
    const pagination = this.asOptionalRecord(result.pagination);
    if (!pagination) {
      throw new Error('Project list response is missing pagination.');
    }

    return {
      items: result.items.map((item) =>
        this.toProjectListItemReadModel(this.requireProjectRecord(item)),
      ),
      pagination: this.toPaginationReadModel(pagination),
    };
  }

  private toProjectListItemReadModel(result: Record<string, unknown>): ProjectListItemReadModel {
    const displayState = readProjectListDisplayState(result);
    const projectId = this.asString(result.projectId);
    const projectNo = this.asString(result.projectNo);
    const buildingType = this.asString(result.buildingType);
    const budgetAmount = this.asFiniteNumber(result.budgetAmount);
    const state = this.asString(result.state);
    const summary = this.asOptionalRecord(result.summary);
    const title =
      displayState.nameAccess.status === 'visible'
        ? this.asString(result.title) || displayState.displayTitle
        : displayState.displayTitle;

    if (!projectId || !projectNo || !title || !buildingType || budgetAmount === undefined || !state || !summary) {
      throw new Error('Project detail response is missing required fields.');
    }

    return {
      projectId,
      projectNo,
      title,
      displayTitle: displayState.displayTitle,
      exhibitionName:
        displayState.nameAccess.status === 'visible'
          ? this.asNullableString(result.exhibitionName)
          : null,
      brandName:
        displayState.nameAccess.status === 'visible'
          ? this.asNullableString(result.brandName)
          : null,
      buildingType,
      budgetAmount,
      areaSqm: this.asNullableFiniteNumber(result.areaSqm, 'Project list response contains an invalid areaSqm field.'),
      provinceCode: this.asNullableString(result.provinceCode),
      provinceName: this.asNullableString(result.provinceName),
      cityCode: this.asNullableString(result.cityCode),
      cityName: this.asNullableString(result.cityName),
      plannedStartAt: this.asNullableDateString(result.plannedStartAt),
      plannedEndAt: this.asNullableDateString(result.plannedEndAt),
      state,
      nameAccess: displayState.nameAccess,
      summary,
    };
  }

  private toProjectDetailReadModel(result: Record<string, unknown>): ProjectDetailReadModel {
    const base = this.toProjectListItemReadModel(result);
    const displayState = readProjectDetailDisplayState(result);
    return {
      ...base,
      title:
        displayState.nameAccess.status === 'visible'
          ? this.asString(result.title) || displayState.displayTitle
          : displayState.displayTitle,
      displayTitle: displayState.displayTitle,
      areaSqm: this.asNullableFiniteNumber(result.areaSqm, 'Project detail response contains an invalid areaSqm field.'),
      buildingTypeRemark: this.asNullableString(result.buildingTypeRemark),
      provinceCode: this.asNullableString(result.provinceCode),
      provinceName: this.asNullableString(result.provinceName),
      cityCode: this.asNullableString(result.cityCode),
      cityName: this.asNullableString(result.cityName),
      districtCode: this.asNullableString(result.districtCode),
      districtName: this.asNullableString(result.districtName),
      detailAddress: this.asNullableString(result.detailAddress),
      scopeSummary: this.asNullableString(result.scopeSummary),
      plannedStartAt: this.asNullableDateString(result.plannedStartAt),
      plannedEndAt: this.asNullableDateString(result.plannedEndAt),
      scheduleDetail: this.asNullableString(result.scheduleDetail),
      viewerProjectRelation: this.asViewerProjectRelation(result.viewerProjectRelation),
      description: this.asNullableString(result.description),
      nameAccess: displayState.nameAccess,
      bidCandidates: this.toProjectBidCandidates(result.bidCandidates),
      bidSelection: this.toProjectBidSelection(result.bidSelection),
    };
  }

  private toProjectBidCandidates(value: unknown): ProjectBidCandidateReadModel[] {
    if (!Array.isArray(value)) {
      return [];
    }
    return value
      .map((item) => this.asOptionalRecord(item))
      .filter((item): item is Record<string, unknown> => item !== null)
      .map((item) => this.toProjectBidCandidate(item))
      .filter((item): item is ProjectBidCandidateReadModel => item !== null);
  }

  private toProjectBidCandidate(result: Record<string, unknown>) {
    const bidId = this.asString(result.bidId);
    if (!bidId) {
      return null;
    }
    return {
      bidId,
      bidNo: this.asNullableString(result.bidNo),
      bidderOrganizationId: this.asNullableString(result.bidderOrganizationId),
      bidderOrganizationName: this.asNullableString(result.bidderOrganizationName),
      quoteAmount: this.asNullableFiniteNumber(
        result.quoteAmount,
        'Project detail bidCandidates contains an invalid quoteAmount field.',
      ),
      proposalSummary: this.asNullableString(result.proposalSummary),
      state: this.asNullableString(result.state),
      submittedAt: this.asNullableString(result.submittedAt),
    } satisfies ProjectBidCandidateReadModel;
  }

  private toProjectBidSelection(value: unknown) {
    const record = this.asOptionalRecord(value);
    if (!record) {
      return null;
    }
    return {
      winningBidId: this.asNullableString(record.winningBidId),
      orderId: this.asNullableString(record.orderId),
      contractId: this.asNullableString(record.contractId),
    } satisfies ProjectBidSelectionReadModel;
  }

  private requireProjectRecord(value: unknown) {
    const record = this.asOptionalRecord(value);
    if (!record) {
      throw new Error('Project list response contains an invalid item.');
    }
    return record;
  }

  private toCreateAcceptedResponse(result: Record<string, unknown>) {
    return this.toLifecycleAcceptedResponse(
      result,
      'Project create response is missing required fields.',
    );
  }

  private toLifecycleAcceptedResponse(
    result: Record<string, unknown>,
    message: string,
  ): ProjectLifecycleAcceptedResponse {
    const projectId = this.asString(result.projectId);
    const state = this.asString(result.state);
    if (!projectId || !state) {
      throw new Error(message);
    }
    return { projectId, state };
  }

  private toServerCreatePayload(
    source: Record<string, unknown>,
    invalidCode: ProjectLifecycleInvalidCode = 'PROJECT_CREATE_INVALID',
  ) {
    const exhibitionName = this.asNullableString(source.exhibitionName);
    const brandName = this.asNullableString(source.brandName);
    const hasDualFieldInput = Boolean(exhibitionName || brandName);

    if (hasDualFieldInput && (!exhibitionName || !brandName)) {
      throw this.createProjectInvalidException(
        invalidCode,
        '展会名称与品牌名称必须同时提供，或仅使用传统标题模式。',
      );
    }

    const payload: Record<string, unknown> = {
      buildingType: source.buildingType,
      budgetAmount: source.budgetAmount,
    };

    if ('title' in source) {
      payload.title = source.title;
    }
    if (exhibitionName) {
      payload.exhibitionName = exhibitionName;
    }
    if (brandName) {
      payload.brandName = brandName;
    }

    const passthroughKeys = [
      'areaSqm',
      'buildingTypeRemark',
      'provinceCode',
      'provinceName',
      'cityCode',
      'cityName',
      'districtCode',
      'districtName',
      'detailAddress',
      'scopeSummary',
      'plannedStartAt',
      'plannedEndAt',
      'scheduleDetail',
      'description',
    ] as const;

    for (const key of passthroughKeys) {
      if (key in source) {
        payload[key] = source[key];
      }
    }

    return payload;
  }

  private toServerSavePayload(source: Record<string, unknown>) {
    const payload = this.toServerCreatePayload(source, 'PROJECT_SAVE_INVALID');
    payload.projectId = this.readRequiredCommandString(
      source.projectId,
      'PROJECT_SAVE_INVALID',
      '当前项目保存参数无效，请检查后再试。',
    );
    return payload;
  }

  private toProjectActionPayload(
    source: Record<string, unknown>,
    code: 'PROJECT_SUBMIT_INVALID' | 'PROJECT_PUBLISH_INVALID',
    message: string,
  ) {
    return {
      projectId: this.readRequiredCommandString(source.projectId, code, message),
    };
  }

  private toListQueryParams(query: ProjectListQuery) {
    const params: Record<string, string> = {};
    const mappings: Array<keyof ProjectListQuery> = [
      'provinceCode',
      'cityCode',
      'areaBucket',
      'budgetBucket',
      'page',
      'pageSize',
    ];

    for (const key of mappings) {
      const value = this.asString(query[key]);
      if (value) {
        params[key] = value;
      }
    }

    return params;
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }

    throw this.createProjectInvalidException('PROJECT_CREATE_INVALID', message);
  }

  private requireCommandRecord(
    value: unknown,
    code: 'PROJECT_SAVE_INVALID' | 'PROJECT_SUBMIT_INVALID' | 'PROJECT_PUBLISH_INVALID',
    message: string,
  ) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff',
    });
  }

  private asOptionalRecord(value: unknown): Record<string, unknown> | null {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    return null;
  }

  private toPaginationReadModel(result: Record<string, unknown>) {
    return {
      page: this.asPositiveInt(result.page, 'Project list response contains an invalid pagination.page field.'),
      pageSize: this.asPositiveInt(
        result.pageSize,
        'Project list response contains an invalid pagination.pageSize field.',
      ),
      total: this.asNonNegativeInt(
        result.total,
        'Project list response contains an invalid pagination.total field.',
      ),
      hasMore: this.asBoolean(
        result.hasMore,
        'Project list response contains an invalid pagination.hasMore field.',
      ),
    };
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private readRequiredCommandString(
    value: unknown,
    code: 'PROJECT_SAVE_INVALID' | 'PROJECT_SUBMIT_INVALID' | 'PROJECT_PUBLISH_INVALID',
    message: string,
  ) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }
    throw new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff',
    });
  }

  private createProjectInvalidException(code: ProjectLifecycleInvalidCode, message: string) {
    return new BadRequestException({
      statusCode: 400,
      code,
      message,
      source: 'bff',
    });
  }

  private asBoolean(value: unknown, errorMessage: string) {
    if (typeof value === 'boolean') {
      return value;
    }
    throw new Error(errorMessage);
  }

  private asPositiveInt(value: unknown, errorMessage: string) {
    const parsed = this.asFiniteNumber(value);
    if (parsed === undefined || !Number.isInteger(parsed) || parsed <= 0) {
      throw new Error(errorMessage);
    }
    return parsed;
  }

  private asNonNegativeInt(value: unknown, errorMessage: string) {
    const parsed = this.asFiniteNumber(value);
    if (parsed === undefined || !Number.isInteger(parsed) || parsed < 0) {
      throw new Error(errorMessage);
    }
    return parsed;
  }

  private asNullableString(value: unknown) {
    const normalized = this.asString(value);
    return normalized.length > 0 ? normalized : null;
  }

  private asFiniteNumber(value: unknown) {
    const normalized =
      typeof value === 'number' ? value : typeof value === 'string' && value.trim().length > 0 ? Number(value) : NaN;
    return Number.isFinite(normalized) ? normalized : undefined;
  }

  private asNullableFiniteNumber(value: unknown, errorMessage: string) {
    if (value === null || value === undefined) {
      return null;
    }

    const normalized = this.asFiniteNumber(value);
    if (normalized === undefined) {
      throw new Error(errorMessage);
    }

    return normalized;
  }

  private asNullableDateString(value: unknown) {
    const normalized = this.asNullableString(value);
    if (!normalized) {
      return null;
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(normalized)) {
      throw new Error('Project detail response contains an invalid date field.');
    }
    return normalized;
  }

  private asViewerProjectRelation(value: unknown): ProjectViewerRelation {
    const normalized = this.asString(value) as ProjectViewerRelation;
    if (PROJECT_VIEWER_RELATIONS.has(normalized)) {
      return normalized;
    }
    throw new Error('Project detail response contains an invalid viewerProjectRelation field.');
  }

  private rewriteCreateErrorMessage(
    statusCode: number,
    code: string,
    message: string,
    payload: Record<string, unknown>,
  ) {
    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }

    if (code === 'PROJECT_CREATE_INVALID') {
      return message;
    }

    if (statusCode === 404 && code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前组织不可用，请切换到可发布项目的组织后再试。';
    }

    if (statusCode !== 403 || code !== 'AUTH_PERMISSION_INSUFFICIENT') {
      return message;
    }

    const structuredReason = this.readCreateEligibilityReason(payload);
    if (structuredReason === 'organization_scope_missing') {
      return '当前组织身份不可用，请先进入可发布项目的组织后再试。';
    }
    if (structuredReason === 'organization_type_not_allowed') {
      return '当前主体不是发布方类型，请切换到可发布项目的组织后再试。';
    }
    if (structuredReason === 'buyer_role_not_allowed') {
      return '当前组织角色不具备项目发布资格，请切换到买方侧可发布角色后再试。';
    }
    if (structuredReason === 'certification_not_approved') {
      return '当前组织认证尚未通过，暂不可创建项目。';
    }

    return '当前组织不具备项目发布资格，请确认组织身份后再试。';
  }

  private rewriteLifecycleTransportMessage(
    statusCode: number,
    code: string,
    message: string,
    payload: Record<string, unknown>,
    action: ProjectLifecycleAction | undefined,
    invalidMessage: string | null,
    unavailableMessage: string,
  ) {
    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }

    if (statusCode === 404 && code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return action === 'edit' ? '当前项目不可用。' : unavailableMessage;
    }

    if (statusCode === 403 && code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return this.rewriteLifecyclePermissionMessage(payload, action);
    }

    if (statusCode === 409 && code === 'PROJECT_INVALID_STATE') {
      return this.rewriteLifecycleInvalidStateMessage(action);
    }

    if (invalidMessage && code) {
      const invalidCodes: ProjectLifecycleInvalidCode[] = [
        'PROJECT_CREATE_INVALID',
        'PROJECT_SAVE_INVALID',
        'PROJECT_SUBMIT_INVALID',
        'PROJECT_PUBLISH_INVALID',
      ];
      if (invalidCodes.includes(code as ProjectLifecycleInvalidCode)) {
        return invalidMessage;
      }
    }

    return message;
  }

  private rewriteLifecyclePermissionMessage(
    payload: Record<string, unknown>,
    action: ProjectLifecycleAction | undefined,
  ) {
    const structuredReason = this.readCreateEligibilityReason(payload);
    const suffix = this.readLifecycleActionSuffix(action);

    if (structuredReason === 'organization_scope_missing') {
      return `当前组织身份不可用，请先进入可发布项目的组织后再${suffix}。`;
    }
    if (structuredReason === 'organization_type_not_allowed') {
      return `当前主体不是发布方类型，请切换到可发布项目的组织后再${suffix}。`;
    }
    if (structuredReason === 'buyer_role_not_allowed') {
      return `当前组织角色不具备项目发布资格，请切换到买方侧可发布角色后再${suffix}。`;
    }
    if (structuredReason === 'certification_not_approved') {
      return `当前组织认证尚未通过，暂不可${suffix}项目。`;
    }

    return '当前组织不具备项目发布资格，请确认组织身份后再试。';
  }

  private rewriteLifecycleInvalidStateMessage(action: ProjectLifecycleAction | undefined) {
    if (action === 'save') {
      return '当前项目不是草稿状态，暂不支持保存。';
    }
    if (action === 'submit') {
      return '当前项目不是草稿状态，暂不支持提交。';
    }
    if (action === 'publish') {
      return '当前项目尚未提交，暂不支持发布。';
    }
    return '当前项目状态暂不允许执行该动作。';
  }

  private readLifecycleActionSuffix(action: ProjectLifecycleAction | undefined) {
    if (action === 'save') {
      return '保存';
    }
    if (action === 'submit') {
      return '提交';
    }
    if (action === 'publish') {
      return '发布';
    }
    return '操作';
  }

  private readCreateEligibilityReason(payload: Record<string, unknown>) {
    const details = this.asOptionalRecord(payload.details);
    const reason = this.asString(details?.reason);
    return reason.length > 0 ? reason : '';
  }
}

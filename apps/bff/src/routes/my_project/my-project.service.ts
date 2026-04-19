import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  MyProjectDetailReadModel,
  MyProjectEvaluationStatus,
  MyProjectFormalCompletionStatus,
  MyProjectListItemReadModel,
  MyProjectListResponse,
  MyProjectPrivateProgressBase,
  ProjectReadModel,
  ProjectShowcaseListItemReadModel,
  ProjectViewerRelation,
} from './my-project.read-model';

const FORMAL_COMPLETION_STATUSES = new Set<MyProjectFormalCompletionStatus>([
  'not_formally_completed',
  'formally_completed',
]);

const EVALUATION_STATUSES = new Set<MyProjectEvaluationStatus>([
  'not_eligible',
  'eligible',
  'submitted',
]);

const VIEWER_PROJECT_RELATIONS = new Set<ProjectViewerRelation>([
  'owner',
  'non_owner',
]);

@Injectable()
export class MyProjectService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getMyProjects(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/my/projects',
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toMyProjectListResponse(this.requireRecord(result, 'My-project list response must be an object.'));
    } catch (error) {
      throw this.normalizeListError(error);
    }
  }

  async getMyProjectDetail(projectId: string, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/my/projects/${encodeURIComponent(normalizedProjectId)}`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toMyProjectDetailReadModel(
        this.requireRecord(result, 'My-project detail response must be an object.'),
      );
    } catch (error) {
      throw this.normalizeDetailError(error);
    }
  }

  async deleteMyProject(projectId: string, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    try {
      const result = await this.serverClient.delete<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toProjectDeleteAcceptedResponse(
        this.requireRecord(result, 'My-project delete response must be an object.'),
      );
    } catch (error) {
      throw this.normalizeDeleteError(error);
    }
  }

  private normalizeListError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前我的项目暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    return this.rewriteUnauthorizedMessage(
      normalized,
      '当前登录态不可用，请重新登录或刷新后再试。',
    );
  }

  private normalizeDetailError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目不可用。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const unauthorized = this.rewriteUnauthorizedMessage(
      normalized,
      '当前登录态不可用，请重新登录或刷新后再试。',
    );
    if (unauthorized !== normalized) {
      return unauthorized;
    }

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    if (normalized.getStatus() !== 404 || this.asString(payload.code) !== 'AUTH_RESOURCE_UNAVAILABLE') {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        message: '当前项目不可用。',
      },
      normalized.getStatus(),
    );
  }

  private normalizeDeleteError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目删除入口暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'PROJECT_INVALID_STATE',
      },
    );

    const unauthorized = this.rewriteUnauthorizedMessage(
      normalized,
      '当前登录态不可用，请重新登录或刷新后再试。',
    );
    if (unauthorized !== normalized) {
      return unauthorized;
    }

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const statusCode = normalized.getStatus();
    const code = this.asString(payload.code);
    if (statusCode == 404 && code == 'AUTH_RESOURCE_UNAVAILABLE') {
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

    if (statusCode == 409 && code == 'PROJECT_INVALID_STATE') {
      return new HttpException(
        {
          ...payload,
          statusCode,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前只有草稿项目允许删除。',
        },
        statusCode,
      );
    }

    return normalized;
  }

  private rewriteUnauthorizedMessage(normalized: HttpException, message: string) {
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
        message,
      },
      normalized.getStatus(),
    );
  }

  private readProjectId(value: string) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'AUTH_RESOURCE_UNAVAILABLE',
      message: '当前项目不可用。',
      source: 'bff',
    });
  }

  private toMyProjectListResponse(result: Record<string, unknown>): MyProjectListResponse {
    return {
      ongoingProjects: this.readListItems(result.ongoingProjects, 'ongoingProjects'),
      historicalProjects: this.readListItems(result.historicalProjects, 'historicalProjects'),
    };
  }

  private readListItems(value: unknown, fieldName: string): MyProjectListItemReadModel[] {
    if (!Array.isArray(value)) {
      throw new Error(`My-project list response is missing \`${fieldName}\`.`);
    }

    return value.map((item) =>
      this.toMyProjectListItemReadModel(
        this.requireRecord(item, `My-project list item in \`${fieldName}\` must be an object.`),
      ),
    );
  }

  private toMyProjectListItemReadModel(result: Record<string, unknown>): MyProjectListItemReadModel {
    return {
      publicProject: this.toProjectShowcaseListItemReadModel(
        this.requireRecord(result.publicProject, 'My-project list item is missing publicProject.'),
      ),
      privateSummary: this.toPrivateProgress(
        this.requireRecord(result.privateSummary, 'My-project list item is missing privateSummary.'),
      ),
    };
  }

  private toMyProjectDetailReadModel(result: Record<string, unknown>): MyProjectDetailReadModel {
    return {
      publicProject: this.toProjectReadModel(
        this.requireRecord(result.publicProject, 'My-project detail response is missing publicProject.'),
      ),
      privateProgress: this.toPrivateProgress(
        this.requireRecord(result.privateProgress, 'My-project detail response is missing privateProgress.'),
      ),
    };
  }

  private toProjectDeleteAcceptedResponse(result: Record<string, unknown>) {
    const projectId = this.asString(result.projectId);
    const state = this.asString(result.state);
    if (!projectId || state !== 'deleted') {
      throw new Error('My-project delete response is missing required fields.');
    }

    return {
      projectId,
      state,
    };
  }

  private toProjectShowcaseListItemReadModel(
    result: Record<string, unknown>,
  ): ProjectShowcaseListItemReadModel {
    const projectId = this.asString(result.projectId);
    const projectNo = this.asString(result.projectNo);
    const title = this.asString(result.title);
    const buildingType = this.asString(result.buildingType);
    const budgetAmount = this.asFiniteNumber(result.budgetAmount);
    const state = this.asString(result.state);
    const summary = this.asOptionalRecord(result.summary);

    if (!projectId || !projectNo || !title || !buildingType || budgetAmount === undefined || !state || !summary) {
      throw new Error('My-project publicProject summary is missing required fields.');
    }

    return {
      projectId,
      projectNo,
      title,
      exhibitionName: this.asNullableString(result.exhibitionName),
      brandName: this.asNullableString(result.brandName),
      buildingType,
      budgetAmount,
      areaSqm: this.asNullableFiniteNumber(
        result.areaSqm,
        'My-project publicProject contains an invalid areaSqm field.',
      ),
      provinceCode: this.asNullableString(result.provinceCode),
      provinceName: this.asNullableString(result.provinceName),
      cityCode: this.asNullableString(result.cityCode),
      cityName: this.asNullableString(result.cityName),
      plannedStartAt: this.asNullableDateString(result.plannedStartAt),
      plannedEndAt: this.asNullableDateString(result.plannedEndAt),
      state,
      summary,
    };
  }

  private toProjectReadModel(result: Record<string, unknown>): ProjectReadModel {
    return {
      ...this.toProjectShowcaseListItemReadModel(result),
      buildingTypeRemark: this.asNullableString(result.buildingTypeRemark),
      districtCode: this.asNullableString(result.districtCode),
      districtName: this.asNullableString(result.districtName),
      detailAddress: this.asNullableString(result.detailAddress),
      scopeSummary: this.asNullableString(result.scopeSummary),
      scheduleDetail: this.asNullableString(result.scheduleDetail),
      description: this.asNullableString(result.description),
      // The private `my/projects/{projectId}` family is owner-scoped by the
      // upstream route contract. When the current server presenter still lags
      // the shared ProjectReadModel carrier, keep the app-facing detail shape
      // aligned without introducing a second owner truth.
      viewerProjectRelation: this.asViewerProjectRelation(result.viewerProjectRelation),
    };
  }

  private toPrivateProgress(result: Record<string, unknown>): MyProjectPrivateProgressBase {
    return {
      hasAcceptedOrder: this.asBoolean(result.hasAcceptedOrder, 'My-project private progress is missing hasAcceptedOrder.'),
      orderStatus: this.asNullableString(result.orderStatus),
      contractStatus: this.asNullableString(result.contractStatus),
      fulfillmentStatus: this.asNullableString(result.fulfillmentStatus),
      acceptanceStatus: this.asNullableString(result.acceptanceStatus),
      afterSalesOrDisputeStatus: this.asNullableString(result.afterSalesOrDisputeStatus),
      formalCompletionStatus: this.asFormalCompletionStatus(result.formalCompletionStatus),
      evaluationStatus: this.asEvaluationStatus(result.evaluationStatus),
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asOptionalRecord(value: unknown): Record<string, unknown> | null {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    return null;
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    const normalized = this.asString(value);
    return normalized ? normalized : null;
  }

  private asFiniteNumber(value: unknown) {
    const normalized =
      typeof value === 'number'
        ? value
        : typeof value === 'string' && value.trim().length > 0
          ? Number(value)
          : NaN;
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
      throw new Error('My-project publicProject contains an invalid date field.');
    }
    return normalized;
  }

  private asBoolean(value: unknown, errorMessage: string) {
    if (typeof value === 'boolean') {
      return value;
    }
    throw new Error(errorMessage);
  }

  private asFormalCompletionStatus(value: unknown): MyProjectFormalCompletionStatus {
    const normalized = this.asString(value) as MyProjectFormalCompletionStatus;
    if (FORMAL_COMPLETION_STATUSES.has(normalized)) {
      return normalized;
    }
    throw new Error('My-project private progress contains an invalid formalCompletionStatus field.');
  }

  private asEvaluationStatus(value: unknown): MyProjectEvaluationStatus {
    const normalized = this.asString(value) as MyProjectEvaluationStatus;
    if (EVALUATION_STATUSES.has(normalized)) {
      return normalized;
    }
    throw new Error('My-project private progress contains an invalid evaluationStatus field.');
  }

  private asViewerProjectRelation(value: unknown): ProjectViewerRelation {
    if (value === null || value === undefined) {
      throw new Error('My-project publicProject is missing viewerProjectRelation.');
    }

    const normalized = this.asString(value) as ProjectViewerRelation;
    if (VIEWER_PROJECT_RELATIONS.has(normalized)) {
      return normalized;
    }

    throw new Error('My-project publicProject contains an invalid viewerProjectRelation field.');
  }
}

import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

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
  buildingType: string;
  budgetAmount: number;
  areaSqm: number | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  state: string;
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
};

type ProjectListResponse = {
  items: ProjectListItemReadModel[];
};

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

  async getProjectList(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/projects',
        {
          headers: this.authContext.buildForwardHeaders(headers),
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
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toProjectDetailReadModel(result);
    } catch (error) {
      throw this.normalizeDetailError(error);
    }
  }

  private normalizeCreateError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'PROJECT_CREATE_FAILED',
      '当前项目创建失败，请稍后再试。',
      {
        400: 'PROJECT_CREATE_INVALID',
      },
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

    return {
      items: result.items.map((item) =>
        this.toProjectListItemReadModel(this.requireProjectRecord(item)),
      ),
    };
  }

  private toProjectListItemReadModel(result: Record<string, unknown>): ProjectListItemReadModel {
    const projectId = this.asString(result.projectId);
    const projectNo = this.asString(result.projectNo);
    const title = this.asString(result.title);
    const buildingType = this.asString(result.buildingType);
    const budgetAmount = this.asFiniteNumber(result.budgetAmount);
    const state = this.asString(result.state);
    const summary = this.asOptionalRecord(result.summary);

    if (!projectId || !projectNo || !title || !buildingType || budgetAmount === undefined || !state || !summary) {
      throw new Error('Project detail response is missing required fields.');
    }

    return {
      projectId,
      projectNo,
      title,
      buildingType,
      budgetAmount,
      areaSqm: this.asNullableFiniteNumber(result.areaSqm, 'Project list response contains an invalid areaSqm field.'),
      provinceCode: this.asNullableString(result.provinceCode),
      provinceName: this.asNullableString(result.provinceName),
      cityCode: this.asNullableString(result.cityCode),
      cityName: this.asNullableString(result.cityName),
      state,
      summary,
    };
  }

  private toProjectDetailReadModel(result: Record<string, unknown>): ProjectDetailReadModel {
    return {
      ...this.toProjectListItemReadModel(result),
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
    };
  }

  private requireProjectRecord(value: unknown) {
    const record = this.asOptionalRecord(value);
    if (!record) {
      throw new Error('Project list response contains an invalid item.');
    }
    return record;
  }

  private toCreateAcceptedResponse(result: Record<string, unknown>) {
    const projectId = this.asString(result.projectId);
    if (!projectId) {
      throw new Error('Project create response is missing projectId.');
    }
    return { projectId };
  }

  private toServerCreatePayload(source: Record<string, unknown>) {
    const payload: Record<string, unknown> = {
      title: source.title,
      buildingType: source.buildingType,
      budgetAmount: source.budgetAmount,
    };

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

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_CREATE_INVALID',
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

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
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
}

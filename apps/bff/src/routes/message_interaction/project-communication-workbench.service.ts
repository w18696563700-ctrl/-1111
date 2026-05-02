import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readProjectCommunicationMaterialReviewResponseReadModel,
  readProjectCommunicationWorkbenchReadModel
} from './project-communication-workbench.read-model';

const MATERIAL_REVIEW_ENTRY_KEYS = new Set([
  'publisher_effect_image_review',
  'publisher_construction_doc_review',
  'publisher_material_sample_review',
  'publisher_equipment_material_list_review',
  'publisher_service_list_review',
  'bid_project_understanding_review',
  'bid_quote_sheet_review',
  'bid_schedule_plan_review'
]);

@Injectable()
export class ProjectCommunicationWorkbenchBffService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getWorkbench(
    projectId: string | undefined,
    threadId: string | undefined,
    counterpartOrganizationId: string | undefined,
    bidId: string | undefined,
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/project-communication/workbench';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: {
          projectId: this.readRequiredParam(projectId),
          threadId: this.readRequiredParam(threadId),
          counterpartOrganizationId: this.readOptionalParam(counterpartOrganizationId),
          bidId: this.readOptionalParam(bidId)
        }
      });
      return readProjectCommunicationWorkbenchReadModel(result);
    } catch (error) {
      throw this.sanitizeRouteDrift(this.normalizeWorkbenchError(error), 'GET', path);
    }
  }

  async reviewMaterial(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    const path = '/server/project-communication/workbench/material-review';
    try {
      const result = await this.serverClient.post<unknown>(
        path,
        this.toMaterialReviewPayload(payload),
        { headers: this.buildScopedHeaders(headers) }
      );
      return readProjectCommunicationMaterialReviewResponseReadModel(result);
    } catch (error) {
      throw this.sanitizeRouteDrift(this.normalizeWorkbenchError(error), 'POST', path);
    }
  }

  private toMaterialReviewPayload(payload: Record<string, unknown>) {
    const source = this.requireBodyRecord(payload);
    const entryKey = this.readRequiredBodyString(source.entryKey, 'entryKey');
    if (!MATERIAL_REVIEW_ENTRY_KEYS.has(entryKey)) {
      throw this.badWorkbenchRequest('Material review only accepts material entry keys.');
    }
    const reviewAction = this.readRequiredBodyString(source.reviewAction, 'reviewAction');
    if (reviewAction !== 'confirm' && reviewAction !== 'request_supplement') {
      throw this.badWorkbenchRequest('Field `reviewAction` must be confirm or request_supplement.');
    }
    return {
      projectId: this.readRequiredBodyString(source.projectId, 'projectId'),
      threadId: this.readRequiredBodyString(source.threadId, 'threadId'),
      bidId: this.readOptionalBodyString(source.bidId),
      entryKey,
      reviewAction,
      feedbackReasonCodes: this.readOptionalStringArray(source.feedbackReasonCodes),
      feedbackText: this.readOptionalBodyString(source.feedbackText),
      sourceVersionToken: this.readOptionalBodyString(source.sourceVersionToken),
      idempotencyKey: this.readRequiredBodyString(source.idempotencyKey, 'idempotencyKey')
    };
  }

  private requireBodyRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw this.badWorkbenchRequest('Project communication workbench body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredParam(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      return normalized;
    }
    throw this.badWorkbenchRequest('Project communication workbench query params are invalid.');
  }

  private readOptionalParam(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : undefined;
  }

  private readRequiredBodyString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw this.badWorkbenchRequest(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalBodyString(value: unknown) {
    if (value === undefined || value === null) {
      return undefined;
    }
    if (typeof value !== 'string') {
      throw this.badWorkbenchRequest('Optional workbench field must be a string.');
    }
    const normalized = value.trim();
    return normalized ? normalized : undefined;
  }

  private readOptionalStringArray(value: unknown) {
    if (value === undefined || value === null) {
      return [];
    }
    if (!Array.isArray(value)) {
      throw this.badWorkbenchRequest('Field `feedbackReasonCodes` must be an array.');
    }
    return value
      .map((item) => (typeof item === 'string' ? item.trim() : ''))
      .filter(Boolean);
  }

  private badWorkbenchRequest(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_COMMUNICATION_WORKBENCH_INVALID',
      message,
      source: 'bff'
    });
  }

  private normalizeWorkbenchError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'PROJECT_COMMUNICATION_WORKBENCH_UNAVAILABLE',
      '当前项目工作台暂不可用，请稍后再试。',
      {
        400: 'PROJECT_COMMUNICATION_WORKBENCH_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_COMMUNICATION_WORKBENCH_FORBIDDEN',
        404: 'PROJECT_COMMUNICATION_WORKBENCH_UNAVAILABLE',
        409: 'PROJECT_COMMUNICATION_WORKBENCH_CONFLICT'
      }
    );
  }

  private sanitizeRouteDrift(error: HttpException, method: 'GET' | 'POST', path: string) {
    const payload = this.readErrorPayload(error);
    const message = String(payload.message ?? '');
    if (error.getStatus() !== 404 && !message.includes(`Cannot ${method} ${path}`)) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: 'PROJECT_COMMUNICATION_WORKBENCH_UNAVAILABLE',
        message: '当前项目工作台暂不可用，请稍后再试。',
        source: payload.source === 'bff' ? 'bff' : 'server'
      },
      error.getStatus()
    );
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders) {
    return {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers)
    };
  }

  private readOrganizationScopeHeaders(headers: IncomingHttpHeaders) {
    const result: Record<string, string> = {};
    this.assignIfPresent(result, 'x-organization-id', this.readHeader(headers, 'x-organization-id', 'x-org-id'));
    this.assignIfPresent(result, 'x-actor-role', this.readHeader(headers, 'x-actor-role', 'x-role'));
    return result;
  }

  private assignIfPresent(target: Record<string, string>, key: string, value: string | undefined) {
    if (value) {
      target[key] = value;
    }
  }

  private readHeader(headers: IncomingHttpHeaders, ...keys: string[]) {
    for (const key of keys) {
      const value = headers[key];
      if (Array.isArray(value)) {
        if (typeof value[0] === 'string' && value[0].length > 0) {
          return value[0];
        }
        continue;
      }
      if (typeof value === 'string' && value.length > 0) {
        return value;
      }
    }
    return undefined;
  }

  private readErrorPayload(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      code: 'PROJECT_COMMUNICATION_WORKBENCH_UNAVAILABLE',
      message: String(response),
      source: 'server'
    };
  }
}

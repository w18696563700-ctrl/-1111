import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';

const EXHIBITION_REPORT_SUBMIT_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/report/submit'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('AUTH_PERMISSION_INSUFFICIENT'),
    requireErrorCode('REVIEW_REPORT_INVALID'),
    requireErrorCode('REVIEW_REPORT_RESOURCE_UNAVAILABLE'),
    requireErrorCode('REVIEW_REPORT_INVALID_STATE')
  ]
} as const;

@Injectable()
export class ExhibitionReportService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async submit(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = EXHIBITION_REPORT_SUBMIT_ROUTE_CONTRACT;
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/exhibition/report/submit',
        this.requirePayloadObject(payload),
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers)
        }
      );
      void routeContract;
      return this.shapeSubmitResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'REVIEW_REPORT_RESOURCE_UNAVAILABLE',
        'Exhibition report submit is currently unavailable.',
        {
          400: 'REVIEW_REPORT_INVALID',
          401: 'AUTH_SESSION_INVALID',
          403: 'AUTH_PERMISSION_INSUFFICIENT',
          404: 'REVIEW_REPORT_RESOURCE_UNAVAILABLE',
          409: 'REVIEW_REPORT_INVALID_STATE'
        }
      );
    }
  }

  private requirePayloadObject(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      return {};
    }
    return payload;
  }

  private shapeSubmitResponse(payload: Record<string, unknown>) {
    return {
      reportCaseId: this.readString(payload.reportCaseId),
      targetType: this.readString(payload.targetType),
      targetId: this.readString(payload.targetId),
      status: this.readString(payload.status),
      acceptMode: this.readString(payload.acceptMode),
      traceId: this.readString(payload.traceId)
    };
  }

  private readString(value: unknown) {
    return typeof value === 'string' ? value : '';
  }
}

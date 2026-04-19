import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import { ForumCommandContextService } from '../forum/forum-command-context.service';
import { toEnterpriseHubWorkbenchResponse } from './enterprise-hub-workbench.read-model';

const ENTERPRISE_WORKBENCH_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/exhibition/enterprise-hub/workbench'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('ENTERPRISE_HUB_PERMISSION_DENIED'),
  ],
} as const;

@Injectable()
export class EnterpriseHubWorkbenchService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService,
  ) {}

  async getWorkbench(headers: IncomingHttpHeaders, boardType?: string) {
    void ENTERPRISE_WORKBENCH_ROUTE_CONTRACT;
    try {
      const forwardHeaders =
        await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/exhibition/enterprise-hub/workbench',
        {
          headers: forwardHeaders,
          params: boardType ? { boardType } : undefined,
        },
      );
      return toEnterpriseHubWorkbenchResponse(result);
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'ENTERPRISE_HUB_PERMISSION_DENIED',
        '企业展示工作台聚合失败。',
        {
          401: 'AUTH_SESSION_INVALID',
          403: 'ENTERPRISE_HUB_PERMISSION_DENIED',
        },
      );
    }
  }
}

import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import { ForumCommandContextService } from './forum-command-context.service';

const FORUM_INTERACTION_INBOX_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/interaction/inbox'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')]
} as const;

@Injectable()
export class ForumInteractionInboxService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService
  ) {}

  async getInbox(
    headers: IncomingHttpHeaders,
    tab?: string,
    cursor?: string,
    pageSize?: string
  ) {
    try {
      const routeContract = FORUM_INTERACTION_INBOX_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/forum/interaction/inbox',
        {
          headers: forwardHeaders,
          params: {
            tab: this.asOptionalString(tab),
            cursor: this.asOptionalString(cursor),
            pageSize: this.asOptionalString(pageSize)
          }
        }
      );
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(
        error,
        'FORUM_INTERACTION_INBOX_FAILED',
        'Forum interaction inbox aggregation failed.'
      );
    }
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }
}

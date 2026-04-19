import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { ForumReportMineErrorService } from './forum-report-mine-error.service';
import {
  shapeForumReportMineDetail,
  shapeForumReportMineList,
} from './forum-report-mine.read-model';

const FORUM_REPORTS_MINE_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/reports/mine',
} as const;

const FORUM_REPORTS_MINE_DETAIL_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/reports/mine/:ticketId',
} as const;

@Injectable()
export class ForumReportMineService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ForumReportMineErrorService,
  ) {}

  async getMine(headers: IncomingHttpHeaders, limit?: string) {
    try {
      const routeContract = FORUM_REPORTS_MINE_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/reports/mine', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          limit: this.asOptionalString(limit),
        },
      });
      void routeContract;
      return shapeForumReportMineList(result);
    } catch (error) {
      throw this.errors.normalizeMineListError(error);
    }
  }

  async getMineDetail(headers: IncomingHttpHeaders, ticketId: string) {
    try {
      const routeContract = FORUM_REPORTS_MINE_DETAIL_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/forum/reports/mine/${encodeURIComponent(ticketId)}`,
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      void routeContract;
      return shapeForumReportMineDetail(result);
    } catch (error) {
      throw this.errors.normalizeMineDetailError(error);
    }
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }
}

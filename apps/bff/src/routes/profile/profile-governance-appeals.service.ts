import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type GovernanceAppealDetailView,
  type GovernanceAppealListView,
  readGovernanceAppealDetailViewModel,
  readGovernanceAppealListViewModel,
} from './profile-governance-appeals.read-model';
import { ProfileGovernanceAppealsErrorService } from './profile-governance-appeals.error.service';

@Injectable()
export class ProfileGovernanceAppealsService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly governanceAppealErrors: ProfileGovernanceAppealsErrorService,
  ) {}

  async getAppeals(
    headers: IncomingHttpHeaders,
    query: Record<string, unknown>,
  ): Promise<GovernanceAppealListView> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/governance/appeals',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
          params: this.buildListParams(query),
        },
      );
      return readGovernanceAppealListViewModel(
        this.requireRecord(result, 'Governance appeal list response must be an object.'),
      );
    } catch (error) {
      throw this.governanceAppealErrors.normalizeListError(error);
    }
  }

  async getAppealDetail(
    headers: IncomingHttpHeaders,
    appealCaseId: string,
  ): Promise<GovernanceAppealDetailView> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/profile/governance/appeals/${encodeURIComponent(appealCaseId)}`,
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readGovernanceAppealDetailViewModel(
        this.requireRecord(result, 'Governance appeal detail response must be an object.'),
      );
    } catch (error) {
      throw this.governanceAppealErrors.normalizeDetailError(error);
    }
  }

  private buildListParams(query: Record<string, unknown>) {
    return {
      page: this.asOptionalString(query.page),
      pageSize: this.asOptionalString(query.pageSize),
      status: this.asOptionalString(query.status),
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }
}

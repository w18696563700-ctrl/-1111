import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type GovernanceStatusViewModel,
  readGovernanceStatusViewModel,
} from './profile-governance-status.read-model';
import { ProfileGovernanceStatusErrorService } from './profile-governance-status.error.service';

@Injectable()
export class ProfileGovernanceStatusService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly governanceStatusErrors: ProfileGovernanceStatusErrorService,
  ) {}

  async getStatus(headers: IncomingHttpHeaders): Promise<GovernanceStatusViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/governance/status',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readGovernanceStatusViewModel(
        this.requireRecord(result, 'Governance status response must be an object.'),
      );
    } catch (error) {
      throw this.governanceStatusErrors.normalizeStatusError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }
}

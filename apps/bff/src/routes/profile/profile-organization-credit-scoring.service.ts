import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type OrganizationCreditScoringExplanationViewModel,
  type OrganizationCreditScoringHandoffViewModel,
  type OrganizationCreditScoringStatusViewModel,
  readOrganizationCreditScoringExplanationViewModel,
  readOrganizationCreditScoringHandoffViewModel,
  readOrganizationCreditScoringStatusViewModel,
} from './profile-organization-credit-scoring.read-model';
import { ProfileOrganizationCreditScoringErrorService } from './profile-organization-credit-scoring-error.service';

@Injectable()
export class ProfileOrganizationCreditScoringService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly organizationCreditScoringErrors: ProfileOrganizationCreditScoringErrorService,
  ) {}

  async getStatus(
    headers: IncomingHttpHeaders,
  ): Promise<OrganizationCreditScoringStatusViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/organization-credit-scoring/status',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readOrganizationCreditScoringStatusViewModel(
        this.requireRecord(result, 'Organization-credit-scoring status response must be an object.'),
      );
    } catch (error) {
      throw this.organizationCreditScoringErrors.normalizeStatusError(error);
    }
  }

  async getExplanation(
    headers: IncomingHttpHeaders,
  ): Promise<OrganizationCreditScoringExplanationViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/organization-credit-scoring/explanation',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readOrganizationCreditScoringExplanationViewModel(
        this.requireRecord(
          result,
          'Organization-credit-scoring explanation response must be an object.',
        ),
      );
    } catch (error) {
      throw this.organizationCreditScoringErrors.normalizeExplanationError(error);
    }
  }

  async getHandoff(
    headers: IncomingHttpHeaders,
  ): Promise<OrganizationCreditScoringHandoffViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/organization-credit-scoring/handoff',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readOrganizationCreditScoringHandoffViewModel(
        this.requireRecord(result, 'Organization-credit-scoring handoff response must be an object.'),
      );
    } catch (error) {
      throw this.organizationCreditScoringErrors.normalizeHandoffError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }
}

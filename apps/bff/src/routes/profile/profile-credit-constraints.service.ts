import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type CreditConstraintsExplanationViewModel,
  type CreditConstraintsHandoffViewModel,
  type CreditConstraintsStatusViewModel,
  readCreditConstraintsExplanationViewModel,
  readCreditConstraintsHandoffViewModel,
  readCreditConstraintsStatusViewModel,
} from './profile-credit-constraints.read-model';
import { ProfileCreditConstraintsErrorService } from './profile-credit-constraints-error.service';

@Injectable()
export class ProfileCreditConstraintsService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly creditConstraintsErrors: ProfileCreditConstraintsErrorService,
  ) {}

  async getStatus(headers: IncomingHttpHeaders): Promise<CreditConstraintsStatusViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/credit-and-constraints/status',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readCreditConstraintsStatusViewModel(
        this.requireRecord(result, 'Credit-and-constraints status response must be an object.'),
      );
    } catch (error) {
      throw this.creditConstraintsErrors.normalizeStatusError(error);
    }
  }

  async getExplanation(
    headers: IncomingHttpHeaders,
  ): Promise<CreditConstraintsExplanationViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/credit-and-constraints/explanation',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readCreditConstraintsExplanationViewModel(
        this.requireRecord(result, 'Credit-and-constraints explanation response must be an object.'),
      );
    } catch (error) {
      throw this.creditConstraintsErrors.normalizeExplanationError(error);
    }
  }

  async getHandoff(headers: IncomingHttpHeaders): Promise<CreditConstraintsHandoffViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/credit-and-constraints/handoff',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readCreditConstraintsHandoffViewModel(
        this.requireRecord(result, 'Credit-and-constraints handoff response must be an object.'),
      );
    } catch (error) {
      throw this.creditConstraintsErrors.normalizeHandoffError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }
}

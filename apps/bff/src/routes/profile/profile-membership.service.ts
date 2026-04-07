import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type MembershipCurrentViewModel,
  type MembershipExplanationViewModel,
  type MembershipQuotaViewModel,
  type MembershipUpgradeGuideViewModel,
  readMembershipCurrentViewModel,
  readMembershipExplanationViewModel,
  readMembershipQuotaViewModel,
  readMembershipUpgradeGuideViewModel,
} from './profile-membership.read-model';
import { ProfileMembershipErrorService } from './profile-membership-error.service';

@Injectable()
export class ProfileMembershipService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly membershipErrors: ProfileMembershipErrorService,
  ) {}

  async getCurrent(headers: IncomingHttpHeaders): Promise<MembershipCurrentViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/membership/current',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readMembershipCurrentViewModel(
        this.requireRecord(result, 'Membership current response must be an object.'),
      );
    } catch (error) {
      throw this.membershipErrors.normalizeCurrentError(error);
    }
  }

  async getExplanation(headers: IncomingHttpHeaders): Promise<MembershipExplanationViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/membership/explanation',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readMembershipExplanationViewModel(
        this.requireRecord(result, 'Membership explanation response must be an object.'),
      );
    } catch (error) {
      throw this.membershipErrors.normalizeExplanationError(error);
    }
  }

  async getQuota(headers: IncomingHttpHeaders): Promise<MembershipQuotaViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/membership/quota',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readMembershipQuotaViewModel(
        this.requireRecord(result, 'Membership quota response must be an object.'),
      );
    } catch (error) {
      throw this.membershipErrors.normalizeQuotaError(error);
    }
  }

  async getUpgradeGuide(headers: IncomingHttpHeaders): Promise<MembershipUpgradeGuideViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/membership/upgrade-guide',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return readMembershipUpgradeGuideViewModel(
        this.requireRecord(result, 'Membership upgrade guide response must be an object.'),
      );
    } catch (error) {
      throw this.membershipErrors.normalizeUpgradeGuideError(error);
    }
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }
}

import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  CertificationAcceptedViewModel,
  OrganizationCreateAcceptedViewModel,
  OrganizationJoinAcceptedViewModel,
  PersonalProfileAcceptedViewModel,
  ProfileShellContextCompatibleViewModel,
} from './profile-command.read-model';
import { ProfileCommandErrorService } from './profile-command-error.service';
import {
  readCertificationStatus,
  readMembershipStatus,
} from './profile-status.read-model';

@Injectable()
export class ProfileCommandService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly commandErrors: ProfileCommandErrorService,
  ) {}

  async createOrganization(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/organization/create',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toOrganizationCreateAcceptedViewModel(
        this.requireRecord(result, 'Organization create response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizeOrganizationCreateError(error);
    }
  }

  async joinOrganizationByCode(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/organization/join-by-code',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return await this.toOrganizationJoinAcceptedViewModel(
        this.requireRecord(result, 'Organization join response must be an object.'),
        headers,
      );
    } catch (error) {
      throw this.commandErrors.normalizeOrganizationJoinError(error);
    }
  }

  async switchOrganization(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/organization/switch',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toShellContextCompatibleViewModel(
        this.requireRecord(result, 'Organization switch response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizeOrganizationSwitchError(error);
    }
  }

  async submitCertification(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/certification/submit',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toCertificationAcceptedViewModel(
        this.requireRecord(result, 'Certification submit response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizeCertificationSubmitError(error);
    }
  }

  async resubmitCertification(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/certification/resubmit',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toCertificationAcceptedViewModel(
        this.requireRecord(result, 'Certification resubmit response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizeCertificationResubmitError(error);
    }
  }

  async updatePersonalNickname(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/personal/nickname',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toPersonalProfileAcceptedViewModel(
        this.requireRecord(result, 'Personal nickname response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizePersonalNicknameError(error);
    }
  }

  async updatePersonalAvatar(
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/personal/avatar',
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toPersonalProfileAcceptedViewModel(
        this.requireRecord(result, 'Personal avatar response must be an object.'),
      );
    } catch (error) {
      throw this.commandErrors.normalizePersonalAvatarError(error);
    }
  }

  private toOrganizationCreateAcceptedViewModel(
    result: Record<string, unknown>,
  ): OrganizationCreateAcceptedViewModel {
    const organizationId = this.asString(result.organizationId);
    const roleKeys = this.readRequiredStringArray(
      result.roleKeys,
      'Organization create response is missing roleKeys.',
    );
    const membershipStatus = readMembershipStatus(
      result.membershipStatus,
      'Organization create response is missing a valid membershipStatus.',
    );
    const certificationStatus = readCertificationStatus(
      result.certificationStatus,
      'Organization create response is missing a valid certificationStatus.',
    );

    if (!organizationId) {
      throw new Error('Organization create response is missing required fields.');
    }

    return {
      organizationId,
      roleKeys,
      membershipStatus,
      certificationStatus,
    };
  }

  private async toOrganizationJoinAcceptedViewModel(
    result: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<OrganizationJoinAcceptedViewModel> {
    const organizationId = this.asString(result.organizationId);
    const membershipStatus = readMembershipStatus(
      result.membershipStatus,
      'Organization join response is missing a valid membershipStatus.',
    );
    const traceId = this.asString(result.traceId);

    if (!organizationId || !traceId) {
      throw new Error('Organization join response is missing required fields.');
    }

    const organizationSummary = await this.loadJoinedOrganizationSummary(organizationId, headers);

    return {
      organizationId,
      roleKeys: organizationSummary.roleKeys,
      membershipStatus: organizationSummary.membershipStatus,
      certificationStatus: organizationSummary.certificationStatus,
      traceId,
    };
  }

  private toShellContextCompatibleViewModel(
    result: Record<string, unknown>,
  ): ProfileShellContextCompatibleViewModel {
    const userId = this.asString(result.userId);
    const organizationId = this.asString(result.organizationId);
    const roleKeys = this.readRequiredStringArray(
      result.roleKeys,
      'Organization switch response is missing roleKeys.',
    );
    const certificationStatus = readCertificationStatus(
      result.certificationStatus,
      'Organization switch response is missing a valid certificationStatus.',
    );
    const membershipStatus = readMembershipStatus(
      result.membershipStatus,
      'Organization switch response is missing a valid membershipStatus.',
    );
    const featureFlagsVersion = this.asString(result.featureFlagsVersion);
    const unreadSummary = this.asOptionalRecord(result.unreadSummary);

    if (!userId || !organizationId || !featureFlagsVersion || !unreadSummary) {
      throw new Error('Organization switch response is missing required fields.');
    }

    return {
      userId,
      organizationId,
      roleKeys,
      certificationStatus,
      membershipStatus,
      visibleBuildings: this.asStringArray(result.visibleBuildings),
      featureFlagsVersion,
      unreadSummary,
    };
  }

  private toCertificationAcceptedViewModel(
    result: Record<string, unknown>,
  ): CertificationAcceptedViewModel {
    const organizationId = this.asString(result.organizationId);
    const certificationStatus = readCertificationStatus(
      result.certificationStatus,
      'Certification accepted response is missing a valid certificationStatus.',
    );
    const traceId = this.asString(result.traceId);

    if (!organizationId || !traceId) {
      throw new Error('Certification accepted response is missing required fields.');
    }

    return {
      organizationId,
      certificationStatus,
      submittedAt: this.asNullableString(result.submittedAt),
      traceId,
    };
  }

  private toPersonalProfileAcceptedViewModel(
    result: Record<string, unknown>,
  ): PersonalProfileAcceptedViewModel {
    const ok = result.ok === true;
    const traceId = this.asString(result.traceId);
    const displayName = this.asString(result.displayName);

    if (!ok || !traceId || !displayName) {
      throw new Error('Personal profile response is missing required fields.');
    }

    return {
      ok,
      traceId,
      displayName,
      avatarUrl: this.asNullableString(result.avatarUrl),
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asOptionalRecord(value: unknown) {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private async loadJoinedOrganizationSummary(
    organizationId: string,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/organization/mine', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.findJoinedOrganizationSummary(
        this.requireRecord(result, 'Organization join readback response must be an object.'),
        organizationId,
      );
    } catch (error) {
      throw this.commandErrors.normalizeOrganizationJoinReadbackError(error);
    }
  }

  private findJoinedOrganizationSummary(
    result: Record<string, unknown>,
    organizationId: string,
  ) {
    if (!Array.isArray(result.items)) {
      throw this.commandErrors.normalizeOrganizationJoinReadbackError(
        new Error('Organization join readback response is missing items.'),
      );
    }

    const joined = result.items.find((item) => {
      const record = this.asOptionalRecord(item);
      return record && this.asString(record.organizationId) === organizationId;
    });

    const record = this.asOptionalRecord(joined);
    if (!record) {
      throw this.commandErrors.normalizeOrganizationJoinReadbackError(
        new Error('Joined organization is missing from profile organization readback.'),
      );
    }

    return {
      roleKeys: this.readRequiredStringArray(
        record.roleKeys,
        'Joined organization readback is missing roleKeys.',
      ),
      membershipStatus: readMembershipStatus(
        record.membershipStatus,
        'Joined organization readback is missing a valid membershipStatus.',
      ),
      certificationStatus: readCertificationStatus(
        record.certificationStatus,
        'Joined organization readback is missing a valid certificationStatus.',
      ),
    };
  }

  private asStringArray(value: unknown) {
    if (!Array.isArray(value)) {
      throw new Error('Expected a string array in profile command response.');
    }

    return [...new Set(value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0))];
  }

  private readRequiredStringArray(value: unknown, message: string) {
    const items = this.asStringArray(value);
    if (!items.length) {
      throw new Error(message);
    }
    return items;
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null) {
      return null;
    }
    return this.asString(value) || null;
  }
}

import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  ActionAckViewModel,
  OrganizationMemberItemViewModel,
  OrganizationMembersViewModel,
} from './profile-members.read-model';
import { readAppRoleKey } from './profile-members.read-model';
import { ProfileMembersErrorService } from './profile-members-error.service';
import { readMembershipStatus } from './profile-status.read-model';

@Injectable()
export class ProfileMembersService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly membersErrors: ProfileMembersErrorService,
  ) {}

  async getOrganizationMembers(headers: IncomingHttpHeaders): Promise<OrganizationMembersViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/organization/members',
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return this.toOrganizationMembersViewModel(
        this.requireRecord(result, 'Organization members response must be an object.'),
      );
    } catch (error) {
      throw this.membersErrors.normalizeMembersListError(error);
    }
  }

  async patchOrganizationMemberRole(
    memberId: string,
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<ActionAckViewModel> {
    try {
      const result = await this.serverClient.patch<Record<string, unknown>>(
        `/server/profile/organization/members/${encodeURIComponent(memberId)}/role`,
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toActionAckViewModel(
        this.requireRecord(result, 'Organization member role patch response must be an object.'),
      );
    } catch (error) {
      throw this.membersErrors.normalizeMemberRolePatchError(error);
    }
  }

  async disableOrganizationMember(
    memberId: string,
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<ActionAckViewModel> {
    try {
      const result = await this.serverClient.patch<Record<string, unknown>>(
        `/server/profile/organization/members/${encodeURIComponent(memberId)}/disable`,
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toActionAckViewModel(
        this.requireRecord(result, 'Organization member disable response must be an object.'),
      );
    } catch (error) {
      throw this.membersErrors.normalizeMemberDisableError(error);
    }
  }

  private toOrganizationMembersViewModel(
    result: Record<string, unknown>,
  ): OrganizationMembersViewModel {
    if (!Array.isArray(result.items)) {
      throw new Error('Organization members response is missing items.');
    }

    return {
      items: result.items.map((item) => this.toOrganizationMemberItemViewModel(item)),
    };
  }

  private toOrganizationMemberItemViewModel(value: unknown): OrganizationMemberItemViewModel {
    const item = this.requireRecord(value, 'Organization members response contains an invalid item.');
    const memberId = this.asString(item.memberId);
    const userId = this.asString(item.userId);
    const roleKey = readAppRoleKey(
      item.roleKey,
      'Organization members response contains an invalid roleKey.',
    );
    const memberStatus = readMembershipStatus(
      item.memberStatus,
      'Organization members response contains an invalid memberStatus.',
    );

    if (!memberId || !userId) {
      throw new Error('Organization members response contains an incomplete item.');
    }

    return {
      memberId,
      userId,
      displayName: this.asNullableString(item.displayName),
      mobileMasked: this.asNullableString(item.mobileMasked),
      roleKey,
      memberStatus,
      joinedAt: this.asNullableString(item.joinedAt),
      disabledAt: this.asNullableString(item.disabledAt),
    };
  }

  private toActionAckViewModel(result: Record<string, unknown>): ActionAckViewModel {
    const traceId = this.asString(result.traceId);
    if (result.ok !== true || !traceId) {
      throw new Error('Organization members action response is missing required ack fields.');
    }

    return {
      ok: true,
      traceId,
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    return this.asString(value) || null;
  }
}

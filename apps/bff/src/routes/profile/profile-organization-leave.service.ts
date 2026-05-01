import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type { OrganizationLeaveAcceptedViewModel } from './profile-command.read-model';
import { ProfileOrganizationLeaveErrorService } from './profile-organization-leave-error.service';

@Injectable()
export class ProfileOrganizationLeaveService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly leaveErrors: ProfileOrganizationLeaveErrorService,
  ) {}

  async leaveCurrentOrganization(
    body: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/organization/current/leave',
        body ?? {},
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toAcceptedViewModel(
        this.requireRecord(result, 'Organization leave response must be an object.'),
      );
    } catch (error) {
      throw this.leaveErrors.normalize(error);
    }
  }

  private toAcceptedViewModel(
    result: Record<string, unknown>,
  ): OrganizationLeaveAcceptedViewModel {
    const leftOrganizationId = this.asString(result.leftOrganizationId);
    const nextOrganizationId = this.asNullableString(result.nextOrganizationId);
    const shellBootstrapState = this.asString(result.shellBootstrapState);
    const traceId = this.asString(result.traceId);

    if (
      !leftOrganizationId ||
      !traceId ||
      (shellBootstrapState !== 'authenticated' &&
        shellBootstrapState !== 'no_organization')
    ) {
      throw new Error('Organization leave response is missing required fields.');
    }

    return {
      leftOrganizationId,
      nextOrganizationId,
      shellBootstrapState,
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
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : null;
  }

  private asNullableString(value: unknown) {
    return value === null || value === undefined ? null : this.asString(value);
  }
}

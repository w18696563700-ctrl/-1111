import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';

@Injectable()
export class ForumCommandContextService {
  constructor(
    private readonly authContext: AuthContextService,
    private readonly serverClient: ServerClientService,
  ) {}

  async buildCommandHeaders(
    headers: IncomingHttpHeaders,
  ): Promise<Record<string, string>> {
    const forwardHeaders = this.authContext.buildForwardHeaders(headers);
    const resolvedHeaders: Record<string, string> = { ...forwardHeaders };

    if (!this.hasText(resolvedHeaders.authorization)) {
      return resolvedHeaders;
    }

    if (
      !this.hasText(resolvedHeaders['x-actor-id']) ||
      !this.hasText(resolvedHeaders['x-organization-id']) ||
      !this.hasText(resolvedHeaders['x-actor-role'])
    ) {
      await this.assignShellScope(resolvedHeaders);
    }

    if (!this.hasText(resolvedHeaders['x-organization-id'])) {
      await this.assignOrganizationScope(resolvedHeaders);
    }

    return resolvedHeaders;
  }

  private async assignShellScope(headers: Record<string, string>) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/shell/context',
        { headers },
      );
      const userId = this.asOptionalString(result.userId);
      if (!this.hasText(headers['x-actor-id']) && userId) {
        headers['x-actor-id'] = userId;
      }
      if (!this.hasText(headers['x-user-id']) && userId) {
        headers['x-user-id'] = userId;
      }

      const organizationId = this.asOptionalString(result.organizationId);
      if (!this.hasText(headers['x-organization-id']) && organizationId) {
        headers['x-organization-id'] = organizationId;
      }

      const roleKey = this.readPrimaryRoleKey(result.roleKeys);
      if (!this.hasText(headers['x-actor-role']) && roleKey) {
        headers['x-actor-role'] = roleKey;
      }
    } catch {
      return;
    }
  }

  private async assignOrganizationScope(headers: Record<string, string>) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/profile/organization/mine',
        { headers },
      );
      const items = Array.isArray(result.items)
        ? result.items
        : Array.isArray(result.organizations)
          ? result.organizations
          : [];
      const currentItem =
        items.find(
          (item) =>
            this.asRecord(item).current === true &&
            this.hasText(this.asOptionalString(this.asRecord(item).organizationId)),
        ) ?? items[0];
      const organizationId = this.asOptionalString(
        this.asRecord(currentItem).organizationId,
      );
      if (organizationId && !this.hasText(headers['x-organization-id'])) {
        headers['x-organization-id'] = organizationId;
      }
    } catch {
      return;
    }
  }

  private readPrimaryRoleKey(value: unknown): string | undefined {
    if (!Array.isArray(value)) {
      return undefined;
    }

    return value.find(
      (item): item is string =>
        typeof item === 'string' && item.trim().length > 0,
    );
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? (value as Record<string, unknown>)
      : {};
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private hasText(value: string | undefined): boolean {
    return typeof value === 'string' && value.trim().length > 0;
  }
}

import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, In, Not, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { SessionEntity } from '../identity/entities/session.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import {
  APP_ORGANIZATION_ROLE_KEYS,
  isAppFacingOrganizationType
} from '../organization/organization-scope.constants';
import {
  organizationLastAdminLeaveBlocked,
  organizationMemberLeaveInvalid,
  organizationMemberUnavailable,
  organizationScopeRequired
} from './profile.errors';

const ADMIN_ROLE_KEYS = new Set(['buyer_admin', 'supplier_admin']);

type OrganizationLeaveCommand = {
  reason: string | null;
};

type OrganizationLeaveResult = {
  leftOrganizationId: string;
  nextOrganizationId: string | null;
  shellBootstrapState: 'authenticated' | 'no_organization';
  traceId: string;
};

@Injectable()
export class ProfileOrganizationSelfLeaveService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async leaveCurrent(
    payload: Record<string, unknown> | undefined,
    context: RequestContext
  ): Promise<OrganizationLeaveResult> {
    const command = this.toLeaveCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const organizationId = this.readOrganizationId(currentSession.organizationId);

    return this.dataSource.transaction(async (manager) => {
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const organizationRepository = manager.getRepository(OrganizationEntity);
      const sessionRepository = manager.getRepository(SessionEntity);

      const organization = await organizationRepository.findOneBy({ id: organizationId });
      if (!organization || !isAppFacingOrganizationType(organization.organizationType)) {
        throw organizationMemberLeaveInvalid(
          'Current organization cannot be left through the app-facing self-leave command.'
        );
      }

      const membership = await membershipRepository.findOneBy({
        organizationId,
        userId: user.id
      });
      if (!membership) {
        throw organizationMemberUnavailable(
          'Current actor has no membership under the current organization.'
        );
      }
      if (
        membership.memberStatus !== 'active' ||
        !APP_ORGANIZATION_ROLE_KEYS.has(membership.roleKey)
      ) {
        throw organizationMemberLeaveInvalid(
          'Current membership state does not allow self-leave.'
        );
      }

      await this.ensureCanLeaveAdminRole(membershipRepository, membership);

      const nextMembership = await this.findNextActiveMembership(
        membershipRepository,
        organizationRepository,
        user.id,
        organizationId
      );
      const nextOrganizationId = nextMembership?.organizationId ?? null;

      membership.memberStatus = 'removed';
      membership.disabledAt = new Date();
      await membershipRepository.save(membership);
      await sessionRepository.update(
        { userId: user.id, organizationId, status: 'valid' },
        { organizationId: nextOrganizationId }
      );
      await this.appendAudit(
        manager,
        {
          membership,
          actorRole: membership.roleKey,
          nextOrganizationId,
          reason: command.reason
        },
        context
      );

      return {
        leftOrganizationId: organizationId,
        nextOrganizationId,
        shellBootstrapState: nextOrganizationId ? 'authenticated' : 'no_organization',
        traceId: context.traceId
      };
    });
  }

  private async ensureCanLeaveAdminRole(
    membershipRepository: Repository<OrganizationMemberEntity>,
    membership: OrganizationMemberEntity
  ) {
    if (!ADMIN_ROLE_KEYS.has(membership.roleKey)) {
      return;
    }
    const otherAdmins = await membershipRepository.count({
      where: {
        organizationId: membership.organizationId,
        memberStatus: 'active',
        id: Not(membership.id),
        roleKey: In([...ADMIN_ROLE_KEYS])
      }
    });
    if (!otherAdmins) {
      throw organizationLastAdminLeaveBlocked(
        'Current actor is the last active administrator and cannot leave this organization.'
      );
    }
  }

  private async findNextActiveMembership(
    membershipRepository: Repository<OrganizationMemberEntity>,
    organizationRepository: Repository<OrganizationEntity>,
    userId: string,
    leftOrganizationId: string
  ) {
    const memberships = await membershipRepository.find({
      where: {
        userId,
        memberStatus: 'active',
        organizationId: Not(leftOrganizationId),
        roleKey: In([...APP_ORGANIZATION_ROLE_KEYS])
      },
      order: { joinedAt: 'DESC', id: 'ASC' }
    });
    if (!memberships.length) {
      return null;
    }

    const organizations = await organizationRepository.findBy({
      id: In(memberships.map((item) => item.organizationId))
    });
    const appFacingOrganizationIds = new Set(
      organizations
        .filter((organization) => isAppFacingOrganizationType(organization.organizationType))
        .map((organization) => organization.id)
    );
    return (
      memberships.find((membership) =>
        appFacingOrganizationIds.has(membership.organizationId)
      ) ?? null
    );
  }

  private async appendAudit(
    manager: EntityManager,
    input: {
      membership: OrganizationMemberEntity;
      actorRole: string;
      nextOrganizationId: string | null;
      reason: string | null;
    },
    context: RequestContext
  ) {
    await manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: 'organization_membership',
      objectId: input.membership.id,
      objectNo: input.membership.organizationId,
      action: 'OrganizationMemberLeft',
      actorId: input.membership.userId,
      actorRole: input.actorRole,
      beforeState: 'active',
      afterState: 'removed',
      reason: this.composeReason(input.reason, input.nextOrganizationId),
      requestId: context.requestId,
      traceId: context.traceId,
      occurredAt: new Date()
    });
  }

  private toLeaveCommand(payload: Record<string, unknown> | undefined) {
    const source = payload === undefined ? {} : this.asRecord(payload);
    return {
      reason: this.readOptionalString(source.reason, 256)
    } satisfies OrganizationLeaveCommand;
  }

  private composeReason(reason: string | null, nextOrganizationId: string | null) {
    const fragments = ['action=leave_current_organization'];
    if (reason) {
      fragments.push(`reason=${reason}`);
    }
    fragments.push(`nextOrganizationId=${nextOrganizationId ?? 'null'}`);
    return fragments.join('; ');
  }

  private readOrganizationId(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw organizationScopeRequired(
        'Current organization scope is required to leave an organization.'
      );
    }
    return normalized;
  }

  private readOptionalString(value: unknown, maxLength: number) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw organizationMemberLeaveInvalid('Optional leave reason must be a string.');
    }
    const normalized = value.trim();
    if (!normalized) {
      return null;
    }
    if (normalized.length > maxLength) {
      throw organizationMemberLeaveInvalid('Optional leave reason exceeds the maximum length.');
    }
    return normalized;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw organizationMemberLeaveInvalid('Organization leave body must be an object.');
    }
    return value as Record<string, unknown>;
  }
}

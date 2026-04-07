import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, In, Not, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { ProfilePresenter } from './profile.presenter';
import {
  organizationMemberInvalid,
  organizationMemberUnavailable
} from './profile.errors';

const BUYER_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const SUPPLIER_ROLE_KEYS = new Set(['supplier_admin', 'supplier_member(scoped)']);
const APP_MEMBER_ROLE_KEYS = new Set([...BUYER_ROLE_KEYS, ...SUPPLIER_ROLE_KEYS]);
const ADMIN_ROLE_KEYS = new Set(['buyer_admin', 'supplier_admin']);

type MemberRolePatchCommand = {
  memberId: string;
  roleKey: string;
  reason: string | null;
};

type MemberDisableCommand = {
  memberId: string;
  reason: string | null;
};

@Injectable()
export class ProfileOrganizationMembersWriteService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfilePresenter
  ) {}

  async patchRole(pathMemberId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toRolePatchCommand(pathMemberId, payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const organizationId = this.readOrganizationId(currentSession.organizationId);
    const scope = await this.eligibilityService.requireOrganizationAdmin(currentSession, organizationId);
    const allowedRoleKeys = this.allowedRoleKeys(scope.organization.organizationType);
    if (!allowedRoleKeys.has(command.roleKey)) {
      throw organizationMemberInvalid(
        'Current role patch request is outside the current organization role boundary.'
      );
    }

    return this.dataSource.transaction(async (manager) => {
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const target = await membershipRepository.findOneBy({
        id: command.memberId,
        organizationId: scope.organization.id
      });
      if (!target) {
        throw organizationMemberUnavailable('Current organization member is unavailable.');
      }
      if (target.memberStatus !== 'active') {
        throw organizationMemberInvalid(
          'Current organization member role can only be patched while the membership is active.'
        );
      }
      if (target.roleKey === command.roleKey) {
        throw organizationMemberInvalid('Current organization member already holds the requested role.');
      }

      await this.ensureAdminRemainAvailable(membershipRepository, scope.organization.id, target, command.roleKey);

      const beforeRole = target.roleKey;
      target.roleKey = command.roleKey;
      await membershipRepository.save(target);

      await this.appendAudit(manager, {
        objectId: target.id,
        objectNo: scope.organization.id,
        action: 'OrganizationMemberRoleChanged',
        actorId: currentSession.userId,
        actorRole: scope.membership.roleKey,
        beforeState: beforeRole,
        afterState: target.roleKey,
        reason: this.composeReason('role_change', command.reason)
      }, context);

      return this.presenter.toActionAck(context.traceId);
    });
  }

  async disable(pathMemberId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toDisableCommand(pathMemberId, payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const organizationId = this.readOrganizationId(currentSession.organizationId);
    const scope = await this.eligibilityService.requireOrganizationAdmin(currentSession, organizationId);

    return this.dataSource.transaction(async (manager) => {
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const target = await membershipRepository.findOneBy({
        id: command.memberId,
        organizationId: scope.organization.id
      });
      if (!target) {
        throw organizationMemberUnavailable('Current organization member is unavailable.');
      }
      if (target.memberStatus !== 'active') {
        throw organizationMemberInvalid(
          'Current organization member disable only applies to active memberships.'
        );
      }
      if (target.userId === currentSession.userId) {
        throw organizationMemberInvalid('Current actor cannot disable the active membership bound to the current session.');
      }

      await this.ensureAnotherAdminExistsForDisable(membershipRepository, scope.organization.id, target);

      const disabledAt = new Date();
      target.memberStatus = 'disabled';
      target.disabledAt = disabledAt;
      await membershipRepository.save(target);

      await this.appendAudit(manager, {
        objectId: target.id,
        objectNo: scope.organization.id,
        action: 'OrganizationMemberDisabled',
        actorId: currentSession.userId,
        actorRole: scope.membership.roleKey,
        beforeState: 'active',
        afterState: 'disabled',
        reason: this.composeReason('disable', command.reason)
      }, context);

      return this.presenter.toActionAck(context.traceId);
    });
  }

  private async ensureAdminRemainAvailable(
    membershipRepository: Repository<OrganizationMemberEntity>,
    organizationId: string,
    target: OrganizationMemberEntity,
    nextRoleKey: string
  ) {
    if (!this.isAdminRole(target.roleKey) || this.isAdminRole(nextRoleKey)) {
      return;
    }
    const activeAdmins = await membershipRepository.count({
      where: {
        organizationId,
        memberStatus: 'active',
        id: Not(target.id),
        roleKey: In([...ADMIN_ROLE_KEYS])
      }
    });
    if (!activeAdmins) {
      throw organizationMemberInvalid(
        'Current organization member role patch would leave the organization without an active admin.'
      );
    }
  }

  private async ensureAnotherAdminExistsForDisable(
    membershipRepository: Repository<OrganizationMemberEntity>,
    organizationId: string,
    target: OrganizationMemberEntity
  ) {
    if (!this.isAdminRole(target.roleKey)) {
      return;
    }
    const otherActiveAdmins = await membershipRepository.count({
      where: {
        organizationId,
        memberStatus: 'active',
        id: Not(target.id),
        roleKey: In([...ADMIN_ROLE_KEYS])
      }
    });
    if (!otherActiveAdmins) {
      throw organizationMemberInvalid(
        'Current organization member disable would leave the organization without an active admin.'
      );
    }
  }

  private appendAudit(
    manager: DataSource['manager'],
    input: {
      objectId: string;
      objectNo: string;
      action: 'OrganizationMemberRoleChanged' | 'OrganizationMemberDisabled';
      actorId: string;
      actorRole: string;
      beforeState: string;
      afterState: string;
      reason: string;
    },
    context: RequestContext
  ) {
    return manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: 'organization_membership',
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: input.action,
      actorId: input.actorId,
      actorRole: input.actorRole,
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: context.requestId,
      traceId: context.traceId,
      occurredAt: new Date()
    });
  }

  private toRolePatchCommand(pathMemberId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload, 'Organization member role patch body must be an object.');
    const memberId = this.readRequiredString(pathMemberId, 'memberId');
    return {
      memberId,
      roleKey: this.readRequiredString(source.roleKey, 'roleKey'),
      reason: this.readOptionalString(source.reason)
    } satisfies MemberRolePatchCommand;
  }

  private toDisableCommand(pathMemberId: string, payload: Record<string, unknown>) {
    const source = this.asRecord(payload, 'Organization member disable body must be an object.');
    return {
      memberId: this.readRequiredString(pathMemberId, 'memberId'),
      reason: this.readOptionalString(source.reason)
    } satisfies MemberDisableCommand;
  }

  private composeReason(action: string, reason: string | null) {
    if (!reason) {
      return `action=${action}`;
    }
    return `action=${action}; reason=${reason}`;
  }

  private readOrganizationId(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw authPermissionInsufficient(
        'Current organization scope is required for organization member management.'
      );
    }
    return normalized;
  }

  private allowedRoleKeys(organizationType: string) {
    switch (organizationType.trim()) {
      case 'buyer':
      case 'demand':
        return BUYER_ROLE_KEYS;
      case 'supplier':
        return SUPPLIER_ROLE_KEYS;
      case 'both':
        return APP_MEMBER_ROLE_KEYS;
      default:
        return new Set<string>();
    }
  }

  private isAdminRole(roleKey: string) {
    return ADMIN_ROLE_KEYS.has(roleKey);
  }

  private asRecord(value: unknown, message: string) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw organizationMemberInvalid(message);
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw organizationMemberInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw organizationMemberInvalid('Optional organization member fields must be strings when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { CurrentActorEligibilityService } from './current-actor-eligibility.service';
import { OrganizationCertificationEntity } from './entities/organization-certification.entity';
import { OrganizationInvitationEntity } from './entities/organization-invitation.entity';
import { OrganizationMemberEntity } from './entities/organization-member.entity';
import { OrganizationEntity } from './entities/organization.entity';
import {
  APP_ORGANIZATION_ROLE_KEYS,
  isAppFacingOrganizationType
} from './organization-scope.constants';
import {
  orgCreateInvalid,
  orgJoinDuplicate,
  orgJoinInvalid,
  orgSwitchInvalid,
  orgUpdateInvalid
} from './organization-auth.errors';
import { OrganizationWritePresenter } from './organization-write.presenter';

const ORGANIZATION_TYPES = new Set(['demand', 'supplier', 'both']);
const INVALID_AREA_CODE_PLACEHOLDERS = new Set(['000000']);

type OrganizationCreateCommand = {
  name: string;
  organizationType: string;
  provinceCode: string;
  cityCode: string;
  contactName: string;
  contactMobile: string;
  uscc: string | null;
  businessLicenseFileId: string | null;
  intro: string | null;
};

type OrganizationJoinByCodeCommand = {
  inviteCode: string;
};

type OrganizationSwitchCommand = {
  organizationId: string;
};

type OrganizationUpdateCurrentCommand = {
  name: string;
  provinceCode: string;
  cityCode: string;
  contactName: string;
  contactMobile: string;
  intro: string | null;
};

@Injectable()
export class OrganizationWriteService {
  constructor(
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly organizationMemberRepository: Repository<OrganizationMemberEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(OrganizationInvitationEntity)
    private readonly organizationInvitationRepository: Repository<OrganizationInvitationEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: OrganizationWritePresenter
  ) {}

  async create(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCreateCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    await this.ensureBusinessLicenseFile(command.businessLicenseFileId);

    return this.dataSource.transaction(async (manager) => {
      const organization = manager.getRepository(OrganizationEntity).create({
        id: randomUUID(),
        name: command.name,
        organizationType: command.organizationType,
        provinceCode: command.provinceCode,
        cityCode: command.cityCode,
        contactName: command.contactName,
        contactMobile: command.contactMobile,
        uscc: command.uscc,
        businessLicenseFileId: command.businessLicenseFileId,
        intro: command.intro,
        status: 'draft',
        createdBy: user.id
      });
      await manager.getRepository(OrganizationEntity).save(organization);

      const roleKey = this.defaultCreatorRoleKey(command.organizationType);
      const joinedAt = new Date();
      const membership = manager.getRepository(OrganizationMemberEntity).create({
        id: randomUUID(),
        organizationId: organization.id,
        userId: user.id,
        roleKey,
        memberStatus: 'active',
        invitedBy: null,
        invitedAt: null,
        joinedAt,
        disabledAt: null
      });
      await manager.getRepository(OrganizationMemberEntity).save(membership);
      await manager.getRepository(SessionEntity).update(
        { id: currentSession.sessionId },
        { organizationId: organization.id }
      );

      await this.appendAudit(manager, {
        objectType: 'organization',
        objectId: organization.id,
        objectNo: organization.name,
        action: 'OrganizationCreated',
        actorId: user.id,
        actorRole: roleKey,
        beforeState: 'null',
        afterState: organization.status,
        reason: `organizationType=${organization.organizationType}`
      }, context);

      return this.presenter.toOrganizationCreated({
        organizationId: organization.id,
        roleKeys: [roleKey],
        membershipStatus: membership.memberStatus,
        certificationStatus: 'not_submitted'
      });
    });
  }

  async joinByCode(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toJoinByCodeCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const invitation = await this.organizationInvitationRepository.findOneBy({
      inviteCode: command.inviteCode
    });
    if (!invitation) {
      throw orgJoinInvalid('Current invite code is unavailable.');
    }
    if (!APP_ORGANIZATION_ROLE_KEYS.has(invitation.roleKey)) {
      throw orgJoinInvalid('Current invite code carries an unsupported organization role.');
    }

    const now = Date.now();
    if (invitation.expiresAt.getTime() <= now) {
      throw orgJoinInvalid('Current invite code has expired.');
    }
    if (invitation.usedAt || invitation.usedBy) {
      if (invitation.usedBy === user.id) {
        throw orgJoinDuplicate('Current actor already consumed this organization invite code.');
      }
      throw orgJoinInvalid('Current invite code has already been used.');
    }

    const organization = await this.organizationRepository.findOneBy({ id: invitation.organizationId });
    if (!organization) {
      throw orgJoinInvalid('Current invite code does not reference an available organization.');
    }

    return this.dataSource.transaction(async (manager) => {
      const membershipRepository = manager.getRepository(OrganizationMemberEntity);
      const invitationRepository = manager.getRepository(OrganizationInvitationEntity);
      const existingMembership = await membershipRepository.findOneBy({
        organizationId: organization.id,
        userId: user.id
      });
      if (existingMembership && existingMembership.memberStatus !== 'removed') {
        throw orgJoinDuplicate('Current actor already belongs to the target organization.');
      }

      const joinedAt = new Date();
      const membership =
        existingMembership ??
        membershipRepository.create({
          id: randomUUID(),
          organizationId: organization.id,
          userId: user.id
        });
      const beforeState = existingMembership?.memberStatus ?? 'null';

      membership.roleKey = invitation.roleKey;
      membership.memberStatus = 'active';
      membership.invitedBy = invitation.inviterUserId;
      membership.invitedAt = membership.invitedAt ?? joinedAt;
      membership.joinedAt = joinedAt;
      membership.disabledAt = null;

      invitation.usedAt = joinedAt;
      invitation.usedBy = user.id;

      await membershipRepository.save(membership);
      await invitationRepository.save(invitation);
      await this.appendAudit(manager, {
        objectType: 'organization_membership',
        objectId: membership.id,
        objectNo: organization.id,
        action: 'OrganizationJoinRequested',
        actorId: user.id,
        actorRole: membership.roleKey,
        beforeState,
        afterState: membership.memberStatus,
        reason: `invitationId=${invitation.id}; organizationId=${organization.id}`
      }, context);

      return this.presenter.toOrganizationJoined({
        organizationId: organization.id,
        membershipStatus: membership.memberStatus,
        traceId: context.traceId
      });
    });
  }

  async switch(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSwitchCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);

    const organization = await this.organizationRepository.findOneBy({ id: command.organizationId });
    if (!organization) {
      throw orgSwitchInvalid('Current organization switch target is unavailable.');
    }
    const membership = await this.organizationMemberRepository.findOneBy({
      organizationId: organization.id,
      userId: user.id,
      memberStatus: 'active'
    });
    if (!membership) {
      throw orgSwitchInvalid('Current actor cannot switch to the requested organization.');
    }
    if (
      !APP_ORGANIZATION_ROLE_KEYS.has(membership.roleKey) ||
      !isAppFacingOrganizationType(organization.organizationType)
    ) {
      throw orgSwitchInvalid('Current actor cannot switch to the requested organization.');
    }
    const certification = await this.organizationCertificationRepository.findOne({
      where: { organizationId: organization.id },
      order: { updatedAt: 'DESC' }
    });

    const beforeState = this.readOptionalId(currentSession.organizationId) ?? 'null';
    const shouldWriteAudit = beforeState !== organization.id;

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(SessionEntity).update(
        { id: currentSession.sessionId },
        { organizationId: organization.id }
      );
      if (shouldWriteAudit) {
        await this.appendAudit(
          manager,
          {
            objectType: 'organization_scope',
            objectId: organization.id,
            objectNo: organization.name,
            action: 'OrganizationSwitched',
            actorId: user.id,
            actorRole: membership.roleKey,
            beforeState,
            afterState: organization.id,
            reason: `membershipId=${membership.id}`
          },
          context
        );
      }
    });

    return this.presenter.toSwitchedShellContext({
      userId: user.id,
      organizationId: organization.id,
      roleKeys: [membership.roleKey],
      certificationStatus: certification?.certificationStatus ?? 'not_submitted',
      membershipStatus: membership.memberStatus
    });
  }

  async updateCurrent(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toUpdateCurrentCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const currentOrganizationId = this.readOptionalId(currentSession.organizationId);
    if (!currentOrganizationId) {
      throw orgUpdateInvalid('Current organization scope is required for organization update.');
    }
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.requireOrganizationAdmin(
      currentSession,
      currentOrganizationId
    );

    return this.dataSource.transaction(async (manager) => {
      const organizationRepository = manager.getRepository(OrganizationEntity);
      const organization = await organizationRepository.findOneBy({
        id: scope.organization.id
      });
      if (!organization) {
        throw orgUpdateInvalid('Current organization update target is unavailable.');
      }

      organization.name = command.name;
      organization.provinceCode = command.provinceCode;
      organization.cityCode = command.cityCode;
      organization.contactName = command.contactName;
      organization.contactMobile = command.contactMobile;
      organization.intro = command.intro;
      await organizationRepository.save(organization);

      await this.appendAudit(
        manager,
        {
          objectType: 'organization',
          objectId: organization.id,
          objectNo: organization.name,
          action: 'OrganizationUpdated',
          actorId: user.id,
          actorRole: scope.membership.roleKey,
          beforeState: organization.status,
          afterState: organization.status,
          reason: 'fields=name,provinceCode,cityCode,contactName,contactMobile,intro'
        },
        context
      );

      return this.presenter.toActionAck(context.traceId);
    });
  }

  private async ensureBusinessLicenseFile(fileId: string | null) {
    if (!fileId) {
      return;
    }
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: fileId });
    if (!fileAsset) {
      throw orgCreateInvalid('Current organization create request references an unavailable license file truth.');
    }
  }

  private async appendAudit(
    manager: EntityManager,
    input: {
      objectType: string;
      objectId: string;
      objectNo: string;
      action:
        | 'OrganizationCreated'
        | 'OrganizationJoinRequested'
        | 'OrganizationSwitched'
        | 'OrganizationUpdated';
      actorId: string;
      actorRole: string;
      beforeState: string;
      afterState: string;
      reason: string;
    },
    context: RequestContext
  ) {
    await manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: input.objectType,
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

  private toCreateCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, orgCreateInvalid, 'Organization create body must be an object.');
    const organizationType = this.readRequiredString(
      source.organizationType,
      'organizationType',
      orgCreateInvalid,
      32
    );
    if (!ORGANIZATION_TYPES.has(organizationType)) {
      throw orgCreateInvalid('Field `organizationType` is outside the current minimum organization boundary.');
    }

    return {
      name: this.readRequiredString(source.name, 'name', orgCreateInvalid, 256),
      organizationType,
      provinceCode: this.readRequiredAreaCode(
        source.provinceCode,
        'provinceCode',
        orgCreateInvalid,
        32
      ),
      cityCode: this.readRequiredAreaCode(source.cityCode, 'cityCode', orgCreateInvalid, 32),
      contactName: this.readRequiredString(
        source.contactName,
        'contactName',
        orgCreateInvalid,
        128
      ),
      contactMobile: this.readRequiredString(
        source.contactMobile,
        'contactMobile',
        orgCreateInvalid,
        32
      ),
      uscc: this.readOptionalString(source.uscc, orgCreateInvalid, 64),
      businessLicenseFileId: this.readOptionalString(
        source.businessLicenseFileId,
        orgCreateInvalid,
        64
      ),
      intro: this.readOptionalString(source.intro, orgCreateInvalid)
    } satisfies OrganizationCreateCommand;
  }

  private toUpdateCurrentCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      orgUpdateInvalid,
      'Organization update body must be an object.'
    );
    return {
      name: this.readRequiredString(source.name, 'name', orgUpdateInvalid, 256),
      provinceCode: this.readRequiredAreaCode(
        source.provinceCode,
        'provinceCode',
        orgUpdateInvalid,
        32
      ),
      cityCode: this.readRequiredAreaCode(source.cityCode, 'cityCode', orgUpdateInvalid, 32),
      contactName: this.readRequiredString(
        source.contactName,
        'contactName',
        orgUpdateInvalid,
        128
      ),
      contactMobile: this.readRequiredString(
        source.contactMobile,
        'contactMobile',
        orgUpdateInvalid,
        32
      ),
      intro: this.readOptionalString(source.intro, orgUpdateInvalid)
    } satisfies OrganizationUpdateCurrentCommand;
  }

  private toJoinByCodeCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, orgJoinInvalid, 'Organization join body must be an object.');
    return {
      inviteCode: this.readRequiredString(source.inviteCode, 'inviteCode', orgJoinInvalid, 128)
    } satisfies OrganizationJoinByCodeCommand;
  }

  private toSwitchCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, orgSwitchInvalid, 'Organization switch body must be an object.');
    return {
      organizationId: this.readRequiredString(
        source.organizationId,
        'organizationId',
        orgSwitchInvalid,
        64
      )
    } satisfies OrganizationSwitchCommand;
  }

  private defaultCreatorRoleKey(organizationType: string) {
    return organizationType === 'supplier' ? 'supplier_admin' : 'buyer_admin';
  }

  private readRequiredString(
    value: unknown,
    field: string,
    errorFactory: (message: string) => Error,
    maxLength?: number
  ) {
    if (typeof value !== 'string') {
      throw errorFactory(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw errorFactory(`Field \`${field}\` is required.`);
    }
    if (maxLength && normalized.length > maxLength) {
      throw errorFactory(`Field \`${field}\` exceeds the current maximum length.`);
    }
    return normalized;
  }

  private readRequiredAreaCode(
    value: unknown,
    field: string,
    errorFactory: (message: string) => Error,
    maxLength?: number
  ) {
    const normalized = this.readRequiredString(value, field, errorFactory, maxLength);
    if (INVALID_AREA_CODE_PLACEHOLDERS.has(normalized)) {
      throw errorFactory(
        `Field \`${field}\` must carry a real administrative area code, placeholder values are not allowed.`
      );
    }
    return normalized;
  }

  private readOptionalString(
    value: unknown,
    errorFactory: (message: string) => Error,
    maxLength?: number
  ) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw errorFactory('Optional organization fields must be strings when provided.');
    }
    const normalized = value.trim();
    if (!normalized) {
      return null;
    }
    if (maxLength && normalized.length > maxLength) {
      throw errorFactory('Optional organization fields exceed the current maximum length.');
    }
    return normalized;
  }

  private asRecord(
    value: unknown,
    errorFactory: (message: string) => Error,
    message: string
  ) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw errorFactory(message);
    }
    return value as Record<string, unknown>;
  }

  private readOptionalId(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

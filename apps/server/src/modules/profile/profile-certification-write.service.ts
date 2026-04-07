import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import {
  certificationDuplicateSubmit,
  certificationResubmitInvalid,
  certificationSubmitInvalid
} from './profile.errors';
import { ProfilePresenter } from './profile.presenter';

type CertificationCommand = {
  organizationId: string;
  legalName: string;
  uscc: string;
  licenseFileId: string;
  contactName: string | null;
  contactMobile: string | null;
  supplementNote: string | null;
};

@Injectable()
export class ProfileCertificationWriteService {
  constructor(
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProfilePresenter
  ) {}

  async submit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSubmitCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireOrganizationAdmin(
      currentSession,
      command.organizationId
    );
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: command.licenseFileId });
    if (!fileAsset) {
      throw certificationSubmitInvalid('Certification submit requires a confirmed license file truth.');
    }
    if (fileAsset.organizationId && fileAsset.organizationId !== scope.organization.id) {
      throw certificationSubmitInvalid('Certification submit license file does not belong to the current organization.');
    }

    const auditContext = {
      ...context,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      organizationId: scope.organization.id,
      actorRole: scope.membership.roleKey
    };

    return this.dataSource.transaction(async (manager) => {
      const organization = await manager.getRepository(OrganizationEntity).findOneBy({ id: scope.organization.id });
      const current = await manager
        .getRepository(OrganizationCertificationEntity)
        .findOne({ where: { organizationId: scope.organization.id }, order: { updatedAt: 'DESC' } });
      if (!organization) {
        throw certificationSubmitInvalid('Current organization is unavailable for certification submit.');
      }

      const beforeState = current?.certificationStatus ?? 'not_submitted';
      if (beforeState === 'pending_review') {
        throw certificationDuplicateSubmit('Current certification is already pending review.');
      }
      if (!['not_submitted', 'rejected', 'expired'].includes(beforeState)) {
        throw certificationSubmitInvalid('Current certification state does not allow submit.');
      }

      const submittedAt = new Date();
      const certification =
        current ??
        manager.getRepository(OrganizationCertificationEntity).create({
          id: randomUUID(),
          organizationId: scope.organization.id
        });

      certification.certificationStatus = 'pending_review';
      certification.legalName = command.legalName;
      certification.uscc = command.uscc;
      certification.licenseFileId = command.licenseFileId;
      certification.submittedAt = submittedAt;
      certification.reviewedAt = null;
      certification.reviewedBy = null;
      certification.rejectReason = null;
      certification.expiresAt = null;

      organization.uscc = command.uscc;
      organization.businessLicenseFileId = command.licenseFileId;
      organization.contactName = command.contactName ?? organization.contactName;
      organization.contactMobile = command.contactMobile ?? organization.contactMobile;

      await manager.getRepository(OrganizationEntity).save(organization);
      await manager.getRepository(OrganizationCertificationEntity).save(certification);
      await this.appendAudit(
        manager,
        {
          objectId: certification.id,
          objectNo: organization.id,
          beforeState,
          afterState: certification.certificationStatus,
          reason: this.buildAuditReason(command.licenseFileId, command.supplementNote)
        },
        auditContext
      );

      return this.presenter.toCertificationAccepted({
        organizationId: organization.id,
        certificationStatus: certification.certificationStatus,
        submittedAt,
        traceId: context.traceId
      });
    });
  }

  async resubmit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toResubmitCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireOrganizationAdmin(
      currentSession,
      command.organizationId
    );
    const fileAsset = await this.fileAssetRepository.findOneBy({ id: command.licenseFileId });
    if (!fileAsset) {
      throw certificationResubmitInvalid('Certification resubmit requires a confirmed license file truth.');
    }
    if (fileAsset.organizationId && fileAsset.organizationId !== scope.organization.id) {
      throw certificationResubmitInvalid('Certification resubmit license file does not belong to the current organization.');
    }

    const auditContext = {
      ...context,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      organizationId: scope.organization.id,
      actorRole: scope.membership.roleKey
    };

    return this.dataSource.transaction(async (manager) => {
      const organization = await manager.getRepository(OrganizationEntity).findOneBy({ id: scope.organization.id });
      const certification = await manager
        .getRepository(OrganizationCertificationEntity)
        .findOne({ where: { organizationId: scope.organization.id }, order: { updatedAt: 'DESC' } });
      if (!organization || !certification) {
        throw certificationResubmitInvalid('Current certification is unavailable for resubmit.');
      }

      const beforeState = certification.certificationStatus;
      if (beforeState === 'pending_review') {
        throw certificationDuplicateSubmit('Current certification is already pending review.');
      }
      if (!['rejected', 'expired'].includes(beforeState)) {
        throw certificationResubmitInvalid('Current certification state does not allow resubmit.');
      }

      const submittedAt = new Date();
      certification.certificationStatus = 'pending_review';
      certification.legalName = command.legalName;
      certification.uscc = command.uscc;
      certification.licenseFileId = command.licenseFileId;
      certification.submittedAt = submittedAt;
      certification.reviewedAt = null;
      certification.reviewedBy = null;
      certification.rejectReason = null;
      certification.expiresAt = null;

      organization.uscc = command.uscc;
      organization.businessLicenseFileId = command.licenseFileId;

      await manager.getRepository(OrganizationEntity).save(organization);
      await manager.getRepository(OrganizationCertificationEntity).save(certification);
      await this.appendAudit(
        manager,
        {
          objectId: certification.id,
          objectNo: organization.id,
          beforeState,
          afterState: certification.certificationStatus,
          reason: this.buildAuditReason(command.licenseFileId, command.supplementNote)
        },
        auditContext
      );

      return this.presenter.toCertificationAccepted({
        organizationId: organization.id,
        certificationStatus: certification.certificationStatus,
        submittedAt,
        traceId: context.traceId
      });
    });
  }

  private toSubmitCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, true);
    return {
      organizationId: this.readRequiredString(source.organizationId, 'organizationId', certificationSubmitInvalid),
      legalName: this.readRequiredString(source.legalName, 'legalName', certificationSubmitInvalid),
      uscc: this.readRequiredString(source.uscc, 'uscc', certificationSubmitInvalid),
      licenseFileId: this.readRequiredString(source.licenseFileId, 'licenseFileId', certificationSubmitInvalid),
      contactName: this.readOptionalString(source.contactName, certificationSubmitInvalid),
      contactMobile: this.readOptionalString(source.contactMobile, certificationSubmitInvalid),
      supplementNote: null
    } satisfies CertificationCommand;
  }

  private toResubmitCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload, false);
    return {
      organizationId: this.readRequiredString(source.organizationId, 'organizationId', certificationResubmitInvalid),
      legalName: this.readRequiredString(source.legalName, 'legalName', certificationResubmitInvalid),
      uscc: this.readRequiredString(source.uscc, 'uscc', certificationResubmitInvalid),
      licenseFileId: this.readRequiredString(source.licenseFileId, 'licenseFileId', certificationResubmitInvalid),
      contactName: null,
      contactMobile: null,
      supplementNote: this.readOptionalString(source.supplementNote, certificationResubmitInvalid)
    } satisfies CertificationCommand;
  }

  private readRequiredString(
    value: unknown,
    field: string,
    errorFactory: (message: string) => Error
  ) {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw errorFactory(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown, errorFactory: (message: string) => Error) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw errorFactory('Optional certification fields must be strings when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private asRecord(value: unknown, submit: boolean) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw submit
        ? certificationSubmitInvalid('Certification submit body must be an object.')
        : certificationResubmitInvalid('Certification resubmit body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private buildAuditReason(licenseFileId: string, note: string | null) {
    return note ? `licenseFileId=${licenseFileId}; note=${note}` : `licenseFileId=${licenseFileId}`;
  }

  private async appendAudit(
    manager: EntityManager,
    input: {
      objectId: string;
      objectNo: string;
      beforeState: string;
      afterState: string;
      reason: string;
    },
    context: {
      actorId: string;
      actorRole: string;
      requestId: string;
      traceId: string;
    }
  ) {
    await manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: 'organization_certification',
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: 'OrganizationCertificationSubmitted',
      actorId: context.actorId,
      actorRole: context.actorRole,
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: context.requestId,
      traceId: context.traceId,
      occurredAt: new Date()
    });
  }
}

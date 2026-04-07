import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationReviewPresenter } from './organization-review.presenter';
import {
  organizationReviewApproveInvalid,
  organizationReviewInvalidState,
  organizationReviewRejectInvalid,
  organizationReviewResourceUnavailable
} from './review.errors';

@Injectable()
export class OrganizationReviewWriteService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: OrganizationReviewPresenter
  ) {}

  async approve(
    organizationId: string,
    payload: Record<string, unknown> | undefined,
    context: RequestContext
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    const normalizedOrganizationId = this.readOrganizationId(organizationId, organizationReviewApproveInvalid);
    const note = this.readOptionalString(payload?.note, organizationReviewApproveInvalid);
    const auditContext = {
      ...context,
      actorId: reviewer.user.id,
      userId: reviewer.user.id,
      organizationId: reviewer.organizationId,
      actorRole: reviewer.actorRole
    };

    return this.dataSource.transaction(async (manager) => {
      const organization = await manager.getRepository(OrganizationEntity).findOneBy({ id: normalizedOrganizationId });
      const certification = await manager
        .getRepository(OrganizationCertificationEntity)
        .findOne({ where: { organizationId: normalizedOrganizationId }, order: { updatedAt: 'DESC' } });
      if (!organization || !certification) {
        throw organizationReviewResourceUnavailable('Current organization review resource is unavailable.');
      }

      const fileAsset = await this.fileAssetRepository.findOneBy({ id: certification.licenseFileId });
      if (!fileAsset) {
        throw organizationReviewApproveInvalid('Organization review approve requires an existing certification file truth.');
      }
      if (certification.certificationStatus !== 'pending_review') {
        throw organizationReviewInvalidState('Current certification state does not allow approve.');
      }

      const beforeState = certification.certificationStatus;
      certification.certificationStatus = 'approved';
      certification.reviewedAt = new Date();
      certification.reviewedBy = reviewer.user.id;
      certification.rejectReason = null;

      if (organization.status === 'draft') {
        organization.status = 'active';
      }

      await manager.getRepository(OrganizationCertificationEntity).save(certification);
      await manager.getRepository(OrganizationEntity).save(organization);
      await this.appendAudit(
        manager,
        {
          objectType: 'organization_certification',
          objectId: certification.id,
          objectNo: organization.id,
          action: 'OrganizationCertificationApproved',
          beforeState,
          afterState: certification.certificationStatus,
          reason: note ? `licenseFileId=${certification.licenseFileId}; note=${note}` : `licenseFileId=${certification.licenseFileId}`
        },
        auditContext
      );

      return this.presenter.toActionAck(context.traceId);
    });
  }

  async reject(
    organizationId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    const normalizedOrganizationId = this.readOrganizationId(organizationId, organizationReviewRejectInvalid);
    const source = this.asRecord(payload);
    const reason = this.readRequiredString(source.reason, 'reason', organizationReviewRejectInvalid);
    const note = this.readOptionalString(source.note, organizationReviewRejectInvalid);
    const auditContext = {
      ...context,
      actorId: reviewer.user.id,
      userId: reviewer.user.id,
      organizationId: reviewer.organizationId,
      actorRole: reviewer.actorRole
    };

    return this.dataSource.transaction(async (manager) => {
      const organization = await manager.getRepository(OrganizationEntity).findOneBy({ id: normalizedOrganizationId });
      const certification = await manager
        .getRepository(OrganizationCertificationEntity)
        .findOne({ where: { organizationId: normalizedOrganizationId }, order: { updatedAt: 'DESC' } });
      if (!organization || !certification) {
        throw organizationReviewResourceUnavailable('Current organization review resource is unavailable.');
      }
      if (certification.certificationStatus !== 'pending_review') {
        throw organizationReviewInvalidState('Current certification state does not allow reject.');
      }

      const beforeState = certification.certificationStatus;
      certification.certificationStatus = 'rejected';
      certification.reviewedAt = new Date();
      certification.reviewedBy = reviewer.user.id;
      certification.rejectReason = reason;

      await manager.getRepository(OrganizationCertificationEntity).save(certification);
      await this.appendAudit(
        manager,
        {
          objectType: 'organization_certification',
          objectId: certification.id,
          objectNo: organization.id,
          action: 'OrganizationCertificationRejected',
          beforeState,
          afterState: certification.certificationStatus,
          reason: note
            ? `licenseFileId=${certification.licenseFileId}; reason=${reason}; note=${note}`
            : `licenseFileId=${certification.licenseFileId}; reason=${reason}`
        },
        auditContext
      );

      return this.presenter.toActionAck(context.traceId);
    });
  }

  private appendAudit(
    manager: DataSource['manager'],
    input: {
      objectType: string;
      objectId: string;
      objectNo: string;
      action: 'OrganizationCertificationApproved' | 'OrganizationCertificationRejected';
      beforeState: string;
      afterState: string;
      reason: string;
    },
    context: RequestContext
  ) {
    return manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: input.objectType,
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: input.action,
      actorId: context.userId.trim() || null,
      actorRole: context.actorRole.trim(),
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: context.requestId,
      traceId: context.traceId,
      occurredAt: new Date()
    });
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw organizationReviewRejectInvalid('Organization review reject body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readOrganizationId(
    value: string,
    errorFactory: (message: string) => Error
  ) {
    const normalized = value.trim();
    if (!normalized) {
      throw errorFactory('organizationId is required.');
    }
    return normalized;
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

  private readOptionalString(
    value: unknown,
    errorFactory: (message: string) => Error
  ) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw errorFactory('Review note must be a string when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}

import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import type { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { EnterpriseHubCertificationSyncService } from '../enterprise_hub/enterprise-hub-certification-sync.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { certificationRevalidateInvalid } from './profile.errors';
import {
  type CertificationLicenseOcrView,
  ProfileCertificationOcrService,
} from './profile-certification-ocr.service';
import { OrganizationCertificationRevalidationAttemptEntity } from './entities/organization-certification-revalidation-attempt.entity';
import { ProfilePresenter } from './profile.presenter';

type CertificationRevalidateCommand = {
  organizationId: string;
  legalName: string;
  uscc: string;
  licenseFileId: string;
  correctionNote: string | null;
};

type RevalidationTransactionResult =
  | {
      ok: true;
      response: {
        organizationId: string;
        certificationStatus: string;
        submittedAt: Date;
      };
    }
  | {
      ok: false;
      message: string;
    };

@Injectable()
export class ProfileCertificationRevalidationService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly certificationOcrService: ProfileCertificationOcrService,
    private readonly presenter: ProfilePresenter,
    private readonly enterpriseHubCertificationSyncService: EnterpriseHubCertificationSyncService,
  ) {}

  async revalidate(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    const scope = await this.eligibilityService.requireOrganizationAdmin(
      currentSession,
      command.organizationId,
    );

    const result = await this.dataSource.transaction(async (manager) => {
      const organization = await manager
        .getRepository(OrganizationEntity)
        .findOneBy({ id: scope.organization.id });
      const certification = await manager
        .getRepository(OrganizationCertificationEntity)
        .findOne({
          where: { organizationId: scope.organization.id },
          order: { updatedAt: 'DESC', createdAt: 'DESC' },
        });

      if (!organization) {
        return { ok: false, message: 'Current organization is unavailable for certification revalidate.' } satisfies RevalidationTransactionResult;
      }

      const beforeStatus = certification?.certificationStatus ?? 'not_submitted';
      const currentSnapshot = this.buildCurrentSnapshot(certification);

      if (!certification) {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: null,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: null,
            outcomeReason: 'Current certification is unavailable for revalidate.',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return { ok: false, message: 'Current certification is unavailable for revalidate.' } satisfies RevalidationTransactionResult;
      }

      if (beforeStatus !== 'approved') {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: certification.id,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: null,
            outcomeReason: 'Current certification state does not allow revalidate.',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return { ok: false, message: 'Current certification state does not allow revalidate.' } satisfies RevalidationTransactionResult;
      }

      const fileAsset = await manager.getRepository(FileAssetEntity).findOneBy({
        id: command.licenseFileId,
      });
      if (!fileAsset) {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: certification.id,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: null,
            outcomeReason: 'Certification revalidate requires a confirmed license file truth.',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return { ok: false, message: 'Certification revalidate requires a confirmed license file truth.' } satisfies RevalidationTransactionResult;
      }

      if (
        fileAsset.organizationId &&
        fileAsset.organizationId !== scope.organization.id
      ) {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: certification.id,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: null,
            outcomeReason:
                'Certification revalidate license file does not belong to the current organization.',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return {
          ok: false,
          message:
              'Certification revalidate license file does not belong to the current organization.',
        } satisfies RevalidationTransactionResult;
      }

      if (!fileAsset.mimeType.toLowerCase().startsWith('image/')) {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: certification.id,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: null,
            outcomeReason:
                'Certification revalidate only supports image license files.',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return {
          ok: false,
          message: 'Certification revalidate only supports image license files.',
        } satisfies RevalidationTransactionResult;
      }

      const ocrView =
        await this.certificationOcrService.recognizeLicenseForOrganization(
          scope.organization.id,
          command.licenseFileId,
        );
      const failureMessage = this.readRevalidationFailure(command, ocrView);
      if (failureMessage) {
        await this.recordAttempt(
          manager,
          {
            organizationId: scope.organization.id,
            certificationId: certification.id,
            actorId: currentSession.actorId,
            userId: currentSession.userId,
            actorRole: scope.membership.roleKey,
            licenseFileId: command.licenseFileId,
            correctionNote: command.correctionNote,
            beforeStatus,
            afterStatus: beforeStatus,
            commandOutcome: 'rejected',
            oldSnapshot: currentSnapshot,
            requestedSnapshot: this.buildRequestedSnapshot(command),
            ocrSnapshot: this.buildOcrSnapshot(ocrView),
            outcomeReason: failureMessage,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        await this.appendIdentityAudit(
          manager,
          {
            action: 'OrganizationCertificationRevalidationRejected',
            objectId: certification.id,
            objectNo: organization.id,
            beforeState: beforeStatus,
            afterState: beforeStatus,
            reason: this.buildAuditReason(command, ocrView, 'rejected', failureMessage),
            actorId: currentSession.actorId,
            actorRole: scope.membership.roleKey,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        );
        return { ok: false, message: failureMessage } satisfies RevalidationTransactionResult;
      }

      const decidedAt = new Date();
      certification.certificationStatus = 'approved';
      certification.legalName = command.legalName;
      certification.uscc = command.uscc;
      certification.licenseFileId = command.licenseFileId;
      certification.address = this.readNullableText(ocrView.address);
      certification.establishedAt = this.normalizeEstablishedAt(
        ocrView.establishedAt,
      );
      certification.legalPerson = this.readNullableText(ocrView.legalPerson);
      certification.businessType = this.normalizeBusinessType(
        ocrView.businessType,
      );
      certification.registeredCapital = this.readNullableText(
        ocrView.registeredCapital,
      );
      certification.businessTerm = this.readNullableText(ocrView.businessTerm);
      certification.businessScope = this.readNullableText(
        ocrView.businessScope,
      );
      certification.submittedAt = decidedAt;
      certification.reviewedAt = decidedAt;
      certification.reviewedBy = null;
      certification.rejectReason = null;
      certification.expiresAt = null;

      organization.uscc = command.uscc;
      organization.businessLicenseFileId = command.licenseFileId;

      await manager.getRepository(OrganizationEntity).save(organization);
      await manager
        .getRepository(OrganizationCertificationEntity)
        .save(certification);
      await this.enterpriseHubCertificationSyncService.syncOrganizationListings(
        scope.organization.id,
        manager,
      );
      await this.recordAttempt(
        manager,
        {
          organizationId: scope.organization.id,
          certificationId: certification.id,
          actorId: currentSession.actorId,
          userId: currentSession.userId,
          actorRole: scope.membership.roleKey,
          licenseFileId: command.licenseFileId,
          correctionNote: command.correctionNote,
          beforeStatus,
          afterStatus: 'approved',
          commandOutcome: 'updated',
          oldSnapshot: currentSnapshot,
          requestedSnapshot: this.buildRequestedSnapshot(command),
          ocrSnapshot: this.buildOcrSnapshot(ocrView),
          outcomeReason: null,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      );
      await this.appendIdentityAudit(
        manager,
        {
          action: 'OrganizationCertificationRevalidated',
          objectId: certification.id,
          objectNo: organization.id,
          beforeState: beforeStatus,
          afterState: 'approved',
          reason: this.buildAuditReason(command, ocrView, 'updated', null),
          actorId: currentSession.actorId,
          actorRole: scope.membership.roleKey,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      );

      return {
        ok: true,
        response: {
          organizationId: organization.id,
          certificationStatus: certification.certificationStatus,
          submittedAt: decidedAt,
        },
      } satisfies RevalidationTransactionResult;
    });

    if (!result.ok) {
      throw certificationRevalidateInvalid(result.message);
    }

    return this.presenter.toCertificationAccepted({
      organizationId: result.response.organizationId,
      certificationStatus: result.response.certificationStatus,
      submittedAt: result.response.submittedAt,
      traceId: context.traceId,
    });
  }

  private toCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      organizationId: this.readRequiredString(
        source.organizationId,
        'organizationId',
      ),
      legalName: this.readRequiredString(source.legalName, 'legalName'),
      uscc: this.readRequiredString(source.uscc, 'uscc'),
      licenseFileId: this.readRequiredString(
        source.licenseFileId,
        'licenseFileId',
      ),
      correctionNote: this.readOptionalString(source.correctionNote),
    } satisfies CertificationRevalidateCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw certificationRevalidateInvalid(
        'Certification revalidate body must be an object.',
      );
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw certificationRevalidateInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw certificationRevalidateInvalid(
        'Optional certification fields must be strings when provided.',
      );
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readRevalidationFailure(
    command: CertificationRevalidateCommand,
    ocrView: CertificationLicenseOcrView,
  ) {
    const normalizedInputName = this.normalizeCompareText(command.legalName);
    const normalizedOcrName = this.normalizeCompareText(ocrView.legalName);
    const normalizedInputUscc = this.normalizeUscc(command.uscc);
    const normalizedOcrUscc = this.normalizeUscc(ocrView.uscc);

    if (
      ocrView.status !== 'recognized' ||
      !normalizedOcrName ||
      !normalizedOcrUscc
    ) {
      return '营业执照 OCR 自动核验未完成，未识别到完整的认证主体和统一社会信用代码，请上传清晰完整的营业执照后重新提交。';
    }
    if (
      normalizedInputName !== normalizedOcrName &&
      normalizedInputUscc !== normalizedOcrUscc
    ) {
      return '营业执照 OCR 自动核验未通过：识别出的认证主体和统一社会信用代码都与填写内容不一致，请核对后重新提交。';
    }
    if (normalizedInputName !== normalizedOcrName) {
      return '营业执照 OCR 自动核验未通过：识别出的认证主体与填写内容不一致，请核对后重新提交。';
    }
    if (normalizedInputUscc !== normalizedOcrUscc) {
      return '营业执照 OCR 自动核验未通过：识别出的统一社会信用代码与填写内容不一致，请核对后重新提交。';
    }
    return null;
  }

  private buildCurrentSnapshot(certification: OrganizationCertificationEntity | null) {
    if (!certification) {
      return {
        certificationStatus: 'not_submitted',
      } satisfies Record<string, unknown>;
    }
    return {
      certificationId: certification.id,
      certificationStatus: certification.certificationStatus,
      legalName: certification.legalName,
      uscc: certification.uscc,
      licenseFileId: certification.licenseFileId,
      address: certification.address,
      establishedAt: certification.establishedAt,
      legalPerson: certification.legalPerson,
      businessType: certification.businessType,
      registeredCapital: certification.registeredCapital,
      businessTerm: certification.businessTerm,
      businessScope: certification.businessScope,
      rejectReason: certification.rejectReason,
      expiresAt: certification.expiresAt?.toISOString() ?? null,
      submittedAt: certification.submittedAt?.toISOString() ?? null,
    } satisfies Record<string, unknown>;
  }

  private buildRequestedSnapshot(command: CertificationRevalidateCommand) {
    return {
      legalName: command.legalName,
      uscc: command.uscc,
      licenseFileId: command.licenseFileId,
      correctionNote: command.correctionNote,
    } satisfies Record<string, unknown>;
  }

  private buildOcrSnapshot(view: CertificationLicenseOcrView) {
    return {
      status: view.status,
      message: view.message,
      legalName: view.legalName,
      uscc: view.uscc,
      legalPerson: view.legalPerson,
      businessType: view.businessType,
      address: view.address,
      registeredCapital: view.registeredCapital,
      establishedAt: view.establishedAt,
      businessTerm: view.businessTerm,
      businessScope: view.businessScope,
      providerRequestId: view.providerRequestId,
    } satisfies Record<string, unknown>;
  }

  private normalizeCompareText(value: string | null) {
    return value?.replace(/\s+/gu, '').trim() ?? '';
  }

  private normalizeUscc(value: string | null) {
    return (
      value
        ?.toUpperCase()
        .replace(/[^0-9A-Z]/gu, '')
        .trim() ?? ''
    );
  }

  private readNullableText(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private normalizeEstablishedAt(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    const match =
      normalized.match(/^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$/u) ??
      normalized.match(/^(\d{4})年(\d{1,2})月(\d{1,2})日$/u);
    if (!match) {
      return null;
    }
    const [, year, month, day] = match;
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
  }

  private normalizeBusinessType(value: string | null) {
    const normalized = this.readNullableText(value);
    if (!normalized) {
      return null;
    }
    const compact = normalized.replace(/\s+/gu, '').toLowerCase();
    if (
      /^(qrcode|二维码|扫码|扫描码|条码|barcode|document|doctype|documenttype|scantype|scan|filetype|imagetype|picturetype)$/u.test(
        compact,
      ) ||
      /文档类型|扫描类型|版式标签|版面标签|识别类型/u.test(normalized)
    ) {
      return null;
    }
    return normalized;
  }

  private buildAuditReason(
    command: CertificationRevalidateCommand,
    ocrView: CertificationLicenseOcrView,
    outcome: 'updated' | 'rejected',
    outcomeReason: string | null,
  ) {
    const parts = [
      `sourceLicenseFileId=${command.licenseFileId}`,
      `outcome=${outcome}`,
      `ocrStatus=${ocrView.status}`,
    ];
    if (command.correctionNote) {
      parts.push(`correctionNote=${command.correctionNote}`);
    }
    if (ocrView.providerRequestId) {
      parts.push(`ocrRequestId=${ocrView.providerRequestId}`);
    }
    if (outcomeReason) {
      parts.push(`outcomeReason=${outcomeReason}`);
    }
    return parts.join('; ');
  }

  private async recordAttempt(
    manager: EntityManager,
    input: {
      organizationId: string;
      certificationId: string | null;
      actorId: string;
      userId: string;
      actorRole: string;
      licenseFileId: string;
      correctionNote: string | null;
      beforeStatus: string;
      afterStatus: string;
      commandOutcome: string;
      oldSnapshot: Record<string, unknown>;
      requestedSnapshot: Record<string, unknown>;
      ocrSnapshot: Record<string, unknown> | null;
      outcomeReason: string | null;
      requestId: string;
      traceId: string;
    },
  ) {
    await manager
      .getRepository(OrganizationCertificationRevalidationAttemptEntity)
      .save({
        id: randomUUID(),
        organizationId: input.organizationId,
        certificationId: input.certificationId,
        triggeredByUserId: input.userId,
        triggeredByActorId: input.actorId,
        triggeredByRole: input.actorRole,
        sourceLicenseFileId: input.licenseFileId,
        correctionNote: input.correctionNote,
        beforeStatus: input.beforeStatus,
        afterStatus: input.afterStatus,
        commandOutcome: input.commandOutcome,
        oldSnapshot: input.oldSnapshot,
        requestedSnapshot: input.requestedSnapshot,
        ocrSnapshot: input.ocrSnapshot,
        outcomeReason: input.outcomeReason,
        requestId: input.requestId,
        traceId: input.traceId,
      });
  }

  private async appendIdentityAudit(
    manager: EntityManager,
    input: {
      action: string;
      objectId: string;
      objectNo: string;
      beforeState: string;
      afterState: string;
      reason: string;
      actorId: string;
      actorRole: string;
      requestId: string;
      traceId: string;
    },
  ) {
    await manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: 'organization_certification',
      objectId: input.objectId,
      objectNo: input.objectNo,
      action: input.action,
      actorId: input.actorId,
      actorRole: input.actorRole,
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: input.requestId,
      traceId: input.traceId,
      occurredAt: new Date(),
    });
  }
}

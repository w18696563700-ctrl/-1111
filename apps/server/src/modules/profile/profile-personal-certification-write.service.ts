import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PersonalCertificationEntity } from './entities/personal-certification.entity';
import {
  personalCertificationSubmitInvalid,
  personalCertificationLocked,
} from './profile.errors';
import {
  PersonalCertificationIdCardOcrView,
  ProfilePersonalCertificationOcrService,
} from './profile-personal-certification-ocr.service';
import { ProfilePresenter } from './profile.presenter';

type PersonalCertificationSubmitCommand = {
  organizationId: string;
  idCardFrontFileId: string;
};

@Injectable()
export class ProfilePersonalCertificationWriteService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(PersonalCertificationEntity)
    private readonly personalCertificationRepository: Repository<PersonalCertificationEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly personalCertificationOcrService: ProfilePersonalCertificationOcrService,
    private readonly presenter: ProfilePresenter
  ) {}

  async submit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireCurrentOrganizationScope(
      currentSession,
      command.organizationId
    );
    const organizationCertification =
      await this.organizationCertificationRepository.findOne({
        where: { organizationId: scope.organization.id },
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      });
    if (!organizationCertification) {
      throw personalCertificationSubmitInvalid(
        'Current organization certification truth is unavailable.'
      );
    }
    if (organizationCertification.certificationStatus !== 'approved') {
      throw personalCertificationSubmitInvalid(
        'Current organization certification must be approved before personal certification submit.'
      );
    }
    const legalPerson = this.normalizeCompareText(organizationCertification.legalPerson);
    if (!legalPerson) {
      throw personalCertificationSubmitInvalid(
        'Current organization certification is missing legal-person truth.'
      );
    }

    const ocrView =
      await this.personalCertificationOcrService.recognizeIdCardFrontForOrganization(
        scope.organization.id,
        command.idCardFrontFileId
      );
    const decision = this.decide(ocrView, legalPerson);
    const submittedAt = new Date();

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(PersonalCertificationEntity);
      const current = await repository.findOne({
        where: { organizationId: scope.organization.id },
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      });
      if (
        current?.certificationStatus === 'approved' &&
        current.userId !== currentSession.userId
      ) {
        throw personalCertificationLocked(
          'Current personal certification is already locked to another actor.'
        );
      }

      const beforeState = current?.certificationStatus ?? 'not_submitted';
      if (
        current?.certificationStatus === 'approved' &&
        current.userId === currentSession.userId
      ) {
        throw personalCertificationLocked(
          'Current personal certification is already approved and locked.'
        );
      }

      const certification =
        current ??
        repository.create({
          id: randomUUID(),
          organizationId: scope.organization.id,
        });

      certification.userId = currentSession.userId;
      certification.certificationStatus = decision.status;
      certification.realName = decision.realName;
      certification.idNumberMasked = decision.idNumberMasked;
      certification.idCardFrontFileId = command.idCardFrontFileId;
      certification.providerRequestId = ocrView.providerRequestId;
      certification.submittedAt = submittedAt;
      certification.reviewedAt = submittedAt;
      certification.rejectReason = decision.rejectReason;
      certification.lockedAt = decision.status === 'approved' ? submittedAt : null;

      await repository.save(certification);
      await manager.getRepository(IdentityAuditLogEntity).save({
        id: randomUUID(),
        objectType: 'personal_certification',
        objectId: certification.id,
        objectNo: scope.organization.id,
        action: 'PersonalCertificationSubmitted',
        actorId: currentSession.userId,
        actorRole: scope.membership.roleKey,
        beforeState,
        afterState: certification.certificationStatus,
        reason: this.buildAuditReason(command.idCardFrontFileId, legalPerson, ocrView, decision.rejectReason),
        requestId: context.requestId,
        traceId: context.traceId,
        occurredAt: submittedAt,
      });

      return this.presenter.toPersonalCertificationAccepted({
        organizationId: scope.organization.id,
        userId: certification.userId,
        certificationStatus: certification.certificationStatus,
        submittedAt,
        lockedAt: certification.lockedAt,
        traceId: context.traceId,
      });
    });
  }

  private toCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      organizationId: this.readRequiredString(source.organizationId, 'organizationId'),
      idCardFrontFileId: this.readRequiredString(
        source.idCardFrontFileId,
        'idCardFrontFileId'
      ),
    } satisfies PersonalCertificationSubmitCommand;
  }

  private decide(
    ocrView: PersonalCertificationIdCardOcrView,
    legalPerson: string
  ) {
    const realName = this.normalizeCompareText(ocrView.realName);
    if (ocrView.status !== 'recognized' || !realName || !ocrView.idNumberMasked) {
      return {
        status: 'rejected',
        realName: ocrView.realName?.trim() ?? null,
        idNumberMasked: ocrView.idNumberMasked,
        rejectReason: '身份证正面 OCR 未完成稳定识别，请重新上传清晰的身份证正面。',
      } as const;
    }
    if (realName !== legalPerson) {
      return {
        status: 'rejected',
        realName: ocrView.realName?.trim() ?? null,
        idNumberMasked: ocrView.idNumberMasked,
        rejectReason: '身份证姓名与营业执照法定代表人不一致，当前不能通过我的认证。',
      } as const;
    }
    return {
      status: 'approved',
      realName: ocrView.realName?.trim() ?? null,
      idNumberMasked: ocrView.idNumberMasked,
      rejectReason: null,
    } as const;
  }

  private asRecord(value: unknown) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      throw personalCertificationSubmitInvalid(
        'Personal certification submit body must be an object.'
      );
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw personalCertificationSubmitInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private normalizeCompareText(value: string | null | undefined) {
    const normalized = value?.replace(/\s+/gu, '').trim() ?? '';
    return normalized.length > 0 ? normalized : null;
  }

  private buildAuditReason(
    idCardFrontFileId: string,
    legalPerson: string,
    ocrView: PersonalCertificationIdCardOcrView,
    rejectReason: string | null
  ) {
    const parts: string[] = [
      `idCardFrontFileId=${idCardFrontFileId}`,
      `organizationLegalPerson=${legalPerson}`,
      `ocrStatus=${ocrView.status}`,
    ];
    if ((ocrView.realName?.trim().length ?? 0) > 0) {
      parts.push(`ocrRealName=${ocrView.realName!.trim()}`);
    }
    if ((ocrView.idNumberMasked?.trim().length ?? 0) > 0) {
      parts.push(`ocrIdNumberMasked=${ocrView.idNumberMasked!.trim()}`);
    }
    if ((ocrView.providerRequestId?.trim().length ?? 0) > 0) {
      parts.push(`ocrRequestId=${ocrView.providerRequestId!.trim()}`);
    }
    if (rejectReason != null && rejectReason.trim().length > 0) {
      parts.push(`rejectReason=${rejectReason.trim()}`);
    }
    return parts.join('; ');
  }
}

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindOptionsWhere, In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { GovernanceAppealCaseEntity } from '../governance/entities/governance-appeal-case.entity';
import { GovernancePenaltyEntity } from '../governance/entities/governance-penalty.entity';
import { GOVERNANCE_APPEAL_STATUSES } from '../governance/governance.constants';
import { governanceAppealResourceUnavailable } from '../governance/governance.errors';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PrivateOperatingSystemReorganizationService } from '../private_operating_system_reorganization/private-operating-system-reorganization.service';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ProfilePresenter } from './profile.presenter';

const GOVERNANCE_APPEAL_STATUS_SET = new Set<string>(GOVERNANCE_APPEAL_STATUSES);

@Injectable()
export class ProfileQueryService {
  constructor(
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly privateOperatingSystemService: PrivateOperatingSystemReorganizationService,
    private readonly avatarUrlService: UploadPublicUrlService,
    private readonly presenter: ProfilePresenter,
    @InjectRepository(GovernanceAppealCaseEntity)
    private readonly governanceAppealRepository: Repository<GovernanceAppealCaseEntity>,
    @InjectRepository(GovernancePenaltyEntity)
    private readonly governancePenaltyRepository: Repository<GovernancePenaltyEntity>
  ) {}

  async getProfileIndex(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const myBuildingProjection = this.privateOperatingSystemService.getProfileIndexProjection();
    return this.presenter.toIndex({
      displayName: this.toDisplayName(user),
      avatarUrl: await this.readAvatarUrl(user.avatarUrl),
      profileIntro: this.readProfileIntro(user.profileIntro),
      organizationId: scope?.organization.id ?? null,
      roleKeys: scope?.roleKeys ?? [],
      certificationStatus: scope ? scope.certification.certificationStatus : null,
      personalCertificationStatus: scope?.personalCertification?.certificationStatus ?? null,
      personalCertificationQualified: scope?.personalCertification?.qualifiedForCurrentActor ?? null,
      personalCertificationLockedToOtherActor:
        scope?.personalCertification?.lockedToOtherActor ?? null,
      membershipStatus: scope?.membership.memberStatus ?? null,
      myBuildingProjection
    });
  }

  async getOrganizations(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const currentOrganizationId = currentSession.organizationId;
    const organizations = await this.eligibilityService.listAccessibleOrganizations(user.id);
    return this.presenter.toOrganizations(
      organizations.map((item) => ({
        organizationId: item.organization.id,
        name: item.organization.name,
        organizationType: item.organization.organizationType,
        provinceCode: item.organization.provinceCode,
        cityCode: item.organization.cityCode,
        contactName: item.organization.contactName,
        contactMobile: item.organization.contactMobile,
        intro: item.organization.intro,
        roleKeys: item.roleKeys,
        membershipStatus: item.membershipStatus,
        certificationStatus: item.certificationStatus,
        current: item.organization.id === currentOrganizationId
      }))
    );
  }

  async getCurrentCertification(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient('Current organization scope is required for certification current.');
    }

    const certification = scope.certification;
    return this.presenter.toCurrentCertification({
      organizationId: scope.organization.id,
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
      expiresAt: certification.expiresAt,
      submittedAt: certification.submittedAt,
      personalCertification: scope.personalCertification
        ? {
            organizationId: scope.organization.id,
            userId: scope.personalCertification.userId,
            certificationStatus: scope.personalCertification.certificationStatus,
            realName: scope.personalCertification.realName,
            idNumberMasked: scope.personalCertification.idNumberMasked,
            idCardFrontFileId: scope.personalCertification.idCardFrontFileId,
            rejectReason: scope.personalCertification.rejectReason,
            submittedAt: scope.personalCertification.submittedAt,
            lockedAt: scope.personalCertification.lockedAt,
            qualifiedForCurrentActor:
              scope.personalCertification.qualifiedForCurrentActor,
            lockedToOtherActor: scope.personalCertification.lockedToOtherActor,
          }
        : null,
    });
  }

  async getGovernanceAppeals(query: Record<string, unknown>, context: RequestContext) {
    const currentSession = await this.requireCurrentActorSession(context);
    const listQuery = this.readGovernanceAppealListQuery(query);
    const where: FindOptionsWhere<GovernanceAppealCaseEntity> = {
      submittedBy: currentSession.userId
    };
    if (listQuery.status) {
      where.status = listQuery.status;
    }

    const [appeals, total] = await this.governanceAppealRepository.findAndCount({
      where,
      order: {
        submittedAt: 'DESC',
        createdAt: 'DESC'
      },
      skip: (listQuery.page - 1) * listQuery.pageSize,
      take: listQuery.pageSize
    });
    const penaltyMap = await this.loadPenaltyMap(appeals);

    return this.presenter.toGovernanceAppealList({
      items: appeals.map((appeal) => ({
        appeal,
        penalty: this.requirePenalty(penaltyMap, appeal.penaltyId)
      })),
      page: listQuery.page,
      pageSize: listQuery.pageSize,
      total
    });
  }

  async getGovernanceAppealDetail(appealCaseId: string, context: RequestContext) {
    const currentSession = await this.requireCurrentActorSession(context);
    const normalizedAppealCaseId = this.readGovernanceAppealCaseId(appealCaseId);
    const appeal = await this.governanceAppealRepository.findOneBy({
      id: normalizedAppealCaseId,
      submittedBy: currentSession.userId
    });
    if (!appeal) {
      throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
    }

    const penalty = await this.governancePenaltyRepository.findOneBy({ id: appeal.penaltyId });
    if (!penalty) {
      throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
    }

    return this.presenter.toGovernanceAppealDetail({ appeal, penalty });
  }

  private toDisplayName(user: { id: string; mobile: string; nickname: string | null }) {
    const nickname = user.nickname?.trim() ?? '';
    if (nickname) {
      return nickname;
    }
    const mobileSuffix = user.mobile.trim().slice(-4);
    return mobileSuffix ? `用户${mobileSuffix}` : `用户${user.id.slice(0, 6)}`;
  }

  private async readAvatarUrl(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(normalized)) ?? normalized;
  }

  private readProfileIntro(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private async requireCurrentActorSession(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    return currentSession;
  }

  private async loadPenaltyMap(appeals: GovernanceAppealCaseEntity[]) {
    const penaltyIds = [...new Set(appeals.map((appeal) => appeal.penaltyId))];
    if (!penaltyIds.length) {
      return new Map<string, GovernancePenaltyEntity>();
    }

    const penalties = await this.governancePenaltyRepository.findBy({
      id: In(penaltyIds)
    });
    return new Map(penalties.map((penalty) => [penalty.id, penalty]));
  }

  private requirePenalty(penaltyMap: Map<string, GovernancePenaltyEntity>, penaltyId: string) {
    const penalty = penaltyMap.get(penaltyId);
    if (!penalty) {
      throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
    }
    return penalty;
  }

  private readGovernanceAppealListQuery(query: Record<string, unknown>) {
    return {
      page: this.readPositiveInt(query.page, 1, 10_000),
      pageSize: this.readPositiveInt(query.pageSize, 20, 100),
      status: this.readOptionalGovernanceAppealStatus(query.status)
    };
  }

  private readPositiveInt(value: unknown, fallback: number, max: number) {
    const numeric = typeof value === 'string' ? Number(value) : value;
    if (!Number.isInteger(numeric) || (numeric as number) <= 0 || (numeric as number) > max) {
      return fallback;
    }
    return numeric as number;
  }

  private readOptionalGovernanceAppealStatus(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    if (!normalized || !GOVERNANCE_APPEAL_STATUS_SET.has(normalized)) {
      return null;
    }
    return normalized;
  }

  private readGovernanceAppealCaseId(value: string) {
    const normalized = value.trim();
    if (!/^[a-zA-Z0-9._:-]{4,64}$/.test(normalized)) {
      throw governanceAppealResourceUnavailable('Governance appeal resource is unavailable.');
    }
    return normalized;
  }
}

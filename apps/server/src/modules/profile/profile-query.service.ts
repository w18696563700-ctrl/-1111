import { Injectable } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PrivateOperatingSystemReorganizationService } from '../private_operating_system_reorganization/private-operating-system-reorganization.service';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ProfilePresenter } from './profile.presenter';

@Injectable()
export class ProfileQueryService {
  constructor(
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly privateOperatingSystemService: PrivateOperatingSystemReorganizationService,
    private readonly avatarUrlService: UploadPublicUrlService,
    private readonly presenter: ProfilePresenter
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
      rejectReason: certification.rejectReason,
      expiresAt: certification.expiresAt,
      submittedAt: certification.submittedAt
    });
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
}

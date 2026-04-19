import { Injectable } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { MembershipQueryService } from '../membership/membership.query.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PrivateOperatingSystemReorganizationService } from '../private_operating_system_reorganization/private-operating-system-reorganization.service';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { ShellPresenter } from './shell.presenter';

@Injectable()
export class ShellQueryService {
  constructor(
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly membershipQueryService: MembershipQueryService,
    private readonly privateOperatingSystemService: PrivateOperatingSystemReorganizationService,
    private readonly avatarUrlService: UploadPublicUrlService,
    private readonly presenter: ShellPresenter
  ) {}

  async getContext(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const membershipSummary = await this.loadMembershipSummary(scope?.organization.id ?? null);
    const myBuildingProjection = this.privateOperatingSystemService.getShellContextProjection();
    return this.presenter.toContext({
      userId: user.id,
      displayName: this.toDisplayName(user),
      avatarUrl: await this.readAvatarUrl(user.avatarUrl),
      profileIntro: this.readProfileIntro(user.profileIntro),
      organizationId: scope?.organization.id ?? null,
      organizationType: scope?.organization.organizationType ?? null,
      roleKeys: scope?.roleKeys ?? [],
      certificationStatus: scope?.certification?.certificationStatus ?? null,
      personalCertificationStatus:
        scope?.personalCertification?.certificationStatus ?? null,
      personalCertificationQualified:
        scope?.personalCertification?.qualifiedForCurrentActor ?? null,
      personalCertificationLockedToOtherActor:
        scope?.personalCertification?.lockedToOtherActor ?? null,
      membershipStatus: scope?.membership.memberStatus ?? null,
      projectCreateEligibility: scope
        ? {
            canCreateProject: this.eligibilityService.canPublishProjectInScope(scope)
          }
        : null,
      paidMembershipTier: membershipSummary.paidMembershipTier,
      paidMembershipEntitlementsSummary: membershipSummary.paidMembershipEntitlementsSummary,
      paidMembershipQuotaSummary: membershipSummary.paidMembershipQuotaSummary,
      paidMembershipNextRefreshAt: membershipSummary.paidMembershipNextRefreshAt,
      myBuildingProjection
    });
  }

  private async loadMembershipSummary(organizationId: string | null) {
    try {
      return await this.membershipQueryService.getShellSummaryProjection(organizationId);
    } catch (error) {
      if (this.isMissingMembershipProjectionSource(error)) {
        return {
          paidMembershipTier: null,
          paidMembershipEntitlementsSummary: [],
          paidMembershipQuotaSummary: [],
          paidMembershipNextRefreshAt: null
        };
      }
      throw error;
    }
  }

  private isMissingMembershipProjectionSource(error: unknown) {
    const candidate = error as {
      code?: string;
      query?: string;
      driverError?: {
        code?: string;
      };
    };

    return (candidate.driverError?.code ?? candidate.code) === '42P01';
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

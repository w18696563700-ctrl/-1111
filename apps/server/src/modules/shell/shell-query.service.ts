import { Injectable, Optional } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { MembershipQueryService } from '../membership/membership.query.service';
import { CounterpartConversationProjectionService } from '../message_interaction/counterpart-conversation.projection.service';
import { NotificationService } from '../notifications/notification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PrivateOperatingSystemReorganizationService } from '../private_operating_system_reorganization/private-operating-system-reorganization.service';
import { ProjectCommunicationUnreadQueryService } from '../project_communication/project-communication-unread.query.service';
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
    private readonly presenter: ShellPresenter,
    @Optional()
    private readonly projectCommunicationUnreadQueryService?: ProjectCommunicationUnreadQueryService,
    @Optional()
    private readonly counterpartConversationProjectionService?: CounterpartConversationProjectionService,
    @Optional()
    private readonly notificationService?: NotificationService
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
    const messagesUnreadCount = await this.countMessagesUnread({
      userId: user.id,
      organizationId: scope?.organization.id ?? null
    });
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
      messagesUnreadCount,
      myBuildingProjection
    });
  }

  private async countMessagesUnread(input: {
    userId: string;
    organizationId: string | null;
  }) {
    const organizationId = input.organizationId;
    const bidParticipationNotificationUnread =
      await this.countBidParticipationNotificationUnread(
        input.userId,
        organizationId
      );
    if (this.counterpartConversationProjectionService && organizationId) {
      const conversations =
        await this.counterpartConversationProjectionService.listConversations(
          organizationId
        );
      return bidParticipationNotificationUnread + conversations.reduce(
        (total, conversation) => total + conversation.conversationUnreadCount,
        0
      );
    }
    if (!this.projectCommunicationUnreadQueryService) {
      return bidParticipationNotificationUnread;
    }
    return (
      bidParticipationNotificationUnread +
      await this.projectCommunicationUnreadQueryService.countUnreadForShell(organizationId)
    );
  }

  private async countBidParticipationNotificationUnread(
    userId: string,
    organizationId: string | null
  ) {
    if (!this.notificationService || !organizationId) {
      return 0;
    }
    return this.notificationService.countBidParticipationRequestUnreadForShell(
      userId,
      organizationId
    );
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

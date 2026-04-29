import { Injectable } from '@nestjs/common';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { BidParticipationRequestEntity } from './entities/bid-participation-request.entity';
import {
  BID_PARTICIPATION_THREAD_TYPE,
  buildBidParticipationSubmitRouteTarget,
  buildBidParticipationThreadSummary,
} from './bid-participation-request.support';

@Injectable()
export class BidParticipationRequestPresenter {
  toRequestAcceptedResponse(request: BidParticipationRequestEntity) {
    return {
      requestId: request.id,
      projectId: request.projectId,
      status: request.state,
      threadId: request.id,
    };
  }

  toPendingListResponse(input: {
    projectId: string;
    items: Array<{
      request: BidParticipationRequestEntity;
      requesterOrganization: OrganizationEntity | null;
      requesterUser: UserEntity | null;
      requesterCertification: OrganizationCertificationEntity | null;
    }>;
  }) {
    return {
      projectId: input.projectId,
      items: input.items.map(({ request, requesterOrganization, requesterUser, requesterCertification }) => ({
        requestId: request.id,
        requesterOrganization: this.toRequesterOrganization({
          request,
          requesterOrganization,
          requesterUser,
          requesterCertification,
        }),
        requestedAt: request.createdAt.toISOString(),
        status: request.state,
        threadId: request.id,
      })),
    };
  }

  toThreadDetail(input: {
    threadId: string;
    projectId: string;
    request: BidParticipationRequestEntity;
    displayTitle: string;
    requesterOrganization: OrganizationEntity | null;
    requesterUser: UserEntity | null;
    requesterCertification: OrganizationCertificationEntity | null;
    ownerCanReview: boolean;
    requesterCanSubmit: boolean;
  }) {
    const requesterOrganization = this.toRequesterOrganization({
      request: input.request,
      requesterOrganization: input.requesterOrganization,
      requesterUser: input.requesterUser,
      requesterCertification: input.requesterCertification,
    });
    const items = [
      {
        itemId: `${input.request.id}:seed`,
        itemKind: 'system_seed',
        title: '参与竞标申请',
        summary: buildBidParticipationThreadSummary({
          requesterOrganizationName: requesterOrganization.displayName,
          state: 'pending',
        }),
        createdAt: input.request.createdAt.toISOString(),
        action:
          input.ownerCanReview && input.request.state === 'pending'
            ? {
                actionKey: 'bid_participation.review',
                objectType: 'bid_participation_request',
                canonicalPath: null,
                label: '处理申请',
                params: {},
              }
            : null,
      },
    ];

    if (input.request.state !== 'pending' && input.request.reviewedAt) {
      items.push({
        itemId: `${input.request.id}:decision`,
        itemKind: 'system_notice',
        title: input.request.state === 'approved' ? '申请已通过' : '申请已拒绝',
        summary: buildBidParticipationThreadSummary({
          requesterOrganizationName: requesterOrganization.displayName,
          state: input.request.state as 'approved' | 'rejected',
        }),
        createdAt: input.request.reviewedAt.toISOString(),
        action:
          input.request.state === 'approved' && input.requesterCanSubmit
            ? {
                ...buildBidParticipationSubmitRouteTarget({ projectId: input.projectId }),
                label: '继续提交竞标',
              }
            : {
                actionKey: 'bid_participation.refresh',
                objectType: 'bid_participation_request',
                canonicalPath: null,
                label: '刷新状态',
                params: {},
              },
      });
    }

    return {
      threadId: input.threadId,
      threadType: BID_PARTICIPATION_THREAD_TYPE,
      projectId: input.projectId,
      requestId: input.request.id,
      requestStatus: input.request.state,
      displayTitle: input.displayTitle,
      requesterOrganization,
      items,
      primaryReviewAction: {
        actionKey: 'bid_participation.review',
        enabled: input.ownerCanReview && input.request.state === 'pending',
        availableDecisions:
          input.ownerCanReview && input.request.state === 'pending' ? ['approve', 'reject'] : [],
      },
    };
  }

  private toRequesterOrganization(input: {
    request: BidParticipationRequestEntity;
    requesterOrganization: OrganizationEntity | null;
    requesterUser: UserEntity | null;
    requesterCertification: OrganizationCertificationEntity | null;
  }) {
    return {
      organizationId: input.request.requesterOrganizationId,
      displayName:
        input.requesterCertification?.legalName?.trim() ||
        input.requesterOrganization?.name?.trim() ||
        input.requesterUser?.nickname?.trim() ||
        '当前申请组织',
      avatarUrl: input.requesterUser?.avatarUrl?.trim() || null,
      certificationStatus: input.requesterCertification?.certificationStatus ?? null,
      legalName: input.requesterCertification?.legalName?.trim() || null,
      uscc: input.requesterCertification?.uscc?.trim() || null,
    };
  }
}

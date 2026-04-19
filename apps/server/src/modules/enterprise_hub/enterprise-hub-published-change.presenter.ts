import { Injectable } from '@nestjs/common';
import { EnterpriseHubPublishedChangeSnapshot } from './enterprise-hub-published-change.types';
import { EnterpriseChangeRequestEntity } from './entities/enterprise-change-request.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubPublishedChangePresenter {
  toLiveSnapshot(listing: EnterpriseListingEntity) {
    return {
      enterpriseStatus: listing.enterpriseStatus,
      displayStatus: listing.displayStatus,
      publishedAt: listing.publishedAt?.toISOString() ?? null,
    };
  }

  toCurrentChangeRequest(request: EnterpriseChangeRequestEntity | null) {
    if (!request) {
      return null;
    }
    return {
      changeRequestId: request.id,
      changeStatus: request.changeStatus,
      submittedAt: request.submittedAt?.toISOString() ?? null,
      reviewedAt: request.reviewedAt?.toISOString() ?? null,
      rejectionReason: request.rejectionReason,
    };
  }

  toWorkbenchResponse(input: {
    listing: EnterpriseListingEntity;
    snapshot: EnterpriseHubPublishedChangeSnapshot;
    request: EnterpriseChangeRequestEntity | null;
    changeReadiness: {
      draftEditable: boolean;
      submitReady: boolean;
      blockers: string[];
    };
  }) {
    return {
      enterpriseId: input.listing.id,
      boardType: input.listing.primaryBoardType,
      liveSnapshot: this.toLiveSnapshot(input.listing),
      currentChangeRequest: this.toCurrentChangeRequest(input.request),
      basic: input.snapshot.basic,
      boardProfile: input.snapshot.boardProfile,
      primaryContact: input.snapshot.primaryContact,
      cases: input.snapshot.cases,
      changeReadiness: input.changeReadiness,
    };
  }

  toStatusResponse(enterpriseId: string, request: EnterpriseChangeRequestEntity) {
    return {
      enterpriseId,
      changeRequestId: request.id,
      changeStatus: request.changeStatus,
      submittedAt: request.submittedAt?.toISOString() ?? null,
      reviewedAt: request.reviewedAt?.toISOString() ?? null,
      rejectionReason: request.rejectionReason,
    };
  }

  toAdminListItem(request: EnterpriseChangeRequestEntity, listing: EnterpriseListingEntity | null) {
    return {
      changeRequestId: request.id,
      enterpriseId: request.enterpriseId,
      boardType: request.boardType,
      enterpriseName: listing?.name?.trim() || null,
      changeStatus: request.changeStatus,
      submittedAt: request.submittedAt?.toISOString() ?? null,
      reviewedAt: request.reviewedAt?.toISOString() ?? null,
      appliedAt: request.appliedAt?.toISOString() ?? null,
    };
  }

  toAdminDetail(input: {
    request: EnterpriseChangeRequestEntity;
    listing: EnterpriseListingEntity;
    snapshot: EnterpriseHubPublishedChangeSnapshot;
  }) {
    return {
      changeRequest: {
        changeRequestId: input.request.id,
        enterpriseId: input.request.enterpriseId,
        boardType: input.request.boardType,
        changeStatus: input.request.changeStatus,
        submittedAt: input.request.submittedAt?.toISOString() ?? null,
        reviewedAt: input.request.reviewedAt?.toISOString() ?? null,
        appliedAt: input.request.appliedAt?.toISOString() ?? null,
        reviewNote: input.request.reviewNote,
      },
      enterprise: {
        enterpriseId: input.listing.id,
        organizationId: input.listing.organizationId,
        name: input.listing.name || null,
        primaryBoardType: input.listing.primaryBoardType,
        secondaryCapabilities: input.listing.secondaryCapabilities ?? [],
        enterpriseStatus: input.listing.enterpriseStatus,
        displayStatus: input.listing.displayStatus,
      },
      liveSnapshot: this.toLiveSnapshot(input.listing),
      basic: input.snapshot.basic,
      boardProfile: input.snapshot.boardProfile,
      primaryContact: input.snapshot.primaryContact,
      cases: input.snapshot.cases,
    };
  }

  toReviewResponse(request: EnterpriseChangeRequestEntity) {
    return {
      changeRequestId: request.id,
      changeStatus: request.changeStatus,
      reviewedAt: request.reviewedAt?.toISOString() ?? null,
    };
  }

  toApplyResponse(request: EnterpriseChangeRequestEntity, listing: EnterpriseListingEntity) {
    return {
      changeRequestId: request.id,
      enterpriseId: listing.id,
      changeStatus: request.changeStatus,
      appliedAt: request.appliedAt?.toISOString() ?? null,
      enterpriseStatus: listing.enterpriseStatus,
      displayStatus: listing.displayStatus,
    };
  }
}

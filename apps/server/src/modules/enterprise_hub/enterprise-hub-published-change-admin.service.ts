import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { invalidStateTransition } from './enterprise-hub.errors';
import { EnterpriseHubPublishedChangeLiveWriteService } from './enterprise-hub-published-change-live-write.service';
import { EnterpriseHubPublishedChangePresenter } from './enterprise-hub-published-change.presenter';
import { EnterpriseHubPublishedChangeSupportService } from './enterprise-hub-published-change-support.service';
import { EnterpriseChangeRequestEntity } from './entities/enterprise-change-request.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubPublishedChangeAdminService {
  constructor(
    @InjectRepository(EnterpriseChangeRequestEntity)
    private readonly changeRequestRepository: Repository<EnterpriseChangeRequestEntity>,
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: EnterpriseHubPublishedChangePresenter,
    private readonly supportService: EnterpriseHubPublishedChangeSupportService,
    private readonly liveWriteService: EnterpriseHubPublishedChangeLiveWriteService,
  ) {}

  async listChangeRequests(query: Record<string, unknown>, context: RequestContext) {
    await this.requireReviewer(context);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 100);
    const [total, requests] = await Promise.all([
      this.changeRequestRepository.count(),
      this.changeRequestRepository.find({
        order: { createdAt: 'DESC', updatedAt: 'DESC' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);
    const listings = await this.listingRepository.findBy({
      id: In(requests.map((item) => item.enterpriseId)),
    });
    const listingMap = new Map(listings.map((item) => [item.id, item]));

    return {
      items: requests.map((item) =>
        this.presenter.toAdminListItem(item, listingMap.get(item.enterpriseId) ?? null),
      ),
      pagination: {
        page,
        pageSize,
        total,
        hasMore: page * pageSize < total,
      },
    };
  }

  async getChangeRequestDetail(changeRequestId: string, context: RequestContext) {
    await this.requireReviewer(context);
    const current = await this.supportService.loadChangeRequestById(changeRequestId);
    if (current.request.changeStatus === 'submitted') {
      current.request.changeStatus = 'under_review';
      await this.changeRequestRepository.save(current.request);
    }
    return this.presenter.toAdminDetail({
      request: current.request,
      listing: current.listing,
      snapshot: current.snapshot,
    });
  }

  async reviewChangeRequest(
    changeRequestId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const reviewer = await this.requireReviewer(context);
    const current = await this.supportService.loadChangeRequestById(changeRequestId);
    const action = typeof payload.action === 'string' ? payload.action.trim() : '';
    if (!['approved', 'revision_required', 'rejected'].includes(action)) {
      throw invalidStateTransition('Enterprise hub published change review action is invalid.');
    }
    if (current.request.changeStatus === 'submitted') {
      current.request.changeStatus = 'under_review';
    }
    if (current.request.changeStatus !== 'under_review') {
      throw invalidStateTransition('Enterprise hub published change request is not reviewable in its current state.');
    }

    current.request.changeStatus = action;
    current.request.reviewedAt = new Date();
    current.request.reviewNote = this.readOptionalText(payload.reviewNote);
    current.request.rejectionReason =
      action === 'approved' ? null : current.request.reviewNote;
    current.request.reviewerActorId = reviewer.currentSession.actorId;
    await this.changeRequestRepository.save(current.request);
    return this.presenter.toReviewResponse(current.request);
  }

  async applyChangeRequest(changeRequestId: string, context: RequestContext) {
    const reviewer = await this.requireReviewer(context);
    const current = await this.supportService.loadChangeRequestById(changeRequestId);
    if (current.request.changeStatus !== 'approved' || current.request.appliedAt) {
      throw invalidStateTransition(
        'Enterprise hub published change request must be approved and not yet applied before live apply.',
      );
    }

    await this.liveWriteService.applyToLiveListing(current.listing, current.snapshot);
    await this.listingRepository.save(current.listing);
    current.request.changeStatus = 'applied';
    current.request.appliedAt = new Date();
    current.request.appliedByActorId = reviewer.currentSession.actorId;
    await this.changeRequestRepository.save(current.request);
    return this.presenter.toApplyResponse(current.request, current.listing);
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private readOptionalText(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound = 50) {
    const parsed =
      typeof value === 'string' ? Number.parseInt(value, 10) : typeof value === 'number' ? value : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }
}

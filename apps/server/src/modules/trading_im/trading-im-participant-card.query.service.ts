import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { EnterpriseHubMediaProjectionService } from '../enterprise_hub/enterprise-hub-media-projection.service';
import { EnterpriseListingEntity } from '../enterprise_hub/entities/enterprise-listing.entity';
import { EnterpriseReviewSummaryEntity } from '../enterprise_hub/entities/enterprise-review-summary.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { TradingImPresenter, TradingImParticipantRole } from './trading-im.presenter';
import {
  threadParticipantCardForbidden,
  threadParticipantCardInvalid,
  threadParticipantCardUnavailable
} from './trading-im.errors';

type ParticipantCardCommand = {
  projectId: string;
  bidId: string;
  participantOrganizationId: string;
};

@Injectable()
export class TradingImParticipantCardQueryService {
  constructor(
    @InjectRepository(BidPrivateThreadEntity)
    private readonly threadRepository: Repository<BidPrivateThreadEntity>,
    @InjectRepository(EnterpriseListingEntity)
    private readonly enterpriseListingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(EnterpriseReviewSummaryEntity)
    private readonly enterpriseReviewSummaryRepository: Repository<EnterpriseReviewSummaryEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionService,
    private readonly presenter: TradingImPresenter
  ) {}

  async getParticipantCard(
    query: {
      projectId?: string;
      bidId?: string;
      participantOrganizationId?: string;
    },
    context: RequestContext
  ) {
    const command = this.readCommand(query);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const viewerOrganizationId = scope?.organization.id?.trim() ?? '';
    if (!viewerOrganizationId) {
      throw threadParticipantCardForbidden(
        'Current organization scope is required for participant-card.'
      );
    }

    const thread = await this.threadRepository.findOneBy({
      projectId: command.projectId,
      bidId: command.bidId
    });
    if (!thread) {
      throw threadParticipantCardUnavailable('Current bid thread is unavailable for participant-card.');
    }

    this.resolveViewerParticipantRole(thread, viewerOrganizationId);
    const participantRole = this.resolveTargetParticipantRole(
      thread,
      command.participantOrganizationId
    );

    const listing = await this.enterpriseListingRepository.findOneBy({
      organizationId: command.participantOrganizationId,
      enterpriseStatus: 'published',
      displayStatus: 'visible'
    });
    if (!listing) {
      throw threadParticipantCardUnavailable('Current participant enterprise summary is unavailable.');
    }

    const [reviewSummary, certification, displayUrlMap] = await Promise.all([
      this.enterpriseReviewSummaryRepository.findOneBy({ enterpriseId: listing.id }),
      this.organizationCertificationRepository.findOne({
        where: { organizationId: command.participantOrganizationId },
        order: { updatedAt: 'DESC', createdAt: 'DESC' }
      }),
      this.mediaProjectionService.buildDisplayUrlMap([listing.logoFileAssetId])
    ]);

    if (!reviewSummary) {
      throw threadParticipantCardUnavailable('Current participant review summary is unavailable.');
    }
    if (!certification || certification.certificationStatus !== 'approved') {
      throw threadParticipantCardUnavailable('Current participant formal-info summary is unavailable.');
    }

    return this.presenter.toParticipantCard({
      projectId: command.projectId,
      bidId: command.bidId,
      participantOrganizationId: command.participantOrganizationId,
      participantRole,
      enterpriseSummary: {
        enterpriseId: listing.id,
        displayName: listing.name.trim() || certification.legalName,
        logoUrl: this.mediaProjectionService.readDisplayUrl(
          listing.logoFileAssetId,
          displayUrlMap
        ),
        primaryBoardType: listing.primaryBoardType,
        provinceName: listing.provinceName,
        cityName: listing.cityName,
        verificationStatus:
          listing.verificationStatusSnapshot?.trim() || certification.certificationStatus
      },
      reviewSummary: {
        avgScore: this.toNumber(reviewSummary.avgScore),
        reviewCount: reviewSummary.reviewCount ?? 0,
        keywordTags: this.readStringArray(reviewSummary.keywordTags)
      },
      formalInfoSummary: {
        legalName: certification.legalName,
        businessType: certification.businessType,
        registeredCapital: certification.registeredCapital,
        establishedAt: certification.establishedAt,
        businessScope: certification.businessScope,
        certificationStatus: certification.certificationStatus
      }
    });
  }

  private readCommand(query: {
    projectId?: string;
    bidId?: string;
    participantOrganizationId?: string;
  }): ParticipantCardCommand {
    return {
      projectId: this.readRequiredId(query.projectId),
      bidId: this.readRequiredId(query.bidId),
      participantOrganizationId: this.readRequiredId(query.participantOrganizationId)
    };
  }

  private resolveViewerParticipantRole(
    thread: BidPrivateThreadEntity,
    viewerOrganizationId: string
  ): TradingImParticipantRole {
    if (viewerOrganizationId === thread.projectOwnerOrganizationId) {
      return 'project_owner';
    }
    if (viewerOrganizationId === thread.bidderOrganizationId) {
      return 'bidder';
    }
    throw threadParticipantCardForbidden(
      'Current organization is not an admitted participant of this bid thread.'
    );
  }

  private resolveTargetParticipantRole(
    thread: BidPrivateThreadEntity,
    participantOrganizationId: string
  ): Exclude<TradingImParticipantRole, 'viewer'> {
    if (participantOrganizationId === thread.projectOwnerOrganizationId) {
      return 'project_owner';
    }
    if (participantOrganizationId === thread.bidderOrganizationId) {
      return 'bidder';
    }
    throw threadParticipantCardInvalid(
      'Field `participantOrganizationId` must target one admitted thread participant.'
    );
  }

  private readRequiredId(value: unknown) {
    if (typeof value !== 'string') {
      throw threadParticipantCardInvalid('Required string field is missing.');
    }
    const normalized = value.trim();
    if (!normalized) {
      throw threadParticipantCardInvalid('Required string field is missing.');
    }
    return normalized;
  }

  private toNumber(value: unknown) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (typeof value === 'string' && value.trim()) {
      const parsed = Number(value);
      return Number.isFinite(parsed) ? parsed : null;
    }
    return null;
  }

  private readStringArray(value: unknown) {
    if (!Array.isArray(value)) {
      return [];
    }
    return value.flatMap((item) => {
      if (typeof item !== 'string') {
        return [];
      }
      const normalized = item.trim();
      return normalized ? [normalized] : [];
    });
  }
}

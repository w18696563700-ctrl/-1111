import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { EnterpriseHubMediaProjectionService } from '../enterprise_hub/enterprise-hub-media-projection.service';
import { EnterpriseListingEntity } from '../enterprise_hub/entities/enterprise-listing.entity';
import { EnterpriseReviewSummaryEntity } from '../enterprise_hub/entities/enterprise-review-summary.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
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
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(EnterpriseListingEntity)
    private readonly enterpriseListingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(EnterpriseReviewSummaryEntity)
    private readonly enterpriseReviewSummaryRepository: Repository<EnterpriseReviewSummaryEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionService,
    private readonly avatarUrlService: UploadPublicUrlService,
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

    const [listing, certification, organization, bid, project] = await Promise.all([
      this.enterpriseListingRepository.findOneBy({
        organizationId: command.participantOrganizationId,
        enterpriseStatus: 'published',
        displayStatus: 'visible'
      }),
      this.organizationCertificationRepository.findOne({
        where: { organizationId: command.participantOrganizationId },
        order: { updatedAt: 'DESC', createdAt: 'DESC' }
      }),
      this.organizationRepository.findOneBy({ id: command.participantOrganizationId }),
      this.bidRepository.findOneBy({ id: command.bidId, projectId: command.projectId }),
      this.projectRepository.findOneBy({ id: command.projectId })
    ]);

    if (!certification || certification.certificationStatus !== 'approved') {
      throw threadParticipantCardUnavailable('Current participant formal-info summary is unavailable.');
    }

    const participantUserId = this.resolveParticipantUserId({
      participantRole,
      bid,
      project
    });
    const participantUser = participantUserId
      ? await this.userRepository.findOneBy({ id: participantUserId })
      : null;
    const reviewSummary = listing
      ? await this.enterpriseReviewSummaryRepository.findOneBy({ enterpriseId: listing.id })
      : null;
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap(
      listing?.logoFileAssetId ? [listing.logoFileAssetId] : []
    );

    return this.presenter.toParticipantCard({
      projectId: command.projectId,
      bidId: command.bidId,
      participantOrganizationId: command.participantOrganizationId,
      participantRole,
      enterpriseSummary: this.buildEnterpriseSummary({
        participantOrganizationId: command.participantOrganizationId,
        participantRole,
        listing,
        certification,
        organization,
        displayUrlMap,
        participantAvatarUrl: await this.readAvatarUrl(participantUser?.avatarUrl ?? null),
      }),
      reviewSummary: this.buildReviewSummary(reviewSummary),
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

  private buildEnterpriseSummary(params: {
    participantOrganizationId: string;
    participantRole: Exclude<TradingImParticipantRole, 'viewer'>;
    listing: EnterpriseListingEntity | null;
    certification: OrganizationCertificationEntity;
    organization: OrganizationEntity | null;
    displayUrlMap: Map<string, string>;
    participantAvatarUrl: string | null;
  }) {
    const {
      participantOrganizationId,
      participantRole,
      listing,
      certification,
      organization,
      displayUrlMap,
      participantAvatarUrl,
    } = params;
    const boardType =
      listing?.primaryBoardType?.trim() ||
      (participantRole === 'bidder' ? 'supplier' : 'company');
    return {
      enterpriseId: listing?.id ?? participantOrganizationId,
      displayName: this.firstNonEmpty(
        listing?.name,
        organization?.name,
        certification.legalName,
        '当前合作方'
      ),
      logoUrl:
        (listing?.logoFileAssetId
          ? this.mediaProjectionService.readDisplayUrl(listing.logoFileAssetId, displayUrlMap)
          : null) || participantAvatarUrl,
      primaryBoardType: boardType,
      provinceName: this.firstNonEmpty(listing?.provinceName, '未提供'),
      cityName: this.firstNonEmpty(listing?.cityName, '未提供'),
      verificationStatus:
        this.firstNonEmpty(listing?.verificationStatusSnapshot, certification.certificationStatus)
    };
  }

  private buildReviewSummary(reviewSummary: EnterpriseReviewSummaryEntity | null) {
    if (!reviewSummary) {
      return {
        avgScore: null,
        reviewCount: 0,
        keywordTags: []
      };
    }
    return {
      avgScore: this.toNumber(reviewSummary.avgScore),
      reviewCount: reviewSummary.reviewCount ?? 0,
      keywordTags: this.readStringArray(reviewSummary.keywordTags)
    };
  }

  private firstNonEmpty(...values: Array<string | null | undefined>) {
    for (const value of values) {
      const normalized = value?.trim() ?? '';
      if (normalized) {
        return normalized;
      }
    }
    return '';
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

  private resolveParticipantUserId(params: {
    participantRole: Exclude<TradingImParticipantRole, 'viewer'>;
    bid: BidEntity | null;
    project: ProjectEntity | null;
  }) {
    const { participantRole, bid, project } = params;
    const userId =
      participantRole === 'bidder'
        ? bid?.userId?.trim() ?? ''
        : project?.creatorUserId?.trim() ?? '';
    return userId || null;
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

  private async readAvatarUrl(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(normalized)) ?? normalized;
  }
}

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import {
  bidSubmissionAttachmentSlots,
  buildBidSubmissionSnapshotAttachments,
} from '../bid/bid-submission-attachment.support';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { UploadPublicUrlService } from '../upload/upload-public-url.service';
import { MyBidPresenter } from './my-bid.presenter';
import { myBidsForbidden, myBidsInvalid, myBidsUnavailable } from './my-bid.errors';

type MyBidFilter = 'active' | 'historical' | null;

@Injectable()
export class MyBidQueryService {
  constructor(
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidPrivateThreadEntity)
    private readonly threadRepository: Repository<BidPrivateThreadEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly avatarUrlService: UploadPublicUrlService,
    private readonly presenter: MyBidPresenter,
  ) {}

  async listMyBids(state: string | undefined, context: RequestContext) {
    const filter = this.readFilter(state);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw myBidsForbidden('Current organization scope is required for my bids.');
    }

    const bids = await this.bidRepository.find({
      where: [
        { bidderOrganizationId: organizationId },
        { organizationId },
      ],
      order: { submittedAt: 'DESC', createdAt: 'DESC' },
    });
    if (!bids.length) {
      return this.presenter.toListResponse([]);
    }

    const projectIds = [...new Set(bids.map((item) => item.projectId))];
    const bidIds = bids.map((item) => item.id);
    const [projects, threads] = await Promise.all([
      this.projectRepository.findBy({ id: In(projectIds) }),
      this.threadRepository.findBy({ bidId: In(bidIds) }),
    ]);
    const projectMap = new Map(projects.map((item) => [item.id, item]));
    const threadBidIds = new Set(threads.map((item) => item.bidId));

    const items = bids
      .map((bid) => {
        const project = projectMap.get(bid.projectId);
        if (!project) {
          return null;
        }
        const outcomeState = this.deriveOutcomeState(project, bid);
        const item = {
          bidId: bid.id,
          projectId: project.id,
          projectNo: project.projectNo,
          projectTitle: project.title,
          quoteAmount: Number(bid.quoteAmount),
          proposalSummaryPreview: this.previewProposalSummary(bid.proposalSummary),
          submittedAt: bid.submittedAt.toISOString(),
          outcomeState,
          canOpenBidThread: threadBidIds.has(bid.id) || project.state !== 'archived',
          canOpenBidResult: this.canOpenBidResult(project, bid),
          snapshotReadable: true,
        };
        if (!this.matchesFilter(filter, item.outcomeState)) {
          return null;
        }
        return item;
      })
      .filter((item): item is NonNullable<typeof item> => item !== null);

    return this.presenter.toListResponse(items);
  }

  async getSubmissionSnapshot(
    query: { projectId?: string; bidId?: string },
    context: RequestContext,
  ) {
    const projectId = this.readRequiredId(query.projectId, 'projectId');
    const bidId = this.readRequiredId(query.bidId, 'bidId');
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw myBidsForbidden('Current organization scope is required for bid submission snapshot.');
    }

    const [bid, project] = await Promise.all([
      this.bidRepository.findOneBy({ id: bidId, projectId }),
      this.projectRepository.findOneBy({ id: projectId }),
    ]);
    if (!bid || !project) {
      throw myBidsUnavailable('Current bid submission snapshot is unavailable.');
    }

    const isBidder =
      organizationId === bid.bidderOrganizationId || organizationId === bid.organizationId;
    const isProjectOwner = organizationId === project.organizationId;
    if (!isBidder && !isProjectOwner) {
      throw myBidsForbidden('Current actor cannot access the bid submission snapshot.');
    }

    const bidderOrganizationId = bid.bidderOrganizationId || bid.organizationId;
    const [bidderOrganization, bidderUser] = await Promise.all([
      this.organizationRepository.findOneBy({
        id: bidderOrganizationId,
      }),
      bid.userId?.trim()
        ? this.userRepository.findOneBy({ id: bid.userId.trim() })
        : Promise.resolve(null),
    ]);
    const attachments = await this.loadSnapshotAttachments(bid);

    return this.presenter.toSnapshot({
      projectId,
      bidId,
      bidder: {
        organizationId: bidderOrganizationId,
        displayName: bidderOrganization?.name ?? '当前竞标方',
        avatarUrl: await this.readAvatarUrl(bidderUser?.avatarUrl ?? null),
      },
      submittedAt: bid.submittedAt,
      quoteAmount: Number(bid.quoteAmount),
      proposalSummary: bid.proposalSummary,
      attachmentSummary: { count: attachments.length },
      attachments,
      availability: {
        canOpenBidThread: true,
        canOpenBidResult: this.canOpenBidResult(project, bid),
        snapshotReadable: true,
        participantCardReadable: true,
        reason: 'participant_allowed',
      },
    });
  }

  private async loadSnapshotAttachments(bid: BidEntity) {
    const ids = [
      bid.projectUnderstandingFileAssetId,
      bid.quoteSheetFileAssetId,
      bid.schedulePlanFileAssetId,
    ]
      .map((item) => item?.trim() ?? '')
      .filter((item) => item.length > 0);
    if (ids.length) {
      const fileAssets = await this.fileAssetRepository.findBy({ id: In(ids) });
      if (fileAssets.length !== ids.length) {
        throw myBidsUnavailable('Current bid submission attachments are unavailable.');
      }
      return buildBidSubmissionSnapshotAttachments(
        bid,
        new Map(fileAssets.map((item) => [item.id, item])),
      );
    }
    return this.loadLegacySnapshotAttachments(bid);
  }

  private async loadLegacySnapshotAttachments(bid: BidEntity) {
    const bidderOrganizationId =
      bid.bidderOrganizationId?.trim() || bid.organizationId?.trim() || '';
    if (!bidderOrganizationId) {
      return [];
    }
    const legacyAssets = await this.fileAssetRepository.find({
      where: {
        organizationId: bidderOrganizationId,
        businessType: 'project',
        businessId: bid.projectId,
        fileKind: In(bidSubmissionAttachmentSlots.map((slot) => slot.fileKind)),
      },
      order: { createdAt: 'DESC' },
    });
    if (!legacyAssets.length) {
      return [];
    }
    const resolvedBySlot = new Map<string, FileAssetEntity>();
    for (const slot of bidSubmissionAttachmentSlots) {
      const matched = legacyAssets.find(
        (item) => item.fileKind === slot.fileKind && item.createdAt <= bid.submittedAt,
      );
      if (!matched) {
        return [];
      }
      resolvedBySlot.set(slot.bidField, matched);
    }
    const legacyBid = {
      ...bid,
      projectUnderstandingFileAssetId:
        resolvedBySlot.get('projectUnderstandingFileAssetId')?.id ?? null,
      quoteSheetFileAssetId: resolvedBySlot.get('quoteSheetFileAssetId')?.id ?? null,
      schedulePlanFileAssetId: resolvedBySlot.get('schedulePlanFileAssetId')?.id ?? null,
    } satisfies BidEntity;
    return buildBidSubmissionSnapshotAttachments(
      legacyBid,
      new Map(legacyAssets.map((item) => [item.id, item])),
    );
  }

  private readFilter(value: string | undefined): MyBidFilter {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    if (normalized === 'active' || normalized === 'historical') {
      return normalized;
    }
    throw myBidsInvalid('Field `state` only admits `active` or `historical`.');
  }

  private matchesFilter(filter: MyBidFilter, outcomeState: string) {
    if (!filter) {
      return true;
    }
    const historical = outcomeState === 'awarded' || outcomeState === 'converted_to_order' || outcomeState === 'lost';
    return filter === 'historical' ? historical : !historical;
  }

  private deriveOutcomeState(project: ProjectEntity, bid: BidEntity) {
    if (bid.state === 'awarded' || bid.state === 'lost') {
      return bid.state;
    }
    if (project.state === 'converted_to_order') {
      return 'converted_to_order';
    }
    if (project.state === 'awarded' && bid.state !== 'submitted') {
      return bid.state;
    }
    if (project.state) {
      return project.state;
    }
    return 'submitted';
  }

  private async readAvatarUrl(value: string | null) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    return (await this.avatarUrlService.buildAccessUrlFromObjectUrl(normalized)) ?? normalized;
  }

  private canOpenBidResult(project: ProjectEntity, bid: BidEntity) {
    return (
      bid.state === 'awarded' ||
      bid.state === 'lost' ||
      project.state === 'awarded' ||
      project.state === 'converted_to_order'
    );
  }

  private previewProposalSummary(value: string) {
    const normalized = value.trim();
    if (normalized.length <= 100) {
      return normalized;
    }
    return `${normalized.slice(0, 97)}...`;
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      return normalized;
    }
    throw myBidsInvalid(`Field \`${fieldName}\` is required.`);
  }
}

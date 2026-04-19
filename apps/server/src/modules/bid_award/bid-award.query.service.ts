import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidAwardPresenter } from './bid-award.presenter';
import { bidResultInvalid, bidResultUnavailable } from './bid-award.errors';
import { readBidAwardTruth } from './bid-award.truth';

const VISIBLE_RESULT_STATES = new Set(['awarded', 'lost']);

@Injectable()
export class BidAwardQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: BidAwardPresenter
  ) {}

  async getResult(projectId: string | undefined, context: RequestContext) {
    const normalizedProjectId = this.readProjectId(projectId);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireBidQualifiedScope(
      currentSession,
      'bid result'
    );
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project) {
      throw bidResultUnavailable('Current bid result is unavailable for this project.');
    }
    if (scope.organization.id === project.organizationId) {
      throw authPermissionInsufficient('Current organization cannot read bid result for its own project.', {
        reason: 'owner_relation_not_allowed',
        organizationId: scope.organization.id,
        projectOrganizationId: project.organizationId
      });
    }

    const award = readBidAwardTruth(project.summary);
    if (!award || !this.isVisibleProjectState(project.state)) {
      throw bidResultUnavailable('Current bid result is unavailable for this project.');
    }

    const bids = await this.bidRepository.find({
      where: {
        projectId: normalizedProjectId,
        organizationId: scope.organization.id
      },
      order: {
        updatedAt: 'DESC',
        createdAt: 'DESC',
        id: 'DESC'
      }
    });
    const selectedBid = this.pickVisibleBid(bids);
    if (!selectedBid) {
      throw bidResultUnavailable('Current bid result is unavailable for this project.');
    }

    return this.presenter.toResultReadModel(selectedBid, award);
  }

  private readProjectId(projectId: string | undefined) {
    const normalized = projectId?.trim() ?? '';
    if (!normalized) {
      throw bidResultInvalid('Field `projectId` is required for bid result.');
    }
    return normalized;
  }

  private pickVisibleBid(bids: BidEntity[]) {
    for (const bid of bids) {
      if (VISIBLE_RESULT_STATES.has(bid.state)) {
        return bid;
      }
    }
    return null;
  }

  private isVisibleProjectState(value: string | null | undefined) {
    const normalized = this.readOptionalText(value);
    return normalized === 'awarded' || normalized === 'converted_to_order';
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

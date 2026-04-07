import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationMembershipQuotaSnapshotEntity } from './entities/organization-membership-quota-snapshot.entity';
import { OrganizationPaidMembershipEntity } from './entities/organization-paid-membership.entity';
import {
  buildQuotaSummaryLine,
  buildUpgradeGuide,
  getCommercialDisclosure,
  getQuotaSpec,
  getTierSpec,
  listAvailableTierItems,
  listEntitlementNotes,
  listExplanationTiers,
  listQuotaNotes
} from './membership.catalog';
import { MembershipPresenter } from './membership.presenter';

type ShellMembershipSummary = {
  paidMembershipTier: string | null;
  paidMembershipEntitlementsSummary: string[];
  paidMembershipQuotaSummary: string[];
  paidMembershipNextRefreshAt: Date | null;
};

@Injectable()
export class MembershipQueryService {
  constructor(
    @InjectRepository(OrganizationPaidMembershipEntity)
    private readonly paidMembershipRepository: Repository<OrganizationPaidMembershipEntity>,
    @InjectRepository(OrganizationMembershipQuotaSnapshotEntity)
    private readonly quotaSnapshotRepository: Repository<OrganizationMembershipQuotaSnapshotEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: MembershipPresenter
  ) {}

  async getCurrent(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const projection = await this.buildScopedProjection(organizationId);
    return this.presenter.toCurrent({
      organizationId,
      paidMembershipTier: projection.paidMembershipTier,
      rateBand: projection.rateBand,
      entitlementsSummary: projection.entitlementsSummary,
      quotaSummary: projection.quotaSummary,
      effectiveAt: projection.effectiveAt,
      expiresAt: projection.expiresAt,
      nextRefreshAt: projection.nextRefreshAt
    });
  }

  async getExplanation(context: RequestContext) {
    await this.requireCurrentOrganizationId(context);
    return this.presenter.toExplanation({
      tiers: listExplanationTiers(),
      entitlementNotes: listEntitlementNotes(),
      quotaNotes: listQuotaNotes(),
      disclaimer: getCommercialDisclosure()
    });
  }

  async getQuota(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const projection = await this.buildScopedProjection(organizationId);
    return this.presenter.toQuota({
      items: projection.quotaItems,
      nextRefreshAt: projection.nextRefreshAt
    });
  }

  async getUpgradeGuide(context: RequestContext) {
    const organizationId = await this.requireCurrentOrganizationId(context);
    const projection = await this.buildScopedProjection(organizationId);
    const guide = buildUpgradeGuide(projection.paidMembershipTier);
    return this.presenter.toUpgradeGuide({
      currentTier: guide.currentTier,
      availableTiers: listAvailableTierItems(projection.paidMembershipTier),
      upgradeHighlights: guide.upgradeHighlights,
      commercialDisclosure: getCommercialDisclosure()
    });
  }

  async getShellSummaryProjection(organizationId: string | null): Promise<ShellMembershipSummary> {
    if (!organizationId) {
      return {
        paidMembershipTier: null,
        paidMembershipEntitlementsSummary: [],
        paidMembershipQuotaSummary: [],
        paidMembershipNextRefreshAt: null
      };
    }

    const projection = await this.buildScopedProjection(organizationId);
    return {
      paidMembershipTier: projection.paidMembershipTier,
      paidMembershipEntitlementsSummary: projection.entitlementsSummary,
      paidMembershipQuotaSummary: projection.quotaSummary,
      paidMembershipNextRefreshAt: projection.nextRefreshAt
    };
  }

  private async requireCurrentOrganizationId(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient('Current organization scope is required for membership read.');
    }
    return scope.organization.id;
  }

  private async buildScopedProjection(organizationId: string) {
    const [currentCycle, quotaSnapshots] = await Promise.all([
      this.findCurrentCycle(organizationId),
      this.listQuotaSnapshots(organizationId)
    ]);
    const tierSpec = getTierSpec(currentCycle?.tierCode ?? null);
    const quotaItems = quotaSnapshots.map((snapshot) => {
      const quotaSpec = getQuotaSpec(snapshot.quotaType);
      return {
        quotaType: snapshot.quotaType,
        summary: buildQuotaSummaryLine({
          quotaType: snapshot.quotaType,
          currentValue: snapshot.currentValue,
          refreshRule: snapshot.refreshRule
        }),
        currentValue: snapshot.currentValue,
        refreshRule: snapshot.refreshRule ?? quotaSpec?.defaultRefreshRule ?? null
      };
    });
    const nextRefreshAt = this.pickNextRefreshAt(quotaSnapshots);

    return {
      paidMembershipTier: currentCycle?.tierCode ?? null,
      rateBand: tierSpec?.rateBand ?? null,
      entitlementsSummary: tierSpec?.entitlementsSummary ?? [],
      quotaSummary: quotaItems.map((item) => item.summary),
      effectiveAt: currentCycle?.effectiveAt ?? null,
      expiresAt: currentCycle?.expiresAt ?? null,
      nextRefreshAt,
      quotaItems
    };
  }

  private findCurrentCycle(organizationId: string) {
    const now = new Date();
    return this.paidMembershipRepository
      .createQueryBuilder('membership')
      .where('membership.organization_id = :organizationId', { organizationId })
      .andWhere('membership.effective_at <= :now', { now })
      .andWhere('(membership.expires_at IS NULL OR membership.expires_at > :now)', { now })
      .orderBy('membership.effective_at', 'DESC')
      .addOrderBy('membership.created_at', 'DESC')
      .getOne();
  }

  private listQuotaSnapshots(organizationId: string) {
    return this.quotaSnapshotRepository.find({
      where: { organizationId },
      order: { quotaType: 'ASC', updatedAt: 'DESC' }
    });
  }

  private pickNextRefreshAt(quotaSnapshots: OrganizationMembershipQuotaSnapshotEntity[]) {
    return quotaSnapshots.reduce<Date | null>((earliest, item) => {
      if (!item.nextRefreshAt) {
        return earliest;
      }
      if (!earliest || item.nextRefreshAt.getTime() < earliest.getTime()) {
        return item.nextRefreshAt;
      }
      return earliest;
    }, null);
  }
}

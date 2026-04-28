import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Not, Repository } from 'typeorm';
import { CurrentSessionVerificationResult } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import {
  CurrentActorEligibilityService,
  CurrentOrganizationScope,
} from '../organization/current-actor-eligibility.service';
import { readBidAwardTruth } from '../bid_award/bid-award.truth';
import { ProjectNameAccessProjectionService } from '../project_name_access/project-name-access-projection.service';
import { ProjectEntity } from './entities/project.entity';
import { projectUnavailable } from './project.errors';
import { ProjectPresenter } from './project.presenter';

type ProjectViewerRelation = 'owner' | 'non_owner';
type ProjectBidCandidateRow = {
  bidId: string;
  bidNo: string | null;
  bidderOrganizationId: string | null;
  bidderOrganizationName: string | null;
  quoteAmount: string | number | null;
  proposalSummary: string | null;
  state: string | null;
  submittedAt: string | Date | null;
};

type ProjectBidCandidateReadModel = {
  bidId: string;
  bidNo: string | null;
  bidderOrganizationId: string | null;
  bidderOrganizationName: string | null;
  quoteAmount: number | null;
  proposalSummary: string | null;
  state: string | null;
  submittedAt: string | null;
};
type ProjectCurrentViewerBidRow = {
  bidId: string;
  state: string | null;
};
type ProjectCurrentViewerBidReadModel = {
  bidId: string;
  state: string;
};
type ProjectListQuery = {
  provinceCode?: string;
  cityCode?: string;
  areaBucket?: string;
  budgetBucket?: string;
  page?: string;
  pageSize?: string;
};

const STANDARD_AREA_BUCKETS = new Map<string, number>([
  ['9_sqm', 9],
  ['18_sqm', 18],
  ['27_sqm', 27],
  ['36_sqm', 36],
  ['54_sqm', 54],
  ['72_sqm', 72],
  ['81_sqm', 81],
  ['90_sqm', 90],
  ['108_sqm', 108]
]);

const BUDGET_BUCKET_RANGES = new Map<string, { min: number; max: number | null }>([
  ['0_2w', { min: 0, max: 20000 }],
  ['2_4w', { min: 20000, max: 40000 }],
  ['4_6w', { min: 40000, max: 60000 }],
  ['6_8w', { min: 60000, max: 80000 }],
  ['8_10w', { min: 80000, max: 100000 }],
  ['10_15w', { min: 100000, max: 150000 }],
  ['15_20w', { min: 150000, max: 200000 }],
  ['20w_plus', { min: 200000, max: null }]
]);

@Injectable()
export class ProjectQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly projectNameAccessProjectionService: ProjectNameAccessProjectionService,
    private readonly presenter: ProjectPresenter
  ) {}

  async listProjects(context: RequestContext, query: ProjectListQuery = {}) {
    const provinceCode = this.normalizeText(query.provinceCode);
    const cityCode = this.normalizeText(query.cityCode);
    const areaBucket = this.normalizeText(query.areaBucket);
    const budgetBucket = this.normalizeText(query.budgetBucket);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 50);
    const projects = await this.projectRepository.find({
      where: {
        publishedAt: Not(IsNull()),
        ...(provinceCode ? { provinceCode } : {}),
        ...(cityCode ? { cityCode } : {})
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    const visibleProjects = projects.filter(
      (project) =>
        this.isPublicShowcaseVisible(project) &&
        this.matchesAreaBucket(project, areaBucket) &&
        this.matchesBudgetBucket(project, budgetBucket)
    );
    const total = visibleProjects.length;
    const pagedProjects = visibleProjects.slice((page - 1) * pageSize, page * pageSize);
    const viewer = await this.resolveOptionalViewerContext(context);
    const accessProjectionByProjectId =
      await this.projectNameAccessProjectionService.buildPublicProjectionMap({
        projects: pagedProjects,
        viewerOrganizationId: viewer.scope?.organization.id ?? null,
        ownerProjectIds: new Set(
          pagedProjects
            .filter((project) => this.isOwnerOrganizationViewer(project, viewer.scope))
            .map((project) => project.id),
        ),
      });
    return this.presenter.toListResponse(
      pagedProjects,
      page,
      pageSize,
      total,
      accessProjectionByProjectId,
    );
  }

  async getProjectById(projectId: string, context: RequestContext) {
    const normalized = projectId.trim();
    if (!normalized) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const project = await this.projectRepository.findOneBy({ id: normalized });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    if (this.isArchivedProject(project)) {
      throw projectUnavailable('Current project is unavailable.');
    }
    const viewer = await this.resolveOptionalViewerContext(context);
    const viewerProjectRelation = this.resolveViewerProjectRelation(project, viewer);
    if (project.publishedAt == null) {
      throw projectUnavailable('Current project is unavailable.');
    }
    if (viewerProjectRelation !== 'owner' && !this.isPublicShowcaseVisible(project)) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const currentViewerBid =
      viewerProjectRelation === 'owner'
        ? null
        : await this.fetchCurrentViewerBid(
            project.id,
            viewer.scope?.organization.id ?? null,
          );
    const readModel = {
      ...this.presenter.toReadModel(
        project,
        await this.projectNameAccessProjectionService.buildSingleProjectProjection({
          project,
          viewerOrganizationId: viewer.scope?.organization.id ?? null,
          isOwnerViewer: this.isOwnerOrganizationViewer(project, viewer.scope),
        }),
      ),
      viewerProjectRelation,
      currentViewerBid
    };
    if (viewerProjectRelation !== 'owner') {
      return readModel;
    }
    return {
      ...readModel,
      bidCandidates: await this.fetchProjectBidCandidates(project.id),
      bidSelection: this.readProjectBidSelection(project),
    };
  }

  async getEditableProjectById(projectId: string, context: RequestContext) {
    const normalizedProjectId = projectId.trim();
    if (!normalizedProjectId) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const { scope } = await this.eligibilityService.requireProjectPublishEligibilityFromContext(
      context,
      this.currentSessionVerificationService
    );
    const project = await this.projectRepository.findOneBy({
      id: normalizedProjectId,
      organizationId: scope.organization.id
    });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }

    return {
      ...this.presenter.toReadModel(project),
      viewerProjectRelation: 'owner' satisfies ProjectViewerRelation
    };
  }

  private async resolveOptionalViewerContext(context: RequestContext) {
    const verification = await this.verifyOptionalCurrentSession(context);
    if (verification.outcome !== 'verified') {
      return {
        currentSession: null,
        scope: null,
      };
    }

    try {
      return {
        currentSession: verification.currentSession,
        scope: await this.eligibilityService.getCurrentOrganizationScope(verification.currentSession),
      };
    } catch {
      return {
        currentSession: verification.currentSession,
        scope: null,
      };
    }
  }

  private resolveViewerProjectRelation(
    project: ProjectEntity,
    viewer: {
      currentSession: { userId: string } | null;
      scope: CurrentOrganizationScope | null;
    },
  ) {
    if (!viewer.currentSession) {
      return 'non_owner' satisfies ProjectViewerRelation;
    }
    if (!this.sameUser(project.creatorUserId, viewer.currentSession.userId)) {
      return 'non_owner' satisfies ProjectViewerRelation;
    }
    if (!viewer.scope) {
      return 'non_owner' satisfies ProjectViewerRelation;
    }
    return viewer.scope.organization.id === project.organizationId
      ? ('owner' satisfies ProjectViewerRelation)
      : ('non_owner' satisfies ProjectViewerRelation);
  }

  private isOwnerOrganizationViewer(project: ProjectEntity, scope: CurrentOrganizationScope | null) {
    return Boolean(scope && scope.organization.id === project.organizationId);
  }

  private async verifyOptionalCurrentSession(context: RequestContext) {
    if (!context.authorization.trim()) {
      return {
        outcome: 'failed' as const,
        reason: 'missing_current_session_carrier' as const,
        requestId: context.requestId,
        traceId: context.traceId
      } satisfies Extract<CurrentSessionVerificationResult, { outcome: 'failed' }>;
    }

    return this.currentSessionVerificationService.verifyCurrentSessionContext(context);
  }

  private sameUser(projectCreatorUserId: string | null, currentUserId: string) {
    const creatorUserId = projectCreatorUserId?.trim() ?? '';
    const viewerUserId = currentUserId.trim();
    return Boolean(creatorUserId) && creatorUserId === viewerUserId;
  }

  private async fetchProjectBidCandidates(projectId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          bid.id as "bidId",
          bid.bid_no as "bidNo",
          coalesce(nullif(bid.bidder_organization_id, ''), bid.organization_id) as "bidderOrganizationId",
          organization.name as "bidderOrganizationName",
          bid.quote_amount as "quoteAmount",
          bid.proposal_summary as "proposalSummary",
          bid.state as "state",
          bid.submitted_at as "submittedAt"
        from public.bids bid
        left join public.organizations organization
          on organization.id::text = coalesce(nullif(bid.bidder_organization_id, ''), bid.organization_id)
        where bid.project_id = $1
        order by bid.submitted_at asc nulls last, bid.created_at asc nulls last, bid.id asc
      `,
      [projectId]
    )) as ProjectBidCandidateRow[];

    return rows
      .map((row) => this.toProjectBidCandidate(row))
      .filter((row): row is ProjectBidCandidateReadModel => row !== null);
  }

  private async fetchCurrentViewerBid(
    projectId: string,
    organizationId: string | null,
  ) {
    const normalizedOrganizationId = this.normalizeNullableText(organizationId);
    if (!normalizedOrganizationId) {
      return null;
    }

    const rows = (await this.projectRepository.query(
      `
        select
          bid.id as "bidId",
          bid.state as "state"
        from public.bids bid
        where bid.project_id = $1
          and (
            bid.bidder_organization_id = $2
            or bid.organization_id = $2
          )
        order by bid.submitted_at desc nulls last, bid.created_at desc nulls last, bid.id desc
        limit 1
      `,
      [projectId, normalizedOrganizationId]
    )) as ProjectCurrentViewerBidRow[];

    return this.toProjectCurrentViewerBid(rows[0]);
  }

  private toProjectCurrentViewerBid(row: ProjectCurrentViewerBidRow | undefined) {
    if (!row) {
      return null;
    }
    const bidId = this.normalizeText(row.bidId);
    if (!bidId) {
      return null;
    }
    return {
      bidId,
      state: this.normalizeNullableText(row.state) ?? 'submitted',
    } satisfies ProjectCurrentViewerBidReadModel;
  }

  private toProjectBidCandidate(row: ProjectBidCandidateRow) {
    const bidId = this.normalizeText(row.bidId);
    if (!bidId) {
      return null;
    }
    return {
      bidId,
      bidNo: this.normalizeNullableText(row.bidNo),
      bidderOrganizationId: this.normalizeNullableText(row.bidderOrganizationId),
      bidderOrganizationName: this.normalizeNullableText(row.bidderOrganizationName),
      quoteAmount: this.toNullableNumber(row.quoteAmount),
      proposalSummary: this.normalizeNullableText(row.proposalSummary),
      state: this.normalizeNullableText(row.state),
      submittedAt: this.toDateTimeString(row.submittedAt),
    } satisfies ProjectBidCandidateReadModel;
  }

  private readProjectBidSelection(project: ProjectEntity) {
    const award = readBidAwardTruth(project.summary);
    if (!award) {
      return null;
    }
    return {
      winningBidId: award.winningBidId,
      orderId: award.orderId,
      contractId: award.contractId,
    };
  }

  private normalizeNullableText(value: string | null | undefined) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private toDateTimeString(value: string | Date | null | undefined) {
    if (typeof value === 'string') {
      const normalized = value.trim();
      return normalized ? normalized : null;
    }
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
      return value.toISOString();
    }
    return null;
  }

  private normalizeText(value: string | undefined) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private readPositiveInt(value: string | undefined, fallback: number, max = 100) {
    if (value === undefined) {
      return fallback;
    }
    const normalized = this.normalizeText(value);
    if (!normalized) {
      return fallback;
    }
    if (!/^\d+$/.test(normalized)) {
      return fallback;
    }
    const parsed = Number(normalized);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, max);
  }

  private isPublicShowcaseVisible(project: ProjectEntity) {
    if (this.isArchivedProject(project)) {
      return false;
    }
    const plannedEndAt = this.toDateOnlyString(project.plannedEndAt);
    if (!plannedEndAt) {
      return true;
    }
    return plannedEndAt >= this.currentDateString();
  }

  private matchesAreaBucket(project: ProjectEntity, areaBucket: string) {
    if (!areaBucket) {
      return true;
    }

    const areaSqm = this.toNullableNumber(project.areaSqm);
    if (areaSqm === null || areaSqm <= 0) {
      return false;
    }

    const standardArea = STANDARD_AREA_BUCKETS.get(areaBucket);
    if (standardArea !== undefined) {
      return areaSqm === standardArea;
    }
    if (areaBucket === 'gt_108_sqm') {
      return areaSqm > 108;
    }
    if (areaBucket === 'custom_sqm') {
      return areaSqm <= 108 && ![...STANDARD_AREA_BUCKETS.values()].includes(areaSqm);
    }
    return false;
  }

  private matchesBudgetBucket(project: ProjectEntity, budgetBucket: string) {
    if (!budgetBucket) {
      return true;
    }

    const budgetAmount = this.toNullableNumber(project.budgetAmount);
    if (budgetAmount === null) {
      return false;
    }

    const range = BUDGET_BUCKET_RANGES.get(budgetBucket);
    if (!range) {
      return false;
    }
    if (budgetAmount < range.min) {
      return false;
    }
    return range.max === null ? true : budgetAmount < range.max;
  }

  private toNullableNumber(value: string | number | null | undefined) {
    if (value === null || value === undefined) {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private toDateOnlyString(value: string | Date | null | undefined) {
    if (typeof value === 'string') {
      const normalized = value.trim();
      return normalized.length > 0 ? normalized : null;
    }
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
      return value.toISOString().slice(0, 10);
    }
    return null;
  }

  private currentDateString() {
    return new Date().toISOString().slice(0, 10);
  }

  private isArchivedProject(project: ProjectEntity) {
    return project.state?.trim() === 'archived';
  }
}

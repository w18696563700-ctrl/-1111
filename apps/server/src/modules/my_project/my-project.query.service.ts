import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { projectUnavailable } from '../project/project.errors';
import { MyProjectPresenter } from './my-project.presenter';
import {
  MyProjectPrivateProgressReadModel,
  createDefaultMyProjectPrivateProgress,
  deriveMyProjectPrivateProgress
} from './my-project.private-progress';

type OrderTruthRow = {
  id: string;
  projectId: string;
  state: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type ContractTruthRow = {
  id: string;
  orderId: string;
  state: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type MilestoneTruthRow = {
  id: string;
  orderId: string;
  state: string | null;
  sequenceNo: number | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type DisputeTruthRow = {
  id: string;
  orderId: string;
  state: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type RatingTruthRow = {
  id: string;
  orderId: string;
  state: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type ProjectViewerRelation = 'owner' | 'non_owner';

@Injectable()
export class MyProjectQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: MyProjectPresenter
  ) {}

  async listProjects(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      return this.presenter.toListResponse([], new Map());
    }

    const projects = await this.projectRepository.find({
      where: { organizationId: scope.organization.id },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    const privateProgressByProjectId = await this.loadPrivateProgressByProjectId(projects);
    return this.presenter.toListResponse(
      projects,
      this.ensurePrivateProgressByProjectId(projects, privateProgressByProjectId)
    );
  }

  async getProjectById(projectId: string, context: RequestContext) {
    const normalizedProjectId = projectId.trim();
    if (!normalizedProjectId) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const project = await this.projectRepository.findOneBy({
      id: normalizedProjectId,
      organizationId: scope.organization.id
    });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const privateProgressByProjectId = await this.loadPrivateProgressByProjectId([project]);
    return this.presenter.toDetailResponse(
      project,
      this.ensurePrivateProgress(project.id, privateProgressByProjectId),
      this.resolveViewerProjectRelation(project, currentSession.userId, scope.organization.id)
    );
  }

  private async loadPrivateProgressByProjectId(projects: ProjectEntity[]) {
    const privateProgressByProjectId = new Map<string, MyProjectPrivateProgressReadModel>();

    for (const project of projects) {
      privateProgressByProjectId.set(project.id, createDefaultMyProjectPrivateProgress());
    }

    const projectIds = projects.map((project) => project.id);
    if (!projectIds.length) {
      return privateProgressByProjectId;
    }

    const orderRows = await this.fetchOrderRows(projectIds);
    const latestOrderByProjectId = this.pickFirstRowByKey(orderRows, (row) => row.projectId);
    const latestOrderIds = Array.from(
      new Set(Array.from(latestOrderByProjectId.values()).map((row) => row.id))
    );

    if (!latestOrderIds.length) {
      return privateProgressByProjectId;
    }

    const [contractRows, milestoneRows, disputeRows, ratingRows] = await Promise.all([
      this.fetchContractRows(latestOrderIds),
      this.fetchMilestoneRows(latestOrderIds),
      this.fetchDisputeRows(latestOrderIds),
      this.fetchRatingRows(latestOrderIds)
    ]);

    const latestContractByOrderId = this.pickFirstRowByKey(contractRows, (row) => row.orderId);
    const currentMilestoneByOrderId = this.pickFirstRowByKey(milestoneRows, (row) => row.orderId);
    const latestDisputeByOrderId = this.pickFirstRowByKey(disputeRows, (row) => row.orderId);
    const latestRatingByOrderId = this.pickFirstRowByKey(ratingRows, (row) => row.orderId);

    for (const project of projects) {
      const order = latestOrderByProjectId.get(project.id);
      if (!order) {
        continue;
      }

      privateProgressByProjectId.set(
        project.id,
        deriveMyProjectPrivateProgress({
          hasAcceptedOrder: true,
          orderStatus: this.normalizeState(order.state),
          contractStatus: this.normalizeState(latestContractByOrderId.get(order.id)?.state ?? null),
          fulfillmentStatus: this.normalizeState(currentMilestoneByOrderId.get(order.id)?.state ?? null),
          // The current runtime has no dedicated acceptance truth carrier wired into this repo.
          acceptanceStatus: null,
          afterSalesOrDisputeStatus: this.normalizeState(
            latestDisputeByOrderId.get(order.id)?.state ?? null
          ),
          ratingStatus: this.normalizeState(latestRatingByOrderId.get(order.id)?.state ?? null)
        })
      );
    }

    return privateProgressByProjectId;
  }

  private ensurePrivateProgressByProjectId(
    projects: ProjectEntity[],
    privateProgressByProjectId: Map<string, MyProjectPrivateProgressReadModel>
  ) {
    for (const project of projects) {
      this.ensurePrivateProgress(project.id, privateProgressByProjectId);
    }
    return privateProgressByProjectId;
  }

  private ensurePrivateProgress(
    projectId: string,
    privateProgressByProjectId: Map<string, MyProjectPrivateProgressReadModel>
  ) {
    const privateProgress = privateProgressByProjectId.get(projectId);
    if (privateProgress) {
      return privateProgress;
    }
    const fallback = createDefaultMyProjectPrivateProgress();
    privateProgressByProjectId.set(projectId, fallback);
    return fallback;
  }

  private fetchOrderRows(projectIds: string[]) {
    return this.projectRepository.query(
      `
        select
          id,
          project_id as "projectId",
          state,
          created_at as "createdAt",
          updated_at as "updatedAt"
        from public.orders
        where project_id = any($1::varchar[])
        order by project_id asc, updated_at desc nulls last, created_at desc nulls last, id desc
      `,
      [projectIds]
    ) as Promise<OrderTruthRow[]>;
  }

  private fetchContractRows(orderIds: string[]) {
    return this.projectRepository.query(
      `
        select
          id,
          order_id as "orderId",
          state,
          created_at as "createdAt",
          updated_at as "updatedAt"
        from public.contracts
        where order_id = any($1::varchar[])
        order by order_id asc, updated_at desc nulls last, created_at desc nulls last, id desc
      `,
      [orderIds]
    ) as Promise<ContractTruthRow[]>;
  }

  private fetchMilestoneRows(orderIds: string[]) {
    return this.projectRepository.query(
      `
        select
          id,
          order_id as "orderId",
          state,
          sequence_no as "sequenceNo",
          created_at as "createdAt",
          updated_at as "updatedAt"
        from public.milestones
        where order_id = any($1::varchar[])
        order by
          order_id asc,
          case when state = 'completed' then 1 else 0 end asc,
          sequence_no asc nulls last,
          updated_at desc nulls last,
          created_at desc nulls last,
          id desc
      `,
      [orderIds]
    ) as Promise<MilestoneTruthRow[]>;
  }

  private fetchDisputeRows(orderIds: string[]) {
    return this.projectRepository.query(
      `
        select
          id,
          order_id as "orderId",
          state,
          created_at as "createdAt",
          updated_at as "updatedAt"
        from public.disputes
        where order_id = any($1::varchar[])
        order by order_id asc, updated_at desc nulls last, created_at desc nulls last, id desc
      `,
      [orderIds]
    ) as Promise<DisputeTruthRow[]>;
  }

  private fetchRatingRows(orderIds: string[]) {
    return this.projectRepository.query(
      `
        select
          id,
          order_id as "orderId",
          state,
          created_at as "createdAt",
          updated_at as "updatedAt"
        from public.ratings
        where order_id = any($1::varchar[])
        order by order_id asc, updated_at desc nulls last, created_at desc nulls last, id desc
      `,
      [orderIds]
    ) as Promise<RatingTruthRow[]>;
  }

  private pickFirstRowByKey<T>(rows: T[], readKey: (row: T) => string) {
    const byKey = new Map<string, T>();
    for (const row of rows) {
      const key = readKey(row);
      if (byKey.has(key)) {
        continue;
      }
      byKey.set(key, row);
    }
    return byKey;
  }

  private normalizeState(value: string | null | undefined) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private resolveViewerProjectRelation(
    project: ProjectEntity,
    currentUserId: string,
    currentOrganizationId: string
  ) {
    return this.sameUser(project.creatorUserId, currentUserId) &&
      this.sameOrganization(project.organizationId, currentOrganizationId)
      ? ('owner' satisfies ProjectViewerRelation)
      : ('non_owner' satisfies ProjectViewerRelation);
  }

  private sameUser(projectCreatorUserId: string | null, currentUserId: string) {
    const creatorUserId = projectCreatorUserId?.trim() ?? '';
    const viewerUserId = currentUserId.trim();
    return Boolean(creatorUserId) && creatorUserId === viewerUserId;
  }

  private sameOrganization(projectOrganizationId: string | null, currentOrganizationId: string) {
    const normalizedProjectOrganizationId = projectOrganizationId?.trim() ?? '';
    const normalizedCurrentOrganizationId = currentOrganizationId.trim();
    return (
      Boolean(normalizedProjectOrganizationId) &&
      normalizedProjectOrganizationId === normalizedCurrentOrganizationId
    );
  }
}

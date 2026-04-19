import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  contractDetailInvalid,
  contractEntryUnavailable,
  inspectionDetailInvalid,
  inspectionEntryUnavailable,
  milestoneListInvalid,
  milestoneListUnavailable,
  orderDetailInvalid,
  orderDetailUnavailable,
} from './trading-read-corridor.errors';
import { TradingReadCorridorPresenter } from './trading-read-corridor.presenter';

const ACTIVE_ORDER_STATE = 'active';
const VISIBLE_CONTRACT_STATES = new Set(['pending_confirm', 'active', 'amended']);
const VISIBLE_MILESTONE_STATES = new Set(['pending_submission', 'submitted']);
const VISIBLE_INSPECTION_STATES = new Set(['draft', 'submitted', 'rechecked']);

type ScopedOrderTruthRow = {
  orderId: string;
  orderNo: string;
  projectId: string;
  bidId: string;
  buyerOrganizationId: string | null;
  supplierOrganizationId: string | null;
  title: string | null;
  totalAmount: number | string | null;
  state: string | null;
  activatedAt: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type ContractTruthRow = {
  contractId: string;
  orderId: string;
  state: string | null;
  summaryText: string | null;
  confirmedAt: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  amendCount: number | null;
};

type MilestoneTruthRow = {
  milestoneId: string;
  orderId: string;
  sequenceNo: number | null;
  title: string | null;
  amount: number | string | null;
  state: string | null;
  submittedAt: string | null;
  submittedBy: string | null;
  submissionNote: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type InspectionTruthRow = {
  inspectionId: string;
  milestoneId: string;
  orderId: string;
  state: string | null;
  summaryText: string | null;
  submittedAt: string | null;
  submittedBy: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  rectificationCount: number | null;
  recheckCount: number | null;
};

@Injectable()
export class TradingReadCorridorQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: TradingReadCorridorPresenter,
  ) {}

  async getOrderDetail(orderId: string | undefined, context: RequestContext) {
    const normalizedOrderId = this.readRequiredId(
      orderId,
      orderDetailInvalid('Field `orderId` is required for order detail.')
    );
    const scopeOrganizationId = await this.requireScopedOrganizationId(context);
    const order = await this.safeFetchScopedOrder(normalizedOrderId, scopeOrganizationId);
    if (!order || !this.isVisibleOrderState(order.state)) {
      throw orderDetailUnavailable('Current order detail is unavailable.');
    }

    const milestones = await this.safeFetchScopedMilestones(
      normalizedOrderId,
      scopeOrganizationId,
    );
    return this.presenter.toOrderDetail(order, milestones);
  }

  async getContractDetail(orderId: string | undefined, context: RequestContext) {
    const normalizedOrderId = this.readRequiredId(
      orderId,
      contractDetailInvalid('Field `orderId` is required for contract detail.')
    );
    const scopeOrganizationId = await this.requireScopedOrganizationId(context);
    const order = await this.safeFetchScopedOrder(normalizedOrderId, scopeOrganizationId);
    if (!order || !this.isVisibleOrderState(order.state)) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }

    const contract = await this.safeFetchLatestContract(normalizedOrderId, scopeOrganizationId);
    if (!contract || !this.isVisibleContractState(contract.state)) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }

    return this.presenter.toContractDetail(contract, normalizedOrderId);
  }

  async listMilestones(orderId: string | undefined, context: RequestContext) {
    const normalizedOrderId = this.readRequiredId(
      orderId,
      milestoneListInvalid('Field `orderId` is required for milestone list.')
    );
    const scopeOrganizationId = await this.requireScopedOrganizationId(context);
    const order = await this.fetchScopedOrder(normalizedOrderId, scopeOrganizationId);
    if (!order || !this.isVisibleOrderState(order.state)) {
      throw milestoneListUnavailable('Current milestone list is unavailable.');
    }

    const milestones = await this.fetchScopedMilestones(normalizedOrderId, scopeOrganizationId);
    return this.presenter.toMilestoneList(milestones);
  }

  async getInspectionDetail(milestoneId: string | undefined, context: RequestContext) {
    const normalizedMilestoneId = this.readRequiredId(
      milestoneId,
      inspectionDetailInvalid('Field `milestoneId` is required for inspection detail.')
    );
    const scopeOrganizationId = await this.requireScopedOrganizationId(context);
    const inspection = await this.fetchLatestInspection(normalizedMilestoneId, scopeOrganizationId);
    if (!inspection) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }

    const order = await this.fetchScopedOrder(inspection.orderId, scopeOrganizationId);
    if (!order || !this.isVisibleOrderState(order.state)) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    if (!this.isVisibleInspectionState(inspection.state)) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }

    return this.presenter.toInspectionDetail(inspection);
  }

  private async requireScopedOrganizationId(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }
    return scope.organization.id;
  }

  private async fetchScopedOrder(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          "order".id as "orderId",
          "order".order_no as "orderNo",
          "order".project_id as "projectId",
          "order".bid_id as "bidId",
          "order".buyer_organization_id as "buyerOrganizationId",
          "order".supplier_organization_id as "supplierOrganizationId",
          "order".title as "title",
          "order".total_amount as "totalAmount",
          "order".state as "state",
          "order".activated_at as "activatedAt",
          "order".created_at as "createdAt",
          "order".updated_at as "updatedAt"
        from public.orders "order"
        where "order".id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        order by "order".updated_at desc nulls last, "order".created_at desc nulls last, "order".id desc
        limit 1
      `,
      [orderId, organizationId]
    )) as ScopedOrderTruthRow[];
    return rows[0] ?? null;
  }

  private async fetchLatestContract(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          contract.id as "contractId",
          contract.order_id as "orderId",
          contract.state as "state",
          contract.summary_text as "summaryText",
          contract.confirmed_at as "confirmedAt",
          contract.created_at as "createdAt",
          contract.updated_at as "updatedAt",
          contract.amend_count as "amendCount"
        from public.contracts contract
        join public.orders "order" on "order".id = contract.order_id
        where contract.order_id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        order by contract.updated_at desc nulls last, contract.created_at desc nulls last, contract.id desc
        limit 1
      `,
      [orderId, organizationId]
    )) as ContractTruthRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedMilestones(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          milestone.id as "milestoneId",
          milestone.order_id as "orderId",
          milestone.sequence_no as "sequenceNo",
          milestone.title as "title",
          milestone.amount as "amount",
          milestone.state as "state",
          milestone.submitted_at as "submittedAt",
          milestone.submitted_by as "submittedBy",
          milestone.submission_note as "submissionNote",
          milestone.created_at as "createdAt",
          milestone.updated_at as "updatedAt"
        from public.milestones milestone
        join public.orders "order" on "order".id = milestone.order_id
        where milestone.order_id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        order by
          milestone.sequence_no asc nulls last,
          milestone.updated_at desc nulls last,
          milestone.created_at desc nulls last,
          milestone.id desc
      `,
      [orderId, organizationId]
    )) as MilestoneTruthRow[];
    return rows.filter((row) => this.isVisibleMilestoneState(row.state));
  }

  private async fetchLatestInspection(milestoneId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          inspection.id as "inspectionId",
          inspection.milestone_id as "milestoneId",
          inspection.order_id as "orderId",
          inspection.state as "state",
          inspection.summary_text as "summaryText",
          inspection.submitted_at as "submittedAt",
          inspection.submitted_by as "submittedBy",
          inspection.created_at as "createdAt",
          inspection.updated_at as "updatedAt",
          inspection.rectification_count as "rectificationCount",
          inspection.recheck_count as "recheckCount"
        from public.inspections inspection
        join public.orders "order" on "order".id = inspection.order_id
        where inspection.milestone_id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        order by
          inspection.updated_at desc nulls last,
          inspection.created_at desc nulls last,
          inspection.id desc
        limit 1
      `,
      [milestoneId, organizationId]
    )) as InspectionTruthRow[];
    return rows[0] ?? null;
  }

  private async safeFetchScopedOrder(orderId: string, organizationId: string) {
    try {
      return await this.fetchScopedOrder(orderId, organizationId);
    } catch {
      throw orderDetailUnavailable('Current order detail is unavailable.');
    }
  }

  private async safeFetchLatestContract(orderId: string, organizationId: string) {
    try {
      return await this.fetchLatestContract(orderId, organizationId);
    } catch {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }
  }

  private async safeFetchScopedMilestones(orderId: string, organizationId: string) {
    try {
      return await this.fetchScopedMilestones(orderId, organizationId);
    } catch {
      throw orderDetailUnavailable('Current order detail is unavailable.');
    }
  }

  private isVisibleOrderState(value: string | null) {
    return this.normalizeState(value) === ACTIVE_ORDER_STATE;
  }

  private isVisibleContractState(value: string | null) {
    const normalized = this.normalizeState(value);
    return normalized ? VISIBLE_CONTRACT_STATES.has(normalized) : false;
  }

  private isVisibleMilestoneState(value: string | null) {
    const normalized = this.normalizeState(value);
    return normalized ? VISIBLE_MILESTONE_STATES.has(normalized) : false;
  }

  private isVisibleInspectionState(value: string | null) {
    const normalized = this.normalizeState(value);
    return normalized ? VISIBLE_INSPECTION_STATES.has(normalized) : false;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private readRequiredId<T extends Error>(value: string | undefined, error: T) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw error;
    }
    return normalized;
  }
}

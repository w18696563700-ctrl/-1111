import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext,
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient, authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  inspectionEntryUnavailable,
  inspectionInvalidState,
  inspectionPassInvalid,
  inspectionSubmitInvalid,
  milestoneInvalidState,
  milestoneSubmitInvalid,
} from './trading-shell-handoff.errors';
import { TradingShellHandoffPresenter } from './trading-shell-handoff.presenter';

const ACTIVE_ORDER_STATE = 'active';
const COMPLETED_ORDER_STATE = 'completed';
const PENDING_SUBMISSION_STATE = 'pending_submission';
const SUBMITTED_MILESTONE_STATE = 'submitted';
const COMPLETED_MILESTONE_STATE = 'completed';
const DRAFT_INSPECTION_STATE = 'draft';
const SUBMITTED_INSPECTION_STATE = 'submitted';
const PASSED_INSPECTION_STATE = 'passed';

type FulfillmentActor = {
  currentSession: VerifiedCurrentSessionContext;
  organizationId: string;
};

type ScopedMilestoneRow = {
  milestoneId: string;
  orderId: string;
  state: string | null;
  orderState: string | null;
  buyerOrganizationId: string | null;
  supplierOrganizationId: string | null;
};

type ScopedInspectionRow = ScopedMilestoneRow & {
  inspectionId: string;
  milestoneId: string;
};

type MilestoneSubmitCommand = {
  milestoneId: string;
  submissionNote: string | null;
};

type InspectionCommand = {
  inspectionId: string;
};

@Injectable()
export class TradingShellFulfillmentProgressService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: TradingShellHandoffPresenter,
  ) {}

  async submitMilestone(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toMilestoneSubmitCommand(payload);
    const actor = await this.requireActor(context);
    const milestone = await this.fetchScopedMilestone(command.milestoneId, actor.organizationId);
    if (!milestone || this.normalizeState(milestone.orderState) !== ACTIVE_ORDER_STATE) {
      throw milestoneInvalidState('Current milestone submit entry is unavailable.');
    }
    this.requireSupplier(milestone, actor.organizationId);
    if (this.normalizeState(milestone.state) !== PENDING_SUBMISSION_STATE) {
      throw milestoneInvalidState('Only pending_submission milestones may be submitted.');
    }

    await this.projectRepository.query(
      `
        update public.milestones
        set
          state = $2,
          submitted_at = now(),
          submitted_by = $3,
          submission_note = $4,
          updated_at = now()
        where id = $1
      `,
      [
        milestone.milestoneId,
        SUBMITTED_MILESTONE_STATE,
        this.resolveActorId(actor.currentSession),
        command.submissionNote,
      ],
    );

    return this.presenter.toMilestoneSubmitAccepted(milestone.milestoneId);
  }

  async submitInspection(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toInspectionCommand(
      payload,
      inspectionSubmitInvalid,
      'Inspection submit body must be an object.',
      'Field `inspectionId` is required for inspection submit.',
    );
    const actor = await this.requireActor(context);
    const inspection = await this.fetchScopedInspection(command.inspectionId, actor.organizationId);
    if (!inspection || this.normalizeState(inspection.orderState) !== ACTIVE_ORDER_STATE) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    this.requireBuyer(inspection, actor.organizationId);
    if (this.normalizeState(inspection.state) !== DRAFT_INSPECTION_STATE) {
      throw inspectionInvalidState('Only draft inspections may continue through submit handoff.');
    }

    await this.projectRepository.query(
      `
        update public.inspections
        set
          state = $2,
          submitted_at = now(),
          submitted_by = $3,
          updated_at = now()
        where id = $1
      `,
      [inspection.inspectionId, SUBMITTED_INSPECTION_STATE, this.resolveActorId(actor.currentSession)],
    );

    return this.presenter.toInspectionSubmitAccepted({
      inspectionId: inspection.inspectionId,
      milestoneId: inspection.milestoneId,
      state: SUBMITTED_INSPECTION_STATE,
    });
  }

  async passInspection(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toInspectionCommand(
      payload,
      inspectionPassInvalid,
      'Inspection pass body must be an object.',
      'Field `inspectionId` is required for inspection pass.',
    );
    const actor = await this.requireActor(context);

    return this.projectRepository.manager.transaction(async (manager) => {
      const inspection = await this.fetchScopedInspectionForUpdate(
        manager,
        command.inspectionId,
        actor.organizationId,
      );
      if (!inspection) {
        throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
      }
      this.requireBuyer(inspection, actor.organizationId);

      const inspectionState = this.normalizeState(inspection.state);
      if (inspectionState === PASSED_INSPECTION_STATE) {
        const orderState = await this.deriveCompletedOrderIfReady(manager, inspection.orderId);
        return this.toInspectionPassAccepted(inspection, orderState);
      }
      if (
        this.normalizeState(inspection.orderState) !== ACTIVE_ORDER_STATE ||
        inspectionState !== SUBMITTED_INSPECTION_STATE
      ) {
        throw inspectionInvalidState('Only submitted inspections may be passed.');
      }

      await manager.query(
        `
          update public.inspections
          set
            state = $2,
            passed_at = now(),
            passed_by = $3,
            updated_at = now()
          where id = $1
        `,
        [inspection.inspectionId, PASSED_INSPECTION_STATE, this.resolveActorId(actor.currentSession)],
      );
      await manager.query(
        `
          update public.milestones
          set
            state = $2,
            updated_at = now()
          where id = $1
        `,
        [inspection.milestoneId, COMPLETED_MILESTONE_STATE],
      );

      const orderState = await this.deriveCompletedOrderIfReady(manager, inspection.orderId);
      return this.toInspectionPassAccepted(inspection, orderState);
    });
  }

  private async requireActor(context: RequestContext): Promise<FulfillmentActor> {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }
    return { currentSession, organizationId };
  }

  private async fetchScopedMilestone(milestoneId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      this.scopedMilestoneSql('milestone.id = $1'),
      [milestoneId, organizationId],
    )) as ScopedMilestoneRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedInspection(inspectionId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      this.scopedInspectionSql('inspection.id = $1'),
      [inspectionId, organizationId],
    )) as ScopedInspectionRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedInspectionForUpdate(
    manager: EntityManager,
    inspectionId: string,
    organizationId: string,
  ) {
    const rows = (await manager.query(
      `${this.scopedInspectionSql('inspection.id = $1')} for update`,
      [inspectionId, organizationId],
    )) as ScopedInspectionRow[];
    return rows[0] ?? null;
  }

  private scopedMilestoneSql(predicate: string) {
    return `
      select
        milestone.id as "milestoneId",
        milestone.order_id as "orderId",
        milestone.state as "state",
        "order".state as "orderState",
        "order".buyer_organization_id as "buyerOrganizationId",
        "order".supplier_organization_id as "supplierOrganizationId"
      from public.milestones milestone
      join public.orders "order" on "order".id = milestone.order_id
      where ${predicate}
        and (
          "order".buyer_organization_id = $2
          or "order".supplier_organization_id = $2
        )
      limit 1
    `;
  }

  private scopedInspectionSql(predicate: string) {
    return `
      select
        inspection.id as "inspectionId",
        inspection.milestone_id as "milestoneId",
        inspection.order_id as "orderId",
        inspection.state as "state",
        "order".state as "orderState",
        "order".buyer_organization_id as "buyerOrganizationId",
        "order".supplier_organization_id as "supplierOrganizationId"
      from public.inspections inspection
      join public.orders "order" on "order".id = inspection.order_id
      where ${predicate}
        and (
          "order".buyer_organization_id = $2
          or "order".supplier_organization_id = $2
        )
      limit 1
    `;
  }

  private async deriveCompletedOrderIfReady(manager: EntityManager, orderId: string) {
    const rows = (await manager.query(
      `
        select
          count(*)::int as "totalCount",
          count(*) filter (where state = $2)::int as "completedCount"
        from public.milestones
        where order_id = $1
      `,
      [orderId, COMPLETED_MILESTONE_STATE],
    )) as Array<{ totalCount: number | string; completedCount: number | string }>;
    const totalCount = Number(rows[0]?.totalCount ?? 0);
    const completedCount = Number(rows[0]?.completedCount ?? 0);
    if (totalCount <= 0 || completedCount !== totalCount) {
      return ACTIVE_ORDER_STATE;
    }

    await manager.query(
      `
        update public.orders
        set
          state = $2,
          completed_at = coalesce(completed_at, now()),
          updated_at = now()
        where id = $1
          and state = $3
      `,
      [orderId, COMPLETED_ORDER_STATE, ACTIVE_ORDER_STATE],
    );
    return COMPLETED_ORDER_STATE;
  }

  private toInspectionPassAccepted(inspection: ScopedInspectionRow, orderState: string) {
    return this.presenter.toInspectionPassAccepted({
      inspectionId: inspection.inspectionId,
      milestoneId: inspection.milestoneId,
      orderId: inspection.orderId,
      state: PASSED_INSPECTION_STATE,
      orderState,
    });
  }

  private requireSupplier(row: ScopedMilestoneRow, organizationId: string) {
    if (this.normalizeId(row.supplierOrganizationId) !== organizationId) {
      throw authPermissionInsufficient('Only the supplier organization may submit the milestone.');
    }
  }

  private requireBuyer(row: ScopedMilestoneRow, organizationId: string) {
    if (this.normalizeId(row.buyerOrganizationId) !== organizationId) {
      throw authPermissionInsufficient('Only the buyer organization may continue this inspection action.');
    }
  }

  private toMilestoneSubmitCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      milestoneSubmitInvalid,
      'Milestone submit body must be an object.',
    );
    return {
      milestoneId: this.readRequiredString(
        source.milestoneId,
        milestoneSubmitInvalid,
        'Field `milestoneId` is required for milestone submit.',
      ),
      submissionNote: this.readOptionalString(source.submissionNote),
    } satisfies MilestoneSubmitCommand;
  }

  private toInspectionCommand(
    payload: Record<string, unknown>,
    invalidFactory: (message: string) => Error,
    objectMessage: string,
    fieldMessage: string,
  ) {
    const source = this.asRecord(payload, invalidFactory, objectMessage);
    return {
      inspectionId: this.readRequiredString(
        source.inspectionId,
        invalidFactory,
        fieldMessage,
      ),
    } satisfies InspectionCommand;
  }

  private asRecord(
    value: unknown,
    invalidFactory: (message: string) => Error,
    message: string,
  ) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      throw invalidFactory(message);
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(
    value: unknown,
    invalidFactory: (message: string) => Error,
    message: string,
  ) {
    if (typeof value !== 'string') {
      throw invalidFactory(message);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw invalidFactory(message);
    }
    return normalized;
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private resolveActorId(currentSession: VerifiedCurrentSessionContext) {
    return this.normalizeId(currentSession.actorId) ?? this.normalizeId(currentSession.userId);
  }

  private normalizeId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private normalizeState(value: string | null | undefined) {
    return this.normalizeId(value);
  }
}

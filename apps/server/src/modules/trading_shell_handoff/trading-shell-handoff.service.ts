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
  contractAmendInvalid,
  contractConfirmInvalid,
  contractEntryUnavailable,
  contractInvalidState,
  disputeInvalidState,
  disputeOpenInvalid,
  disputeWithdrawInvalid,
  inspectionEntryUnavailable,
  inspectionInvalidState,
  inspectionRecheckInvalid,
  inspectionSubmitInvalid,
  milestoneInvalidState,
  milestoneSubmitInvalid,
} from './trading-shell-handoff.errors';
import { TradingShellHandoffPresenter } from './trading-shell-handoff.presenter';

const ACTIVE_ORDER_STATE = 'active';
const PENDING_CONFIRM_CONTRACT_STATE = 'pending_confirm';
const ACTIVE_CONTRACT_STATE = 'active';
const AMENDED_CONTRACT_STATE = 'amended';
const OPENED_DISPUTE_STATE = 'opened';
const WITHDRAWN_DISPUTE_STATE = 'withdrawn';
const PENDING_SUBMISSION_STATE = 'pending_submission';
const DRAFT_INSPECTION_STATE = 'draft';
const SUBMITTED_INSPECTION_STATE = 'submitted';
const RECHECKED_INSPECTION_STATE = 'rechecked';

type ScopedOrderRow = {
  orderId: string;
  state: string | null;
};

type ScopedMilestoneRow = {
  milestoneId: string;
  orderId: string;
  state: string | null;
  orderState: string | null;
};

type ScopedInspectionRow = {
  inspectionId: string;
  milestoneId: string;
  orderId: string;
  state: string | null;
  orderState: string | null;
};

type ScopedContractRow = {
  contractId: string;
  orderId: string;
  state: string | null;
  orderState: string | null;
};

type ScopedDisputeRow = {
  disputeId: string;
  orderId: string;
  state: string | null;
  orderState: string | null;
};

type MilestoneSubmitCommand = {
  milestoneId: string;
  submissionNote: string | null;
};

type InspectionSubmitCommand = {
  inspectionId: string;
};

type InspectionRecheckCommand = {
  inspectionId: string;
};

type ContractConfirmCommand = {
  orderId: string;
};

type ContractAmendCommand = {
  orderId: string;
};

type DisputeOpenCommand = {
  orderId: string;
  reason: string | null;
};

type DisputeWithdrawCommand = {
  orderId: string;
};

@Injectable()
export class TradingShellHandoffService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: TradingShellHandoffPresenter,
  ) {}

  async submitMilestone(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toMilestoneSubmitCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const milestone = await this.fetchScopedMilestone(command.milestoneId, organizationId);
    if (!milestone || !this.isActiveOrderState(milestone.orderState)) {
      throw milestoneInvalidState('Current milestone submit entry is unavailable.');
    }
    if (this.normalizeState(milestone.state) !== PENDING_SUBMISSION_STATE) {
      throw milestoneInvalidState('Only pending_submission milestones may be submitted.');
    }
    return this.presenter.toMilestoneSubmitAccepted(milestone.milestoneId);
  }

  async submitInspection(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toInspectionSubmitCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const inspection = await this.fetchScopedInspection(command.inspectionId, organizationId);
    if (!inspection || !this.isActiveOrderState(inspection.orderState)) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    const inspectionState = this.normalizeState(inspection.state);
    if (!inspectionState) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    if (inspectionState !== DRAFT_INSPECTION_STATE) {
      throw inspectionInvalidState('Only draft inspections may continue through submit handoff.');
    }
    return this.presenter.toInspectionSubmitAccepted({
      inspectionId: inspection.inspectionId,
      milestoneId: inspection.milestoneId,
      state: inspectionState,
    });
  }

  async recheckInspection(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toInspectionRecheckCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const inspection = await this.fetchScopedInspection(command.inspectionId, organizationId);
    if (!inspection || !this.isActiveOrderState(inspection.orderState)) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    const inspectionState = this.normalizeState(inspection.state);
    if (!inspectionState) {
      throw inspectionEntryUnavailable('Current inspection entry is unavailable.');
    }
    if (inspectionState !== SUBMITTED_INSPECTION_STATE) {
      throw inspectionInvalidState('Only submitted inspections may continue through recheck handoff.');
    }

    await this.projectRepository.query(
      `
        update public.inspections
        set
          state = $2,
          recheck_count = coalesce(recheck_count, 0) + 1,
          updated_at = now()
        where id = $1
      `,
      [inspection.inspectionId, RECHECKED_INSPECTION_STATE],
    );

    return this.presenter.toInspectionRecheckAccepted({
      inspectionId: inspection.inspectionId,
      milestoneId: inspection.milestoneId,
      state: RECHECKED_INSPECTION_STATE,
    });
  }

  async confirmContract(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toContractConfirmCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const contract = await this.fetchScopedContract(command.orderId, organizationId);
    if (!contract || !this.isActiveOrderState(contract.orderState)) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }
    const contractState = this.normalizeState(contract.state);
    if (!contractState) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }
    if (contractState !== PENDING_CONFIRM_CONTRACT_STATE) {
      throw contractInvalidState('Only pending_confirm contracts may continue through confirm handoff.');
    }

    await this.projectRepository.query(
      `
        update public.contracts
        set
          state = $2,
          confirmed_at = now(),
          updated_at = now()
        where id = $1
      `,
      [contract.contractId, ACTIVE_CONTRACT_STATE],
    );

    return this.presenter.toContractConfirmAccepted({
      contractId: contract.contractId,
      orderId: contract.orderId,
      state: ACTIVE_CONTRACT_STATE,
    });
  }

  async amendContract(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toContractAmendCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const contract = await this.fetchScopedContract(command.orderId, organizationId);
    if (!contract || !this.isActiveOrderState(contract.orderState)) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }
    const contractState = this.normalizeState(contract.state);
    if (!contractState) {
      throw contractEntryUnavailable('Current contract entry is unavailable.');
    }
    if (contractState !== ACTIVE_CONTRACT_STATE) {
      throw contractInvalidState('Only active contracts may continue through amend handoff.');
    }

    await this.projectRepository.query(
      `
        update public.contracts
        set
          state = $2,
          amend_count = coalesce(amend_count, 0) + 1,
          updated_at = now()
        where id = $1
      `,
      [contract.contractId, AMENDED_CONTRACT_STATE],
    );

    return this.presenter.toContractAmendAccepted({
      contractId: contract.contractId,
      orderId: contract.orderId,
      state: AMENDED_CONTRACT_STATE,
    });
  }

  async openDispute(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toDisputeOpenCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const order = await this.fetchScopedOrder(command.orderId, organizationId);
    if (!order || !this.isActiveOrderState(order.state)) {
      throw disputeInvalidState('Current order is unavailable for dispute-open handoff.');
    }
    return this.presenter.toDisputeOpenAccepted(order.orderId);
  }

  async withdrawDispute(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toDisputeWithdrawCommand(payload);
    const organizationId = await this.requireScopedOrganizationId(context);
    const dispute = await this.fetchScopedDispute(command.orderId, organizationId);
    if (!dispute || !this.isActiveOrderState(dispute.orderState)) {
      throw disputeInvalidState('Current dispute entry is unavailable for dispute-withdraw handoff.');
    }
    const disputeState = this.normalizeState(dispute.state);
    if (disputeState !== OPENED_DISPUTE_STATE) {
      throw disputeInvalidState('Only opened disputes may continue through withdraw handoff.');
    }

    await this.projectRepository.query(
      `
        update public.disputes
        set
          state = $2,
          updated_at = now()
        where id = $1
      `,
      [dispute.disputeId, WITHDRAWN_DISPUTE_STATE],
    );

    return this.presenter.toDisputeWithdrawAccepted({
      disputeId: dispute.disputeId,
      orderId: dispute.orderId,
      state: WITHDRAWN_DISPUTE_STATE,
    });
  }

  private async requireScopedOrganizationId(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
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
          "order".state as "state"
        from public.orders "order"
        where "order".id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        limit 1
      `,
      [orderId, organizationId],
    )) as ScopedOrderRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedMilestone(milestoneId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          milestone.id as "milestoneId",
          milestone.order_id as "orderId",
          milestone.state as "state",
          "order".state as "orderState"
        from public.milestones milestone
        join public.orders "order" on "order".id = milestone.order_id
        where milestone.id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        limit 1
      `,
      [milestoneId, organizationId],
    )) as ScopedMilestoneRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedInspection(inspectionId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          inspection.id as "inspectionId",
          inspection.milestone_id as "milestoneId",
          inspection.order_id as "orderId",
          inspection.state as "state",
          "order".state as "orderState"
        from public.inspections inspection
        join public.orders "order" on "order".id = inspection.order_id
        where inspection.id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        limit 1
      `,
      [inspectionId, organizationId],
    )) as ScopedInspectionRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedContract(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          contract.id as "contractId",
          contract.order_id as "orderId",
          contract.state as "state",
          "order".state as "orderState"
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
      [orderId, organizationId],
    )) as ScopedContractRow[];
    return rows[0] ?? null;
  }

  private async fetchScopedDispute(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          dispute.id as "disputeId",
          dispute.order_id as "orderId",
          dispute.state as "state",
          "order".state as "orderState"
        from public.disputes dispute
        join public.orders "order" on "order".id = dispute.order_id
        where dispute.order_id = $1
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
        order by dispute.updated_at desc nulls last, dispute.created_at desc nulls last, dispute.id desc
        limit 1
      `,
      [orderId, organizationId],
    )) as ScopedDisputeRow[];
    return rows[0] ?? null;
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
        'milestoneId',
        'Field `milestoneId` is required for milestone submit.',
      ),
      submissionNote: this.readOptionalString(source.submissionNote),
    } satisfies MilestoneSubmitCommand;
  }

  private toInspectionSubmitCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      inspectionSubmitInvalid,
      'Inspection submit body must be an object.',
    );
    return {
      inspectionId: this.readRequiredString(
        source.inspectionId,
        'inspectionId',
        'Field `inspectionId` is required for inspection submit.',
      ),
    } satisfies InspectionSubmitCommand;
  }

  private toInspectionRecheckCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      inspectionRecheckInvalid,
      'Inspection recheck body must be an object.',
    );
    return {
      inspectionId: this.readRequiredString(
        source.inspectionId,
        'inspectionId',
        'Field `inspectionId` is required for inspection recheck.',
      ),
    } satisfies InspectionRecheckCommand;
  }

  private toContractConfirmCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      contractConfirmInvalid,
      'Contract confirm body must be an object.',
    );
    return {
      orderId: this.readRequiredString(
        source.orderId,
        'orderId',
        'Field `orderId` is required for contract confirm.',
      ),
    } satisfies ContractConfirmCommand;
  }

  private toContractAmendCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      contractAmendInvalid,
      'Contract amend body must be an object.',
    );
    return {
      orderId: this.readRequiredString(
        source.orderId,
        'orderId',
        'Field `orderId` is required for contract amend.',
      ),
    } satisfies ContractAmendCommand;
  }

  private toDisputeOpenCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      disputeOpenInvalid,
      'Dispute open body must be an object.',
    );
    return {
      orderId: this.readRequiredString(
        source.orderId,
        'orderId',
        'Field `orderId` is required for dispute open.',
      ),
      reason: this.readOptionalString(source.reason),
    } satisfies DisputeOpenCommand;
  }

  private toDisputeWithdrawCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      disputeWithdrawInvalid,
      'Dispute withdraw body must be an object.',
    );
    return {
      orderId: this.readRequiredString(
        source.orderId,
        'orderId',
        'Field `orderId` is required for dispute withdraw.',
      ),
    } satisfies DisputeWithdrawCommand;
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
    field: string,
    message: string,
  ) {
    if (typeof value !== 'string') {
      throw this.invalidForField(field, message);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw this.invalidForField(field, message);
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

  private invalidForField(field: string, message: string) {
    if (field === 'inspectionId') {
      if (message.includes('inspection recheck')) {
        return inspectionRecheckInvalid(message);
      }
      return inspectionSubmitInvalid(message);
    }
    if (field === 'orderId') {
      if (message.includes('dispute withdraw')) {
        return disputeWithdrawInvalid(message);
      }
      if (message.includes('contract amend')) {
        return contractAmendInvalid(message);
      }
      if (message.includes('contract confirm')) {
        return contractConfirmInvalid(message);
      }
      return disputeOpenInvalid(message);
    }
    return milestoneSubmitInvalid(message);
  }

  private isActiveOrderState(value: string | null) {
    return this.normalizeState(value) === ACTIVE_ORDER_STATE;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

import { Injectable, Optional } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { createContractSeed } from '../contract/contract.seed';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient, authResourceUnavailable } from '../organization/organization-auth.errors';
import { createOrderSeed } from '../order/order.seed';
import { BidAwardFulfillmentSeedService } from './bid-award-fulfillment-seed.service';
import { BidAwardPresenter } from './bid-award.presenter';
import {
  bidAwardConcurrentConflict,
  bidAwardDuplicate,
  bidAwardInvalid,
  bidAwardInvalidState,
  contractSeedFailed,
  orderConversionFailed
} from './bid-award.errors';
import { BidAwardTruthCarrier, readBidAwardTruth, writeBidAwardTruth } from './bid-award.truth';

type BidAwardCommand = {
  projectId: string;
  winningBidId: string;
  reasonCode: string;
  reasonText: string;
};

type LockedProjectRow = {
  id: string;
  projectNo: string;
  organizationId: string;
  title: string | null;
  state: string | null;
  summary: Record<string, unknown> | null;
  publishedAt: string | null;
};

type LockedBidRow = {
  id: string;
  projectId: string;
  organizationId: string;
  quoteAmount: string | number | null;
  proposalSummary: string | null;
  state: string | null;
};

type ExistingOrderRow = {
  orderId: string;
};

type ExistingContractRow = {
  contractId: string;
  orderId: string;
};

const PROJECT_PUBLISHED_STATE = 'published';
const PROJECT_CONVERTED_STATE = 'converted_to_order';
const BID_SUBMITTED_STATE = 'submitted';
const BID_AWARDED_STATE = 'awarded';
const BID_LOST_STATE = 'lost';
const ORDER_CREATED_BY_COLUMN = 'created_by';
const CONTRACT_NO_COLUMN = 'contract_no';

@Injectable()
export class BidAwardWriteService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: BidAwardPresenter,
    @Optional()
    private readonly fulfillmentSeedService?: BidAwardFulfillmentSeedService
  ) {}

  async award(payload: Record<string, unknown>, context: RequestContext) {
    return this.selectBidAndCreateOrder(payload, context);
  }

  async selectBidAndCreateOrder(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toAwardCommand(payload);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );

    const response = await this.dataSource.transaction(async (manager) => {
      const auditRepository = manager.getRepository(IdentityAuditLogEntity);
      await this.requireProjectAwardLock(manager, command.projectId);

      const project = await this.fetchProjectForUpdate(manager, command.projectId);
      if (!project) {
        throw authResourceUnavailable('Current project is unavailable for bid award.');
      }
      if (scope.organization.id !== project.organizationId) {
        throw authPermissionInsufficient('Current actor lacks the required buyer scope for bid award.', {
          reason: 'owner_scope_required',
          organizationId: scope.organization.id,
          projectOrganizationId: project.organizationId
        });
      }
      const currentAward = readBidAwardTruth(project.summary);
      const existingOrder = await this.fetchExistingOrderForUpdate(manager, project.id);
      const existingContract = await this.fetchExistingContractForUpdate(manager, project.id);
      if (
        currentAward ||
        existingOrder ||
        existingContract ||
        this.isEffectiveAwardProjectState(project.state)
      ) {
        throw bidAwardDuplicate('Current project already has an effective bid award.');
      }
      if (project.state !== PROJECT_PUBLISHED_STATE || project.publishedAt === null) {
        throw bidAwardInvalidState('Current project state does not allow bid award.');
      }

      const bids = await this.fetchProjectBidsForUpdate(manager, project.id);
      const winningBid = bids.find((bid) => bid.id === command.winningBidId) ?? null;
      if (!winningBid) {
        throw authResourceUnavailable('Current winning bid is unavailable for bid award.');
      }
      if (!bids.length || bids.some((bid) => this.normalizeState(bid.state) !== BID_SUBMITTED_STATE)) {
        throw bidAwardInvalidState('Current bid state does not allow bid award.');
      }
      if (winningBid.organizationId === project.organizationId) {
        throw bidAwardInvalid('Current buyer organization cannot award its own bid.');
      }
      const decidedAt = new Date().toISOString();
      const orderSeed = createOrderSeed(
        project,
        winningBid,
        this.resolveOrderCreatedBy(currentSession.actorId, currentSession.userId),
        randomUUID(),
        decidedAt
      );
      const contractSeed = createContractSeed(project, orderSeed, randomUUID());
      const award = this.createAwardTruth(command, winningBid, orderSeed.orderId, contractSeed.contractId, decidedAt);

      await this.insertOrder(manager, orderSeed);
      await this.insertContract(manager, contractSeed);
      await this.fulfillmentSeedService?.seedDefaultFulfillment(manager, {
        project,
        order: orderSeed
      });
      await this.updateBidResults(manager, project.id, winningBid.id);
      await this.updateProjectAwardTruth(manager, project.id, writeBidAwardTruth(project.summary, award));
      await auditRepository.save({
        id: randomUUID(),
        objectType: 'project',
        objectId: project.id,
        objectNo: project.projectNo,
        action: 'BidAwarded',
        actorId: currentSession.userId,
        actorRole: scope.membership.roleKey,
        beforeState: 'published',
        afterState: PROJECT_CONVERTED_STATE,
        reason: `winningBidId=${winningBid.id}; reasonCode=${award.reasonCode}; orderId=${orderSeed.orderId}; contractId=${contractSeed.contractId}`,
        requestId: context.requestId,
        traceId: context.traceId,
        occurredAt: new Date()
      });

      return this.presenter.toAwardAcceptedResponse(award);
    });

    return response;
  }

  private createAwardTruth(
    command: BidAwardCommand,
    winningBid: LockedBidRow,
    orderId: string,
    contractId: string,
    decidedAt: string
  ) {
    return {
      bidAwardId: randomUUID(),
      projectId: command.projectId,
      winningBidId: command.winningBidId,
      winningOrganizationId: winningBid.organizationId,
      reasonCode: command.reasonCode,
      reasonText: command.reasonText,
      state: PROJECT_CONVERTED_STATE,
      orderId,
      contractId,
      decidedAt
    } satisfies BidAwardTruthCarrier;
  }

  private async requireProjectAwardLock(manager: EntityManager, projectId: string) {
    const rows = (await manager.query(
      `
        select pg_try_advisory_xact_lock(hashtext($1), hashtext('bid_award')) as locked
      `,
      [projectId]
    )) as Array<{ locked?: boolean }>;
    if (!rows[0]?.locked) {
      throw bidAwardConcurrentConflict('Current project is locked by another bid award command.');
    }
  }

  private async fetchProjectForUpdate(manager: EntityManager, projectId: string) {
    const rows = (await manager.query(
      `
        select
          project.id as "id",
          project.project_no as "projectNo",
          project.organization_id as "organizationId",
          project.title as "title",
          project.state as "state",
          project.summary as "summary",
          project.published_at as "publishedAt"
        from project project
        where project.id = $1
        for update
      `,
      [projectId]
    )) as LockedProjectRow[];
    return rows[0] ?? null;
  }

  private async fetchExistingOrderForUpdate(manager: EntityManager, projectId: string) {
    const rows = (await manager.query(
      `
        select
          "order".id as "orderId"
        from public.orders "order"
        where "order".project_id = $1
        order by "order".updated_at desc nulls last, "order".created_at desc nulls last, "order".id desc
        limit 1
        for update
      `,
      [projectId]
    )) as ExistingOrderRow[];
    return rows[0] ?? null;
  }

  private async fetchExistingContractForUpdate(manager: EntityManager, projectId: string) {
    const rows = (await manager.query(
      `
        select
          contract.id as "contractId",
          contract.order_id as "orderId"
        from public.contracts contract
        join public.orders "order" on "order".id = contract.order_id
        where "order".project_id = $1
        order by contract.updated_at desc nulls last, contract.created_at desc nulls last, contract.id desc
        limit 1
        for update
      `,
      [projectId]
    )) as ExistingContractRow[];
    return rows[0] ?? null;
  }

  private async fetchProjectBidsForUpdate(manager: EntityManager, projectId: string) {
    return (await manager.query(
      `
        select
          bid.id as "id",
          bid.project_id as "projectId",
          bid.organization_id as "organizationId",
          bid.quote_amount as "quoteAmount",
          bid.proposal_summary as "proposalSummary",
          bid.state as "state"
        from bids bid
        where bid.project_id = $1
        order by bid.created_at asc, bid.id asc
        for update
      `,
      [projectId]
    )) as LockedBidRow[];
  }

  private async insertOrder(manager: EntityManager, orderSeed: ReturnType<typeof createOrderSeed>) {
    try {
      const hasCreatedByColumn = await this.hasOrderCreatedByColumn(manager);
      const columns = [
        'id',
        'order_no',
        'project_id',
        'bid_id',
        'buyer_organization_id',
        'supplier_organization_id',
        'title',
        'total_amount',
        'state',
        'activated_at'
      ];
      const values: Array<string> = [
        orderSeed.orderId,
        orderSeed.orderNo,
        orderSeed.projectId,
        orderSeed.bidId,
        orderSeed.buyerOrganizationId,
        orderSeed.supplierOrganizationId,
        orderSeed.title,
        orderSeed.totalAmount,
        orderSeed.state,
        orderSeed.activatedAt
      ];
      if (hasCreatedByColumn) {
        columns.push(ORDER_CREATED_BY_COLUMN);
        values.push(orderSeed.createdBy);
      }
      const placeholders = values.map((_, index) => `$${index + 1}`).join(',\n            ');
      await manager.query(
        `
          insert into public.orders (
            ${columns.join(',\n            ')},
            created_at,
            updated_at
          ) values (
            ${placeholders},
            now(),
            now()
          )
        `,
        values
      );
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw bidAwardDuplicate('Current project already has an effective bid award.');
      }
      throw orderConversionFailed('Order conversion failed during bid award bridge closure.');
    }
  }

  private async hasOrderCreatedByColumn(manager: EntityManager) {
    const rows = (await manager.query(
      `
        select column_name as "columnName"
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'orders'
          and column_name = $1
      `,
      [ORDER_CREATED_BY_COLUMN]
    )) as Array<{ columnName?: string }>;
    return rows.some((row) => row.columnName === ORDER_CREATED_BY_COLUMN);
  }

  private async insertContract(
    manager: EntityManager,
    contractSeed: ReturnType<typeof createContractSeed>
  ) {
    try {
      const hasContractNoColumn = await this.hasContractNoColumn(manager);
      const columns = ['id', 'order_id', 'state', 'summary_text', 'amend_count'];
      const values: Array<string | number | null> = [
        contractSeed.contractId,
        contractSeed.orderId,
        contractSeed.state,
        contractSeed.summaryText,
        contractSeed.amendCount
      ];
      if (hasContractNoColumn) {
        columns.push(CONTRACT_NO_COLUMN);
        values.push(contractSeed.contractNo);
      }
      const placeholders = values.map((_, index) => `$${index + 1}`).join(',\n            ');
      await manager.query(
        `
          insert into public.contracts (
            ${columns.join(',\n            ')},
            created_at,
            updated_at
          ) values (
            ${placeholders},
            now(),
            now()
          )
        `,
        values
      );
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw bidAwardDuplicate('Current project already has an effective bid award.');
      }
      throw contractSeedFailed('Synchronous contract seed failed during bid award bridge closure.');
    }
  }

  private async hasContractNoColumn(manager: EntityManager) {
    const rows = (await manager.query(
      `
        select column_name as "columnName"
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'contracts'
          and column_name = $1
      `,
      [CONTRACT_NO_COLUMN]
    )) as Array<{ columnName?: string }>;
    return rows.some((row) => row.columnName === CONTRACT_NO_COLUMN);
  }

  private async updateBidResults(manager: EntityManager, projectId: string, winningBidId: string) {
    await manager.query(
      `
        update public.bids
        set
          state = case when id = $2 then $3 else $4 end,
          updated_at = now()
        where project_id = $1
      `,
      [projectId, winningBidId, BID_AWARDED_STATE, BID_LOST_STATE]
    );
  }

  private async updateProjectAwardTruth(
    manager: EntityManager,
    projectId: string,
    summary: Record<string, unknown>
  ) {
    await manager.query(
      `
        update project
        set
          state = $2,
          summary = $3::jsonb,
          updated_at = now()
        where id = $1
      `,
      [projectId, PROJECT_CONVERTED_STATE, JSON.stringify(summary)]
    );
  }

  private toAwardCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      projectId: this.readRequiredString(source.projectId, 'projectId'),
      winningBidId: this.readRequiredString(source.winningBidId, 'winningBidId'),
      reasonCode: this.readRequiredString(source.reasonCode, 'reasonCode'),
      reasonText: this.readRequiredString(source.reasonText, 'reasonText')
    } satisfies BidAwardCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw bidAwardInvalid('Bid award body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw bidAwardInvalid(`Field \`${field}\` is required for bid award.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw bidAwardInvalid(`Field \`${field}\` is required for bid award.`);
    }
    return normalized;
  }

  private isEffectiveAwardProjectState(value: string | null) {
    const normalized = this.normalizeState(value);
    return normalized === 'awarded' || normalized === PROJECT_CONVERTED_STATE;
  }

  private resolveOrderCreatedBy(actorId: string | null | undefined, userId: string | null | undefined) {
    const createdBy = this.readOptionalText(actorId) ?? this.readOptionalText(userId);
    if (!createdBy) {
      throw orderConversionFailed('Order conversion failed during bid award bridge closure.');
    }
    return createdBy;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private isUniqueViolation(error: unknown) {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      (error as { code?: string }).code === '23505'
    );
  }
}

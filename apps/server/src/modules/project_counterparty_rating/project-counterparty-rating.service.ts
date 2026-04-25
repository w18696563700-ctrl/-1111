import { Injectable, Optional } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CreditScoringShadowAggregationService } from '../credit_scoring_shadow/credit-scoring-shadow.aggregation.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectCounterpartyRatingEntity } from './entities/project-counterparty-rating.entity';
import {
  projectCounterpartyRatingAlreadySubmitted,
  projectCounterpartyRatingForbidden,
  projectCounterpartyRatingInvalid,
  projectCounterpartyRatingUnavailable
} from './project-counterparty-rating.errors';
import { ProjectCounterpartyRatingPresenter } from './project-counterparty-rating.presenter';

type RatingOrderRow = {
  orderId: string;
  projectId: string;
  buyerOrganizationId: string | null;
  supplierOrganizationId: string | null;
  orderState: string | null;
};

type RatingActor = {
  currentSession: VerifiedCurrentSessionContext;
  organizationId: string;
};

type EntryQuery = {
  orderId: string;
  projectId: string;
  rateeOrganizationId: string;
};

type SubmitCommand = EntryQuery & {
  scoreValue: number;
  scoreLabel: string;
  commentText: string | null;
};

const COMPLETED_ORDER_STATE = 'completed';
const SUBMITTED_RATING_STATE = 'submitted';
const SCORE_LABELS = new Set(['very_satisfied', 'satisfied', 'passable', 'negative']);

@Injectable()
export class ProjectCounterpartyRatingService {
  constructor(
    @InjectRepository(ProjectCounterpartyRatingEntity)
    private readonly ratingRepository: Repository<ProjectCounterpartyRatingEntity>,
    private readonly dataSource: DataSource,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectCounterpartyRatingPresenter,
    private readonly auditService: ProjectPublishAuditService,
    @Optional()
    private readonly shadowAggregationService?: CreditScoringShadowAggregationService
  ) {}

  async getEntry(query: Record<string, unknown>, context: RequestContext) {
    const input = this.toEntryQuery(query);
    const actor = await this.requireActor(context);
    const order = await this.fetchOrder(input.orderId, input.projectId, this.dataSource.manager);
    if (!order) {
      throw projectCounterpartyRatingUnavailable('Current order/project rating anchor is unavailable.');
    }
    this.requireRatingDirection(order, actor.organizationId, input.rateeOrganizationId);
    const existing = await this.ratingRepository.findOneBy({
      orderId: input.orderId,
      raterOrganizationId: actor.organizationId,
      rateeOrganizationId: input.rateeOrganizationId
    });

    return this.presenter.toEntry({
      orderId: input.orderId,
      projectId: input.projectId,
      raterOrganizationId: actor.organizationId,
      rateeOrganizationId: input.rateeOrganizationId,
      canRate: this.normalizeState(order.orderState) === COMPLETED_ORDER_STATE && !existing,
      reason: this.entryUnavailableReason(order, existing),
      ratingState: existing?.ratingState ?? null
    });
  }

  async submit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSubmitCommand(payload);
    const actor = await this.requireActor(context);
    const rating = await this.dataSource.transaction(async (manager) => {
      const order = await this.fetchOrder(command.orderId, command.projectId, manager);
      if (!order) {
        throw projectCounterpartyRatingUnavailable('Current order/project rating anchor is unavailable.');
      }
      this.requireRatingDirection(order, actor.organizationId, command.rateeOrganizationId);
      if (this.normalizeState(order.orderState) !== COMPLETED_ORDER_STATE) {
        throw projectCounterpartyRatingUnavailable('Current project/order is not completed for counterparty rating.');
      }

      const repository = manager.getRepository(ProjectCounterpartyRatingEntity);
      const existing = await repository.findOneBy({
        orderId: command.orderId,
        raterOrganizationId: actor.organizationId,
        rateeOrganizationId: command.rateeOrganizationId
      });
      if (existing) {
        throw projectCounterpartyRatingAlreadySubmitted('Current counterparty rating direction has already been submitted.');
      }

      const submittedAt = new Date();
      const rating = repository.create({
        id: randomUUID(),
        orderId: command.orderId,
        projectId: command.projectId,
        raterOrganizationId: actor.organizationId,
        rateeOrganizationId: command.rateeOrganizationId,
        raterUserId: actor.currentSession.userId,
        raterActorId: actor.currentSession.actorId || null,
        scoreValue: command.scoreValue,
        scoreLabel: command.scoreLabel,
        commentText: command.commentText,
        ratingState: SUBMITTED_RATING_STATE,
        submittedAt
      });

      try {
        await repository.save(rating);
      } catch (error) {
        if (this.isUniqueViolation(error)) {
          throw projectCounterpartyRatingAlreadySubmitted('Current counterparty rating direction has already been submitted.');
        }
        throw error;
      }

      await this.auditService.record(
        {
          aggregateType: 'project_counterparty_rating',
          aggregateId: rating.id,
          eventType: 'ProjectCounterpartyRatingSubmitted',
          payload: {
            orderId: rating.orderId,
            projectId: rating.projectId,
            raterOrganizationId: rating.raterOrganizationId,
            rateeOrganizationId: rating.rateeOrganizationId,
            scoreValue: rating.scoreValue,
            scoreLabel: rating.scoreLabel
          }
        },
        context,
        manager
      );

      return rating;
    });

    await this.triggerCreditShadowBridge(rating);
    return this.presenter.toSubmitAccepted(rating);
  }

  private async triggerCreditShadowBridge(rating: ProjectCounterpartyRatingEntity) {
    if (!this.shadowAggregationService) {
      return;
    }
    await this.shadowAggregationService
      .recomputeAfterFormalRatingSubmit({
        organizationId: rating.rateeOrganizationId,
        sourceType: 'project_counterparty_rating',
        sourceOrderId: rating.orderId,
        sourceRatingId: rating.id,
        triggeredAt: rating.submittedAt
      })
      .catch(() => undefined);
  }

  private async requireActor(context: RequestContext): Promise<RatingActor> {
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }
    return { currentSession, organizationId };
  }

  private async fetchOrder(orderId: string, projectId: string, manager: EntityManager) {
    const rows = (await manager.query(
      `
        select
          "order".id as "orderId",
          "order".project_id as "projectId",
          "order".buyer_organization_id as "buyerOrganizationId",
          "order".supplier_organization_id as "supplierOrganizationId",
          "order".state as "orderState"
        from public.orders "order"
        where "order".id = $1
          and "order".project_id = $2
        limit 1
      `,
      [orderId, projectId]
    )) as RatingOrderRow[];
    return rows[0] ?? null;
  }

  private requireRatingDirection(
    order: RatingOrderRow,
    raterOrganizationId: string,
    rateeOrganizationId: string
  ) {
    const buyerOrganizationId = this.normalizeId(order.buyerOrganizationId);
    const supplierOrganizationId = this.normalizeId(order.supplierOrganizationId);
    if (!buyerOrganizationId || !supplierOrganizationId) {
      throw projectCounterpartyRatingUnavailable('Current order counterparty boundary is incomplete.');
    }
    if (raterOrganizationId === buyerOrganizationId && rateeOrganizationId === supplierOrganizationId) {
      return;
    }
    if (raterOrganizationId === supplierOrganizationId && rateeOrganizationId === buyerOrganizationId) {
      return;
    }
    throw projectCounterpartyRatingForbidden('Current actor cannot rate outside the current order counterparty boundary.', {
      orderId: order.orderId,
      projectId: order.projectId,
      raterOrganizationId,
      rateeOrganizationId
    });
  }

  private entryUnavailableReason(
    order: RatingOrderRow,
    existing: ProjectCounterpartyRatingEntity | null
  ) {
    if (this.normalizeState(order.orderState) !== COMPLETED_ORDER_STATE) {
      return '当前项目/订单尚未完成，双方互评入口不会开放。';
    }
    if (existing) {
      return '当前方向已经提交过评价，不允许重复提交。';
    }
    return null;
  }

  private toEntryQuery(query: Record<string, unknown>) {
    return {
      orderId: this.readRequiredString(query.orderId, 'orderId'),
      projectId: this.readRequiredString(query.projectId, 'projectId'),
      rateeOrganizationId: this.readRequiredString(query.rateeOrganizationId, 'rateeOrganizationId')
    } satisfies EntryQuery;
  }

  private toSubmitCommand(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw projectCounterpartyRatingInvalid('Project counterparty rating body must be an object.');
    }
    const scoreLabel = this.readScoreLabel(payload.scoreLabel);
    return {
      ...this.toEntryQuery(payload),
      scoreLabel,
      scoreValue: this.scoreValueForLabel(scoreLabel),
      commentText: this.readOptionalComment(payload.commentText)
    } satisfies SubmitCommand;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectCounterpartyRatingInvalid(`Field \`${field}\` is required.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectCounterpartyRatingInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private readScoreLabel(value: unknown) {
    const normalized = this.readRequiredString(value, 'scoreLabel');
    if (!SCORE_LABELS.has(normalized)) {
      throw projectCounterpartyRatingInvalid('Field `scoreLabel` must be very_satisfied/satisfied/passable/negative.');
    }
    return normalized;
  }

  private scoreValueForLabel(scoreLabel: string) {
    switch (scoreLabel) {
      case 'very_satisfied':
        return 5;
      case 'satisfied':
        return 4;
      case 'passable':
        return 3;
      case 'negative':
        return 1;
      default:
        throw projectCounterpartyRatingInvalid('Field `scoreLabel` must be very_satisfied/satisfied/passable/negative.');
    }
  }

  private readOptionalComment(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw projectCounterpartyRatingInvalid('Field `commentText` must be a string when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized.slice(0, 1000) : null;
  }

  private normalizeId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private isUniqueViolation(error: unknown) {
    return !!error && typeof error === 'object' && 'code' in error && (error as { code?: string }).code === '23505';
  }
}

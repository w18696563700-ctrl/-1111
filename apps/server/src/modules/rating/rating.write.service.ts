import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CreditScoringShadowAggregationService } from '../credit_scoring_shadow/credit-scoring-shadow.aggregation.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient, authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectEntity } from '../project/entities/project.entity';
import { RatingPresenter } from './rating.presenter';
import { ratingEntryUnavailable, ratingInvalidState, ratingSubmitInvalid } from './rating.errors';
import { Optional } from '@nestjs/common';

const BUYER_RATING_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const COMPLETED_ORDER_STATE = 'completed';
const DRAFT_RATING_STATE = 'draft';
const SUBMITTED_RATING_STATE = 'submitted';

type ScopedOrderRow = {
  orderId: string;
  buyerOrganizationId: string | null;
  supplierOrganizationId: string | null;
  state: string | null;
};

type RatingTruthRow = {
  ratingId: string;
  orderId: string;
  state: string | null;
};

@Injectable()
export class RatingWriteService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: RatingPresenter,
    @Optional()
    private readonly shadowAggregationService?: CreditScoringShadowAggregationService,
  ) {}

  async submit(payload: Record<string, unknown>, context: RequestContext) {
    const orderId = this.readSubmitOrderId(payload);
    const { organizationId, userId } = await this.requireBuyerScopedContext(context);
    const order = await this.fetchScopedOrder(orderId, organizationId);
    if (!order || this.normalizeState(order.state) !== COMPLETED_ORDER_STATE) {
      throw ratingEntryUnavailable('Rating entry is not yet available for this order.');
    }

    const rating = await this.fetchLatestRating(orderId);
    if (!rating) {
      throw ratingEntryUnavailable('Rating entry is not yet available for this order.');
    }
    const ratingState = this.normalizeState(rating.state);
    if (ratingState !== DRAFT_RATING_STATE) {
      throw ratingInvalidState('Current rating state does not allow submit.');
    }

    await this.projectRepository.query(
      `
        update public.ratings
        set
          state = $2,
          submitted_at = now(),
          submitted_by = $3,
          updated_at = now()
        where id = $1
      `,
      [rating.ratingId, SUBMITTED_RATING_STATE, userId],
    );

    if (this.shadowAggregationService && order.supplierOrganizationId) {
      await this.shadowAggregationService
        .recomputeAfterFormalRatingSubmit({
          organizationId: order.supplierOrganizationId,
          sourceType: 'order_rating',
          sourceOrderId: order.orderId,
          sourceRatingId: rating.ratingId,
          triggeredAt: new Date(),
        })
        .catch(() => undefined);
    }

    return this.presenter.toSubmitAcceptedResponse(rating.ratingId, orderId);
  }

  private async requireBuyerScopedContext(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }
    if (!scope.roleKeys.some((roleKey) => BUYER_RATING_ROLE_KEYS.has(roleKey))) {
      throw authPermissionInsufficient('Current actor lacks the required buyer role for rating submit.', {
        reason: 'buyer_role_not_allowed',
        currentRoleKeys: scope.roleKeys,
      });
    }
    return {
      organizationId: scope.organization.id,
      userId: currentSession.userId,
    };
  }

  private async fetchScopedOrder(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          "order".id as "orderId",
          "order".buyer_organization_id as "buyerOrganizationId",
          "order".supplier_organization_id as "supplierOrganizationId",
          "order".state as "state"
        from public.orders "order"
        where "order".id = $1
          and "order".buyer_organization_id = $2
        limit 1
      `,
      [orderId, organizationId],
    )) as ScopedOrderRow[];
    return rows[0] ?? null;
  }

  private async fetchLatestRating(orderId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          rating.id as "ratingId",
          rating.order_id as "orderId",
          rating.state as "state"
        from public.ratings rating
        where rating.order_id = $1
        order by rating.updated_at desc nulls last, rating.created_at desc nulls last, rating.id desc
        limit 1
      `,
      [orderId],
    )) as RatingTruthRow[];
    return rows[0] ?? null;
  }

  private readSubmitOrderId(payload: Record<string, unknown>) {
    if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
      throw ratingSubmitInvalid('Rating submit body must be an object.');
    }
    const orderId = typeof payload.orderId === 'string' ? payload.orderId.trim() : '';
    if (!orderId) {
      throw ratingSubmitInvalid('Field `orderId` is required for rating submit.');
    }
    return orderId;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

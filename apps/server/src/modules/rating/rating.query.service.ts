import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient, authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectEntity } from '../project/entities/project.entity';
import { RatingPresenter } from './rating.presenter';
import { ratingEntryUnavailable } from './rating.errors';

const BUYER_RATING_ROLE_KEYS = new Set(['buyer_admin', 'buyer_member(scoped)']);
const COMPLETED_ORDER_STATE = 'completed';
const DRAFT_RATING_STATE = 'draft';

type ScopedOrderRow = {
  orderId: string;
  buyerOrganizationId: string | null;
  state: string | null;
};

type RatingTruthRow = {
  ratingId: string;
  orderId: string;
  state: string | null;
};

@Injectable()
export class RatingQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: RatingPresenter,
  ) {}

  async getEntry(orderId: string | undefined, context: RequestContext) {
    const normalizedOrderId = this.readRequiredOrderId(orderId);
    const organizationId = await this.requireBuyerScopedOrganizationId(context);
    const order = await this.fetchScopedOrder(normalizedOrderId, organizationId);
    if (!order || this.normalizeState(order.state) !== COMPLETED_ORDER_STATE) {
      throw ratingEntryUnavailable('Rating entry is not yet available for this order.');
    }

    const rating = await this.fetchLatestRating(normalizedOrderId);
    if (!rating || this.normalizeState(rating.state) !== DRAFT_RATING_STATE) {
      throw ratingEntryUnavailable('Rating entry is not yet available for this order.');
    }

    return this.presenter.toEntryReadModel(rating.ratingId, normalizedOrderId);
  }

  private async requireBuyerScopedOrganizationId(context: RequestContext) {
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
      throw authPermissionInsufficient('Current actor lacks the required buyer role for rating entry.', {
        reason: 'buyer_role_not_allowed',
        currentRoleKeys: scope.roleKeys,
      });
    }
    return scope.organization.id;
  }

  private async fetchScopedOrder(orderId: string, organizationId: string) {
    const rows = (await this.projectRepository.query(
      `
        select
          "order".id as "orderId",
          "order".buyer_organization_id as "buyerOrganizationId",
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

  private readRequiredOrderId(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw ratingEntryUnavailable('Rating entry is not yet available for this order.');
    }
    return normalized;
  }

  private normalizeState(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

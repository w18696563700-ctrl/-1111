import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindOptionsWhere, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PaymentOrderEntity } from '../p0_pay/entities/payment-order.entity';
import { MembershipOrderEntity } from './entities/membership-order.entity';
import { OrganizationPaidMembershipEntity } from './entities/organization-paid-membership.entity';
import { getTierSpec } from './membership.catalog';

type AdminMembershipListQuery = {
  page: number;
  pageSize: number;
  organizationId: string | null;
  orderStatus: string | null;
  paymentStatus: string | null;
  entitlementStatus: string | null;
};

@Injectable()
export class MembershipAdminQueryService {
  constructor(
    @InjectRepository(MembershipOrderEntity)
    private readonly orderRepository: Repository<MembershipOrderEntity>,
    @InjectRepository(OrganizationPaidMembershipEntity)
    private readonly paidMembershipRepository: Repository<OrganizationPaidMembershipEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async listOrders(query: Record<string, unknown>, context: RequestContext) {
    await this.requireReviewer(context);
    const listQuery = this.readListQuery(query);
    const where = this.toOrderWhere(listQuery);
    const [total, orders] = await Promise.all([
      this.orderRepository.count({ where }),
      this.orderRepository.find({
        where,
        order: { updatedAt: 'DESC' },
        skip: (listQuery.page - 1) * listQuery.pageSize,
        take: listQuery.pageSize
      })
    ]);
    const items = [];
    for (const order of orders) {
      items.push(await this.toOrderView(order));
    }
    return {
      items,
      pagination: this.toPagination(listQuery.page, listQuery.pageSize, total),
      readOnly: true,
      writeActionsEnabled: false
    };
  }

  async getOrderDetail(membershipOrderId: string, context: RequestContext) {
    await this.requireReviewer(context);
    const order = await this.orderRepository.findOneBy({ id: membershipOrderId });
    if (!order) {
      throw new NotFoundException({
        code: 'ADMIN_MEMBERSHIP_ORDER_NOT_FOUND',
        message: 'Membership order is unavailable for admin query.'
      });
    }
    return {
      order: await this.toOrderView(order),
      currentMembership: await this.toMembershipStatus(order.organizationId),
      readOnly: true,
      writeActionsEnabled: false
    };
  }

  async getOrganizationMembershipStatus(
    organizationId: string,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    return {
      membershipStatus: await this.toMembershipStatus(organizationId),
      readOnly: true,
      writeActionsEnabled: false
    };
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireReviewer(currentSession);
  }

  private async toOrderView(order: MembershipOrderEntity) {
    const paymentOrder = order.paymentOrderId
      ? await this.paymentOrderRepository.findOneBy({ id: order.paymentOrderId })
      : null;
    const tierSpec = getTierSpec(order.membershipTier);
    return {
      membershipOrderId: order.id,
      organizationId: order.organizationId,
      createdByUserId: order.createdByUserId,
      skuSnapshot: {
        skuCode: order.skuCode,
        skuName: order.skuName,
        membershipTier: order.membershipTier,
        durationMonths: order.durationMonths,
        serviceFeeDiscountSummary: tierSpec?.serviceFeeDiscountSummary ?? null
      },
      amountSummary: {
        payableAmount: Number(order.payableAmount),
        currency: order.currency
      },
      orderStatus: order.orderStatus,
      paymentStatus: order.paymentStatus,
      entitlementStatus: order.entitlementStatus,
      channelSummary: {
        paymentOrderId: paymentOrder?.id ?? null,
        payChannel: this.toCandidateChannel(paymentOrder?.paymentChannel ?? null),
        paymentReferenceId: paymentOrder?.merchantOrderNo ?? null,
        callbackAwaiting: paymentOrder
          ? ['created', 'pending_user_confirm'].includes(paymentOrder.status)
          : false
      },
      effectiveAt: order.effectiveAt?.toISOString() ?? null,
      expiresAt: order.expiresAt?.toISOString() ?? null,
      failureReasonCode: order.failureReasonCode || null,
      createdAt: order.createdAt?.toISOString() ?? null,
      updatedAt: order.updatedAt?.toISOString() ?? null,
      governanceBoundary: {
        readOnly: true,
        manualOpenEnabled: false,
        refundEnabled: false,
        paymentStatusMutationEnabled: false
      }
    };
  }

  private async toMembershipStatus(organizationId: string) {
    const now = new Date();
    const memberships = await this.paidMembershipRepository.find({
      where: { organizationId },
      order: { effectiveAt: 'DESC' }
    });
    const current =
      memberships.find(
        (item) =>
          item.effectiveAt <= now &&
          (item.expiresAt === null || item.expiresAt > now)
      ) ?? null;
    return {
      organizationId,
      paidMembershipTier: current?.tierCode ?? null,
      effectiveAt: current?.effectiveAt.toISOString() ?? null,
      expiresAt: current?.expiresAt?.toISOString() ?? null,
      sourceType: current?.sourceType ?? null,
      sourceRef: current?.sourceRef ?? null
    };
  }

  private readListQuery(query: Record<string, unknown>): AdminMembershipListQuery {
    return {
      page: this.readPositiveInt(query.page, 1),
      pageSize: this.readPositiveInt(query.pageSize, 20, 50),
      organizationId: this.readOptionalString(query.organizationId),
      orderStatus: this.readOptionalString(query.orderStatus),
      paymentStatus: this.readOptionalString(query.paymentStatus),
      entitlementStatus: this.readOptionalString(query.entitlementStatus)
    };
  }

  private toOrderWhere(query: AdminMembershipListQuery) {
    const where: FindOptionsWhere<MembershipOrderEntity> = {};
    if (query.organizationId) where.organizationId = query.organizationId;
    if (query.orderStatus) where.orderStatus = query.orderStatus as never;
    if (query.paymentStatus) where.paymentStatus = query.paymentStatus as never;
    if (query.entitlementStatus) {
      where.entitlementStatus = query.entitlementStatus as never;
    }
    return where;
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound = 50) {
    const parsed =
      typeof value === 'string'
        ? Number.parseInt(value, 10)
        : typeof value === 'number'
          ? value
          : fallback;
    return Number.isInteger(parsed) && parsed > 0
      ? Math.min(parsed, upperBound)
      : fallback;
  }

  private readOptionalString(value: unknown) {
    return typeof value === 'string' && value.trim() ? value.trim() : null;
  }

  private toPagination(page: number, pageSize: number, total: number) {
    return { page, pageSize, total, hasMore: page * pageSize < total };
  }

  private toCandidateChannel(channel: string | null) {
    if (channel === 'alipay') return 'alipay_candidate';
    if (channel === 'wechat') return 'wechat_candidate';
    return null;
  }
}

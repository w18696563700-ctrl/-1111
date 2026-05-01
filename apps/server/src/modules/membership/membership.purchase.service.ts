import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PaymentIdempotencyRecordEntity } from '../p0_pay/entities/payment-idempotency-record.entity';
import { PaymentOrderEntity } from '../p0_pay/entities/payment-order.entity';
import { P0PayPaymentChannelService } from '../p0_pay/p0-pay-payment-channel.service';
import { P0PayPaymentChannel } from '../p0_pay/p0-pay.types';
import { MembershipOrderEntity } from './entities/membership-order.entity';
import { OrganizationPaidMembershipEntity } from './entities/organization-paid-membership.entity';
import {
  membershipOrderCreateRejected,
  membershipOrderNotFound,
  membershipOrderStateConflict,
  membershipPayInitRejected
} from './membership.errors';
import { MembershipQueryService } from './membership.query.service';
import { findMembershipPurchaseSku, MEMBERSHIP_PURCHASE_SKUS } from './membership.purchase.catalog';
import { MembershipPurchasePresenter } from './membership.purchase.presenter';

const ORDER_CREATE_OPERATION = 'membershipOrder.create';
const PAY_INIT_OPERATION = 'membershipOrder.payInit';
const RESOURCE_ORDER = 'membership_order';
const RESOURCE_PAYMENT_ORDER = 'payment_order';

@Injectable()
export class MembershipPurchaseService {
  constructor(
    @InjectRepository(MembershipOrderEntity)
    private readonly orderRepository: Repository<MembershipOrderEntity>,
    @InjectRepository(OrganizationPaidMembershipEntity)
    private readonly paidMembershipRepository: Repository<OrganizationPaidMembershipEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
    @InjectRepository(PaymentIdempotencyRecordEntity)
    private readonly idempotencyRepository: Repository<PaymentIdempotencyRecordEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly membershipQueryService: MembershipQueryService,
    private readonly paymentChannelService: P0PayPaymentChannelService,
    private readonly presenter: MembershipPurchasePresenter
  ) {}

  async getPurchaseOffers(context: RequestContext) {
    const { organizationId } = await this.requirePurchaseScope(context);
    const snapshot =
      await this.membershipQueryService.getPaidMembershipTierSnapshotForOrganization(organizationId);
    return this.presenter.toOffers({
      organizationId,
      paidMembershipTier: snapshot.tierCode,
      purchaseEligible: true,
      ineligibleReasonCode: null,
      skus: MEMBERSHIP_PURCHASE_SKUS
    });
  }

  async createOrder(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCreateCommand(payload);
    const sku = findMembershipPurchaseSku(command.skuCode);
    if (!sku || sku.status !== 'available') {
      throw membershipOrderCreateRejected('Membership SKU is unavailable.');
    }
    if (command.expectedAmount !== sku.priceAmount || command.expectedCurrency !== sku.currency) {
      throw membershipOrderCreateRejected('Membership SKU price echo does not match Server truth.');
    }

    const { organizationId, currentSession } = await this.requirePurchaseScope(context);
    const keyHash = this.hash(command.idempotencyKey);
    const requestHash = this.hashJson(command);
    const scopeKey = `membership-order:create:${organizationId}:${sku.skuCode}`;
    const existing = await this.findIdempotentOrder(ORDER_CREATE_OPERATION, scopeKey, keyHash, requestHash);
    if (existing) {
      return this.presenter.toCreateResponse(existing);
    }

    const order = await this.dataSource.transaction(async (manager) => {
      const created = this.orderRepository.create({
        id: randomUUID(),
        organizationId,
        createdByUserId: currentSession.userId,
        skuCode: sku.skuCode,
        skuName: sku.skuName,
        membershipTier: sku.membershipTier,
        durationMonths: sku.durationMonths,
        payableAmount: sku.priceAmount,
        currency: sku.currency,
        orderStatus: 'created',
        paymentStatus: 'not_started',
        entitlementStatus: 'not_granted',
        paymentOrderId: null,
        paidMembershipId: null,
        orderExpiresAt: new Date(Date.now() + 30 * 60 * 1000),
        effectiveAt: null,
        expiresAt: null,
        failureReasonCode: '',
        requestId: context.requestId,
        traceId: context.traceId
      });
      await manager.getRepository(MembershipOrderEntity).save(created);
      await this.saveIdempotency(manager, {
        operationKey: ORDER_CREATE_OPERATION,
        scopeKey,
        keyHash,
        requestHash,
        resourceType: RESOURCE_ORDER,
        resourceId: created.id,
        context
      });
      return created;
    });

    return this.presenter.toCreateResponse(order);
  }

  async payInit(orderId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toPayInitCommand(payload);
    const { organizationId } = await this.requirePurchaseScope(context);
    const keyHash = this.hash(command.idempotencyKey);
    const requestHash = this.hashJson(command);
    const scopeKey = `membership-order:pay-init:${orderId}`;
    const existingPayment = await this.findIdempotentPaymentOrder(PAY_INIT_OPERATION, scopeKey, keyHash, requestHash);
    const result = existingPayment
      ? await this.loadOrderAndPayment(orderId, organizationId, existingPayment)
      : await this.createPaymentOrder(orderId, organizationId, command, { keyHash, requestHash, scopeKey, context });
    const action = this.paymentChannelService.buildChannelAction({
      paymentOrderId: result.paymentOrder.id,
      merchantOrderNo: result.paymentOrder.merchantOrderNo,
      amount: result.paymentOrder.amount,
      currency: result.paymentOrder.currency,
      channel: result.paymentOrder.paymentChannel,
      clientPlatform: command.clientPlatform
    });
    return this.presenter.toPayInitResponse(result.order, result.paymentOrder, action);
  }

  async getOrder(orderId: string, context: RequestContext) {
    const { organizationId } = await this.requirePurchaseScope(context);
    const order = await this.findVisibleOrder(orderId, organizationId);
    const paymentOrder = order.paymentOrderId
      ? await this.paymentOrderRepository.findOneBy({ id: order.paymentOrderId })
      : null;
    return this.presenter.toResultResponse(order, paymentOrder);
  }

  async applyPaymentSuccess(manager: EntityManager, paymentOrder: PaymentOrderEntity, context: RequestContext) {
    const order = await manager.getRepository(MembershipOrderEntity).findOneBy({ id: paymentOrder.businessId });
    if (!order || order.orderStatus === 'active') {
      return;
    }
    if (!['paying', 'pending_pay', 'created', 'paid', 'granting'].includes(order.orderStatus)) {
      return;
    }
    const now = new Date();
    order.orderStatus = 'granting';
    order.paymentStatus = 'succeeded';
    order.entitlementStatus = 'granting';
    order.paymentOrderId = paymentOrder.id;
    await manager.getRepository(MembershipOrderEntity).save(order);

    const membership = await this.findOrCreateEntitlement(manager, order, now, context);
    order.orderStatus = 'active';
    order.entitlementStatus = 'active';
    order.paidMembershipId = membership.id;
    order.effectiveAt = membership.effectiveAt;
    order.expiresAt = membership.expiresAt;
    await manager.getRepository(MembershipOrderEntity).save(order);
  }

  async applyPaymentFailure(manager: EntityManager, paymentOrder: PaymentOrderEntity) {
    await manager.getRepository(MembershipOrderEntity).update(
      { id: paymentOrder.businessId },
      {
        orderStatus: 'failed',
        paymentStatus: 'failed',
        entitlementStatus: 'not_granted',
        paymentOrderId: paymentOrder.id,
        failureReasonCode: 'payment_callback_failed'
      }
    );
  }

  private async createPaymentOrder(
    orderId: string,
    organizationId: string,
    command: PayInitCommand,
    idempotency: IdempotencyInput
  ) {
    return this.dataSource.transaction(async (manager) => {
      const order = await this.findVisibleOrderInTransaction(manager, orderId, organizationId);
      if (!['created', 'pending_pay', 'paying'].includes(order.orderStatus)) {
        throw membershipPayInitRejected('Membership order cannot initialize payment in current state.');
      }
      const existing = order.paymentOrderId
        ? await manager.getRepository(PaymentOrderEntity).findOneBy({ id: order.paymentOrderId })
        : null;
      if (existing) {
        return { order, paymentOrder: existing };
      }
      const paymentOrder = this.paymentOrderRepository.create({
        id: randomUUID(),
        businessType: 'membership_direct_purchase',
        businessId: order.id,
        taskId: '',
        bidId: '',
        payerOrganizationId: order.organizationId,
        payeeOrganizationId: '',
        amount: order.payableAmount,
        currency: order.currency,
        paymentChannel: command.payChannel,
        orderRole: 'payment',
        status: 'pending_user_confirm',
        merchantOrderNo: this.buildMerchantOrderNo(),
        channelOrderId: null,
        idempotencyKeyHash: idempotency.keyHash,
        requestId: idempotency.context.requestId,
        traceId: idempotency.context.traceId,
        expiresAt: order.orderExpiresAt
      });
      order.paymentOrderId = paymentOrder.id;
      order.orderStatus = 'paying';
      order.paymentStatus = 'pending';
      await manager.getRepository(PaymentOrderEntity).save(paymentOrder);
      await manager.getRepository(MembershipOrderEntity).save(order);
      await this.saveIdempotency(manager, {
        operationKey: PAY_INIT_OPERATION,
        scopeKey: idempotency.scopeKey,
        keyHash: idempotency.keyHash,
        requestHash: idempotency.requestHash,
        resourceType: RESOURCE_PAYMENT_ORDER,
        resourceId: paymentOrder.id,
        context: idempotency.context
      });
      return { order, paymentOrder };
    });
  }

  private async findOrCreateEntitlement(
    manager: EntityManager,
    order: MembershipOrderEntity,
    now: Date,
    context: RequestContext
  ) {
    const existing = await manager.getRepository(OrganizationPaidMembershipEntity).findOneBy({
      sourceType: 'membership_direct_purchase',
      sourceRef: order.id
    });
    if (existing) {
      return existing;
    }
    const membership = this.paidMembershipRepository.create({
      id: randomUUID(),
      organizationId: order.organizationId,
      tierCode: order.membershipTier,
      effectiveAt: now,
      expiresAt: this.addMonths(now, order.durationMonths),
      sourceType: 'membership_direct_purchase',
      sourceRef: order.id
    });
    await manager.getRepository(OrganizationPaidMembershipEntity).save(membership);
    order.requestId = context.requestId;
    order.traceId = context.traceId;
    return membership;
  }

  private async requirePurchaseScope(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw membershipOrderCreateRejected('Current organization scope is required for membership purchase.');
    }
    return { currentSession, organizationId: scope.organization.id };
  }

  private async findVisibleOrder(orderId: string, organizationId: string) {
    const order = await this.orderRepository.findOneBy({ id: orderId, organizationId });
    if (!order) {
      throw membershipOrderNotFound();
    }
    return order;
  }

  private async findVisibleOrderInTransaction(
    manager: EntityManager,
    orderId: string,
    organizationId: string
  ) {
    const order = await manager.getRepository(MembershipOrderEntity).findOneBy({ id: orderId, organizationId });
    if (!order) {
      throw membershipOrderNotFound();
    }
    return order;
  }

  private async loadOrderAndPayment(
    orderId: string,
    organizationId: string,
    paymentOrder: PaymentOrderEntity
  ) {
    const order = await this.findVisibleOrder(orderId, organizationId);
    if (order.paymentOrderId && order.paymentOrderId !== paymentOrder.id) {
      throw membershipOrderStateConflict('Idempotent payment order does not match membership order truth.');
    }
    return { order, paymentOrder };
  }

  private async findIdempotentOrder(
    operationKey: string,
    scopeKey: string,
    keyHash: string,
    requestHash: string
  ) {
    const record = await this.findIdempotencyRecord(operationKey, scopeKey, keyHash, requestHash);
    return record ? this.orderRepository.findOneBy({ id: record.resourceId }) : null;
  }

  private async findIdempotentPaymentOrder(
    operationKey: string,
    scopeKey: string,
    keyHash: string,
    requestHash: string
  ) {
    const record = await this.findIdempotencyRecord(operationKey, scopeKey, keyHash, requestHash);
    return record ? this.paymentOrderRepository.findOneBy({ id: record.resourceId }) : null;
  }

  private async findIdempotencyRecord(
    operationKey: string,
    scopeKey: string,
    keyHash: string,
    requestHash: string
  ) {
    const record = await this.idempotencyRepository.findOneBy({
      operationKey,
      scopeKey,
      idempotencyKeyHash: keyHash
    });
    if (record && record.requestHash !== requestHash) {
      throw membershipOrderStateConflict('Current idempotency key has already been used for another request.');
    }
    return record;
  }

  private async saveIdempotency(manager: EntityManager, input: SaveIdempotencyInput) {
    await manager.getRepository(PaymentIdempotencyRecordEntity).save({
      id: randomUUID(),
      operationKey: input.operationKey,
      scopeKey: input.scopeKey,
      idempotencyKeyHash: input.keyHash,
      requestHash: input.requestHash,
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      status: 'succeeded',
      requestId: input.context.requestId,
      traceId: input.context.traceId
    });
  }

  private toCreateCommand(payload: Record<string, unknown>) {
    return {
      skuCode: this.readString(payload.skuCode, 'skuCode'),
      purchaseIntentType: this.readPurchaseIntent(payload.purchaseIntentType),
      expectedAmount: this.money(payload.expectedAmount),
      expectedCurrency: this.readCurrency(payload.expectedCurrency),
      idempotencyKey: this.readString(payload.idempotencyKey, 'idempotencyKey')
    };
  }

  private toPayInitCommand(payload: Record<string, unknown>) {
    return {
      payChannel: this.readPayChannel(payload.payChannel),
      clientPlatform: this.readString(payload.clientPlatform, 'clientPlatform').slice(0, 64),
      idempotencyKey: this.readString(payload.idempotencyKey, 'idempotencyKey')
    };
  }

  private readString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw membershipOrderCreateRejected(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readPurchaseIntent(value: unknown) {
    if (value !== 'new_purchase') {
      throw membershipOrderCreateRejected('Only new_purchase is open in current membership purchase loop.');
    }
    return value;
  }

  private readCurrency(value: unknown) {
    if (value !== 'CNY') {
      throw membershipOrderCreateRejected('Field `expectedCurrency` must be CNY.');
    }
    return value;
  }

  private readPayChannel(value: unknown): P0PayPaymentChannel {
    if (value === 'alipay_candidate') {
      return 'alipay';
    }
    if (value === 'wechat_candidate') {
      return 'wechat';
    }
    throw membershipPayInitRejected('Field `payChannel` must be alipay_candidate or wechat_candidate.');
  }

  private money(value: unknown) {
    const numeric = Number(value);
    if (!Number.isFinite(numeric) || numeric < 0) {
      throw membershipOrderCreateRejected('Amount fields must be valid non-negative numbers.');
    }
    return numeric.toFixed(2);
  }

  private buildMerchantOrderNo() {
    return `MEM_PAY_${Date.now()}_${randomUUID().replace(/-/g, '').slice(0, 12)}`;
  }

  private addMonths(value: Date, months: number) {
    const copy = new Date(value);
    copy.setMonth(copy.getMonth() + months);
    return copy;
  }

  private hash(value: string) {
    return createHash('sha256').update(value, 'utf8').digest('hex');
  }

  private hashJson(value: unknown) {
    return this.hash(JSON.stringify(this.sortValue(value)));
  }

  private sortValue(value: unknown): unknown {
    if (Array.isArray(value)) {
      return value.map((item) => this.sortValue(item));
    }
    if (!value || typeof value !== 'object') {
      return value;
    }
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, item]) => [key, this.sortValue(item)])
    );
  }
}

type PayInitCommand = {
  payChannel: P0PayPaymentChannel;
  clientPlatform: string;
  idempotencyKey: string;
};

type IdempotencyInput = {
  keyHash: string;
  requestHash: string;
  scopeKey: string;
  context: RequestContext;
};

type SaveIdempotencyInput = IdempotencyInput & {
  operationKey: string;
  resourceType: string;
  resourceId: string;
};

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { MembershipPurchaseService } from '../membership/membership.purchase.service';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentCallbackEventEntity } from './entities/payment-callback-event.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PaymentTransactionEntity } from './entities/payment-transaction.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { p0PayInvalid, p0PayResourceUnavailable } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';
import { P0PayPaymentChannel } from './p0-pay.types';
import { PLATFORM_PRICING_AUDIT_ACTIONS } from './p0-pay.state';

type CallbackCommand = {
  paymentChannel: P0PayPaymentChannel;
  merchantOrderNo: string;
  channelOrderId: string;
  providerEventId: string;
  channelEventId: string;
  eventType: string;
  eventStatus: string;
  amount: string | null;
  payloadSnapshot: Record<string, unknown>;
};

@Injectable()
export class P0PayCallbackService {
  constructor(
    @InjectRepository(PaymentCallbackEventEntity)
    private readonly callbackRepository: Repository<PaymentCallbackEventEntity>,
    private readonly dataSource: DataSource,
    private readonly paymentChannelService: P0PayPaymentChannelService,
    private readonly auditService: P0PayAuditService,
    private readonly membershipPurchaseService: MembershipPurchaseService
  ) {}

  async handleCallback(
    paymentChannel: string,
    payload: Record<string, unknown>,
    signature: string,
    context: RequestContext
  ) {
    const command = this.toCallbackCommand(paymentChannel, payload);
    const duplicate = await this.callbackRepository.findOneBy({
      paymentChannel: command.paymentChannel,
      channelEventId: command.channelEventId
    });
    if (duplicate) {
      return this.toCallbackResponse(duplicate, true);
    }

    const event = await this.dataSource.transaction(async (manager) => {
      const callback = this.buildCallbackEvent(command, context);
      const verification = this.paymentChannelService.verifyCallback(payload, signature, command.paymentChannel);
      if (!verification.verified) {
        callback.verificationStatus = 'rejected';
        callback.applyStatus = 'not_applied';
        callback.rejectedReasonCode = verification.reasonCode;
        await manager.getRepository(PaymentCallbackEventEntity).save(callback);
        await this.recordCallbackAudit(manager, callback, PLATFORM_PRICING_AUDIT_ACTIONS.paymentCallbackRejected, context);
        return callback;
      }

      callback.verificationStatus = 'verified';
      callback.verifiedAt = new Date();
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      await this.recordCallbackAudit(manager, callback, PLATFORM_PRICING_AUDIT_ACTIONS.paymentCallbackVerified, context);
      await this.applyVerifiedCallback(manager, callback, command, context);
      return callback;
    });

    return this.toCallbackResponse(event, false);
  }

  private async applyVerifiedCallback(
    manager: EntityManager,
    callback: PaymentCallbackEventEntity,
    command: CallbackCommand,
    context: RequestContext
  ) {
    const order = await manager.getRepository(PaymentOrderEntity).findOneBy({
      merchantOrderNo: command.merchantOrderNo,
      paymentChannel: command.paymentChannel
    });
    if (!order) {
      callback.applyStatus = 'apply_failed';
      callback.rejectedReasonCode = 'payment_order_not_found';
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }
    if (!this.amountMatches(order.amount, command.amount)) {
      callback.applyStatus = 'apply_failed';
      callback.rejectedReasonCode = 'payment_amount_mismatch';
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }

    if (this.isSuccessEvent(command)) {
      await this.applySuccess(manager, callback, order, command, context);
      return;
    }
    if (this.isFailureEvent(command)) {
      await this.applyFailure(manager, callback, order, command, context);
      return;
    }

    callback.applyStatus = 'ignored_out_of_order';
    callback.rejectedReasonCode = 'unsupported_event_type';
    await manager.getRepository(PaymentCallbackEventEntity).save(callback);
  }

  private async applySuccess(
    manager: EntityManager,
    callback: PaymentCallbackEventEntity,
    order: PaymentOrderEntity,
    command: CallbackCommand,
    context: RequestContext
  ) {
    if (order.status === 'succeeded' || order.status === 'refunded') {
      callback.applyStatus = 'duplicate';
      callback.appliedAt = new Date();
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }
    const successMutableStatuses = order.businessType === 'project_authenticity_sincerity_refund'
      ? ['created', 'pending_user_confirm', 'refund_pending']
      : ['created', 'pending_user_confirm'];
    if (!successMutableStatuses.includes(order.status)) {
      callback.applyStatus = 'ignored_out_of_order';
      callback.rejectedReasonCode = `order_status_${order.status}`;
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }

    const beforeOrderState = order.status;
    order.status = order.businessType === 'project_authenticity_sincerity_refund' ? 'refunded' : 'succeeded';
    order.channelOrderId = command.channelOrderId;
    await manager.getRepository(PaymentOrderEntity).save(order);
    await this.saveTransaction(manager, order, command, 'succeeded');
    await this.applyBusinessSuccess(manager, order, context);
    callback.applyStatus = 'applied';
    callback.appliedAt = new Date();
    callback.processedAt = callback.appliedAt;
    await manager.getRepository(PaymentCallbackEventEntity).save(callback);
    await this.auditService.record(
      {
        objectType: 'payment_order',
        objectId: order.id,
        objectNo: order.merchantOrderNo,
        action: this.businessSuccessAuditAction(order),
        beforeState: beforeOrderState,
        afterState: order.status,
        reason: `businessType=${order.businessType}; eventType=${command.eventType}`
      },
      context,
      manager
    );
  }

  private async applyFailure(
    manager: EntityManager,
    callback: PaymentCallbackEventEntity,
    order: PaymentOrderEntity,
    command: CallbackCommand,
    context: RequestContext
  ) {
    const failureMutableStatuses = order.businessType === 'project_authenticity_sincerity_refund'
      ? ['created', 'pending_user_confirm', 'refund_pending']
      : ['created', 'pending_user_confirm'];
    if (!failureMutableStatuses.includes(order.status)) {
      callback.applyStatus = 'ignored_out_of_order';
      callback.rejectedReasonCode = `order_status_${order.status}`;
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }
    const beforeOrderState = order.status;
    order.status = 'failed';
    order.channelOrderId = command.channelOrderId;
    await manager.getRepository(PaymentOrderEntity).save(order);
    await this.saveTransaction(manager, order, command, 'failed');
    await this.applyBusinessFailure(manager, order);
    callback.applyStatus = 'applied';
    callback.appliedAt = new Date();
    callback.processedAt = callback.appliedAt;
    await manager.getRepository(PaymentCallbackEventEntity).save(callback);
    await this.auditService.record(
      {
        objectType: 'payment_order',
        objectId: order.id,
        objectNo: order.merchantOrderNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.paymentCallbackRejected,
        beforeState: beforeOrderState,
        afterState: order.status,
        reason: `businessType=${order.businessType}; eventType=${command.eventType}`
      },
      context,
      manager
    );
  }

  private async applyBusinessSuccess(manager: EntityManager, order: PaymentOrderEntity, context: RequestContext) {
    if (
      order.businessType === 'platform_service_fee_authorization' ||
      order.businessType === 'bid_service_fee_authorization_freeze'
    ) {
      const auth = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).findOneBy({ id: order.businessId });
      if (auth && auth.status === 'pending_freeze') {
        auth.status = 'frozen';
        auth.frozenAt = new Date();
        auth.authorizedAt = auth.frozenAt;
        await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(auth);
      } else if (auth && auth.status === 'pending_authorization') {
        auth.status = 'authorized';
        auth.authorizedAt = new Date();
        await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(auth);
      }
    }
    if (
      order.businessType === 'inquiry_deposit' ||
      order.businessType === 'project_authenticity_sincerity_payment'
    ) {
      const deposit = await manager.getRepository(InquiryQuoteDepositEntity).findOneBy({ id: order.businessId });
      if (deposit && deposit.status === 'pending_payment') {
        deposit.status = 'paid';
        deposit.paidAt = new Date();
        await manager.getRepository(InquiryQuoteDepositEntity).save(deposit);
      }
    }
    if (order.businessType === 'project_authenticity_sincerity_refund') {
      await this.applyDepositRefundSuccess(manager, order, context);
    }
    if (order.businessType === 'platform_service_fee_charge') {
      await this.applyChargeSuccess(manager, order, context);
    }
    if (order.businessType === 'membership_direct_purchase') {
      await this.membershipPurchaseService.applyPaymentSuccess(manager, order, context);
    }
  }

  private async applyDepositRefundSuccess(manager: EntityManager, order: PaymentOrderEntity, context: RequestContext) {
    const deposit = await manager.getRepository(InquiryQuoteDepositEntity).findOneBy({ id: order.businessId });
    if (!deposit || deposit.status === 'refunded') {
      return;
    }
    const beforeState = deposit.status;
    if (!['refund_pending', 'paid'].includes(deposit.status)) {
      return;
    }
    deposit.status = 'refunded';
    deposit.refundedAt = new Date();
    await manager.getRepository(InquiryQuoteDepositEntity).save(deposit);
    await this.auditService.record(
      {
        objectType: 'project_authenticity_sincerity_order',
        objectId: deposit.id,
        objectNo: order.merchantOrderNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.projectAuthenticitySincerityRefunded,
        beforeState,
        afterState: deposit.status,
        reason: `taskId=${deposit.taskId}; amount=${deposit.amount}`
      },
      context,
      manager
    );
  }

  private async applyChargeSuccess(manager: EntityManager, order: PaymentOrderEntity, context: RequestContext) {
    const charge = await manager.getRepository(PlatformServiceFeeChargeEntity).findOneBy({ id: order.businessId });
    if (!charge || charge.chargeStatus === 'charged') {
      return;
    }
    const beforeChargeState = charge.chargeStatus;
    charge.chargeStatus = 'charged';
    charge.chargedAt = new Date();
    await manager.getRepository(PlatformServiceFeeChargeEntity).save(charge);
    const auth = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).findOneBy({ id: charge.authorizationId });
    if (auth) {
      auth.status = 'charged';
      auth.chargedAt = charge.chargedAt;
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(auth);
    }
    await this.auditService.record(
      {
        objectType: 'platform_service_fee_charge',
        objectId: charge.id,
        objectNo: order.merchantOrderNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.platformServiceFeeCharged,
        beforeState: beforeChargeState,
        afterState: charge.chargeStatus,
        reason: `taskId=${charge.taskId}; finalFeeAmount=${charge.finalFeeAmount}`
      },
      context,
      manager
    );
  }

  private async applyBusinessFailure(manager: EntityManager, order: PaymentOrderEntity) {
    if (
      order.businessType === 'platform_service_fee_authorization' ||
      order.businessType === 'bid_service_fee_authorization_freeze'
    ) {
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).update(
        { id: order.businessId, status: 'pending_authorization' },
        { status: 'failed' }
      );
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).update(
        { id: order.businessId, status: 'pending_freeze' },
        { status: 'failed' }
      );
    }
    if (
      order.businessType === 'inquiry_deposit' ||
      order.businessType === 'project_authenticity_sincerity_payment'
    ) {
      await manager.getRepository(InquiryQuoteDepositEntity).update(
        { id: order.businessId, status: 'pending_payment' },
        { status: 'failed' }
      );
    }
    if (order.businessType === 'project_authenticity_sincerity_refund') {
      await manager.getRepository(InquiryQuoteDepositEntity).update(
        { id: order.businessId, status: 'refund_pending' },
        { status: 'paid' }
      );
    }
    if (order.businessType === 'platform_service_fee_charge') {
      await manager.getRepository(PlatformServiceFeeChargeEntity).update(
        { id: order.businessId, chargeStatus: 'pending_charge' },
        { chargeStatus: 'charge_failed' }
      );
      await manager.getRepository(PlatformServiceFeeChargeEntity).update(
        { id: order.businessId, chargeStatus: 'charge_pending' },
        { chargeStatus: 'charge_failed' }
      );
    }
    if (order.businessType === 'membership_direct_purchase') {
      await this.membershipPurchaseService.applyPaymentFailure(manager, order);
    }
  }

  private async saveTransaction(
    manager: EntityManager,
    order: PaymentOrderEntity,
    command: CallbackCommand,
    status: 'succeeded' | 'failed'
  ) {
    await manager.getRepository(PaymentTransactionEntity).save({
      id: randomUUID(),
      paymentOrderId: order.id,
      transactionType: order.orderRole === 'authorization'
        ? 'authorization'
        : order.orderRole === 'refund'
          ? 'refund'
          : 'payment',
      paymentChannel: order.paymentChannel,
      channelTransactionId: command.channelOrderId,
      amount: order.amount,
      requestedAmount: order.amount,
      confirmedAmount: status === 'succeeded' ? order.amount : null,
      status,
      channelActionType: order.paymentChannel === 'alipay' ? 'sdk_payload' : 'web_redirect',
      channelReference: command.providerEventId,
      rawStatus: command.eventStatus,
      initiatedAt: null,
      confirmedAt: status === 'succeeded' ? new Date() : null,
      failedAt: status === 'failed' ? new Date() : null,
      failureReasonCode: status === 'failed' ? command.eventStatus : '',
      occurredAt: new Date()
    });
  }

  private buildCallbackEvent(command: CallbackCommand, context: RequestContext) {
    return this.callbackRepository.create({
      id: randomUUID(),
      paymentChannel: command.paymentChannel,
      merchantOrderNo: command.merchantOrderNo,
      channelEventId: command.channelEventId,
      providerEventId: command.providerEventId,
      eventType: command.eventType,
      eventStatus: command.eventStatus,
      payloadSnapshot: command.payloadSnapshot,
      callbackPayloadHash: this.paymentChannelService.hashPayload(command.payloadSnapshot),
      verificationStatus: 'received',
      applyStatus: 'not_applied',
      rejectedReasonCode: '',
      requestId: context.requestId,
      traceId: context.traceId,
      receivedAt: new Date(),
      verifiedAt: null,
      appliedAt: null,
      processedAt: null
    });
  }

  private async recordCallbackAudit(
    manager: EntityManager,
    callback: PaymentCallbackEventEntity,
    action: string,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: 'payment_callback_event',
        objectId: callback.id,
        objectNo: callback.merchantOrderNo,
        action,
        beforeState: 'received',
        afterState: callback.verificationStatus,
        reason: `channel=${callback.paymentChannel}; eventType=${callback.eventType}; applyStatus=${callback.applyStatus}`
      },
      context,
      manager
    );
  }

  private businessSuccessAuditAction(order: PaymentOrderEntity) {
    if (order.businessType === 'inquiry_deposit') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.projectAuthenticitySincerityPaid;
    }
    if (order.businessType === 'project_authenticity_sincerity_payment') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.projectAuthenticitySincerityPaid;
    }
    if (order.businessType === 'project_authenticity_sincerity_refund') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.projectAuthenticitySincerityRefunded;
    }
    if (order.businessType === 'platform_service_fee_authorization') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationFrozen;
    }
    if (order.businessType === 'bid_service_fee_authorization_freeze') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationFrozen;
    }
    if (order.businessType === 'platform_service_fee_charge') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.platformServiceFeeCharged;
    }
    if (order.businessType === 'membership_direct_purchase') {
      return PLATFORM_PRICING_AUDIT_ACTIONS.paymentCallbackVerified;
    }
    return PLATFORM_PRICING_AUDIT_ACTIONS.paymentCallbackReceived;
  }

  private toCallbackCommand(paymentChannel: string, payload: Record<string, unknown>) {
    const channel = this.readPaymentChannel(paymentChannel);
    const merchantOrderNo = this.readRequiredString(
      this.readFirst(payload.merchantOrderNo, payload.out_trade_no),
      'merchantOrderNo'
    );
    const providerEventId = this.readRequiredString(
      this.readFirst(payload.providerEventId, payload.notify_id, payload.trade_no),
      'providerEventId'
    );
    const eventType = this.readRequiredString(
      this.readFirst(payload.eventType, payload.notify_type, 'alipay_trade_status_sync'),
      'eventType'
    );
    const eventStatus = this.readRequiredString(
      this.readFirst(payload.eventStatus, this.toCanonicalAlipayStatus(payload.trade_status)),
      'eventStatus'
    );
    return {
      paymentChannel: channel,
      merchantOrderNo,
      channelOrderId: this.readRequiredString(
        this.readFirst(payload.channelOrderId, payload.trade_no, providerEventId),
        'channelOrderId'
      ),
      providerEventId,
      channelEventId: this.readOptionalString(payload.channelEventId) ?? providerEventId,
      eventType,
      eventStatus,
      amount: this.readOptionalString(this.readFirst(payload.amount, payload.total_amount, payload.receipt_amount, payload.refund_fee)),
      payloadSnapshot: this.toSnapshot(payload)
    } satisfies CallbackCommand;
  }

  private readPaymentChannel(value: string): P0PayPaymentChannel {
    if (value === 'alipay' || value === 'wechat' || value === 'other') {
      return value;
    }
    throw p0PayInvalid('Callback payment channel is unsupported.');
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw p0PayInvalid(`Field \`${field}\` is required for payment callback.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    if (typeof value !== 'string' && typeof value !== 'number') {
      throw p0PayInvalid('Optional callback fields must be strings or numbers.');
    }
    const normalized = String(value).trim();
    return normalized ? normalized : null;
  }

  private readFirst(...values: unknown[]) {
    return values.find((value) => value !== null && value !== undefined && value !== '');
  }

  private toCanonicalAlipayStatus(value: unknown) {
    const status = this.readOptionalString(value);
    if (!status) {
      return null;
    }
    if (status === 'TRADE_SUCCESS' || status === 'TRADE_FINISHED') {
      return 'succeeded';
    }
    if (status === 'TRADE_CLOSED') {
      return 'failed';
    }
    return status.toLowerCase();
  }

  private isSuccessEvent(command: CallbackCommand) {
    return command.eventStatus === 'succeeded' || command.eventType.endsWith('_succeeded');
  }

  private isFailureEvent(command: CallbackCommand) {
    return command.eventStatus === 'failed' || command.eventType.endsWith('_failed');
  }

  private amountMatches(expected: string | number, actual: string | null) {
    if (actual === null) {
      return true;
    }
    const expectedNumber = Number(expected);
    const actualNumber = Number(actual);
    return Number.isFinite(expectedNumber) &&
      Number.isFinite(actualNumber) &&
      expectedNumber.toFixed(2) === actualNumber.toFixed(2);
  }

  private toSnapshot(payload: Record<string, unknown>) {
    return {
      merchantOrderNo: this.readFirst(payload.merchantOrderNo, payload.out_trade_no),
      channelOrderId: this.readFirst(payload.channelOrderId, payload.trade_no),
      providerEventId: this.readFirst(payload.providerEventId, payload.notify_id, payload.trade_no),
      channelEventId: payload.channelEventId,
      eventType: this.readFirst(payload.eventType, payload.notify_type),
      eventStatus: this.readFirst(payload.eventStatus, this.toCanonicalAlipayStatus(payload.trade_status), payload.trade_status),
      amount: this.readFirst(payload.amount, payload.total_amount, payload.receipt_amount, payload.refund_fee),
      currency: this.readFirst(payload.currency, 'CNY'),
      provider: payload.sign ? 'alipay' : undefined,
      rawTradeStatus: payload.trade_status,
      rawNotifyType: payload.notify_type
    };
  }

  private toCallbackResponse(event: PaymentCallbackEventEntity, duplicate: boolean) {
    if (!event) {
      throw p0PayResourceUnavailable('Current payment callback event is unavailable.');
    }
    return {
      callbackEventId: event.id,
      duplicate,
      verificationStatus: event.verificationStatus,
      applyStatus: duplicate ? 'duplicate' : event.applyStatus,
      rejectedReasonCode: event.rejectedReasonCode,
      receivedAt: event.receivedAt,
      processedAt: event.processedAt
    };
  }
}

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentCallbackEventEntity } from './entities/payment-callback-event.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PaymentTransactionEntity } from './entities/payment-transaction.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { p0PayInvalid, p0PayResourceUnavailable } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';
import { P0PayPaymentChannel } from './p0-pay.types';

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
    private readonly auditService: P0PayAuditService
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
      const verification = this.paymentChannelService.verifyCallback(payload, signature);
      if (!verification.verified) {
        callback.verificationStatus = 'rejected';
        callback.applyStatus = 'not_applied';
        callback.rejectedReasonCode = verification.reasonCode;
        await manager.getRepository(PaymentCallbackEventEntity).save(callback);
        await this.recordCallbackAudit(manager, callback, 'PaymentCallbackRejected', context);
        return callback;
      }

      callback.verificationStatus = 'verified';
      callback.verifiedAt = new Date();
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      await this.recordCallbackAudit(manager, callback, 'PaymentCallbackVerified', context);
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
    if (order.status === 'succeeded') {
      callback.applyStatus = 'duplicate';
      callback.appliedAt = new Date();
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }
    if (!['created', 'pending_user_confirm'].includes(order.status)) {
      callback.applyStatus = 'ignored_out_of_order';
      callback.rejectedReasonCode = `order_status_${order.status}`;
      await manager.getRepository(PaymentCallbackEventEntity).save(callback);
      return;
    }

    const beforeOrderState = order.status;
    order.status = 'succeeded';
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
    if (!['created', 'pending_user_confirm'].includes(order.status)) {
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
        action: 'PaymentCallbackRejected',
        beforeState: beforeOrderState,
        afterState: order.status,
        reason: `businessType=${order.businessType}; eventType=${command.eventType}`
      },
      context,
      manager
    );
  }

  private async applyBusinessSuccess(manager: EntityManager, order: PaymentOrderEntity, context: RequestContext) {
    if (order.businessType === 'platform_service_fee_authorization') {
      const auth = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).findOneBy({ id: order.businessId });
      if (auth && auth.status === 'pending_authorization') {
        auth.status = 'authorized';
        auth.authorizedAt = new Date();
        await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(auth);
      }
    }
    if (order.businessType === 'inquiry_deposit') {
      const deposit = await manager.getRepository(InquiryQuoteDepositEntity).findOneBy({ id: order.businessId });
      if (deposit && deposit.status === 'pending_payment') {
        deposit.status = 'paid';
        deposit.paidAt = new Date();
        await manager.getRepository(InquiryQuoteDepositEntity).save(deposit);
        await this.publishInquiryTaskAfterDepositPaid(manager, deposit, context);
      }
    }
    if (order.businessType === 'platform_service_fee_charge') {
      await this.applyChargeSuccess(manager, order, context);
    }
  }

  private async publishInquiryTaskAfterDepositPaid(
    manager: EntityManager,
    deposit: InquiryQuoteDepositEntity,
    context: RequestContext
  ) {
    const project = await manager.getRepository(ProjectEntity).findOneBy({ id: deposit.taskId });
    if (!project || this.readTaskType(project.summary) !== 'inquiry_quote') {
      return;
    }
    if (project.state === 'published' && project.publishedAt) {
      return;
    }

    const beforeState = project.state;
    project.state = 'published';
    project.publishedAt = project.publishedAt ?? new Date();
    await manager.getRepository(ProjectEntity).save(project);
    await this.auditService.record(
      {
        objectType: 'trade_task',
        objectId: project.id,
        objectNo: project.projectNo,
        action: 'InquiryTaskPublishedAfterDepositPaid',
        beforeState,
        afterState: project.state,
        reason: `inquiryDepositId=${deposit.id}; depositStatus=${deposit.status}`
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
        action: 'PlatformServiceFeeCharged',
        beforeState: 'pending_charge',
        afterState: charge.chargeStatus,
        reason: `taskId=${charge.taskId}; finalFeeAmount=${charge.finalFeeAmount}`
      },
      context,
      manager
    );
  }

  private async applyBusinessFailure(manager: EntityManager, order: PaymentOrderEntity) {
    if (order.businessType === 'platform_service_fee_authorization') {
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).update(
        { id: order.businessId, status: 'pending_authorization' },
        { status: 'failed' }
      );
    }
    if (order.businessType === 'inquiry_deposit') {
      await manager.getRepository(InquiryQuoteDepositEntity).update(
        { id: order.businessId, status: 'pending_payment' },
        { status: 'failed' }
      );
    }
    if (order.businessType === 'platform_service_fee_charge') {
      await manager.getRepository(PlatformServiceFeeChargeEntity).update(
        { id: order.businessId, chargeStatus: 'pending_charge' },
        { chargeStatus: 'charge_failed' }
      );
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
      transactionType: order.orderRole === 'authorization' ? 'authorization' : 'payment',
      paymentChannel: order.paymentChannel,
      channelTransactionId: command.channelOrderId,
      amount: order.amount,
      requestedAmount: order.amount,
      confirmedAmount: status === 'succeeded' ? order.amount : null,
      status,
      channelActionType: 'web_redirect',
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
      return 'InquiryDepositPaid';
    }
    if (order.businessType === 'platform_service_fee_authorization') {
      return 'PlatformServiceFeePreauthorizationAuthorized';
    }
    return 'PaymentCallbackReceived';
  }

  private readTaskType(summary: unknown) {
    if (!summary || Array.isArray(summary) || typeof summary !== 'object') {
      return null;
    }
    const p0PayTask = (summary as Record<string, unknown>).p0PayTask;
    if (!p0PayTask || Array.isArray(p0PayTask) || typeof p0PayTask !== 'object') {
      return null;
    }
    const taskType = (p0PayTask as Record<string, unknown>).taskType;
    return typeof taskType === 'string' && taskType.trim() ? taskType.trim() : null;
  }

  private toCallbackCommand(paymentChannel: string, payload: Record<string, unknown>) {
    const channel = this.readPaymentChannel(paymentChannel);
    const merchantOrderNo = this.readRequiredString(payload.merchantOrderNo, 'merchantOrderNo');
    const providerEventId = this.readRequiredString(payload.providerEventId, 'providerEventId');
    const eventType = this.readRequiredString(payload.eventType, 'eventType');
    return {
      paymentChannel: channel,
      merchantOrderNo,
      channelOrderId: this.readRequiredString(payload.channelOrderId, 'channelOrderId'),
      providerEventId,
      channelEventId: this.readOptionalString(payload.channelEventId) ?? providerEventId,
      eventType,
      eventStatus: this.readRequiredString(payload.eventStatus, 'eventStatus'),
      amount: this.readOptionalString(payload.amount),
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

  private isSuccessEvent(command: CallbackCommand) {
    return command.eventStatus === 'succeeded' || command.eventType.endsWith('_succeeded');
  }

  private isFailureEvent(command: CallbackCommand) {
    return command.eventStatus === 'failed' || command.eventType.endsWith('_failed');
  }

  private toSnapshot(payload: Record<string, unknown>) {
    return {
      merchantOrderNo: payload.merchantOrderNo,
      channelOrderId: payload.channelOrderId,
      providerEventId: payload.providerEventId,
      channelEventId: payload.channelEventId,
      eventType: payload.eventType,
      eventStatus: payload.eventStatus,
      amount: payload.amount,
      currency: payload.currency
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

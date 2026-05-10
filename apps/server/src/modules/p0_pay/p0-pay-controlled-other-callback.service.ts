import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { P0PayCallbackService } from './p0-pay-callback.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';

@Injectable()
export class P0PayControlledOtherCallbackService {
  constructor(
    private readonly callbackService: P0PayCallbackService,
    private readonly paymentChannelService: P0PayPaymentChannelService
  ) {}

  async completeAuthorizationFreezeIfEligible(order: PaymentOrderEntity, context: RequestContext) {
    if (!this.canCompleteAuthorizationFreeze(order) || !this.paymentChannelService.canSignControlledCallback()) {
      return null;
    }
    const payload = this.buildAuthorizationSucceededPayload(order);
    const signature = this.paymentChannelService.signPayload(payload);
    return this.callbackService.handleCallback('other', payload, signature, context);
  }

  private canCompleteAuthorizationFreeze(order: PaymentOrderEntity) {
    return (
      order.paymentChannel === 'other' &&
      order.businessType === 'bid_service_fee_authorization_freeze' &&
      order.orderRole === 'authorization' &&
      ['created', 'pending_user_confirm'].includes(order.status)
    );
  }

  private buildAuthorizationSucceededPayload(order: PaymentOrderEntity) {
    const eventId = `other-${order.merchantOrderNo}-authorization-succeeded`;
    return {
      merchantOrderNo: order.merchantOrderNo,
      channelOrderId: `other-${order.id}`,
      providerEventId: eventId,
      channelEventId: eventId,
      eventType: 'authorization_succeeded',
      eventStatus: 'succeeded',
      amount: String(order.amount),
      currency: order.currency
    };
  }
}

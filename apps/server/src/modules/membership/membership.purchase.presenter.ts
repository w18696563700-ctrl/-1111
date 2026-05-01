import { Injectable } from '@nestjs/common';
import { PaymentOrderEntity } from '../p0_pay/entities/payment-order.entity';
import { MembershipOrderEntity } from './entities/membership-order.entity';
import { getTierSpec } from './membership.catalog';
import {
  MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES,
  toPurchaseOffer
} from './membership.purchase.catalog';
import { MembershipPurchaseSku } from './membership.purchase.catalog';

type ChannelAction = {
  channelActionType: 'sdk_payload' | 'web_redirect' | 'qr_code' | 'unavailable';
  channelPayload: Record<string, unknown> | null;
  callbackAwaiting: boolean;
};

@Injectable()
export class MembershipPurchasePresenter {
  toOffers(input: {
    organizationId: string | null;
    paidMembershipTier: string | null;
    purchaseEligible: boolean;
    ineligibleReasonCode: string | null;
    skus: MembershipPurchaseSku[];
  }) {
    return {
      offers: input.skus.map((sku) => toPurchaseOffer(sku)),
      currentOrganizationMembershipContext: {
        organizationId: input.organizationId,
        paidMembershipTier: input.paidMembershipTier,
        purchaseEligible: input.purchaseEligible,
        ineligibleReasonCode: input.ineligibleReasonCode
      },
      channelCandidates: [...MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES],
      commercialDisclosure:
        '会员直购首轮仅开放标准/专业年付 SKU。会员服务费优惠作用于 baseFeeAmount，不是成交金额固定百分比。',
      updatedAt: new Date().toISOString()
    };
  }

  toCreateResponse(order: MembershipOrderEntity) {
    return {
      membershipOrderId: order.id,
      orderStatus: order.orderStatus,
      payableAmount: Number(order.payableAmount),
      currency: order.currency,
      entitlementPreview: this.toSkuSnapshot(order),
      channelCandidates: [...MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES],
      expiresAt: order.orderExpiresAt?.toISOString() ?? null,
      updatedAt: order.updatedAt?.toISOString() ?? new Date().toISOString()
    };
  }

  toPayInitResponse(
    order: MembershipOrderEntity,
    paymentOrder: PaymentOrderEntity,
    action: ChannelAction
  ) {
    return {
      paymentInitStatus: paymentOrder.status,
      membershipOrderId: order.id,
      paymentReferenceId: paymentOrder.merchantOrderNo,
      channelActionType: action.channelActionType,
      channelPayload: action.channelPayload,
      callbackAwaiting: action.callbackAwaiting,
      expiresAt: paymentOrder.expiresAt?.toISOString() ?? order.orderExpiresAt?.toISOString() ?? null,
      updatedAt: paymentOrder.updatedAt?.toISOString() ?? new Date().toISOString()
    };
  }

  toResultResponse(order: MembershipOrderEntity, paymentOrder: PaymentOrderEntity | null) {
    return {
      membershipOrderId: order.id,
      organizationId: order.organizationId,
      orderStatus: order.orderStatus,
      paymentStatus: order.paymentStatus,
      entitlementStatus: order.entitlementStatus,
      skuSnapshot: this.toSkuSnapshot(order),
      amountSummary: {
        payableAmount: Number(order.payableAmount),
        currency: order.currency
      },
      channelSummary: {
        payChannel: this.toCandidateChannel(paymentOrder?.paymentChannel ?? null),
        paymentReferenceId: paymentOrder?.merchantOrderNo ?? null,
        callbackAwaiting:
          paymentOrder ? ['created', 'pending_user_confirm'].includes(paymentOrder.status) : false
      },
      effectiveAt: order.effectiveAt?.toISOString() ?? null,
      expiresAt: order.expiresAt?.toISOString() ?? null,
      failureReasonCode: order.failureReasonCode || null,
      updatedAt: order.updatedAt?.toISOString() ?? new Date().toISOString()
    };
  }

  private toSkuSnapshot(order: MembershipOrderEntity) {
    const tier = getTierSpec(order.membershipTier);
    return {
      skuCode: order.skuCode,
      skuName: order.skuName,
      membershipTier: order.membershipTier,
      durationMonths: order.durationMonths,
      serviceFeeDiscountSummary: tier?.serviceFeeDiscountSummary ?? null
    };
  }

  private toCandidateChannel(channel: string | null) {
    if (channel === 'alipay') {
      return 'alipay_candidate';
    }
    if (channel === 'wechat') {
      return 'wechat_candidate';
    }
    return null;
  }
}

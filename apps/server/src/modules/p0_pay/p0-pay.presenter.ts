import { Injectable } from '@nestjs/common';
import { ContractConfirmationEntity } from './entities/contract-confirmation.entity';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { P0_PAY_ACCOUNT_BINDING_POLICY } from './p0-pay.state';

type ChannelAction = {
  channelActionType: 'sdk_payload' | 'web_redirect' | 'qr_code' | 'unavailable';
  channelPayload: Record<string, unknown> | null;
  callbackAwaiting: boolean;
};

@Injectable()
export class P0PayPresenter {
  toServiceFeeAuthorizationResponse(
    authorization: PlatformServiceFeeAuthorizationEntity,
    order: PaymentOrderEntity | null
  ) {
    const feeSnapshot = this.toAuthorizationFeeSnapshot(authorization);
    return {
      authorizationId: authorization.id,
      authorizationStatus: authorization.status,
      quotedAmount: authorization.quotedAmount,
      estimatedFeeAmount: authorization.estimatedFeeAmount,
      currency: 'CNY',
      ...feeSnapshot,
      authorization: {
        authorizationId: authorization.id,
        taskId: authorization.taskId,
        bidId: authorization.bidId,
        factoryOrganizationId: authorization.factoryOrganizationId,
        publisherOrganizationId: authorization.publisherOrganizationId,
        quotedAmount: authorization.quotedAmount,
        estimatedFeeAmount: authorization.estimatedFeeAmount,
        ...feeSnapshot,
        paymentChannel: authorization.paymentChannel,
        paymentOrderId: authorization.paymentOrderId,
        authorizationOrderId: authorization.authorizationOrderId,
        status: authorization.status,
        ruleVersion: authorization.ruleVersion,
        ruleSnapshotHash: authorization.ruleSnapshotHash,
        agreedAt: authorization.agreedAt,
        createdAt: authorization.createdAt,
        updatedAt: authorization.updatedAt
      },
      channelCandidates: ['alipay_candidate', 'wechat_candidate', 'other_candidate'],
      paymentOrder: order
        ? {
            paymentOrderId: order.id,
            businessType: order.businessType,
            businessId: order.businessId,
            merchantOrderNo: order.merchantOrderNo,
            channelOrderId: order.channelOrderId,
            paymentChannel: order.paymentChannel,
            orderRole: order.orderRole,
            status: order.status,
            amount: order.amount,
            currency: order.currency,
            createdAt: order.createdAt,
            updatedAt: order.updatedAt
          }
        : null,
      paymentHandoff: {
        mode: 'order_level_authorization',
        accountBinding: P0_PAY_ACCOUNT_BINDING_POLICY,
        serverTruth: 'payment_order'
      }
    };
  }

  toAuthorizeInitResponse(
    authorization: PlatformServiceFeeAuthorizationEntity,
    order: PaymentOrderEntity,
    action: ChannelAction = {
      channelActionType: 'unavailable',
      channelPayload: null,
      callbackAwaiting: true
    }
  ) {
    return {
      authorizationInitStatus: order.status,
      authorizationId: authorization.id,
      paymentReferenceId: order.merchantOrderNo,
      paymentOrderId: order.id,
      channelActionType: action.channelActionType,
      channelPayload: action.channelPayload,
      callbackAwaiting: action.callbackAwaiting,
      updatedAt: order.updatedAt,
      paymentOrder: {
        merchantOrderNo: order.merchantOrderNo,
        paymentChannel: order.paymentChannel,
        orderRole: order.orderRole,
        status: order.status,
        amount: order.amount,
        currency: order.currency
      },
      paymentHandoff: {
        mode: 'order_level_authorization',
        accountBinding: P0_PAY_ACCOUNT_BINDING_POLICY,
        serverTruth: 'payment_order'
      }
    };
  }

  toInquiryDepositResponse(deposit: InquiryQuoteDepositEntity, order: PaymentOrderEntity | null) {
    return {
      depositOrderId: deposit.id,
      depositStatus: deposit.status,
      amount: deposit.amount,
      currency: deposit.currency,
      channelCandidates: ['alipay_candidate', 'wechat_candidate', 'other_candidate'],
      refundStatus: this.resolveRefundStatus(deposit),
      deductionStatus: deposit.status === 'deducted' ? 'deducted' : 'not_deducted',
      deductionReason: deposit.deductionReason,
      channelSummary: order
        ? {
            paymentOrderId: order.id,
            merchantOrderNo: order.merchantOrderNo,
            paymentChannel: order.paymentChannel,
            status: order.status
          }
        : null,
      updatedAt: deposit.updatedAt
    };
  }

  toInquiryDepositPayInitResponse(deposit: InquiryQuoteDepositEntity, order: PaymentOrderEntity, action: ChannelAction) {
    return {
      paymentInitStatus: order.status,
      depositOrderId: deposit.id,
      paymentReferenceId: order.merchantOrderNo,
      paymentOrderId: order.id,
      channelActionType: action.channelActionType,
      channelPayload: action.channelPayload,
      callbackAwaiting: action.callbackAwaiting,
      updatedAt: order.updatedAt
    };
  }

  toContractConfirmationResponse(input: {
    confirmation: ContractConfirmationEntity;
    authorization: PlatformServiceFeeAuthorizationEntity | null;
    charge: PlatformServiceFeeChargeEntity | null;
  }) {
    return {
      contractConfirmationId: input.confirmation.id,
      contractStatus: input.confirmation.contractStatus,
      finalConfirmedAmount: input.confirmation.finalConfirmedAmount,
      platformServiceFeeFinalAmount: input.charge?.finalFeeAmount ?? input.authorization?.finalFeeAmount ?? null,
      platformServiceFeeStatus: input.charge?.chargeStatus ?? input.authorization?.status ?? 'not_required',
      platformServiceFeeCharge: input.charge ? this.toChargeFeeSnapshot(input.charge) : null,
      nextAction:
        input.confirmation.contractStatus === 'confirmed'
          ? 'enter_fulfillment'
          : 'wait_counterparty_confirmation',
      updatedAt: input.confirmation.updatedAt
    };
  }

  private toAuthorizationFeeSnapshot(authorization: PlatformServiceFeeAuthorizationEntity) {
    return {
      feeRate: authorization.feeRate,
      feeRateLabel: authorization.feeRateLabel || '默认费率 3.0%',
      feeRateSource: authorization.feeRateSource || 'legacy_fixed_default',
      membershipTierSnapshot: authorization.membershipTierSnapshot || 'none',
      feeRateRuleVersion: authorization.feeRateRuleVersion || authorization.ruleVersion,
      feeRateSnapshotHash: authorization.feeRateSnapshotHash || authorization.ruleSnapshotHash,
      feeCalculatedAt: authorization.feeCalculatedAt ?? authorization.agreedAt ?? authorization.createdAt
    };
  }

  private toChargeFeeSnapshot(charge: PlatformServiceFeeChargeEntity) {
    return {
      finalConfirmedAmount: charge.finalConfirmedAmount,
      feeRate: charge.feeRate,
      feeRateLabel: charge.feeRateLabel || '默认费率 3.0%',
      feeRateSource: charge.feeRateSource || 'legacy_fixed_default',
      membershipTierSnapshot: charge.membershipTierSnapshot || 'none',
      feeRateRuleVersion: charge.feeRateRuleVersion,
      feeRateSnapshotHash: charge.feeRateSnapshotHash,
      feeCalculatedAt: charge.feeCalculatedAt ?? charge.createdAt,
      finalFeeAmount: charge.finalFeeAmount,
      currency: 'CNY',
      chargeStatus: charge.chargeStatus,
      chargedAt: charge.chargedAt,
      updatedAt: charge.updatedAt
    };
  }

  private resolveRefundStatus(deposit: InquiryQuoteDepositEntity) {
    if (deposit.status === 'refunded') {
      return 'refunded';
    }
    if (deposit.status === 'refund_pending') {
      return 'refund_pending';
    }
    return 'not_refunded';
  }
}

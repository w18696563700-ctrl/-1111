import { Injectable } from '@nestjs/common';
import { createHash } from 'crypto';
import { MembershipQueryService } from '../membership/membership.query.service';
import {
  calculatePlatformServiceFeeAmount,
  normalizeFeeRate,
  normalizePositiveMoney
} from './p0-pay-calculator';
import { p0PayInvalid, p0PayResourceUnavailable } from './p0-pay.errors';
import {
  P0PayFeeRateSource,
  P0PayMembershipTierSnapshot
} from './p0-pay.types';
import { PLATFORM_SERVICE_FEE_CAP_AMOUNT } from './p0-pay.state';

export const P0_PAY_MEMBERSHIP_FEE_RULE_VERSION = 'p0_pay_membership_service_fee_v1';

export type P0PayFeeRateSnapshot = {
  feeRate: string;
  feeRateLabel: string;
  feeRateSource: P0PayFeeRateSource;
  membershipTierSnapshot: P0PayMembershipTierSnapshot;
  feeRateRuleVersion: string;
  feeRateSnapshotHash: string;
  feeCalculatedAt: Date;
};

export type P0PayServiceFeeRequirement = P0PayFeeRateSnapshot & {
  quotedAmount: string;
  estimatedFeeAmount: string;
  baseFeeAmount: string;
  membershipDiscountRate: string;
  capAmount: string;
  authorizationQuotaAmount: string;
  quotaAmount: string;
  currency: 'CNY';
  authorizationRequired: boolean;
  authorizationStatus: 'pending_freeze';
};

export type PlatformPricingServiceFeeCalculation = {
  finalConfirmedAmount: string;
  baseFeeAmount: string;
  membershipDiscountRate: string;
  capAmount: string;
  finalFeeAmount: string;
  releasedRemainderAmount: string;
};

type TierPolicy = {
  feeRate: string;
  feeRateLabel: string;
  feeRateSource: P0PayFeeRateSource;
  membershipTierSnapshot: P0PayMembershipTierSnapshot;
};

const TIER_POLICIES: Record<string, TierPolicy> = {
  none: {
    feeRate: '0.030000',
    feeRateLabel: '基础平台定价规则',
    feeRateSource: 'fixed_default',
    membershipTierSnapshot: 'none'
  },
  free_certified: {
    feeRate: '0.030000',
    feeRateLabel: '免费认证版无会员折扣',
    feeRateSource: 'fixed_default',
    membershipTierSnapshot: 'free_certified'
  },
  standard: {
    feeRate: '0.030000',
    feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard'
  },
  professional: {
    feeRate: '0.030000',
    feeRateLabel: '专业会员 8折（作用于 baseFeeAmount）',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'professional'
  }
};

@Injectable()
export class P0PayServiceFeeRatePolicy {
  constructor(private readonly membershipQuery: MembershipQueryService) {}

  async buildRequirement(input: {
    factoryOrganizationId: string;
    quotedAmount: string | number;
    calculatedAt?: Date;
  }): Promise<P0PayServiceFeeRequirement> {
    const quotedAmount = normalizePositiveMoney(input.quotedAmount, 'quotedAmount');
    const snapshot = await this.buildSnapshot({
      factoryOrganizationId: input.factoryOrganizationId,
      calculatedAt: input.calculatedAt
    });
    const feeCalculation = this.calculateDealServiceFee({
      finalConfirmedAmount: quotedAmount,
      membershipTierSnapshot: snapshot.membershipTierSnapshot,
      authorizationQuotaAmount: PLATFORM_SERVICE_FEE_CAP_AMOUNT
    });
    return {
      ...snapshot,
      quotedAmount,
      estimatedFeeAmount: feeCalculation.finalFeeAmount,
      baseFeeAmount: feeCalculation.baseFeeAmount,
      membershipDiscountRate: feeCalculation.membershipDiscountRate,
      capAmount: feeCalculation.capAmount,
      authorizationQuotaAmount: PLATFORM_SERVICE_FEE_CAP_AMOUNT,
      quotaAmount: PLATFORM_SERVICE_FEE_CAP_AMOUNT,
      currency: 'CNY',
      authorizationRequired: true,
      authorizationStatus: 'pending_freeze'
    };
  }

  calculateFinalFeeAmount(finalConfirmedAmount: string | number, snapshot: Pick<P0PayFeeRateSnapshot, 'feeRate'>) {
    return calculatePlatformServiceFeeAmount(finalConfirmedAmount, snapshot.feeRate);
  }

  calculateDealServiceFee(input: {
    finalConfirmedAmount: string | number;
    membershipTierSnapshot: P0PayMembershipTierSnapshot;
    authorizationQuotaAmount?: string | number | null;
  }): PlatformPricingServiceFeeCalculation {
    const finalConfirmedAmount = normalizePositiveMoney(input.finalConfirmedAmount, 'finalConfirmedAmount');
    const baseFeeAmount = this.calculateBaseServiceFeeAmount(finalConfirmedAmount);
    const discount = this.resolveMembershipDiscount(input.membershipTierSnapshot);
    const discountedFee = this.multiplyMoney(baseFeeAmount, discount.discountRate);
    const finalFeeAmount = this.minMoney(discountedFee, discount.capAmount);
    const quotaAmount = normalizePositiveMoney(
      input.authorizationQuotaAmount ?? PLATFORM_SERVICE_FEE_CAP_AMOUNT,
      'authorizationQuotaAmount'
    );
    return {
      finalConfirmedAmount,
      baseFeeAmount,
      membershipDiscountRate: discount.discountRate,
      capAmount: discount.capAmount,
      finalFeeAmount,
      releasedRemainderAmount: this.maxMoney(this.subtractMoney(quotaAmount, finalFeeAmount), '0.00')
    };
  }

  calculateBaseServiceFeeAmount(finalConfirmedAmount: string | number) {
    const amount = Number(normalizePositiveMoney(finalConfirmedAmount, 'finalConfirmedAmount'));
    let fee = 200;
    if (amount > 10000) {
      fee += Math.min(amount - 10000, 20000) * 0.02;
    }
    if (amount > 30000) {
      fee += Math.min(amount - 30000, 70000) * 0.015;
    }
    if (amount > 100000) {
      fee += (amount - 100000) * 0.01;
    }
    return this.minMoney(fee.toFixed(2), PLATFORM_SERVICE_FEE_CAP_AMOUNT);
  }

  private async buildSnapshot(input: {
    factoryOrganizationId: string;
    calculatedAt?: Date;
  }): Promise<P0PayFeeRateSnapshot> {
    const feeCalculatedAt = input.calculatedAt ?? new Date();
    const tierCode = await this.readTierCode(input.factoryOrganizationId, feeCalculatedAt);
    const policy = this.resolveTierPolicy(tierCode);
    const snapshotBase = {
      feeRateRuleVersion: P0_PAY_MEMBERSHIP_FEE_RULE_VERSION,
      factoryOrganizationId: input.factoryOrganizationId,
      feeRate: normalizeFeeRate(policy.feeRate),
      feeRateLabel: policy.feeRateLabel,
      feeRateSource: policy.feeRateSource,
      membershipTierSnapshot: policy.membershipTierSnapshot,
      feeCalculatedAt: feeCalculatedAt.toISOString()
    };
    return {
      feeRate: snapshotBase.feeRate,
      feeRateLabel: snapshotBase.feeRateLabel,
      feeRateSource: snapshotBase.feeRateSource,
      membershipTierSnapshot: snapshotBase.membershipTierSnapshot,
      feeRateRuleVersion: snapshotBase.feeRateRuleVersion,
      feeRateSnapshotHash: this.hashSnapshot(snapshotBase),
      feeCalculatedAt
    };
  }

  private async readTierCode(factoryOrganizationId: string, at: Date) {
    try {
      const snapshot = await this.membershipQuery.getPaidMembershipTierSnapshotForOrganization(factoryOrganizationId, at);
      return snapshot.tierCode ?? 'none';
    } catch (error) {
      throw p0PayResourceUnavailable('Current paid membership tier is unavailable for P0-Pay fee calculation.');
    }
  }

  private resolveTierPolicy(tierCode: string) {
    const policy = TIER_POLICIES[tierCode];
    if (!policy) {
      throw p0PayInvalid('Current paid membership tier is not supported for P0-Pay fee calculation.');
    }
    return policy;
  }

  private hashSnapshot(value: Record<string, unknown>) {
    return createHash('sha256').update(JSON.stringify(value), 'utf8').digest('hex');
  }

  private resolveMembershipDiscount(tier: P0PayMembershipTierSnapshot) {
    if (tier === 'standard') {
      return { discountRate: '0.9000', capAmount: '3600.00' };
    }
    if (tier === 'professional') {
      return { discountRate: '0.8000', capAmount: '3200.00' };
    }
    return { discountRate: '1.0000', capAmount: PLATFORM_SERVICE_FEE_CAP_AMOUNT };
  }

  private multiplyMoney(amount: string, rate: string) {
    return (Number(amount) * Number(rate)).toFixed(2);
  }

  private subtractMoney(left: string, right: string) {
    return (Number(left) - Number(right)).toFixed(2);
  }

  private minMoney(left: string, right: string) {
    return Math.min(Number(left), Number(right)).toFixed(2);
  }

  private maxMoney(left: string, right: string) {
    return Math.max(Number(left), Number(right)).toFixed(2);
  }
}

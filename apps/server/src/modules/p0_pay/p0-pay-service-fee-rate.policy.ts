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
  currency: 'CNY';
  authorizationRequired: boolean;
  authorizationStatus: 'pending_authorization';
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
    feeRateLabel: '默认费率 3.0%',
    feeRateSource: 'fixed_default',
    membershipTierSnapshot: 'none'
  },
  free_certified: {
    feeRate: '0.030000',
    feeRateLabel: '免费认证企业 3.0%',
    feeRateSource: 'fixed_default',
    membershipTierSnapshot: 'free_certified'
  },
  standard: {
    feeRate: '0.025000',
    feeRateLabel: '标准会员 2.5%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard'
  },
  professional: {
    feeRate: '0.020000',
    feeRateLabel: '专业会员 2.0%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'professional'
  },
  ka: {
    feeRate: '0.015000',
    feeRateLabel: 'KA 会员 1.5%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'ka'
  },
  flagship: {
    feeRate: '0.015000',
    feeRateLabel: '旗舰会员 1.5%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'flagship'
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
    return {
      ...snapshot,
      quotedAmount,
      estimatedFeeAmount: calculatePlatformServiceFeeAmount(quotedAmount, snapshot.feeRate),
      currency: 'CNY',
      authorizationRequired: true,
      authorizationStatus: 'pending_authorization'
    };
  }

  calculateFinalFeeAmount(finalConfirmedAmount: string | number, snapshot: Pick<P0PayFeeRateSnapshot, 'feeRate'>) {
    return calculatePlatformServiceFeeAmount(finalConfirmedAmount, snapshot.feeRate);
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
}

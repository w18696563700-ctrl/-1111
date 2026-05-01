import { getTierSpec, MembershipTierCode } from './membership.catalog';

export type MembershipPurchaseSku = {
  skuCode: string;
  skuName: string;
  membershipTier: Extract<MembershipTierCode, 'standard' | 'professional'>;
  durationMonths: number;
  priceAmount: string;
  currency: 'CNY';
  status: 'available' | 'unavailable' | 'reserved';
  isRenewable: boolean;
  isUpgradable: boolean;
};

export const MEMBERSHIP_PURCHASE_SKUS: MembershipPurchaseSku[] = [
  {
    skuCode: 'membership_standard_year_v1',
    skuName: '标准会员年付版',
    membershipTier: 'standard',
    durationMonths: 12,
    priceAmount: '2599.00',
    currency: 'CNY',
    status: 'available',
    isRenewable: false,
    isUpgradable: true
  },
  {
    skuCode: 'membership_professional_year_v1',
    skuName: '专业会员年付版',
    membershipTier: 'professional',
    durationMonths: 12,
    priceAmount: '4599.00',
    currency: 'CNY',
    status: 'available',
    isRenewable: false,
    isUpgradable: false
  }
];

export const MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES = [
  'alipay_candidate',
  'wechat_candidate'
] as const;

export type MembershipPurchaseChannelCandidate =
  (typeof MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES)[number];

export function findMembershipPurchaseSku(skuCode: string) {
  return MEMBERSHIP_PURCHASE_SKUS.find((sku) => sku.skuCode === skuCode) ?? null;
}

export function toPurchaseOffer(sku: MembershipPurchaseSku) {
  const tier = getTierSpec(sku.membershipTier);
  return {
    skuCode: sku.skuCode,
    skuName: sku.skuName,
    membershipTier: sku.membershipTier,
    durationMonths: sku.durationMonths,
    priceAmount: Number(sku.priceAmount),
    currency: sku.currency,
    entitlementSummary: tier?.entitlementsSummary ?? [],
    serviceFeeDiscountSummary: tier?.serviceFeeDiscountSummary ?? null,
    isRenewable: sku.isRenewable,
    isUpgradable: sku.isUpgradable,
    status: sku.status
  };
}

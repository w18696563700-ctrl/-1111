export type MembershipTierCode = 'free_certified' | 'standard' | 'professional';

type TierSpec = {
  tier: MembershipTierCode;
  title: string;
  rateBand: string | null;
  entitlementsSummary: string[];
  explanationHighlights: string[];
  candidateDisplayPrice: string | null;
  candidateDisplayRateBand: string | null;
};

type UpgradeGuideSpec = {
  currentTier: MembershipTierCode | null;
  availableTiers: MembershipTierCode[];
  upgradeHighlights: string[];
};

type QuotaSpec = {
  quotaType: string;
  summaryLabel: string;
  defaultRefreshRule: string | null;
};

const TIER_ORDER: MembershipTierCode[] = ['free_certified', 'standard', 'professional'];

const TIER_SPECS: Record<MembershipTierCode, TierSpec> = {
  free_certified: {
    tier: 'free_certified',
    title: '免费认证版',
    rateBand: '当前规划费率档 3.0%',
    entitlementsSummary: ['基础曝光', '基础排序', '默认费率档位'],
    explanationHighlights: ['基础发布资格前提中的会员维度', '基础竞标资格前提中的会员维度', '基础曝光与基础排序'],
    candidateDisplayPrice: null,
    candidateDisplayRateBand: '3.0%'
  },
  standard: {
    tier: 'standard',
    title: '标准会员',
    rateBand: '当前规划费率档 2.5%',
    entitlementsSummary: ['费率减免', '更高排序', '更多曝光位'],
    explanationHighlights: ['更高排序', '更多商机提醒', '更高额度档位'],
    candidateDisplayPrice: '候选年费 2999 / 年',
    candidateDisplayRateBand: '2.5%'
  },
  professional: {
    tier: 'professional',
    title: '专业会员',
    rateBand: '当前规划费率档 2.0%',
    entitlementsSummary: ['更低费率档位', '人工撮合优先', '客服优先'],
    explanationHighlights: ['更高曝光', '更多席位与经营辅助能力预留', '客服优先'],
    candidateDisplayPrice: '候选年费 6999 / 年',
    candidateDisplayRateBand: '2.0%'
  }
};

const QUOTA_SPECS: Record<string, QuotaSpec> = {
  view_quota: {
    quotaType: 'view_quota',
    summaryLabel: '查看额度',
    defaultRefreshRule: '自然日刷新'
  },
  opportunity_alert_quota: {
    quotaType: 'opportunity_alert_quota',
    summaryLabel: '商机提醒额度',
    defaultRefreshRule: '自然日刷新'
  },
  priority_exposure_quota: {
    quotaType: 'priority_exposure_quota',
    summaryLabel: '优先曝光额度',
    defaultRefreshRule: '按月度周期'
  },
  manual_matchmaking_quota: {
    quotaType: 'manual_matchmaking_quota',
    summaryLabel: '人工撮合次数额度',
    defaultRefreshRule: '按会员周期'
  },
  member_seat_quota: {
    quotaType: 'member_seat_quota',
    summaryLabel: '成员席位额度',
    defaultRefreshRule: '按会员周期'
  }
};

export function getTierSpec(tierCode: string | null) {
  if (!tierCode || !(tierCode in TIER_SPECS)) {
    return null;
  }
  return TIER_SPECS[tierCode as MembershipTierCode];
}

export function listExplanationTiers() {
  return TIER_ORDER.map((tier) => {
    const spec = TIER_SPECS[tier];
    return {
      tier: spec.tier,
      title: spec.title,
      highlights: spec.explanationHighlights
    };
  });
}

export function listEntitlementNotes() {
  return [
    '当前权益摘要只承接会员等级、费率档位、权益摘要、剩余额度摘要与刷新规则。',
    '交易资格最终仍取决于企业认证、组织 scope 与后续交易保障规则。',
    '付费会员不自动等价于全部交易级信息完全开放。'
  ];
}

export function listQuotaNotes() {
  return [
    '查看额度、商机提醒额度、优先曝光额度、人工撮合次数额度、成员席位额度只承接最小摘要。',
    '日额度按自然日刷新，月度权益按月度周期刷新，年度权益按会员周期刷新。',
    '当前不做复杂额度结转，也不承接 billing、payment 或 guarantee 金额。'
  ];
}

export function getQuotaSpec(quotaType: string) {
  return QUOTA_SPECS[quotaType] ?? null;
}

export function listAvailableTierItems(currentTier: string | null) {
  const currentIndex = TIER_ORDER.indexOf((currentTier ?? '') as MembershipTierCode);
  const tierCodes =
    currentIndex >= 0
      ? TIER_ORDER.slice(currentIndex + 1)
      : (['standard', 'professional'] as MembershipTierCode[]);

  return tierCodes.map((tier) => {
    const spec = TIER_SPECS[tier];
    return {
      tier: spec.tier,
      title: spec.title,
      candidateDisplayPrice: spec.candidateDisplayPrice,
      candidateDisplayRateBand: spec.candidateDisplayRateBand
    };
  });
}

export function buildUpgradeGuide(currentTier: string | null): UpgradeGuideSpec {
  if (currentTier === 'professional') {
    return {
      currentTier: 'professional',
      availableTiers: [],
      upgradeHighlights: ['当前已处于 V2.0 首轮开放的最高会员档位。']
    };
  }
  if (currentTier === 'standard') {
    return {
      currentTier: 'standard',
      availableTiers: ['professional'],
      upgradeHighlights: ['可升级到专业会员，获取更低费率档、人工撮合优先与客服优先。']
    };
  }
  return {
    currentTier: currentTier === 'free_certified' ? 'free_certified' : null,
    availableTiers: ['standard', 'professional'],
    upgradeHighlights: ['可升级到标准会员或专业会员，获取更低费率档和更高曝光位。']
  };
}

export function getCommercialDisclosure() {
  return '当前展示的价格与费率为候选商业参数，仅用于会员档位说明，不构成支付、下单或最终上线商业参数。';
}

export function buildQuotaSummaryLine(input: {
  quotaType: string;
  currentValue: number | null;
  refreshRule: string | null;
}) {
  const quota = getQuotaSpec(input.quotaType);
  const label = quota?.summaryLabel ?? input.quotaType;
  const refreshRule = input.refreshRule ?? quota?.defaultRefreshRule;
  const value = input.currentValue === null ? '待初始化' : String(input.currentValue);
  return refreshRule ? `${label}：${value}（${refreshRule}）` : `${label}：${value}`;
}

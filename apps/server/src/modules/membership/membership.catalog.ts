export type MembershipTierCode = "free_certified" | "standard" | "professional";

type TierSpec = {
  tier: MembershipTierCode;
  title: string;
  rateBand: string | null;
  serviceFeeDiscountSummary: string | null;
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

const TIER_ORDER: MembershipTierCode[] = [
  "free_certified",
  "standard",
  "professional",
];

const TIER_SPECS: Record<MembershipTierCode, TierSpec> = {
  free_certified: {
    tier: "free_certified",
    title: "免费认证版",
    rateBand: null,
    serviceFeeDiscountSummary: "免费认证版无会员折扣，按平台定价母规则计算。",
    entitlementsSummary: ["基础曝光", "基础排序", "无会员服务费折扣"],
    explanationHighlights: [
      "基础发布资格前提中的会员维度",
      "基础竞标资格前提中的会员维度",
      "基础曝光与基础排序",
    ],
    candidateDisplayPrice: null,
    candidateDisplayRateBand: null,
  },
  standard: {
    tier: "standard",
    title: "标准会员",
    rateBand: null,
    serviceFeeDiscountSummary:
      "平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。",
    entitlementsSummary: ["平台服务费 9 折", "更高排序", "更多曝光位"],
    explanationHighlights: ["平台服务费 9 折", "更多商机提醒", "更高额度档位"],
    candidateDisplayPrice: null,
    candidateDisplayRateBand: null,
  },
  professional: {
    tier: "professional",
    title: "专业会员",
    rateBand: null,
    serviceFeeDiscountSummary:
      "平台服务费 8 折，作用于 baseFeeAmount，单项目封顶 3200。",
    entitlementsSummary: ["平台服务费 8 折", "人工撮合优先", "客服优先"],
    explanationHighlights: [
      "平台服务费 8 折",
      "更多席位与经营辅助能力预留",
      "客服优先",
    ],
    candidateDisplayPrice: null,
    candidateDisplayRateBand: null,
  },
};

const QUOTA_SPECS: Record<string, QuotaSpec> = {
  view_quota: {
    quotaType: "view_quota",
    summaryLabel: "查看额度",
    defaultRefreshRule: "自然日刷新",
  },
  opportunity_alert_quota: {
    quotaType: "opportunity_alert_quota",
    summaryLabel: "商机提醒额度",
    defaultRefreshRule: "自然日刷新",
  },
  priority_exposure_quota: {
    quotaType: "priority_exposure_quota",
    summaryLabel: "优先曝光额度",
    defaultRefreshRule: "按月度周期",
  },
  manual_matchmaking_quota: {
    quotaType: "manual_matchmaking_quota",
    summaryLabel: "人工撮合次数额度",
    defaultRefreshRule: "按会员周期",
  },
  member_seat_quota: {
    quotaType: "member_seat_quota",
    summaryLabel: "成员席位额度",
    defaultRefreshRule: "按会员周期",
  },
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
      highlights: spec.explanationHighlights,
    };
  });
}

export function listEntitlementNotes() {
  return [
    "当前权益摘要只承接会员等级、服务费优惠说明、权益摘要、剩余额度摘要与刷新规则。",
    "交易资格最终仍取决于企业认证、组织 scope 与后续交易保障规则。",
    "付费会员不自动等价于全部交易级信息完全开放。",
  ];
}

export function listQuotaNotes() {
  return [
    "查看额度、商机提醒额度、优先曝光额度、人工撮合次数额度、成员席位额度只承接最小摘要。",
    "日额度按自然日刷新，月度权益按月度周期刷新，年度权益按会员周期刷新。",
    "当前不做复杂额度结转，也不承接 billing、payment 或 guarantee 金额。",
  ];
}

export function getQuotaSpec(quotaType: string) {
  return QUOTA_SPECS[quotaType] ?? null;
}

export function listAvailableTierItems(currentTier: string | null) {
  const currentIndex = TIER_ORDER.indexOf(
    (currentTier ?? "") as MembershipTierCode,
  );
  const tierCodes =
    currentIndex >= 0
      ? TIER_ORDER.slice(currentIndex + 1)
      : (["standard", "professional"] as MembershipTierCode[]);

  return tierCodes.map((tier) => {
    const spec = TIER_SPECS[tier];
    return {
      tier: spec.tier,
      title: spec.title,
      serviceFeeDiscountSummary: spec.serviceFeeDiscountSummary,
      candidateDisplayPrice: spec.candidateDisplayPrice,
      candidateDisplayRateBand: spec.candidateDisplayRateBand,
    };
  });
}

export function buildUpgradeGuide(
  currentTier: string | null,
): UpgradeGuideSpec {
  if (currentTier === "professional") {
    return {
      currentTier: "professional",
      availableTiers: [],
      upgradeHighlights: ["当前已处于 V2.0 首轮开放的最高会员档位。"],
    };
  }
  if (currentTier === "standard") {
    return {
      currentTier: "standard",
      availableTiers: ["professional"],
      upgradeHighlights: [
        "可升级到专业会员，获取平台服务费 8 折、人工撮合优先与客服优先。",
      ],
    };
  }
  return {
    currentTier: currentTier === "free_certified" ? "free_certified" : null,
    availableTiers: ["standard", "professional"],
    upgradeHighlights: [
      "可升级到标准会员或专业会员，获取平台服务费 9 折或 8 折及更高曝光位。",
    ],
  };
}

export function getCommercialDisclosure() {
  return "升级引导页只展示档位与权益说明；会员直购由 purchase-offers 承接，支付成功后以 Server 回调写入权益为准。";
}

export function buildQuotaSummaryLine(input: {
  quotaType: string;
  currentValue: number | null;
  refreshRule: string | null;
}) {
  const quota = getQuotaSpec(input.quotaType);
  const label = quota?.summaryLabel ?? input.quotaType;
  const refreshRule = input.refreshRule ?? quota?.defaultRefreshRule;
  const value =
    input.currentValue === null ? "待初始化" : String(input.currentValue);
  return refreshRule
    ? `${label}：${value}（${refreshRule}）`
    : `${label}：${value}`;
}

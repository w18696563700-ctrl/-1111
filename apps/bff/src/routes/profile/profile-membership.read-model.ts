export type MembershipCurrentViewModel = {
  organizationId: string | null;
  paidMembershipTier: string | null;
  rateBand: string | null;
  serviceFeeDiscountSummary: string | null;
  entitlementsSummary: string[];
  quotaSummary: string[];
  effectiveAt: string | null;
  expiresAt: string | null;
  nextRefreshAt: string | null;
};

export type MembershipExplanationTierItemViewModel = {
  tier: string;
  title: string;
  highlights?: string[];
};

export type MembershipExplanationViewModel = {
  tiers: MembershipExplanationTierItemViewModel[];
  entitlementNotes: string[];
  quotaNotes: string[];
  disclaimer: string;
};

export type MembershipQuotaItemViewModel = {
  quotaType: string;
  summary: string;
  currentValue: number | null;
  refreshRule: string | null;
};

export type MembershipQuotaViewModel = {
  items: MembershipQuotaItemViewModel[];
  nextRefreshAt: string | null;
};

export type MembershipUpgradeGuideTierItemViewModel = {
  tier: string;
  title: string;
  serviceFeeDiscountSummary: string | null;
  candidateDisplayPrice: string | null;
  candidateDisplayRateBand: string | null;
};

export type MembershipUpgradeGuideViewModel = {
  currentTier: string | null;
  availableTiers: MembershipUpgradeGuideTierItemViewModel[];
  upgradeHighlights: string[];
  commercialDisclosure: string;
};

export type PaidMembershipShellSummaryViewModel = {
  paidMembershipTier: string | null;
  paidMembershipEntitlementsSummary: string[];
  paidMembershipQuotaSummary: string[];
  paidMembershipNextRefreshAt: string | null;
};

export function readMembershipCurrentViewModel(
  result: Record<string, unknown>,
): MembershipCurrentViewModel {
  requireKeys(result, [
    "organizationId",
    "paidMembershipTier",
    "entitlementsSummary",
    "quotaSummary",
  ]);

  return {
    organizationId: readNullableString(result.organizationId),
    paidMembershipTier: readNullableString(result.paidMembershipTier),
    rateBand: readNullableString(result.rateBand),
    serviceFeeDiscountSummary: readNullableString(
      result.serviceFeeDiscountSummary,
    ),
    entitlementsSummary: readStringArray(
      result.entitlementsSummary,
      "Membership current response contains an invalid entitlementsSummary.",
    ),
    quotaSummary: readStringArray(
      result.quotaSummary,
      "Membership current response contains an invalid quotaSummary.",
    ),
    effectiveAt: readNullableString(result.effectiveAt),
    expiresAt: readNullableString(result.expiresAt),
    nextRefreshAt: readNullableString(result.nextRefreshAt),
  };
}

export function readMembershipExplanationViewModel(
  result: Record<string, unknown>,
): MembershipExplanationViewModel {
  requireKeys(result, [
    "tiers",
    "entitlementNotes",
    "quotaNotes",
    "disclaimer",
  ]);

  return {
    tiers: readObjectArray(
      result.tiers,
      "Membership explanation response contains an invalid tiers array.",
    ).map((item) => {
      requireKeys(item, ["tier", "title"]);
      return {
        tier: readRequiredString(
          item.tier,
          "Membership explanation response contains an invalid tier.",
        ),
        title: readRequiredString(
          item.title,
          "Membership explanation response contains an invalid title.",
        ),
        ...(Object.prototype.hasOwnProperty.call(item, "highlights")
          ? {
              highlights: readStringArray(
                item.highlights,
                "Membership explanation response contains invalid highlights.",
              ),
            }
          : {}),
      };
    }),
    entitlementNotes: readStringArray(
      result.entitlementNotes,
      "Membership explanation response contains an invalid entitlementNotes array.",
    ),
    quotaNotes: readStringArray(
      result.quotaNotes,
      "Membership explanation response contains an invalid quotaNotes array.",
    ),
    disclaimer: readRequiredString(
      result.disclaimer,
      "Membership explanation response is missing disclaimer.",
    ),
  };
}

export function readMembershipQuotaViewModel(
  result: Record<string, unknown>,
): MembershipQuotaViewModel {
  requireKeys(result, ["items"]);

  return {
    items: readObjectArray(
      result.items,
      "Membership quota response contains an invalid items array.",
    ).map((item) => {
      requireKeys(item, ["quotaType", "summary"]);
      return {
        quotaType: readRequiredString(
          item.quotaType,
          "Membership quota response contains an invalid quotaType.",
        ),
        summary: readRequiredString(
          item.summary,
          "Membership quota response contains an invalid summary.",
        ),
        currentValue: readNullableInteger(item.currentValue),
        refreshRule: readNullableString(item.refreshRule),
      };
    }),
    nextRefreshAt: readNullableString(result.nextRefreshAt),
  };
}

export function readMembershipUpgradeGuideViewModel(
  result: Record<string, unknown>,
): MembershipUpgradeGuideViewModel {
  requireKeys(result, [
    "currentTier",
    "availableTiers",
    "upgradeHighlights",
    "commercialDisclosure",
  ]);

  return {
    currentTier: readNullableString(result.currentTier),
    availableTiers: readObjectArray(
      result.availableTiers,
      "Membership upgrade guide response contains an invalid availableTiers array.",
    ).map((item) => {
      requireKeys(item, ["tier", "title"]);
      return {
        tier: readRequiredString(
          item.tier,
          "Membership upgrade guide response contains an invalid tier.",
        ),
        title: readRequiredString(
          item.title,
          "Membership upgrade guide response contains an invalid title.",
        ),
        serviceFeeDiscountSummary: readNullableString(
          item.serviceFeeDiscountSummary,
        ),
        candidateDisplayPrice: readNullableString(item.candidateDisplayPrice),
        candidateDisplayRateBand: readNullableString(
          item.candidateDisplayRateBand,
        ),
      };
    }),
    upgradeHighlights: readStringArray(
      result.upgradeHighlights,
      "Membership upgrade guide response contains an invalid upgradeHighlights array.",
    ),
    commercialDisclosure: readRequiredString(
      result.commercialDisclosure,
      "Membership upgrade guide response is missing commercialDisclosure.",
    ),
  };
}

export function readPaidMembershipShellSummary(
  result: Record<string, unknown>,
  context: string,
): PaidMembershipShellSummaryViewModel {
  requireKeys(result, [
    "paidMembershipTier",
    "paidMembershipEntitlementsSummary",
    "paidMembershipQuotaSummary",
    "paidMembershipNextRefreshAt",
  ]);

  return {
    paidMembershipTier: readNullableString(result.paidMembershipTier),
    paidMembershipEntitlementsSummary: readStringArray(
      result.paidMembershipEntitlementsSummary,
      `${context} contains an invalid paidMembershipEntitlementsSummary.`,
    ),
    paidMembershipQuotaSummary: readStringArray(
      result.paidMembershipQuotaSummary,
      `${context} contains an invalid paidMembershipQuotaSummary.`,
    ),
    paidMembershipNextRefreshAt: readNullableString(
      result.paidMembershipNextRefreshAt,
    ),
  };
}

export function hasPaidMembershipShellSummary(result: Record<string, unknown>) {
  return [
    "paidMembershipTier",
    "paidMembershipEntitlementsSummary",
    "paidMembershipQuotaSummary",
    "paidMembershipNextRefreshAt",
  ].some((key) => Object.prototype.hasOwnProperty.call(result, key));
}

function requireKeys(source: Record<string, unknown>, keys: string[]) {
  if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
    return;
  }
  throw new Error("Membership response is missing required fields.");
}

function readRequiredString(value: unknown, message: string) {
  if (typeof value !== "string") {
    throw new Error(message);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(message);
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  return readRequiredString(value, "Expected a string value.");
}

function readStringArray(value: unknown, message: string) {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }
  return value.map((item) => readRequiredString(item, message));
}

function readObjectArray(value: unknown, message: string) {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }
  return value.map((item) => {
    if (item !== null && typeof item === "object" && !Array.isArray(item)) {
      return item as Record<string, unknown>;
    }
    throw new Error(message);
  });
}

function readNullableInteger(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  return typeof value === "number" && Number.isInteger(value) && value >= 0
    ? value
    : null;
}

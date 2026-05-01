import { Injectable } from "@nestjs/common";

@Injectable()
export class MembershipPresenter {
  toCurrent(input: {
    organizationId: string;
    paidMembershipTier: string | null;
    rateBand: string | null;
    serviceFeeDiscountSummary: string | null;
    entitlementsSummary: string[];
    quotaSummary: string[];
    effectiveAt: Date | null;
    expiresAt: Date | null;
    nextRefreshAt: Date | null;
  }) {
    return {
      organizationId: input.organizationId,
      paidMembershipTier: input.paidMembershipTier,
      rateBand: input.rateBand,
      serviceFeeDiscountSummary: input.serviceFeeDiscountSummary,
      entitlementsSummary: input.entitlementsSummary,
      quotaSummary: input.quotaSummary,
      effectiveAt: input.effectiveAt?.toISOString() ?? null,
      expiresAt: input.expiresAt?.toISOString() ?? null,
      nextRefreshAt: input.nextRefreshAt?.toISOString() ?? null,
    };
  }

  toExplanation(input: {
    tiers: Array<{
      tier: string;
      title: string;
      highlights: string[];
    }>;
    entitlementNotes: string[];
    quotaNotes: string[];
    disclaimer: string;
  }) {
    return input;
  }

  toQuota(input: {
    items: Array<{
      quotaType: string;
      summary: string;
      currentValue: number | null;
      refreshRule: string | null;
    }>;
    nextRefreshAt: Date | null;
  }) {
    return {
      items: input.items,
      nextRefreshAt: input.nextRefreshAt?.toISOString() ?? null,
    };
  }

  toUpgradeGuide(input: {
    currentTier: string | null;
    availableTiers: Array<{
      tier: string;
      title: string;
      serviceFeeDiscountSummary?: string | null;
      candidateDisplayPrice: string | null;
      candidateDisplayRateBand: string | null;
    }>;
    upgradeHighlights: string[];
    commercialDisclosure: string;
  }) {
    return input;
  }
}

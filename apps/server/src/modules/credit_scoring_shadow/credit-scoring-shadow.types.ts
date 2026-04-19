export type ShadowRatingValue = {
  orderId: string;
  ratingId: string;
  submittedAt: Date | null;
  scoreValue: number | null;
  scoreLabel: string | null;
};

export type ShadowAggregateSnapshot = {
  organizationId: string;
  aggregationMode: string;
  sampleStatus: 'insufficient' | 'ready';
  ratedCompletedOrderCount: number;
  verySatisfiedCount: number;
  satisfiedCount: number;
  passableCount: number;
  negativeCount: number;
  positiveRate: number;
  negativeRate: number;
  recentConsecutiveNegativeCount: number;
  last20RatedNegativeRate: number;
  baseScore: number;
  rawScore: number;
  effectiveScore: number;
  publicScore: number | null;
  tierCode: 'T0' | 'T1' | 'T2' | 'T3' | 'T4';
  riskPosture: 'normal' | 'observe' | 'risk_alert';
  tierReasonCodes: string[];
  postureReasonCodes: string[];
  reasonSummary: string;
  version: number;
  lastRatedOrderId: string | null;
  lastRatedAt: Date | null;
};

export type RatingScoreSourceMode =
  | { mode: 'numeric'; columnNames: string[] }
  | { mode: 'label'; columnNames: string[] }
  | { mode: 'none' };

export type RecomputeTriggerInput = {
  organizationId: string;
  sourceOrderId: string;
  sourceRatingId: string;
  triggeredAt?: Date;
};


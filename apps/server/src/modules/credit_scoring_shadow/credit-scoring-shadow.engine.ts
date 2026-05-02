import {
  CREDIT_SHADOW_AGGREGATION_MODE,
  CREDIT_SHADOW_BASE_SCORE,
  CREDIT_SHADOW_SCORE_LABELS
} from './credit-scoring-shadow.constants';
import { ShadowAggregateSnapshot, ShadowRatingValue } from './credit-scoring-shadow.types';

function roundToTwo(value: number) {
  return Math.round(value * 100) / 100;
}

function clampScore(value: number) {
  return Math.max(CREDIT_SHADOW_BASE_SCORE, Math.min(100, value));
}

function isNegativeScore(value: number) {
  return value < 70;
}

function isPositiveScore(value: number) {
  return value >= 80;
}

function scoreToTierCode(value: number): 'T0' | 'T1' | 'T2' | 'T3' | 'T4' {
  if (value >= 90) {
    return 'T4';
  }
  if (value >= 80) {
    return 'T3';
  }
  if (value >= 70) {
    return 'T2';
  }
  return 'T1';
}

function scoreToTierReasonCode(value: number) {
  if (value >= 90) {
    return 'RATING_SCORE_90_100';
  }
  if (value >= 80) {
    return 'RATING_SCORE_80_89';
  }
  if (value >= 70) {
    return 'RATING_SCORE_70_79';
  }
  return 'RATING_SCORE_60_69';
}

export function resolveShadowRatingScoreValue(
  row: Pick<ShadowRatingValue, 'scoreValue' | 'scoreLabel'>
) {
  if (typeof row.scoreValue === 'number' && Number.isFinite(row.scoreValue)) {
    return row.scoreValue;
  }

  const normalizedLabel = row.scoreLabel?.trim().toLowerCase() ?? '';
  switch (normalizedLabel) {
    case CREDIT_SHADOW_SCORE_LABELS.verySatisfied:
      return 100;
    case CREDIT_SHADOW_SCORE_LABELS.satisfied:
      return 85;
    case CREDIT_SHADOW_SCORE_LABELS.passable:
      return 70;
    case CREDIT_SHADOW_SCORE_LABELS.negative:
      return 30;
    default:
      return null;
  }
}

export function buildShadowAggregateSnapshot(
  organizationId: string,
  ratings: ShadowRatingValue[],
  triggeredAt = new Date()
): ShadowAggregateSnapshot {
  const normalizedRatings = ratings
    .map((rating) => ({
      ...rating,
      scoreValue: resolveShadowRatingScoreValue(rating)
    }))
    .filter((rating) => typeof rating.scoreValue === 'number') as Array<
    ShadowRatingValue & { scoreValue: number }
  >;

  const ratedCompletedOrderCount = normalizedRatings.length;
  const verySatisfiedCount = normalizedRatings.filter((item) => item.scoreValue >= 90).length;
  const satisfiedCount = normalizedRatings.filter(
    (item) => item.scoreValue >= 80 && item.scoreValue < 90
  ).length;
  const passableCount = normalizedRatings.filter(
    (item) => item.scoreValue >= 70 && item.scoreValue < 80
  ).length;
  const negativeCount = normalizedRatings.filter((item) => item.scoreValue < 70).length;
  const positiveRate = ratedCompletedOrderCount
    ? roundToTwo(((verySatisfiedCount + satisfiedCount) / ratedCompletedOrderCount) * 100)
    : 0;
  const negativeRate = ratedCompletedOrderCount
    ? roundToTwo((negativeCount / ratedCompletedOrderCount) * 100)
    : 0;
  const last20Ratings = [...normalizedRatings]
    .sort((left, right) => thisDateValue(right.submittedAt) - thisDateValue(left.submittedAt))
    .slice(0, 20);
  const last20RatedNegativeRate = last20Ratings.length
    ? roundToTwo(
        (last20Ratings.filter((item) => item.scoreValue < 70).length / last20Ratings.length) * 100
      )
    : 0;
  const recentConsecutiveNegativeCount = countRecentConsecutiveNegative(normalizedRatings);
  const rawScore = ratedCompletedOrderCount
    ? roundToTwo(
        normalizedRatings.reduce((sum, item) => sum + item.scoreValue, 0) /
          ratedCompletedOrderCount
      )
    : CREDIT_SHADOW_BASE_SCORE;
  const effectiveScore = ratedCompletedOrderCount
    ? roundToTwo(clampScore(rawScore))
    : CREDIT_SHADOW_BASE_SCORE;
  const sampleStatus = ratedCompletedOrderCount >= 5 ? 'ready' : 'insufficient';
  const publicScore = sampleStatus === 'ready' ? effectiveScore : null;
  const tierCode = sampleStatus === 'ready' ? scoreToTierCode(effectiveScore) : 'T0';
  const tierReasonCodes =
    sampleStatus === 'ready'
      ? [scoreToTierReasonCode(effectiveScore)]
      : ['SAMPLE_INSUFFICIENT'];
  const postureReasonCodes = resolvePostureReasonCodes(
    sampleStatus,
    positiveRate,
    negativeRate,
    recentConsecutiveNegativeCount,
    last20RatedNegativeRate
  );
  const riskPosture = resolveRiskPosture(
    positiveRate,
    negativeRate,
    recentConsecutiveNegativeCount,
    last20RatedNegativeRate
  );

  return {
    organizationId,
    aggregationMode: CREDIT_SHADOW_AGGREGATION_MODE,
    sampleStatus,
    ratedCompletedOrderCount,
    verySatisfiedCount,
    satisfiedCount,
    passableCount,
    negativeCount,
    positiveRate,
    negativeRate,
    recentConsecutiveNegativeCount,
    last20RatedNegativeRate,
    baseScore: CREDIT_SHADOW_BASE_SCORE,
    rawScore,
    effectiveScore,
    publicScore,
    tierCode,
    riskPosture,
    tierReasonCodes,
    postureReasonCodes,
    reasonSummary: buildReasonSummary({
      sampleStatus,
      ratedCompletedOrderCount,
      effectiveScore,
      tierCode,
      riskPosture,
      positiveRate,
      negativeRate,
      recentConsecutiveNegativeCount,
      last20RatedNegativeRate,
      triggeredAt
    }),
    version: 1,
    lastRatedOrderId: normalizedRatings[0]?.orderId ?? null,
    lastRatedAt: normalizedRatings[0]?.submittedAt ?? null
  };
}

function resolveRiskPosture(
  positiveRate: number,
  negativeRate: number,
  recentConsecutiveNegativeCount: number,
  last20RatedNegativeRate: number
): 'normal' | 'observe' | 'risk_alert' {
  if (
    negativeRate >= 20 ||
    last20RatedNegativeRate >= 30 ||
    recentConsecutiveNegativeCount >= 3
  ) {
    return 'risk_alert';
  }
  if (positiveRate < 80 || recentConsecutiveNegativeCount >= 2) {
    return 'observe';
  }
  return 'normal';
}

function resolvePostureReasonCodes(
  sampleStatus: 'insufficient' | 'ready',
  positiveRate: number,
  negativeRate: number,
  recentConsecutiveNegativeCount: number,
  last20RatedNegativeRate: number
) {
  if (sampleStatus === 'insufficient') {
    return ['SAMPLE_INSUFFICIENT', 'RATING_ONLY_MODE_ACTIVE'];
  }

  if (
    negativeRate >= 20 ||
    last20RatedNegativeRate >= 30 ||
    recentConsecutiveNegativeCount >= 3
  ) {
    const codes = ['RATING_ONLY_MODE_ACTIVE'];
    if (last20RatedNegativeRate >= 30) {
      codes.push('LAST20_NEGATIVE_RATE_AT_LEAST_30');
    }
    if (negativeRate >= 20) {
      codes.push('NEGATIVE_RATE_AT_LEAST_20');
    }
    if (recentConsecutiveNegativeCount >= 3) {
      codes.push('CONSECUTIVE_NEGATIVE_3');
    }
    return codes;
  }

  if (positiveRate < 80 || recentConsecutiveNegativeCount >= 2) {
    const codes = ['RATING_ONLY_MODE_ACTIVE'];
    if (positiveRate < 80) {
      codes.push('POSITIVE_RATE_BELOW_80');
    }
    if (recentConsecutiveNegativeCount >= 2) {
      codes.push('CONSECUTIVE_NEGATIVE_2');
    }
    return codes;
  }

  return ['RATING_ONLY_MODE_ACTIVE'];
}

function buildReasonSummary(input: {
  sampleStatus: 'insufficient' | 'ready';
  ratedCompletedOrderCount: number;
  effectiveScore: number;
  tierCode: string;
  riskPosture: 'normal' | 'observe' | 'risk_alert';
  positiveRate: number;
  negativeRate: number;
  recentConsecutiveNegativeCount: number;
  last20RatedNegativeRate: number;
  triggeredAt: Date;
}) {
  const timestamp = input.triggeredAt.toISOString();
  if (input.sampleStatus === 'insufficient') {
    return [
      `shadow@${timestamp}`,
      `样本不足:${input.ratedCompletedOrderCount}/5`,
      `tier=${input.tierCode}`,
      `risk=${input.riskPosture}`
    ].join(' | ');
  }

  return [
    `shadow@${timestamp}`,
    `样本=${input.ratedCompletedOrderCount}`,
    `effectiveScore=${input.effectiveScore.toFixed(2)}`,
    `tier=${input.tierCode}`,
    `risk=${input.riskPosture}`,
    `positiveRate=${input.positiveRate.toFixed(2)}%`,
    `negativeRate=${input.negativeRate.toFixed(2)}%`,
    `consecutiveNegative=${input.recentConsecutiveNegativeCount}`,
    `last20NegativeRate=${input.last20RatedNegativeRate.toFixed(2)}%`
  ].join(' | ');
}

function countRecentConsecutiveNegative(ratings: ShadowRatingValue[]) {
  const ordered = [...ratings].sort((left, right) => thisDateValue(right.submittedAt) - thisDateValue(left.submittedAt));
  let count = 0;
  for (const rating of ordered) {
    const value = rating.scoreValue;
    if (typeof value !== 'number') {
      continue;
    }
    if (!isNegativeScore(value)) {
      break;
    }
    count += 1;
  }
  return count;
}

function thisDateValue(value: Date | null) {
  return value?.getTime() ?? 0;
}

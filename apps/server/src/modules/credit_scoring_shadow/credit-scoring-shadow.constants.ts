export const CREDIT_SHADOW_MIGRATION_KEY = '20260414_org_credit_shadow_aggregation_truth';

export const CREDIT_SHADOW_AGGREGATION_MODE = 'formal_rating_only_shadow';

export const CREDIT_SHADOW_BASE_SCORE = 60;

export const CREDIT_SHADOW_SCORE_LABELS = {
  verySatisfied: 'very_satisfied',
  satisfied: 'satisfied',
  passable: 'passable',
  negative: 'negative'
} as const;

export const CREDIT_SHADOW_REASON_CODE_ROWS = [
  {
    code: 'SAMPLE_INSUFFICIENT',
    title: '样本不足',
    category: 'sample',
    description: '正式提交且完成的评价样本不足，当前仅保留 shadow-only 结果。'
  },
  {
    code: 'RATING_SCORE_60_69',
    title: '评分 60-69',
    category: 'tier',
    description: '有效样本对应的 shadow 等级落在 60-69 区间。'
  },
  {
    code: 'RATING_SCORE_70_79',
    title: '评分 70-79',
    category: 'tier',
    description: '有效样本对应的 shadow 等级落在 70-79 区间。'
  },
  {
    code: 'RATING_SCORE_80_89',
    title: '评分 80-89',
    category: 'tier',
    description: '有效样本对应的 shadow 等级落在 80-89 区间。'
  },
  {
    code: 'RATING_SCORE_90_100',
    title: '评分 90-100',
    category: 'tier',
    description: '有效样本对应的 shadow 等级落在 90-100 区间。'
  },
  {
    code: 'POSITIVE_RATE_BELOW_80',
    title: '正向占比低于 80%',
    category: 'posture',
    description: '正向评价占比低于 80%，进入 observe 或更高风险姿态。'
  },
  {
    code: 'NEGATIVE_RATE_AT_LEAST_20',
    title: '负向占比达到 20%',
    category: 'posture',
    description: '负向评价占比达到 20% 及以上，进入风险警戒。'
  },
  {
    code: 'CONSECUTIVE_NEGATIVE_2',
    title: '连续负向 2 单',
    category: 'posture',
    description: '最近连续两单为负向评价，进入 observe。'
  },
  {
    code: 'CONSECUTIVE_NEGATIVE_3',
    title: '连续负向 3 单',
    category: 'posture',
    description: '最近连续三单为负向评价，进入 risk_alert。'
  },
  {
    code: 'LAST20_NEGATIVE_RATE_AT_LEAST_30',
    title: '最近 20 单负向占比达到 30%',
    category: 'posture',
    description: '最近 20 单负向占比达到 30% 及以上，进入风险警戒。'
  },
  {
    code: 'RATING_ONLY_MODE_ACTIVE',
    title: '仅评价影子模式',
    category: 'source',
    description: '当前只允许影子聚合，不进入 current V2.1 runtime truth。'
  }
] as const;

export const CREDIT_SHADOW_NUMERIC_SCORE_COLUMNS = [
  'score',
  'rating_score',
  'overall_score',
  'score_snapshot',
  'rating_value',
  'rating_score_snapshot',
  'ratingScore',
  'overallScore',
  'value',
  'star',
  'stars'
] as const;

export const CREDIT_SHADOW_TEXT_SCORE_COLUMNS = [
  'rating_level',
  'satisfaction_level',
  'rating_grade',
  'ratingLevel',
  'satisfactionLevel',
  'ratingGrade'
] as const;

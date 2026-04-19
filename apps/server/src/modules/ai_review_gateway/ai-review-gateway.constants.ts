export const AI_REVIEW_GATEWAY_RESULT_STATUSES = [
  'queued',
  'processing',
  'completed',
  'failed'
] as const;

export type AiReviewGatewayResultStatus =
  (typeof AI_REVIEW_GATEWAY_RESULT_STATUSES)[number];

export const AI_REVIEW_GATEWAY_DECISIONS = ['allow', 'block'] as const;

export type AiReviewGatewayDecision = (typeof AI_REVIEW_GATEWAY_DECISIONS)[number];

export const AI_REVIEW_GATEWAY_DEFAULT_PROVIDER_KEY = 'mock_ai_review_provider';

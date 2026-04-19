import { AiReviewGatewayDecision, AiReviewGatewayResultStatus } from './ai-review-gateway.constants';

export type AiReviewGatewaySubmitCommand = {
  engineType: string;
  providerKey: string;
  reviewObjectType: string;
  objectId: string;
  policyProfile: string;
  reviewPayload: Record<string, unknown>;
  traceId: string;
};

export type AiReviewGatewayProviderResponse = {
  decision: AiReviewGatewayDecision;
  riskScore: number;
  riskLabels: string[];
};

export type AiReviewGatewaySubmissionResponse = {
  requestId: string;
  resultId: string;
  engineType: string;
  providerKey: string;
  reviewObjectType: string;
  objectId: string;
  policyProfile: string;
  requestPayloadRef: string;
  providerResponseRef: string;
  traceId: string;
  decision: AiReviewGatewayDecision;
  riskScore: number;
  riskLabels: string[];
  status: AiReviewGatewayResultStatus;
};

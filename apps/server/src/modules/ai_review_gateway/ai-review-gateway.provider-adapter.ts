import { Injectable } from '@nestjs/common';
import { AI_REVIEW_GATEWAY_DEFAULT_PROVIDER_KEY, AI_REVIEW_GATEWAY_DECISIONS } from './ai-review-gateway.constants';
import { aiReviewGatewayProviderResponseInvalid } from './ai-review-gateway.errors';
import { AiReviewGatewayProviderResponse, AiReviewGatewaySubmitCommand } from './ai-review-gateway.types';

export const AI_REVIEW_GATEWAY_PROVIDER_ADAPTER = Symbol('AI_REVIEW_GATEWAY_PROVIDER_ADAPTER');

export interface AiReviewGatewayProviderAdapter {
  readonly providerKey: string;
  buildRequest(input: AiReviewGatewaySubmitCommand): Record<string, unknown>;
  invoke(request: Record<string, unknown>): Promise<unknown>;
  normalizeResponse(
    rawResponse: unknown,
    input: AiReviewGatewaySubmitCommand
  ): AiReviewGatewayProviderResponse;
}

@Injectable()
export class AiReviewGatewayMockProviderAdapter implements AiReviewGatewayProviderAdapter {
  readonly providerKey = AI_REVIEW_GATEWAY_DEFAULT_PROVIDER_KEY;

  buildRequest(input: AiReviewGatewaySubmitCommand) {
    return {
      engineType: input.engineType,
      providerKey: input.providerKey,
      reviewObjectType: input.reviewObjectType,
      objectId: input.objectId,
      policyProfile: input.policyProfile,
      reviewPayload: JSON.parse(JSON.stringify(input.reviewPayload)),
      traceId: input.traceId
    };
  }

  async invoke() {
    return {
      decision: 'allow',
      riskScore: 0,
      riskLabels: []
    };
  }

  normalizeResponse(
    rawResponse: unknown,
    input: AiReviewGatewaySubmitCommand
  ): AiReviewGatewayProviderResponse {
    if (!rawResponse || Array.isArray(rawResponse) || typeof rawResponse !== 'object') {
      throw aiReviewGatewayProviderResponseInvalid('Provider response must be an object.');
    }
    const source = rawResponse as Record<string, unknown>;
    const decision = this.readDecision(source.decision);
    return {
      decision,
      riskScore: this.readRiskScore(source.riskScore),
      riskLabels: this.readRiskLabels(source.riskLabels, input)
    };
  }

  private readDecision(value: unknown) {
    if (typeof value !== 'string') {
      throw aiReviewGatewayProviderResponseInvalid('Provider decision is required.');
    }
    const normalized = value.trim();
    if (!AI_REVIEW_GATEWAY_DECISIONS.includes(normalized as (typeof AI_REVIEW_GATEWAY_DECISIONS)[number])) {
      throw aiReviewGatewayProviderResponseInvalid('Provider decision is invalid.');
    }
    return normalized as (typeof AI_REVIEW_GATEWAY_DECISIONS)[number];
  }

  private readRiskScore(value: unknown) {
    const numeric = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(numeric) || numeric < 0) {
      throw aiReviewGatewayProviderResponseInvalid('Provider riskScore is invalid.');
    }
    return numeric;
  }

  private readRiskLabels(value: unknown, input: AiReviewGatewaySubmitCommand) {
    if (value === undefined || value === null) {
      return [];
    }
    if (!Array.isArray(value)) {
      throw aiReviewGatewayProviderResponseInvalid('Provider riskLabels are invalid.');
    }
    const labels = value.map((item) => {
      if (typeof item !== 'string') {
        throw aiReviewGatewayProviderResponseInvalid('Provider riskLabels are invalid.');
      }
      const normalized = item.trim();
      if (!normalized || normalized.length > 64) {
        throw aiReviewGatewayProviderResponseInvalid('Provider riskLabels are invalid.');
      }
      return normalized;
    });
    const uniqueLabels = [...new Set(labels)];
    return uniqueLabels;
  }
}

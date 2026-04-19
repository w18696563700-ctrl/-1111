import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { aiReviewGatewayRequestInvalid } from './ai-review-gateway.errors';
import { AiReviewGatewaySubmitCommand } from './ai-review-gateway.types';

@Injectable()
export class AiReviewGatewayRequestNormalizer {
  normalizeSubmitCommand(payload: Record<string, unknown>, context: RequestContext) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw aiReviewGatewayRequestInvalid('AI review gateway submit payload must be an object.');
    }
    const source = payload as Record<string, unknown>;
    return {
      engineType: this.readRequiredText(source.engineType, 'engineType', 32),
      providerKey: this.readRequiredText(source.providerKey, 'providerKey', 64),
      reviewObjectType: this.readRequiredText(source.reviewObjectType, 'reviewObjectType', 64),
      objectId: this.readRequiredText(source.objectId, 'objectId', 128),
      policyProfile: this.readRequiredText(source.policyProfile, 'policyProfile', 64),
      reviewPayload: this.readReviewPayload(source.reviewPayload),
      traceId: this.readOptionalText(source.traceId, 64) ?? context.traceId.trim()
    } satisfies AiReviewGatewaySubmitCommand;
  }

  private readReviewPayload(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw aiReviewGatewayRequestInvalid('reviewPayload is required.');
    }
    return JSON.parse(JSON.stringify(value)) as Record<string, unknown>;
  }

  private readRequiredText(value: unknown, field: string, maxLength: number) {
    if (typeof value !== 'string') {
      throw aiReviewGatewayRequestInvalid(`${field} is required.`);
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > maxLength) {
      throw aiReviewGatewayRequestInvalid(`${field} is invalid.`);
    }
    return normalized;
  }

  private readOptionalText(value: unknown, maxLength: number) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    if (typeof value !== 'string') {
      throw aiReviewGatewayRequestInvalid('Optional fields must be strings when provided.');
    }
    const normalized = value.trim();
    if (!normalized || normalized.length > maxLength) {
      throw aiReviewGatewayRequestInvalid('Optional field value is invalid.');
    }
    return normalized;
  }
}

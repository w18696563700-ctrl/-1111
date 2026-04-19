import { Injectable } from '@nestjs/common';
import { AiReviewGatewayRequestEntity } from './entities/ai-review-gateway-request.entity';
import { AiReviewGatewayResultEntity } from './entities/ai-review-gateway-result.entity';
import { AiReviewGatewaySubmissionResponse } from './ai-review-gateway.types';

@Injectable()
export class AiReviewGatewayPresenter {
  toSubmissionResponse(
    request: AiReviewGatewayRequestEntity,
    result: AiReviewGatewayResultEntity
  ): AiReviewGatewaySubmissionResponse {
    return {
      requestId: request.id,
      resultId: result.id,
      engineType: request.engineType,
      providerKey: request.providerKey,
      reviewObjectType: request.reviewObjectType,
      objectId: request.objectId,
      policyProfile: request.policyProfile,
      requestPayloadRef: request.requestPayloadRef,
      providerResponseRef: result.providerResponseRef,
      traceId: request.traceId,
      decision: result.decision as AiReviewGatewaySubmissionResponse['decision'],
      riskScore: Number(result.riskScore),
      riskLabels: [...result.riskLabels],
      status: result.status
    };
  }
}

import { randomUUID } from 'crypto';
import { Inject, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { aiReviewGatewayProviderUnavailable } from './ai-review-gateway.errors';
import {
  AI_REVIEW_GATEWAY_PROVIDER_ADAPTER,
  AiReviewGatewayProviderAdapter
} from './ai-review-gateway.provider-adapter';
import { AiReviewGatewayRequestNormalizer } from './ai-review-gateway.request-normalizer';
import { AiReviewGatewayPresenter } from './ai-review-gateway.presenter';
import { AiReviewGatewayRequestEntity } from './entities/ai-review-gateway-request.entity';
import { AiReviewGatewayResultEntity } from './entities/ai-review-gateway-result.entity';
import { AiReviewGatewaySubmitCommand } from './ai-review-gateway.types';

@Injectable()
export class AiReviewGatewayService {
  constructor(
    @InjectRepository(AiReviewGatewayRequestEntity)
    private readonly requestRepository: Repository<AiReviewGatewayRequestEntity>,
    @InjectRepository(AiReviewGatewayResultEntity)
    private readonly resultRepository: Repository<AiReviewGatewayResultEntity>,
    @Inject(AI_REVIEW_GATEWAY_PROVIDER_ADAPTER)
    private readonly providerAdapter: AiReviewGatewayProviderAdapter,
    private readonly normalizer: AiReviewGatewayRequestNormalizer,
    private readonly presenter: AiReviewGatewayPresenter
  ) {}

  async submit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.normalizer.normalizeSubmitCommand(payload, context);
    this.assertProviderAdapter(command);

    const now = new Date();
    const requestId = randomUUID();
    const request = await this.requestRepository.save(
      this.requestRepository.create({
        id: requestId,
        engineType: command.engineType,
        providerKey: command.providerKey,
        reviewObjectType: command.reviewObjectType,
        objectId: command.objectId,
        policyProfile: command.policyProfile,
        requestPayloadRef: this.buildRequestPayloadRef(requestId),
        traceId: command.traceId,
        createdAt: now
      })
    );

    const resultId = randomUUID();
    const result = await this.resultRepository.save(
      this.resultRepository.create({
        id: resultId,
        requestId: request.id,
        decision: 'block',
        riskScore: 0,
        riskLabels: [],
        providerResponseRef: this.buildProviderResponseRef(resultId),
        status: 'processing',
        createdAt: now
      })
    );

    try {
      const providerRequest = this.providerAdapter.buildRequest(command);
      const rawProviderResponse = await this.providerAdapter.invoke(providerRequest);
      const normalizedProviderResponse = this.providerAdapter.normalizeResponse(
        rawProviderResponse,
        command
      );
      result.decision = normalizedProviderResponse.decision;
      result.riskScore = normalizedProviderResponse.riskScore;
      result.riskLabels = normalizedProviderResponse.riskLabels;
      result.status = 'completed';
      await this.resultRepository.save(result);
      return this.presenter.toSubmissionResponse(request, result);
    } catch (error) {
      result.decision = 'block';
      result.riskScore = 1;
      result.riskLabels = ['provider_error'];
      result.status = 'failed';
      await this.resultRepository.save(result);
      if (this.isGatewayClientError(error)) {
        throw error;
      }
      throw aiReviewGatewayProviderUnavailable('AI review gateway provider invocation failed.');
    }
  }

  private assertProviderAdapter(command: AiReviewGatewaySubmitCommand) {
    if (!this.providerAdapter || this.providerAdapter.providerKey !== command.providerKey) {
      throw aiReviewGatewayProviderUnavailable('AI review gateway provider is unavailable.');
    }
  }

  private buildRequestPayloadRef(requestId: string) {
    return `ai_review_gateway_request_payload:${requestId}`;
  }

  private buildProviderResponseRef(resultId: string) {
    return `ai_review_gateway_provider_response:${resultId}`;
  }

  private isGatewayClientError(error: unknown) {
    if (!error || typeof error !== 'object') {
      return false;
    }
    const response = typeof (error as { getResponse?: () => unknown }).getResponse === 'function'
      ? (error as { getResponse: () => unknown }).getResponse()
      : null;
    if (!response || typeof response !== 'object') {
      return false;
    }
    const code = (response as { code?: unknown }).code;
    return (
      code === 'AI_REVIEW_GATEWAY_REQUEST_INVALID' ||
      code === 'AI_REVIEW_GATEWAY_PROVIDER_RESPONSE_INVALID'
    );
  }
}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiReviewGatewayRequestNormalizer } from './ai-review-gateway.request-normalizer';
import {
  AI_REVIEW_GATEWAY_PROVIDER_ADAPTER,
  AiReviewGatewayMockProviderAdapter
} from './ai-review-gateway.provider-adapter';
import { AiReviewGatewayPresenter } from './ai-review-gateway.presenter';
import { AiReviewGatewayService } from './ai-review-gateway.service';
import { AiReviewGatewayRequestEntity } from './entities/ai-review-gateway-request.entity';
import { AiReviewGatewayResultEntity } from './entities/ai-review-gateway-result.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AiReviewGatewayRequestEntity, AiReviewGatewayResultEntity])],
  providers: [
    AiReviewGatewayRequestNormalizer,
    AiReviewGatewayPresenter,
    AiReviewGatewayMockProviderAdapter,
    AiReviewGatewayService,
    {
      provide: AI_REVIEW_GATEWAY_PROVIDER_ADAPTER,
      useExisting: AiReviewGatewayMockProviderAdapter
    }
  ],
  exports: [AiReviewGatewayService, AI_REVIEW_GATEWAY_PROVIDER_ADAPTER]
})
export class AiReviewGatewayModule {}

import { BadRequestException, NotFoundException, ServiceUnavailableException } from '@nestjs/common';

export function aiReviewGatewayRequestInvalid(message: string) {
  return new BadRequestException({
    code: 'AI_REVIEW_GATEWAY_REQUEST_INVALID',
    message
  });
}

export function aiReviewGatewayProviderResponseInvalid(message: string) {
  return new BadRequestException({
    code: 'AI_REVIEW_GATEWAY_PROVIDER_RESPONSE_INVALID',
    message
  });
}

export function aiReviewGatewayProviderUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'AI_REVIEW_GATEWAY_PROVIDER_UNAVAILABLE',
    message
  });
}

export function aiReviewGatewayResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'AI_REVIEW_GATEWAY_RESOURCE_UNAVAILABLE',
    message
  });
}

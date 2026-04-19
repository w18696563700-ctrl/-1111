import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function exhibitionReportInvalid(message: string) {
  return new BadRequestException({
    code: 'REVIEW_REPORT_INVALID',
    message
  });
}

export function exhibitionReportResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'REVIEW_REPORT_RESOURCE_UNAVAILABLE',
    message
  });
}

export function exhibitionReportInvalidState(message: string) {
  return new ConflictException({
    code: 'REVIEW_REPORT_INVALID_STATE',
    message
  });
}

export function exhibitionReportRequestExplanationInvalid(message: string) {
  return new BadRequestException({
    code: 'REVIEW_REPORT_REQUEST_EXPLANATION_INVALID',
    message
  });
}

export function exhibitionReportDecideInvalid(message: string) {
  return new BadRequestException({
    code: 'REVIEW_REPORT_DECIDE_INVALID',
    message
  });
}

export function exhibitionReportEscalateInvalid(message: string) {
  return new BadRequestException({
    code: 'REVIEW_REPORT_ESCALATE_INVALID',
    message
  });
}

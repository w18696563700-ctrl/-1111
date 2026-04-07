import { BadRequestException } from '@nestjs/common';

export function profileSafetyRuleBlocked(message: string, details?: Record<string, unknown>) {
  return new BadRequestException({
    code: 'PROFILE_SAFETY_RULE_BLOCKED',
    message,
    details
  });
}

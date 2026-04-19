import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function templateConfigInvalid(message: string) {
  return new BadRequestException({
    code: 'TEMPLATE_CONFIG_INVALID',
    message
  });
}

export function templateConfigInvalidState(message: string) {
  return new ConflictException({
    code: 'TEMPLATE_CONFIG_INVALID_STATE',
    message
  });
}

export function templateConfigTemplateResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'TEMPLATE_CONFIG_TEMPLATE_RESOURCE_UNAVAILABLE',
    message
  });
}

export function templateConfigTemplateVersionResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'TEMPLATE_CONFIG_TEMPLATE_VERSION_RESOURCE_UNAVAILABLE',
    message
  });
}

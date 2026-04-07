import { BadRequestException } from '@nestjs/common';

export function exhibitionHomeLocationRequired(message: string) {
  return new BadRequestException({
    code: 'LOCATION_REQUIRED',
    message
  });
}

import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';

export function orderDetailInvalid(message: string) {
  return new BadRequestException({
    code: 'ORDER_DETAIL_INVALID',
    message,
  });
}

export function orderDetailUnavailable(message: string) {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message,
  });
}

export function contractDetailInvalid(message: string) {
  return new BadRequestException({
    code: 'CONTRACT_DETAIL_INVALID',
    message,
  });
}

export function contractEntryUnavailable(message: string) {
  return new ConflictException({
    code: 'CONTRACT_ENTRY_UNAVAILABLE',
    message,
  });
}

export function milestoneListInvalid(message: string) {
  return new BadRequestException({
    code: 'MILESTONE_LIST_INVALID',
    message,
  });
}

export function milestoneListUnavailable(message: string) {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message,
  });
}

export function inspectionDetailInvalid(message: string) {
  return new BadRequestException({
    code: 'INSPECTION_DETAIL_INVALID',
    message,
  });
}

export function inspectionEntryUnavailable(message: string) {
  return new ConflictException({
    code: 'INSPECTION_ENTRY_UNAVAILABLE',
    message,
  });
}

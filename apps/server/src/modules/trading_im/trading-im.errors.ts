import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';

export function projectClarificationUnavailable(message = 'Current project clarification is unavailable.') {
  return new NotFoundException({
    code: 'PROJECT_CLARIFICATION_UNAVAILABLE',
    message
  });
}

export function projectClarificationForbidden(message = 'Current actor cannot access project clarification.') {
  return new ForbiddenException({
    code: 'PROJECT_CLARIFICATION_FORBIDDEN',
    message
  });
}

export function bidThreadUnavailable(message = 'Current bid thread is unavailable.') {
  return new NotFoundException({
    code: 'BID_THREAD_UNAVAILABLE',
    message
  });
}

export function bidThreadForbidden(message = 'Current actor cannot access bid thread.') {
  return new ForbiddenException({
    code: 'BID_THREAD_FORBIDDEN',
    message
  });
}

export function threadMessageInvalid(message = 'Current thread message request is invalid.') {
  return new BadRequestException({
    code: 'THREAD_MESSAGE_INVALID',
    message
  });
}

export function threadAttachmentInvalid(message = 'Current thread attachment request is invalid.') {
  return new BadRequestException({
    code: 'THREAD_ATTACHMENT_INVALID',
    message
  });
}

export function threadConfirmationInvalid(message = 'Current thread confirmation request is invalid.') {
  return new BadRequestException({
    code: 'THREAD_CONFIRMATION_INVALID',
    message
  });
}

export function threadParticipantCardInvalid(
  message = 'Current participant-card request is invalid.'
) {
  return new BadRequestException({
    code: 'THREAD_PARTICIPANT_CARD_INVALID',
    message
  });
}

export function threadParticipantCardForbidden(
  message = 'Current actor cannot access participant-card.'
) {
  return new ForbiddenException({
    code: 'THREAD_PARTICIPANT_CARD_FORBIDDEN',
    message
  });
}

export function threadParticipantCardUnavailable(
  message = 'Current participant-card is unavailable.'
) {
  return new NotFoundException({
    code: 'THREAD_PARTICIPANT_CARD_UNAVAILABLE',
    message
  });
}

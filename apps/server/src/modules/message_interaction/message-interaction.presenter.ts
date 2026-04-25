import { Injectable } from '@nestjs/common';
import {
  CounterpartConversationDetailProjection,
  CounterpartConversationListItemProjection,
} from './counterpart-conversation.types';

@Injectable()
export class MessageInteractionPresenter {
  toListResponse(
    lane: 'project_communication',
    items: CounterpartConversationListItemProjection[],
  ) {
    return {
      lane,
      items,
    };
  }

  toCounterpartConversationDetail(
    detail: CounterpartConversationDetailProjection,
  ) {
    return detail;
  }
}

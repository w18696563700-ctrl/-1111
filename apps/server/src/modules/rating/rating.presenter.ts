import { Injectable } from '@nestjs/common';

@Injectable()
export class RatingPresenter {
  toEntryReadModel(ratingId: string, orderId: string) {
    return {
      ratingId,
      orderId,
      state: 'eligible',
      summary: {
        heading: '当前评价入口已就绪，可继续提交最小评价真值。',
      },
    };
  }

  toSubmitAcceptedResponse(ratingId: string, orderId: string) {
    return {
      ratingId,
      orderId,
      state: 'submitted',
      summary: {
        heading: '当前评价提交已受理，后续仍以项目私域真值为准。',
      },
    };
  }
}

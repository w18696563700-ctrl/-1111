import { Injectable } from '@nestjs/common';

type CompletionAcceptedInput = {
  orderId: string;
  projectId: string;
  state: string;
  completionRequestState: string;
};

@Injectable()
export class ProjectOrderCompletionPresenter {
  toCompletionRequestAccepted(input: CompletionAcceptedInput) {
    return {
      orderId: input.orderId,
      projectId: input.projectId,
      state: input.state,
      completionRequestState: input.completionRequestState,
      summary: {
        heading: '完工申请已提交，等待发布方确认。',
      },
    };
  }

  toCompletionConfirmAccepted(input: CompletionAcceptedInput) {
    return {
      orderId: input.orderId,
      projectId: input.projectId,
      state: input.state,
      completionRequestState: input.completionRequestState,
      summary: {
        heading: '订单已确认完成，双方互评入口将以 completed 订单真值开放。',
      },
    };
  }

  toCompletionRejectAccepted(input: CompletionAcceptedInput) {
    return {
      orderId: input.orderId,
      projectId: input.projectId,
      state: input.state,
      completionRequestState: input.completionRequestState,
      summary: {
        heading:
          input.completionRequestState === 'dispute_reserved'
            ? '完工申请已拒绝，并保留争议入口。'
            : '完工申请已拒绝，订单仍保持进行中。',
      },
    };
  }
}

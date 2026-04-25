import { Injectable } from '@nestjs/common';

type InspectionAcceptedInput = {
  inspectionId: string;
  milestoneId: string;
  state: string;
};

type InspectionPassAcceptedInput = InspectionAcceptedInput & {
  orderId: string;
  orderState: string;
};

type ContractAcceptedInput = {
  contractId: string;
  orderId: string;
  state: string;
};

type DisputeAcceptedInput = {
  disputeId: string;
  orderId: string;
  state: string;
};

@Injectable()
export class TradingShellHandoffPresenter {
  toMilestoneSubmitAccepted(milestoneId: string) {
    return { milestoneId };
  }

  toInspectionSubmitAccepted(input: InspectionAcceptedInput) {
    return {
      inspectionId: input.inspectionId,
      milestoneId: input.milestoneId,
      state: input.state,
      summary: {
        heading: '当前验收提交入口已受理，后续仍以验收详情真值为准。',
      },
    };
  }

  toInspectionRecheckAccepted(input: InspectionAcceptedInput) {
    return {
      inspectionId: input.inspectionId,
      milestoneId: input.milestoneId,
      state: input.state,
      summary: {
        heading: '当前验收复检已受理，后续仍以验收详情真值为准。',
      },
    };
  }

  toInspectionPassAccepted(input: InspectionPassAcceptedInput) {
    return {
      inspectionId: input.inspectionId,
      milestoneId: input.milestoneId,
      orderId: input.orderId,
      state: input.state,
      orderState: input.orderState,
      summary: {
        heading: '当前验收已通过；若所有里程碑均完成，订单将同步进入完成态。',
      },
    };
  }

  toContractConfirmAccepted(input: ContractAcceptedInput) {
    return {
      contractId: input.contractId,
      orderId: input.orderId,
      state: input.state,
      summary: {
        heading: '当前合同确认已受理，后续仍以合同详情真值为准。',
      },
    };
  }

  toContractAmendAccepted(input: ContractAcceptedInput) {
    return {
      contractId: input.contractId,
      orderId: input.orderId,
      state: input.state,
      summary: {
        heading: '当前合同改单已受理，后续仍以合同详情真值为准。',
      },
    };
  }

  toDisputeOpenAccepted(orderId: string) {
    return {
      orderId,
      state: 'accepted',
      summary: {
        heading: '当前争议开启入口已受理，后续仍保持边界续接。',
      },
    };
  }

  toDisputeWithdrawAccepted(input: DisputeAcceptedInput) {
    return {
      disputeId: input.disputeId,
      orderId: input.orderId,
      state: input.state,
      summary: {
        heading: '当前争议撤回已受理，后续仍以项目私域与工作台真值为准。',
      },
    };
  }
}

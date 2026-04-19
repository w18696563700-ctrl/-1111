import { Injectable } from '@nestjs/common';

type OrderTruthRow = {
  orderId: string;
  orderNo: string;
  projectId: string;
  bidId: string;
  title: string | null;
  totalAmount: number | string | null;
  state: string | null;
};

type ContractTruthRow = {
  contractId: string;
  state: string | null;
  summaryText: string | null;
};

type MilestoneTruthRow = {
  milestoneId: string;
  orderId: string;
  title: string | null;
  amount: number | string | null;
  state: string | null;
  submissionNote: string | null;
};

type InspectionTruthRow = {
  inspectionId: string;
  milestoneId: string;
  state: string | null;
  summaryText: string | null;
};

@Injectable()
export class TradingReadCorridorPresenter {
  toOrderDetail(order: OrderTruthRow, milestones: MilestoneTruthRow[]) {
    return {
      orderId: order.orderId,
      orderNo: order.orderNo,
      projectId: order.projectId,
      bidId: order.bidId,
      state: 'active',
      summary: this.toHeadingSummary(
        this.readOptionalText(order.title) ?? '当前订单已进入最小履约承接走廊。'
      ),
      milestones: milestones.map((milestone) => this.toMilestoneItem(milestone)),
    };
  }

  toContractDetail(contract: ContractTruthRow, orderId: string) {
    return {
      contractId: contract.contractId,
      orderId,
      state: this.normalizeContractState(contract.state),
      summary: this.toHeadingSummary(
        this.readOptionalText(contract.summaryText) ??
          this.describeContractState(contract.state)
      ),
    };
  }

  toMilestoneList(milestones: MilestoneTruthRow[]) {
    return {
      items: milestones.map((milestone) => this.toMilestoneItem(milestone)),
    };
  }

  toInspectionDetail(inspection: InspectionTruthRow) {
    return {
      inspectionId: inspection.inspectionId,
      milestoneId: inspection.milestoneId,
      state: this.normalizeInspectionState(inspection.state),
      summary: this.toHeadingSummary(
        this.readOptionalText(inspection.summaryText) ??
          this.describeInspectionState(inspection.state)
      ),
    };
  }

  private toMilestoneItem(milestone: MilestoneTruthRow) {
    return {
      milestoneId: milestone.milestoneId,
      orderId: milestone.orderId,
      title: this.readOptionalText(milestone.title) ?? '当前里程碑已承接。',
      amount: this.toFiniteNumber(milestone.amount) ?? 0,
      state: this.normalizeMilestoneState(milestone.state),
      summary: this.toHeadingSummary(
        this.readOptionalText(milestone.submissionNote) ??
          this.describeMilestoneState(milestone.state)
      ),
    };
  }

  private toHeadingSummary(heading: string) {
    return { heading };
  }

  private normalizeContractState(value: string | null) {
    const normalized = this.readOptionalText(value);
    if (normalized === 'pending_confirm') return normalized;
    if (normalized === 'active') return normalized;
    return 'amended';
  }

  private normalizeMilestoneState(value: string | null) {
    return this.readOptionalText(value) === 'submitted'
      ? 'submitted'
      : 'pending_submission';
  }

  private normalizeInspectionState(value: string | null) {
    const normalized = this.readOptionalText(value);
    if (normalized === 'submitted') return normalized;
    if (normalized === 'rechecked') return normalized;
    return 'draft';
  }

  private describeContractState(value: string | null) {
    const normalized = this.readOptionalText(value);
    if (normalized === 'active') {
      return '当前合同已生效。';
    }
    if (normalized === 'amended') {
      return '当前合同已进入最小变更承接状态。';
    }
    return '当前合同待确认。';
  }

  private describeMilestoneState(value: string | null) {
    return this.readOptionalText(value) === 'submitted'
      ? '当前里程碑已提交。'
      : '当前里程碑待提交。';
  }

  private describeInspectionState(value: string | null) {
    const normalized = this.readOptionalText(value);
    if (normalized === 'submitted') {
      return '当前验收已提交。';
    }
    if (normalized === 'rechecked') {
      return '当前验收已进入复检承接。';
    }
    return '当前验收待提交。';
  }

  private toFiniteNumber(value: number | string | null) {
    if (value === null || value === undefined) {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private readOptionalText(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}

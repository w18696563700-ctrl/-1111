export type OrderDetailState = 'active' | 'completed';
export type OrderCompletionRequestState =
  | 'none'
  | 'requested'
  | 'confirmed'
  | 'rejected'
  | 'dispute_reserved';
export type MilestoneState = 'pending_submission' | 'submitted' | 'completed';
export type ContractState = 'pending_confirm' | 'active' | 'amended';
export type InspectionState = 'draft' | 'submitted' | 'rechecked' | 'passed';

export type SummaryViewModel = Record<string, unknown>;

export type MilestoneItemViewModel = {
  milestoneId: string;
  orderId: string;
  title: string;
  amount: number;
  state: MilestoneState;
  summary: SummaryViewModel;
};

export type OrderDetailViewModel = {
  orderId: string;
  orderNo: string;
  projectId: string;
  bidId: string;
  buyerOrganizationId: string;
  supplierOrganizationId: string;
  sellerOrganizationId: string;
  state: OrderDetailState;
  completionRequestState: OrderCompletionRequestState;
  summary: SummaryViewModel;
  milestones: MilestoneItemViewModel[];
};

export type ContractDetailViewModel = {
  contractId: string;
  orderId: string;
  state: ContractState;
  summary: SummaryViewModel;
};

export type MilestoneListViewModel = {
  items: MilestoneItemViewModel[];
};

export type InspectionDetailViewModel = {
  inspectionId: string;
  milestoneId: string;
  state: InspectionState;
  summary: SummaryViewModel;
};

const ORDER_STATES = new Set<OrderDetailState>(['active', 'completed']);
const ORDER_COMPLETION_REQUEST_STATES = new Set<OrderCompletionRequestState>([
  'none',
  'requested',
  'confirmed',
  'rejected',
  'dispute_reserved',
]);
const MILESTONE_STATES = new Set<MilestoneState>([
  'pending_submission',
  'submitted',
  'completed',
]);
const CONTRACT_STATES = new Set<ContractState>([
  'pending_confirm',
  'active',
  'amended',
]);
const INSPECTION_STATES = new Set<InspectionState>([
  'draft',
  'submitted',
  'rechecked',
  'passed',
]);

export function readOrderDetailViewModel(
  value: Record<string, unknown>,
): OrderDetailViewModel {
  return {
    orderId: readRequiredString(value.orderId, 'orderId must be a string.'),
    orderNo: readRequiredString(value.orderNo, 'orderNo must be a string.'),
    projectId: readRequiredString(value.projectId, 'projectId must be a string.'),
    bidId: readRequiredString(value.bidId, 'bidId must be a string.'),
    buyerOrganizationId: readRequiredString(
      value.buyerOrganizationId,
      'buyerOrganizationId must be a string.',
    ),
    supplierOrganizationId: readRequiredString(
      value.supplierOrganizationId,
      'supplierOrganizationId must be a string.',
    ),
    sellerOrganizationId: readRequiredString(
      value.sellerOrganizationId ?? value.supplierOrganizationId,
      'sellerOrganizationId must be a string.',
    ),
    state: readOrderState(value.state),
    completionRequestState: readOrderCompletionRequestState(
      value.completionRequestState,
    ),
    summary: readSummary(value.summary, 'order summary must be an object.'),
    milestones: readMilestoneItems(
      value.milestones,
      'order milestones must be an array.',
    ),
  };
}

export function readContractDetailViewModel(
  value: Record<string, unknown>,
): ContractDetailViewModel {
  return {
    contractId: readRequiredString(
      value.contractId,
      'contractId must be a string.',
    ),
    orderId: readRequiredString(value.orderId, 'orderId must be a string.'),
    state: readContractState(value.state),
    summary: readSummary(value.summary, 'contract summary must be an object.'),
  };
}

export function readMilestoneListViewModel(
  value: Record<string, unknown>,
): MilestoneListViewModel {
  return {
    items: readMilestoneItems(value.items, 'milestone items must be an array.'),
  };
}

export function readInspectionDetailViewModel(
  value: Record<string, unknown>,
): InspectionDetailViewModel {
  return {
    inspectionId: readRequiredString(
      value.inspectionId,
      'inspectionId must be a string.',
    ),
    milestoneId: readRequiredString(
      value.milestoneId,
      'milestoneId must be a string.',
    ),
    state: readInspectionState(value.state),
    summary: readSummary(value.summary, 'inspection summary must be an object.'),
  };
}

function readMilestoneItems(
  value: unknown,
  message: string,
): MilestoneItemViewModel[] {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }

  return value.map((item) => {
    const record = readRecord(item, 'milestone item must be an object.');
    return {
      milestoneId: readRequiredString(
        record.milestoneId,
        'milestoneId must be a string.',
      ),
      orderId: readRequiredString(record.orderId, 'orderId must be a string.'),
      title: readRequiredString(record.title, 'title must be a string.'),
      amount: readRequiredNumber(record.amount, 'amount must be a number.'),
      state: readMilestoneState(record.state),
      summary: readSummary(record.summary, 'milestone summary must be an object.'),
    };
  });
}

function readOrderState(value: unknown): OrderDetailState {
  if (typeof value === 'string' && ORDER_STATES.has(value as OrderDetailState)) {
    return value as OrderDetailState;
  }
  throw new Error('order state is unsupported.');
}

function readOrderCompletionRequestState(
  value: unknown,
): OrderCompletionRequestState {
  if (
    typeof value === 'string' &&
    ORDER_COMPLETION_REQUEST_STATES.has(value as OrderCompletionRequestState)
  ) {
    return value as OrderCompletionRequestState;
  }
  throw new Error('order completion request state is unsupported.');
}

function readMilestoneState(value: unknown): MilestoneState {
  if (
    typeof value === 'string' &&
    MILESTONE_STATES.has(value as MilestoneState)
  ) {
    return value as MilestoneState;
  }
  throw new Error('milestone state is unsupported.');
}

function readContractState(value: unknown): ContractState {
  if (
    typeof value === 'string' &&
    CONTRACT_STATES.has(value as ContractState)
  ) {
    return value as ContractState;
  }
  throw new Error('contract state is unsupported.');
}

function readInspectionState(value: unknown): InspectionState {
  if (
    typeof value === 'string' &&
    INSPECTION_STATES.has(value as InspectionState)
  ) {
    return value as InspectionState;
  }
  throw new Error('inspection state is unsupported.');
}

function readSummary(value: unknown, message: string): SummaryViewModel {
  return readRecord(value, message);
}

function readRecord(value: unknown, message: string): Record<string, unknown> {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredString(value: unknown, message: string): string {
  if (typeof value === 'string') {
    return value;
  }
  throw new Error(message);
}

function readRequiredNumber(value: unknown, message: string): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  throw new Error(message);
}

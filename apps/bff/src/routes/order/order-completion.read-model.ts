export type OrderCompletionActionKey =
  | 'order_completion_request.submit'
  | 'order_completion_confirm.submit'
  | 'order_completion_reject.submit';

export type OrderCompletionAcceptedResponse = {
  orderId: string;
  projectId: string;
  state: 'active' | 'completed';
  completionRequestState:
    | 'requested'
    | 'confirmed'
    | 'rejected'
    | 'dispute_reserved';
  summary: Record<string, unknown>;
  actionKey: OrderCompletionActionKey;
  routeTarget: {
    objectType: 'order';
    actionKey: 'order_detail.open';
    canonicalPath: '/api/app/order/detail';
    params: {
      orderId: string;
      projectId: string;
    };
  };
};

const ORDER_STATES = new Set(['active', 'completed']);
const COMPLETION_REQUEST_STATES = new Set([
  'requested',
  'confirmed',
  'rejected',
  'dispute_reserved',
]);

export function readOrderCompletionAcceptedResponse(
  value: unknown,
  actionKey: OrderCompletionActionKey,
): OrderCompletionAcceptedResponse {
  const record = requireRecord(
    value,
    'Order completion accepted response must be an object.',
  );
  const orderId = readRequiredString(record.orderId, 'orderId');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const state = readSupportedString(record.state, ORDER_STATES, 'state');
  const completionRequestState = readSupportedString(
    record.completionRequestState,
    COMPLETION_REQUEST_STATES,
    'completionRequestState',
  );

  return {
    orderId,
    projectId,
    state: state as OrderCompletionAcceptedResponse['state'],
    completionRequestState:
      completionRequestState as OrderCompletionAcceptedResponse['completionRequestState'],
    summary: requireRecord(record.summary, 'Order completion summary must be an object.'),
    actionKey,
    routeTarget: {
      objectType: 'order',
      actionKey: 'order_detail.open',
      canonicalPath: '/api/app/order/detail',
      params: {
        orderId,
        projectId,
      },
    },
  };
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readSupportedString(
  value: unknown,
  supported: Set<string>,
  fieldName: string,
) {
  const normalized = readRequiredString(value, fieldName);
  if (!supported.has(normalized)) {
    throw new Error(`Order completion response returned unsupported ${fieldName}.`);
  }
  return normalized;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value === 'string') {
    const normalized = value.trim();
    if (normalized) {
      return normalized;
    }
  }
  throw new Error(`Order completion response is missing \`${fieldName}\`.`);
}

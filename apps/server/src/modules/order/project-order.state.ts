export const PROJECT_ORDER_ACTIVE_STATE = 'active';
export const PROJECT_ORDER_COMPLETED_STATE = 'completed';
export const PROJECT_ORDER_CANCELLED_STATE = 'cancelled';

export const PROJECT_ORDER_STATES = [
  PROJECT_ORDER_ACTIVE_STATE,
  PROJECT_ORDER_COMPLETED_STATE,
  PROJECT_ORDER_CANCELLED_STATE,
] as const;

export type ProjectOrderState = (typeof PROJECT_ORDER_STATES)[number];

export type ProjectOrderAnchor = {
  projectId: string;
  buyerOrganizationId: string;
  sellerOrganizationId: string;
};

export const PROJECT_ORDER_COMPLETION_NONE_STATE = 'none';
export const PROJECT_ORDER_COMPLETION_REQUESTED_STATE = 'requested';
export const PROJECT_ORDER_COMPLETION_REJECTED_STATE = 'rejected';
export const PROJECT_ORDER_COMPLETION_DISPUTE_RESERVED_STATE = 'dispute_reserved';
export const PROJECT_ORDER_COMPLETION_CONFIRMED_STATE = 'confirmed';

export const PROJECT_ORDER_COMPLETION_REQUEST_STATES = [
  PROJECT_ORDER_COMPLETION_NONE_STATE,
  PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
  PROJECT_ORDER_COMPLETION_REJECTED_STATE,
  PROJECT_ORDER_COMPLETION_DISPUTE_RESERVED_STATE,
  PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
] as const;

export type ProjectOrderCompletionRequestState =
  (typeof PROJECT_ORDER_COMPLETION_REQUEST_STATES)[number];

const PROJECT_ORDER_STATE_SET = new Set<string>(PROJECT_ORDER_STATES);
const PROJECT_ORDER_COMPLETION_REQUEST_STATE_SET = new Set<string>(
  PROJECT_ORDER_COMPLETION_REQUEST_STATES,
);

export function normalizeProjectOrderState(value: string | null | undefined): ProjectOrderState | null {
  const normalized = value?.trim() ?? '';
  if (!normalized || !PROJECT_ORDER_STATE_SET.has(normalized)) {
    return null;
  }
  return normalized as ProjectOrderState;
}

export function isProjectOrderState(value: string | null | undefined): value is ProjectOrderState {
  return normalizeProjectOrderState(value) !== null;
}

export function normalizeProjectOrderCompletionRequestState(
  value: string | null | undefined,
): ProjectOrderCompletionRequestState | null {
  const normalized = value?.trim() ?? '';
  if (!normalized || !PROJECT_ORDER_COMPLETION_REQUEST_STATE_SET.has(normalized)) {
    return null;
  }
  return normalized as ProjectOrderCompletionRequestState;
}

export function isProjectOrderCompletionRequestState(
  value: string | null | undefined,
): value is ProjectOrderCompletionRequestState {
  return normalizeProjectOrderCompletionRequestState(value) !== null;
}

export function canTransitionProjectOrderState(
  from: string | null | undefined,
  to: string | null | undefined,
) {
  const source = normalizeProjectOrderState(from);
  const target = normalizeProjectOrderState(to);
  if (!source || !target) {
    return false;
  }
  if (source === target) {
    return true;
  }
  if (source === PROJECT_ORDER_ACTIVE_STATE) {
    return target === PROJECT_ORDER_COMPLETED_STATE || target === PROJECT_ORDER_CANCELLED_STATE;
  }
  return false;
}

export function normalizeProjectOrderAnchor(input: {
  projectId?: string | null;
  buyerOrganizationId?: string | null;
  sellerOrganizationId?: string | null;
}): ProjectOrderAnchor | null {
  const projectId = normalizeRequiredId(input.projectId);
  const buyerOrganizationId = normalizeRequiredId(input.buyerOrganizationId);
  const sellerOrganizationId = normalizeRequiredId(input.sellerOrganizationId);
  if (!projectId || !buyerOrganizationId || !sellerOrganizationId) {
    return null;
  }
  return {
    projectId,
    buyerOrganizationId,
    sellerOrganizationId,
  };
}

function normalizeRequiredId(value: string | null | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : null;
}

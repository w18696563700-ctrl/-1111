export type PaymentStatusCode = 'pending' | 'unavailable' | 'handoff_required';
export type PaymentAvailabilityCode = 'available' | 'unavailable';
export type BillingReferenceStatusCode = 'available' | 'unavailable';
export type BillingReferenceVisibilityCode = 'visible' | 'hidden';
export type PaymentHandoffStatusCode = 'pending' | 'unavailable' | 'handoff_required';
export type PaymentBillingSummaryStatus =
  | 'pending'
  | 'unavailable'
  | 'handoff_required'
  | 'reference_visible'
  | 'reference_unavailable';

type ExplanationItem = {
  explanationKey: string;
  title: string;
  body: string;
};

type HandoffItem = {
  handoffKey: string;
  title: string;
  body: string;
};

type DependencyItem = {
  dependencyKey: string;
  dependencyFamilyKey: string;
  dependencyRequired: boolean;
  dependencyExplanationKey: string;
  dependencyHandoffKey: string;
  title: string;
  body: string;
};

const PAYMENT_EXPLANATIONS: Record<string, ExplanationItem> = {
  payment_pending: {
    explanationKey: 'payment_pending',
    title: '当前支付状态',
    body: '当前支付仍停在边界读取与规则说明阶段，尚未进入资金执行或成功确认。'
  },
  payment_unavailable: {
    explanationKey: 'payment_unavailable',
    title: '当前支付状态',
    body: '当前支付能力在本轮仅保留为只读边界状态，暂不开放本地继续处理。'
  },
  payment_handoff_required: {
    explanationKey: 'payment_handoff_required',
    title: '当前支付状态',
    body: '当前支付只表达 status、handoff 与 dependency reference，后续仍需进入 future settlement/clearing/tax/finance-admin dependency。'
  }
};

const BILLING_EXPLANATIONS: Record<string, ExplanationItem> = {
  billing_reference_visible: {
    explanationKey: 'billing_reference_visible',
    title: '当前账单参考',
    body: '当前仅提供 bounded billing reference，用于说明当前参考编号可见，不构成结算、发票或税务流程 truth。'
  },
  billing_reference_hidden: {
    explanationKey: 'billing_reference_hidden',
    title: '当前账单参考',
    body: '当前账单参考已形成边界引用，但当前轮次不要求在本地直接暴露完整参考内容。'
  },
  billing_reference_unavailable: {
    explanationKey: 'billing_reference_unavailable',
    title: '当前账单参考',
    body: '当前账单参考尚不可用，后续只能通过 future dependency family 继续衔接。'
  }
};

const HANDOFFS: Record<string, HandoffItem> = {
  payment_open_future_finance_dependency: {
    handoffKey: 'payment_open_future_finance_dependency',
    title: '支付处理方向',
    body: '当前支付后续动作只能 handoff 到 future settlement/clearing/tax/finance-admin dependency，本轮不继续执行资金动作。'
  },
  payment_wait_current_boundary: {
    handoffKey: 'payment_wait_current_boundary',
    title: '支付处理方向',
    body: '当前只允许保持边界只读状态，等待未来 package 再开放更大范围能力。'
  },
  billing_reference_view_current_reference: {
    handoffKey: 'billing_reference_view_current_reference',
    title: '账单参考处理方向',
    body: '当前可查看 bounded billing reference，但不得把它解释为已结算、已开票或已完成税务链。'
  },
  billing_reference_wait_future_reference: {
    handoffKey: 'billing_reference_wait_future_reference',
    title: '账单参考处理方向',
    body: '当前账单参考仍需等待 future dependency family 提供进一步能力，本轮不扩到结算、发票或税务系统。'
  },
  open_future_finance_dependency: {
    handoffKey: 'open_future_finance_dependency',
    title: '后续依赖方向',
    body: '当前更大范围财务动作仍只允许表达为 future settlement/clearing/tax/finance-admin dependency。'
  }
};

const DEPENDENCIES: Record<string, DependencyItem> = {
  future_finance_dependency_required: {
    dependencyKey: 'future_finance_dependency_required',
    dependencyFamilyKey: 'future_settlement_clearing_tax_finance_admin',
    dependencyRequired: true,
    dependencyExplanationKey: 'requires_future_finance_dependency',
    dependencyHandoffKey: 'open_future_finance_dependency',
    title: '后续依赖',
    body: '当前 payment / billing 更大范围动作仍需 future settlement/clearing/tax/finance-admin dependency，本轮不进入 execution truth。'
  }
};

export function findPaymentExplanation(explanationKey: string | null) {
  return explanationKey ? PAYMENT_EXPLANATIONS[explanationKey] ?? null : null;
}

export function findBillingExplanation(explanationKey: string | null) {
  return explanationKey ? BILLING_EXPLANATIONS[explanationKey] ?? null : null;
}

export function findHandoff(handoffKey: string | null) {
  return handoffKey ? HANDOFFS[handoffKey] ?? null : null;
}

export function findDependency(dependencyKey: string | null) {
  return dependencyKey ? DEPENDENCIES[dependencyKey] ?? null : null;
}

export function buildSummaryStatus(input: {
  paymentStatus: PaymentStatusCode;
  paymentAvailabilityStatus: PaymentAvailabilityCode;
  billingReferenceStatus: BillingReferenceStatusCode;
  billingReferenceVisibilityStatus: BillingReferenceVisibilityCode;
  handoffStatus: PaymentHandoffStatusCode;
  dependencyRequired: boolean;
}): PaymentBillingSummaryStatus {
  if (
    input.dependencyRequired ||
    input.paymentStatus === 'handoff_required' ||
    input.handoffStatus === 'handoff_required'
  ) {
    return 'handoff_required';
  }
  if (
    input.billingReferenceStatus === 'available' &&
    input.billingReferenceVisibilityStatus === 'visible'
  ) {
    return 'reference_visible';
  }
  if (input.billingReferenceStatus === 'unavailable') {
    return 'reference_unavailable';
  }
  if (input.paymentStatus === 'pending') {
    return 'pending';
  }
  if (input.paymentAvailabilityStatus === 'unavailable') {
    return 'unavailable';
  }
  return 'reference_visible';
}

export function getPaymentBillingDisclaimer() {
  return '当前支付与账单内容只承接 payment-status、billing-reference、handoff、explanation 与 dependency reference，不构成 payment execution、settlement、clearing、invoice、tax 或 finance-admin truth。';
}

export type CreditConstraintStatus = 'clear' | 'constrained';
export type PerformanceConstraintStatus = 'clear' | 'constrained';
export type ExecutionAvailabilityStatus = 'available' | 'limited' | 'blocked';
export type DepositRequirementStatus = 'not_required' | 'required';
export type DepositEligibilityStatus = 'eligible' | 'not_eligible';
export type DepositRestrictionStatus = 'clear' | 'restricted';
export type DepositPostureStatus = 'clear' | 'restricted' | 'handoff_required';
export type TransactionGuaranteeEligibilityStatus = 'eligible' | 'not_eligible';
export type TransactionGuaranteeRestrictionStatus = 'clear' | 'restricted';
export type CreditAndConstraintsSummaryStatus =
  | 'clear'
  | 'limited'
  | 'blocked'
  | 'handoff_required';

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

const CREDIT_EXPLANATIONS: Record<string, ExplanationItem> = {
  credit_clear: {
    explanationKey: 'credit_clear',
    title: '当前信用约束',
    body: '当前未见会阻断后续衔接的信用或履约约束，后续仍以当前组织 scope 下的 posture truth 为准。'
  },
  credit_constrained: {
    explanationKey: 'credit_constrained',
    title: '当前信用约束',
    body: '当前组织存在信用或履约约束姿态，后续只能先补足前置条件，再进入下一步依赖能力。'
  },
  credit_advisory: {
    explanationKey: 'credit_advisory',
    title: '当前信用约束',
    body: '当前组织没有硬阻断，但存在规则提示。当前包只表达 posture，不自动进入 payment、billing 或治理执行。'
  }
};

const DEPOSIT_EXPLANATIONS: Record<string, ExplanationItem> = {
  deposit_clear: {
    explanationKey: 'deposit_clear',
    title: '当前保证金姿态',
    body: '当前保证金相关 posture 未形成约束。本轮只承接 requirement、eligibility、restriction 与 handoff 语义。'
  },
  deposit_restricted: {
    explanationKey: 'deposit_restricted',
    title: '当前保证金姿态',
    body: '当前保证金 posture 形成限制，后续需要先消除当前约束，才能继续进入后续依赖能力。'
  },
  deposit_dependency_required: {
    explanationKey: 'deposit_dependency_required',
    title: '当前保证金姿态',
    body: '当前保证金只停在 posture 与 handoff 层，真实支付、冻结、退款、清算仍需 V2.2 payment/billing package dependency。'
  }
};

const TRANSACTION_GUARANTEE_EXPLANATIONS: Record<string, ExplanationItem> = {
  transaction_guarantee_clear: {
    explanationKey: 'transaction_guarantee_clear',
    title: '当前交易保障姿态',
    body: '当前交易保障没有形成额外限制，仍以当前组织 scope 下的 guarantee posture truth 为准。'
  },
  transaction_guarantee_dependency_required: {
    explanationKey: 'transaction_guarantee_dependency_required',
    title: '当前交易保障姿态',
    body: '当前交易保障仍停在 eligibility、restriction 与 handoff posture，不进入 dispute 或治理裁定。'
  },
  transaction_guarantee_restricted: {
    explanationKey: 'transaction_guarantee_restricted',
    title: '当前交易保障姿态',
    body: '当前交易保障 posture 存在限制，需先补足前置条件，再进入后续能力。'
  }
};

const HANDOFFS: Record<string, HandoffItem> = {
  credit_readonly_no_action: {
    handoffKey: 'credit_readonly_no_action',
    title: '信用处理方向',
    body: '当前信用 posture 只提供只读说明，不会直接触发任何资金或治理执行。'
  },
  credit_rule_explanation: {
    handoffKey: 'credit_rule_explanation',
    title: '信用处理方向',
    body: '当前建议先查看规则说明，确认限制与提示来源，再决定后续组织侧动作。'
  },
  deposit_open_payment_dependency: {
    handoffKey: 'deposit_open_payment_dependency',
    title: '保证金处理方向',
    body: '当前只允许 handoff 到后续 payment/billing capability family；本轮不执行具体缴纳或冻结。'
  },
  deposit_resolve_restriction: {
    handoffKey: 'deposit_resolve_restriction',
    title: '保证金处理方向',
    body: '当前需先消除现有限制，再回到后续依赖能力。'
  },
  transaction_guarantee_open_dependency: {
    handoffKey: 'transaction_guarantee_open_dependency',
    title: '交易保障处理方向',
    body: '当前保障语义只表达 handoff 与 dependency posture，真实交易保障动作仍依赖后续 package。'
  },
  transaction_guarantee_resolve_restriction: {
    handoffKey: 'transaction_guarantee_resolve_restriction',
    title: '交易保障处理方向',
    body: '当前需先处理保障限制，再决定是否继续进入后续 capability family。'
  },
  open_v22_payment_billing: {
    handoffKey: 'open_v22_payment_billing',
    title: '后续依赖方向',
    body: '当前后续动作仍需 V2.2 payment/billing package dependency，本轮不提供资金执行。'
  }
};

const DEPENDENCIES: Record<string, DependencyItem> = {
  v22_payment_billing_required: {
    dependencyKey: 'v22_payment_billing_required',
    dependencyFamilyKey: 'v22_payment_billing',
    dependencyRequired: true,
    dependencyExplanationKey: 'requires_v22_payment_billing',
    dependencyHandoffKey: 'open_v22_payment_billing',
    title: '后续依赖',
    body: '当前真实资金动作仍属于 V2.2 payment/billing package dependency，本轮只表达 dependency reference。'
  }
};

export function findCreditExplanation(explanationKey: string | null) {
  return explanationKey ? CREDIT_EXPLANATIONS[explanationKey] ?? null : null;
}

export function findDepositExplanationByStatus(status: DepositPostureStatus) {
  if (status === 'handoff_required') {
    return DEPOSIT_EXPLANATIONS.deposit_dependency_required;
  }
  if (status === 'restricted') {
    return DEPOSIT_EXPLANATIONS.deposit_restricted;
  }
  return DEPOSIT_EXPLANATIONS.deposit_clear;
}

export function findTransactionGuaranteeExplanation(explanationKey: string | null) {
  return explanationKey ? TRANSACTION_GUARANTEE_EXPLANATIONS[explanationKey] ?? null : null;
}

export function findHandoff(handoffKey: string | null) {
  return handoffKey ? HANDOFFS[handoffKey] ?? null : null;
}

export function findDependency(dependencyKey: string | null) {
  return dependencyKey ? DEPENDENCIES[dependencyKey] ?? null : null;
}

export function buildSummaryStatus(input: {
  creditConstraintStatus: CreditConstraintStatus;
  performanceConstraintStatus: PerformanceConstraintStatus;
  executionAvailabilityStatus: ExecutionAvailabilityStatus;
  depositPostureStatus: DepositPostureStatus;
  transactionGuaranteeRestrictionStatus: TransactionGuaranteeRestrictionStatus;
  dependencyRequired: boolean;
}): CreditAndConstraintsSummaryStatus {
  if (
    input.executionAvailabilityStatus === 'blocked' ||
    input.depositPostureStatus === 'restricted' ||
    input.transactionGuaranteeRestrictionStatus === 'restricted'
  ) {
    return 'blocked';
  }
  if (input.dependencyRequired || input.depositPostureStatus === 'handoff_required') {
    return 'handoff_required';
  }
  if (
    input.creditConstraintStatus === 'constrained' ||
    input.performanceConstraintStatus === 'constrained' ||
    input.executionAvailabilityStatus === 'limited'
  ) {
    return 'limited';
  }
  return 'clear';
}

export function getCreditAndConstraintsDisclaimer() {
  return '当前信用、保证金与交易保障内容只承接 posture、explanation、handoff 与 dependency reference，不构成 payment、billing、settlement 或治理执行 truth。';
}

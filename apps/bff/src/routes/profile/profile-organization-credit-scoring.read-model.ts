import {
  readNullableString,
  readRequiredString,
  requireKeys,
  requireRecord,
} from './profile-credit-constraints.parse-helpers';

type ReserveSampleStatus = 'UNAVAILABLE' | 'INSUFFICIENT' | 'SUFFICIENT';
type ReserveRiskPosture = 'UNAVAILABLE' | 'LOW' | 'MEDIUM' | 'HIGH' | null;

export type OrganizationCreditScoringStatusViewModel = {
  score: number | null;
  tierCode: string | null;
  tierLabel: string | null;
  sampleStatus: ReserveSampleStatus;
  riskPosture: ReserveRiskPosture;
  ratedCompletedOrderCount: number;
  positiveRate: number | null;
  negativeRate: number | null;
  verySatisfiedCount: number;
  satisfiedCount: number;
  passableCount: number;
  negativeCount: number;
  actionableState: string | null;
  updatedAt: string | null;
};

export type OrganizationCreditScoringExplanationViewModel = {
  reasonSummary: string;
  reasonCodes: string[];
  sampleStatus: ReserveSampleStatus;
  riskPosture: ReserveRiskPosture;
  ratedCompletedOrderCount: number;
  positiveRate: number | null;
  negativeRate: number | null;
  verySatisfiedCount: number;
  satisfiedCount: number;
  passableCount: number;
  negativeCount: number;
  updatedAt: string | null;
};

export type OrganizationCreditScoringHandoffViewModel = {
  actionableState: string | null;
  sampleStatus: ReserveSampleStatus;
  riskPosture: ReserveRiskPosture;
  primaryActionCode: string | null;
  primaryActionLabel: string | null;
  handoffMessage: string | null;
  updatedAt: string | null;
};

const SAMPLE_STATUS_VALUES = new Set<ReserveSampleStatus>([
  'UNAVAILABLE',
  'INSUFFICIENT',
  'SUFFICIENT',
]);
const RISK_POSTURE_VALUES = new Set<Exclude<ReserveRiskPosture, null>>([
  'UNAVAILABLE',
  'LOW',
  'MEDIUM',
  'HIGH',
]);

export function readOrganizationCreditScoringStatusViewModel(
  result: Record<string, unknown>,
): OrganizationCreditScoringStatusViewModel {
  requireKeys(result, [
    'score',
    'tierCode',
    'tierLabel',
    'sampleStatus',
    'riskPosture',
    'ratedCompletedOrderCount',
    'positiveRate',
    'negativeRate',
    'verySatisfiedCount',
    'satisfiedCount',
    'passableCount',
    'negativeCount',
    'actionableState',
    'updatedAt',
  ]);

  return {
    score: readNullableNumber(result.score, 'Organization-credit-scoring status score is invalid.'),
    tierCode: readNullableString(result.tierCode),
    tierLabel: readNullableString(result.tierLabel),
    sampleStatus: readSampleStatus(
      result.sampleStatus,
      'Organization-credit-scoring status sampleStatus is invalid.',
    ),
    riskPosture: readRiskPosture(
      result.riskPosture,
      'Organization-credit-scoring status riskPosture is invalid.',
    ),
    ratedCompletedOrderCount: readRequiredInteger(
      result.ratedCompletedOrderCount,
      'Organization-credit-scoring status ratedCompletedOrderCount is invalid.',
    ),
    positiveRate: readNullableNumber(
      result.positiveRate,
      'Organization-credit-scoring status positiveRate is invalid.',
    ),
    negativeRate: readNullableNumber(
      result.negativeRate,
      'Organization-credit-scoring status negativeRate is invalid.',
    ),
    verySatisfiedCount: readRequiredInteger(
      result.verySatisfiedCount,
      'Organization-credit-scoring status verySatisfiedCount is invalid.',
    ),
    satisfiedCount: readRequiredInteger(
      result.satisfiedCount,
      'Organization-credit-scoring status satisfiedCount is invalid.',
    ),
    passableCount: readRequiredInteger(
      result.passableCount,
      'Organization-credit-scoring status passableCount is invalid.',
    ),
    negativeCount: readRequiredInteger(
      result.negativeCount,
      'Organization-credit-scoring status negativeCount is invalid.',
    ),
    actionableState: readNullableString(result.actionableState),
    updatedAt: readNullableString(result.updatedAt),
  };
}

export function readOrganizationCreditScoringExplanationViewModel(
  result: Record<string, unknown>,
): OrganizationCreditScoringExplanationViewModel {
  requireKeys(result, [
    'reasonSummary',
    'reasonCodes',
    'sampleStatus',
    'riskPosture',
    'ratedCompletedOrderCount',
    'positiveRate',
    'negativeRate',
    'verySatisfiedCount',
    'satisfiedCount',
    'passableCount',
    'negativeCount',
    'updatedAt',
  ]);

  return {
    reasonSummary: readRequiredString(
      result.reasonSummary,
      'Organization-credit-scoring explanation reasonSummary is invalid.',
    ),
    reasonCodes: readRequiredStringArray(
      result.reasonCodes,
      'Organization-credit-scoring explanation reasonCodes is invalid.',
    ),
    sampleStatus: readSampleStatus(
      result.sampleStatus,
      'Organization-credit-scoring explanation sampleStatus is invalid.',
    ),
    riskPosture: readRiskPosture(
      result.riskPosture,
      'Organization-credit-scoring explanation riskPosture is invalid.',
    ),
    ratedCompletedOrderCount: readRequiredInteger(
      result.ratedCompletedOrderCount,
      'Organization-credit-scoring explanation ratedCompletedOrderCount is invalid.',
    ),
    positiveRate: readNullableNumber(
      result.positiveRate,
      'Organization-credit-scoring explanation positiveRate is invalid.',
    ),
    negativeRate: readNullableNumber(
      result.negativeRate,
      'Organization-credit-scoring explanation negativeRate is invalid.',
    ),
    verySatisfiedCount: readRequiredInteger(
      result.verySatisfiedCount,
      'Organization-credit-scoring explanation verySatisfiedCount is invalid.',
    ),
    satisfiedCount: readRequiredInteger(
      result.satisfiedCount,
      'Organization-credit-scoring explanation satisfiedCount is invalid.',
    ),
    passableCount: readRequiredInteger(
      result.passableCount,
      'Organization-credit-scoring explanation passableCount is invalid.',
    ),
    negativeCount: readRequiredInteger(
      result.negativeCount,
      'Organization-credit-scoring explanation negativeCount is invalid.',
    ),
    updatedAt: readNullableString(result.updatedAt),
  };
}

export function readOrganizationCreditScoringHandoffViewModel(
  result: Record<string, unknown>,
): OrganizationCreditScoringHandoffViewModel {
  requireKeys(result, [
    'actionableState',
    'sampleStatus',
    'riskPosture',
    'primaryActionCode',
    'primaryActionLabel',
    'handoffMessage',
    'updatedAt',
  ]);

  return {
    actionableState: readNullableString(result.actionableState),
    sampleStatus: readSampleStatus(
      result.sampleStatus,
      'Organization-credit-scoring handoff sampleStatus is invalid.',
    ),
    riskPosture: readRiskPosture(
      result.riskPosture,
      'Organization-credit-scoring handoff riskPosture is invalid.',
    ),
    primaryActionCode: readNullableString(result.primaryActionCode),
    primaryActionLabel: readNullableString(result.primaryActionLabel),
    handoffMessage: readNullableString(result.handoffMessage),
    updatedAt: readNullableString(result.updatedAt),
  };
}

function readSampleStatus(value: unknown, message: string): ReserveSampleStatus {
  const sampleStatus = readRequiredString(value, message) as ReserveSampleStatus;
  if (!SAMPLE_STATUS_VALUES.has(sampleStatus)) {
    throw new Error(message);
  }
  return sampleStatus;
}

function readRiskPosture(value: unknown, message: string): ReserveRiskPosture {
  if (value === null || value === undefined) {
    return null;
  }
  const riskPosture = readRequiredString(value, message) as Exclude<ReserveRiskPosture, null>;
  if (!RISK_POSTURE_VALUES.has(riskPosture)) {
    throw new Error(message);
  }
  return riskPosture;
}

function readRequiredInteger(value: unknown, message: string) {
  const numeric = readNullableNumber(value, message);
  if (numeric === null || !Number.isInteger(numeric)) {
    throw new Error(message);
  }
  return numeric;
}

function readNullableNumber(value: unknown, message: string) {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && value.trim().length > 0) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  throw new Error(message);
}

function readRequiredStringArray(value: unknown, message: string) {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }
  return value.map((item, index) =>
    readRequiredString(
      item,
      `${message} Item at index ${index} is invalid.`,
    ),
  );
}

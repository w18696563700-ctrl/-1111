export const CERTIFICATION_STATUS_VALUES = [
  'not_submitted',
  'pending_review',
  'approved',
  'rejected',
  'expired',
] as const;

export const MEMBERSHIP_STATUS_VALUES = [
  'invited',
  'pending_accept',
  'active',
  'disabled',
  'removed',
] as const;

export type CertificationStatus = (typeof CERTIFICATION_STATUS_VALUES)[number];
export type MembershipStatus = (typeof MEMBERSHIP_STATUS_VALUES)[number];

const CERTIFICATION_STATUS_SET = new Set<string>(CERTIFICATION_STATUS_VALUES);
const MEMBERSHIP_STATUS_SET = new Set<string>(MEMBERSHIP_STATUS_VALUES);

export function readCertificationStatus(value: unknown, message: string): CertificationStatus {
  const normalized = readTrimmedString(value);
  if (normalized && CERTIFICATION_STATUS_SET.has(normalized)) {
    return normalized as CertificationStatus;
  }
  throw new Error(message);
}

export function readNullableCertificationStatus(
  value: unknown,
  message: string,
): CertificationStatus | null {
  if (value === null) {
    return null;
  }
  return readCertificationStatus(value, message);
}

export function readMembershipStatus(value: unknown, message: string): MembershipStatus {
  const normalized = readTrimmedString(value);
  if (normalized && MEMBERSHIP_STATUS_SET.has(normalized)) {
    return normalized as MembershipStatus;
  }
  throw new Error(message);
}

export function readNullableMembershipStatus(
  value: unknown,
  message: string,
): MembershipStatus | null {
  if (value === null) {
    return null;
  }
  return readMembershipStatus(value, message);
}

export function assertScopedStatusConsistency(input: {
  context: string;
  organizationId: string | null;
  certificationStatus: CertificationStatus | null;
  membershipStatus: MembershipStatus | null;
}) {
  if (!input.organizationId) {
    if (input.certificationStatus !== null || input.membershipStatus !== null) {
      throw new Error(`${input.context} cannot expose certification or membership status without organization scope.`);
    }
    return;
  }

  if (!input.certificationStatus || !input.membershipStatus) {
    throw new Error(`${input.context} is missing certification or membership status for the current organization scope.`);
  }
}

function readTrimmedString(value: unknown) {
  if (typeof value !== 'string') {
    return '';
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : '';
}

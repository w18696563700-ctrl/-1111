import type { CertificationStatus, MembershipStatus } from './profile-status.read-model';

export type OrganizationCreateAcceptedViewModel = {
  organizationId: string;
  roleKeys: string[];
  membershipStatus: MembershipStatus;
  certificationStatus: CertificationStatus;
};

export type OrganizationJoinAcceptedViewModel = {
  organizationId: string;
  roleKeys: string[];
  membershipStatus: MembershipStatus;
  certificationStatus: CertificationStatus;
  traceId: string;
};

export type ProfileShellContextCompatibleViewModel = {
  userId: string;
  organizationId: string;
  roleKeys: string[];
  certificationStatus: CertificationStatus;
  membershipStatus: MembershipStatus;
  visibleBuildings: string[];
  featureFlagsVersion: string;
  unreadSummary: Record<string, unknown>;
};

export type CertificationAcceptedViewModel = {
  organizationId: string;
  certificationStatus: CertificationStatus;
  submittedAt: string | null;
  traceId: string;
};

export type PersonalProfileAcceptedViewModel = {
  ok: boolean;
  traceId: string;
  displayName: string;
  avatarUrl: string | null;
};

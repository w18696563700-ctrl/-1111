import type {
  CertificationStatus,
  MembershipStatus,
} from "./profile-status.read-model";

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

export type OrganizationLeaveAcceptedViewModel = {
  leftOrganizationId: string;
  nextOrganizationId: string | null;
  shellBootstrapState: "authenticated" | "no_organization";
  traceId: string;
};

export type ProfileShellContextCompatibleViewModel = {
  userId: string;
  organizationId: string;
  roleKeys: string[];
  certificationStatus: CertificationStatus;
  personalCertificationStatus?: CertificationStatus | null;
  personalCertificationQualified?: boolean | null;
  personalCertificationLockedToOtherActor?: boolean | null;
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

export type CertificationLicenseOcrViewModel = {
  status: "recognized" | "partial" | "manual_required";
  message: string;
  legalName: string | null;
  uscc: string | null;
  legalPerson: string | null;
  businessType: string | null;
  address: string | null;
  registeredCapital: string | null;
  establishedAt: string | null;
  businessTerm: string | null;
  businessScope: string | null;
  providerRequestId: string | null;
};

export type PersonalCertificationIdCardOcrViewModel = {
  status: 'recognized' | 'manual_required';
  message: string;
  realName: string | null;
  idNumberMasked: string | null;
  providerRequestId: string | null;
};

export type PersonalCertificationAcceptedViewModel = {
  organizationId: string;
  userId: string;
  certificationStatus: CertificationStatus;
  submittedAt: string | null;
  lockedAt: string | null;
  traceId: string;
};

export type ProfileActionAckViewModel = {
  ok: boolean;
  traceId: string;
};

export type PersonalProfileAcceptedViewModel = {
  ok: boolean;
  traceId: string;
  displayName: string;
  avatarUrl: string | null;
};

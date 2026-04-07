import type { MembershipStatus } from './profile-status.read-model';

export const APP_ROLE_KEY_VALUES = [
  'buyer_admin',
  'buyer_member(scoped)',
  'supplier_admin',
  'supplier_member(scoped)',
] as const;

export type AppRoleKey = (typeof APP_ROLE_KEY_VALUES)[number];

export type OrganizationMemberItemViewModel = {
  memberId: string;
  userId: string;
  displayName: string | null;
  mobileMasked: string | null;
  roleKey: AppRoleKey;
  memberStatus: MembershipStatus;
  joinedAt: string | null;
  disabledAt: string | null;
};

export type OrganizationMembersViewModel = {
  items: OrganizationMemberItemViewModel[];
};

export type ActionAckViewModel = {
  ok: true;
  traceId: string;
};

const APP_ROLE_KEY_SET = new Set<string>(APP_ROLE_KEY_VALUES);

export function readAppRoleKey(value: unknown, message: string): AppRoleKey {
  if (typeof value !== 'string') {
    throw new Error(message);
  }

  const normalized = value.trim();
  if (APP_ROLE_KEY_SET.has(normalized)) {
    return normalized as AppRoleKey;
  }

  throw new Error(message);
}

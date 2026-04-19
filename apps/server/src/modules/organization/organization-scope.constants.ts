export const APP_ORGANIZATION_ROLE_KEYS = new Set([
  'buyer_admin',
  'buyer_member(scoped)',
  'supplier_admin',
  'supplier_member(scoped)',
]);

export function isAppFacingOrganizationType(organizationType: string | null | undefined) {
  return (organizationType?.trim() ?? '') !== 'platform';
}

import { MembershipShell } from '@/modules/membership/membership-shell';

export const dynamic = 'force-dynamic';

type MembershipPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function MembershipPage({ searchParams }: MembershipPageProps) {
  const query = await searchParams;
  return (
    <MembershipShell
      membershipOrderId={readQueryParam(query?.membershipOrderId)}
      organizationId={readQueryParam(query?.organizationId)}
      orderStatus={readQueryParam(query?.orderStatus)}
      paymentStatus={readQueryParam(query?.paymentStatus)}
      entitlementStatus={readQueryParam(query?.entitlementStatus)}
      error={readQueryParam(query?.error)}
    />
  );
}

function readQueryParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

import { OrganizationReviewShell } from '@/modules/review/organization-review-shell';

export const dynamic = 'force-dynamic';

type OrganizationReviewDetailPageProps = {
  params: Promise<{ organizationId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function OrganizationReviewDetailPage({
  params,
  searchParams
}: OrganizationReviewDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <OrganizationReviewShell
      selectedOrganizationId={resolvedParams.organizationId}
      organizationId={readQueryParam(query?.organizationId)}
      notice={readQueryParam(query?.notice)}
      error={readQueryParam(query?.error)}
      status={readQueryParam(query?.status)}
      keyword={readQueryParam(query?.keyword)}
    />
  );
}

function readQueryParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

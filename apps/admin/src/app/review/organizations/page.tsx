import { OrganizationReviewShell } from '@/modules/review/organization-review-shell';

export const dynamic = 'force-dynamic';

type OrganizationReviewPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function OrganizationReviewPage({
  searchParams
}: OrganizationReviewPageProps) {
  const query = await searchParams;
  return (
    <OrganizationReviewShell
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

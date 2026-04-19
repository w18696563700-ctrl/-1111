import { EnterpriseHubApplicationReviewShell } from '@/modules/review/enterprise-hub-application-review-shell';

export const dynamic = 'force-dynamic';

type EnterpriseHubApplicationReviewDetailPageProps = {
  params: Promise<{ applicationId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function EnterpriseHubApplicationReviewDetailPage({
  params,
  searchParams,
}: EnterpriseHubApplicationReviewDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <EnterpriseHubApplicationReviewShell
      selectedApplicationId={resolvedParams.applicationId}
      applicationStatus={readQueryParam(query?.applicationStatus)}
      boardType={readQueryParam(query?.boardType)}
      notice={readQueryParam(query?.notice)}
      error={readQueryParam(query?.error)}
    />
  );
}

function readQueryParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

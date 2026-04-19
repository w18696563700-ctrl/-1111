import { PublishedChangeReviewShell } from '@/modules/published_change_review/published-change-review-shell';

export const dynamic = 'force-dynamic';

type PublishedChangeReviewDetailPageProps = {
  params: Promise<{ changeRequestId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function PublishedChangeReviewDetailPage({
  params,
  searchParams,
}: PublishedChangeReviewDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <PublishedChangeReviewShell
      selectedChangeRequestId={resolvedParams.changeRequestId}
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

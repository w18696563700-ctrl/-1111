import { PublishedChangeReviewShell } from '@/modules/published_change_review/published-change-review-shell';

export const dynamic = 'force-dynamic';

type PublishedChangeReviewPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function PublishedChangeReviewPage({
  searchParams,
}: PublishedChangeReviewPageProps) {
  const query = await searchParams;
  return (
    <PublishedChangeReviewShell
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

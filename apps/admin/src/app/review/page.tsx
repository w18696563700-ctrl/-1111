import { ReviewShell } from '@/modules/review/review-shell';

export const dynamic = 'force-dynamic';

type ReviewPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function ReviewPage({ searchParams }: ReviewPageProps) {
  const params = await searchParams;
  return (
    <ReviewShell
      selectedTaskId={readQueryParam(params?.taskId)}
      notice={readQueryParam(params?.notice)}
      error={readQueryParam(params?.error)}
    />
  );
}

function readQueryParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

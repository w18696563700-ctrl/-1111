import { PenaltyShell } from '@/modules/governance/penalty-shell';

export const dynamic = 'force-dynamic';

type PenaltyDetailPageProps = {
  params: Promise<{ penaltyId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function PenaltyDetailPage({
  params,
  searchParams
}: PenaltyDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <PenaltyShell
      selectedPenaltyId={resolvedParams.penaltyId}
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

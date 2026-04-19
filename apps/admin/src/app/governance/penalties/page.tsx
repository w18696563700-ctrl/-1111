import { PenaltyShell } from '@/modules/governance/penalty-shell';

export const dynamic = 'force-dynamic';

type PenaltyPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function PenaltyPage({ searchParams }: PenaltyPageProps) {
  const params = await searchParams;
  return (
    <PenaltyShell
      selectedPenaltyId={readQueryParam(params?.penaltyId)}
      notice={readQueryParam(params?.notice)}
      error={readQueryParam(params?.error)}
      status={readQueryParam(params?.status)}
      keyword={readQueryParam(params?.keyword)}
    />
  );
}

function readQueryParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

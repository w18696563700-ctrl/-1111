import { AppealShell } from '@/modules/governance/appeal-shell';

export const dynamic = 'force-dynamic';

type AppealDetailPageProps = {
  params: Promise<{ appealCaseId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function AppealDetailPage({
  params,
  searchParams
}: AppealDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <AppealShell
      selectedAppealCaseId={resolvedParams.appealCaseId}
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

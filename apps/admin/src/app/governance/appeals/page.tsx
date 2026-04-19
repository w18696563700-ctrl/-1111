import { AppealShell } from '@/modules/governance/appeal-shell';

export const dynamic = 'force-dynamic';

type AppealPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function AppealPage({ searchParams }: AppealPageProps) {
  const params = await searchParams;
  return (
    <AppealShell
      selectedAppealCaseId={readQueryParam(params?.appealCaseId)}
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

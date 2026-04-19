import { ProjectReviewShell } from '@/modules/project_review/project-review-shell';

export const dynamic = 'force-dynamic';

type ProjectReviewDetailPageProps = {
  params: Promise<{ reportCaseId: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function ProjectReviewDetailPage({
  params,
  searchParams
}: ProjectReviewDetailPageProps) {
  const resolvedParams = await params;
  const query = await searchParams;
  return (
    <ProjectReviewShell
      selectedReportCaseId={resolvedParams.reportCaseId}
      notice={readQueryParam(query?.notice)}
      error={readQueryParam(query?.error)}
      status={readQueryParam(query?.status)}
      targetType={readQueryParam(query?.targetType)}
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

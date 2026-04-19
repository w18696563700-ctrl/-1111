import { TemplateConfigShell } from '@/modules/template_config/template-config-shell';

export const dynamic = 'force-dynamic';

type TemplateConfigPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function TemplateConfigPage({ searchParams }: TemplateConfigPageProps) {
  const query = await searchParams;
  return (
    <TemplateConfigShell
      selectedTemplateId={readQueryParam(query?.templateId)}
      selectedTemplateVersionId={readQueryParam(query?.templateVersionId)}
      baseVersionId={readQueryParam(query?.baseVersionId)}
      targetVersionId={readQueryParam(query?.targetVersionId)}
      status={readQueryParam(query?.status)}
      groupRef={readQueryParam(query?.groupRef)}
      keyword={readQueryParam(query?.keyword)}
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

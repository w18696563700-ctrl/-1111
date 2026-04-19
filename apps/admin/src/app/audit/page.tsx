import { AuditShell } from '@/modules/audit/audit-shell';

export const dynamic = 'force-dynamic';

type AuditPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function AuditPage({ searchParams }: AuditPageProps) {
  const query = await searchParams;
  return (
    <AuditShell
      selectedAuditLogId={readQueryParam(query?.auditLogId)}
      sourceFamily={readQueryParam(query?.sourceFamily)}
      objectType={readQueryParam(query?.objectType)}
      objectId={readQueryParam(query?.objectId)}
      objectNo={readQueryParam(query?.objectNo)}
      actorId={readQueryParam(query?.actorId)}
      requestId={readQueryParam(query?.requestId)}
      traceId={readQueryParam(query?.traceId)}
      action={readQueryParam(query?.action)}
      occurredFrom={readQueryParam(query?.occurredFrom)}
      occurredTo={readQueryParam(query?.occurredTo)}
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

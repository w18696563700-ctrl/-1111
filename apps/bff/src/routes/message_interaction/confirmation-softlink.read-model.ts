export function readConfirmationSoftLinkReadModel(value: unknown) {
  const root = asRecord(value) ?? {};
  return {
    projectId: readOptionalString(root.projectId) ?? '',
    threadId: readOptionalString(root.threadId) ?? '',
    messageId: readOptionalString(root.messageId) ?? '',
    confirmationType: readOptionalString(root.confirmationType) ?? 'quote',
    status: readOptionalString(root.status) ?? 'pending',
    title: readOptionalString(root.title),
    summary: readOptionalString(root.summary),
    routeTarget: readRouteTarget(root.routeTarget)
  };
}

function readRouteTarget(value: unknown) {
  const routeTarget = asRecord(value);
  return routeTarget && Object.keys(routeTarget).length > 0 ? routeTarget : null;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : null;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

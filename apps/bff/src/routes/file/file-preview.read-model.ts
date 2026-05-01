export function readFilePreviewAccessReadModel(value: unknown) {
  const root = asRecord(value) ?? {};
  const accessUrl = readOptionalString(root.accessUrl);
  const canPreview = root.canPreview === true;
  return {
    fileAssetId: readOptionalString(root.fileAssetId) ?? '',
    projectId: readOptionalString(root.projectId) ?? '',
    threadId: readOptionalString(root.threadId) ?? '',
    previewType: readOptionalString(root.previewType) ?? 'unsupported',
    canPreview,
    fileName: readOptionalString(root.fileName),
    mimeType: readOptionalString(root.mimeType),
    accessUrl: canPreview ? accessUrl : null,
    expiresAt: canPreview ? readOptionalString(root.expiresAt) : null,
    contentLengthBytes: readOptionalNumber(root.contentLengthBytes),
    downloadAvailable: root.downloadAvailable === true,
    fallbackReason: readOptionalString(root.fallbackReason)
  };
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : null;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function readOptionalNumber(value: unknown) {
  const parsed = typeof value === 'number' ? value : Number(value ?? NaN);
  return Number.isFinite(parsed) ? parsed : null;
}

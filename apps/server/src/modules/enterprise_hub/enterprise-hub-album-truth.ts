export const ENTERPRISE_HUB_ALBUM_LIMIT = 6;

export function normalizeEnterpriseAlbumFileAssetIds(
  values: ReadonlyArray<string | null | undefined> | null | undefined,
) {
  const normalized: string[] = [];
  for (const item of values ?? []) {
    const fileAssetId = item?.trim() ?? '';
    if (!fileAssetId || normalized.includes(fileAssetId)) {
      continue;
    }
    normalized.push(fileAssetId);
    if (normalized.length >= ENTERPRISE_HUB_ALBUM_LIMIT) {
      break;
    }
  }
  return normalized;
}

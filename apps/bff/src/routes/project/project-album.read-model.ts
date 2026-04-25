type AlbumRecord = Record<string, unknown>;

export type ProjectAlbumPhotoReadModel = {
  photoId: string;
  projectId: string;
  fileAssetId: string;
  category: string;
  caption: string | null;
  mimeType: string;
  sortOrder: number;
  photoState: string;
  uploadedByUserId: string;
  uploadedByActorId: string | null;
  uploadedByOrganizationId: string;
  createdAt: string;
  removedAt: string | null;
};

export type ProjectAlbumPhotoListReadModel = {
  projectId: string;
  limit: number;
  photoCount: number;
  items: ProjectAlbumPhotoReadModel[];
};

export function readProjectAlbumPhotoListReadModel(
  value: unknown,
): ProjectAlbumPhotoListReadModel {
  const source = readRecord(value, 'Project album list must be an object.');
  const projectId = readString(source.projectId, 'projectId');
  const limit = readNumber(source.limit, 'limit');
  const items = readArray(source.items, 'items').map(readProjectAlbumPhotoReadModel);
  const photoCount = readNumber(source.photoCount, 'photoCount');
  return {
    projectId,
    limit,
    photoCount,
    items,
  };
}

export function readProjectAlbumPhotoReadModel(
  value: unknown,
): ProjectAlbumPhotoReadModel {
  const source = readRecord(value, 'Project album photo must be an object.');
  return {
    photoId: readString(source.photoId, 'photoId'),
    projectId: readString(source.projectId, 'projectId'),
    fileAssetId: readString(source.fileAssetId, 'fileAssetId'),
    category: readString(source.category, 'category'),
    caption: readNullableString(source.caption, 'caption'),
    mimeType: readString(source.mimeType, 'mimeType'),
    sortOrder: readNumber(source.sortOrder, 'sortOrder'),
    photoState: readString(source.photoState, 'photoState'),
    uploadedByUserId: readString(source.uploadedByUserId, 'uploadedByUserId'),
    uploadedByActorId: readNullableString(source.uploadedByActorId, 'uploadedByActorId'),
    uploadedByOrganizationId: readString(
      source.uploadedByOrganizationId,
      'uploadedByOrganizationId',
    ),
    createdAt: readString(source.createdAt, 'createdAt'),
    removedAt: readNullableString(source.removedAt, 'removedAt'),
  };
}

function readRecord(value: unknown, message: string): AlbumRecord {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as AlbumRecord;
  }
  throw new Error(message);
}

function readArray(value: unknown, field: string): unknown[] {
  if (Array.isArray(value)) {
    return value;
  }
  throw new Error(`Project album response field \`${field}\` must be an array.`);
}

function readString(value: unknown, field: string): string {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  throw new Error(`Project album response field \`${field}\` must be a non-empty string.`);
}

function readNullableString(value: unknown, field: string): string | null {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === 'string') {
    return value;
  }
  throw new Error(`Project album response field \`${field}\` must be a string or null.`);
}

function readNumber(value: unknown, field: string): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  throw new Error(`Project album response field \`${field}\` must be a number.`);
}

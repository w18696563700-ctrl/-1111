import { uploadConfirmRequired, uploadInitInvalid } from './upload.errors';

export type UploadInitCommand = {
  businessType: string;
  businessId: string | null;
  fileKind: string;
  mimeType: string;
  size: number;
  checksum: string;
};

export type VerifiedUploadSession = {
  actorId: string;
  userId: string;
  organizationId: string | null;
};

const BID_PROJECT_UNDERSTANDING_FILE_KIND = 'bid_project_understanding';
const BID_QUOTE_SHEET_FILE_KIND = 'bid_quote_sheet';
const BID_SCHEDULE_PLAN_FILE_KIND = 'bid_schedule_plan';
const PROJECT_ALBUM_PHOTO_FILE_KIND = 'project_album_photo';
const PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND = 'project_communication_attachment';
const FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE = 'forum_draft_attachment';
const FORUM_DRAFT_MEDIA_FILE_KIND = 'media';
const FORUM_DOCUMENT_MAX_SIZE_IN_BYTES = 20 * 1024 * 1024;

export function toUploadInitCommand(payload: Record<string, unknown>): UploadInitCommand {
  const source = asRecord(payload);
  if (!('businessId' in source)) {
    throw uploadInitInvalid(
      'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.'
    );
  }

  const businessType = readRequiredString(source.businessType, 'businessType');
  const fileKind = readRequiredString(source.fileKind, 'fileKind');
  const mimeType = readRequiredString(source.mimeType, 'mimeType');
  const checksum = readRequiredString(source.checksum, 'checksum');
  const size = readPositiveSize(source.size);
  const businessId = readBusinessId(source.businessId);
  ensureSupportedUploadBinding(businessType, fileKind, mimeType, size);

  return {
    businessType,
    businessId,
    fileKind,
    mimeType,
    size,
    checksum
  };
}

export function readUploadSessionId(value: unknown) {
  if (typeof value !== 'string') {
    throw uploadConfirmRequired('uploadSessionId is required for upload confirm.');
  }
  const normalized = value.trim();
  if (!normalized) {
    throw uploadConfirmRequired('uploadSessionId is required for upload confirm.');
  }
  return normalized;
}

export function nullable(value: string) {
  const normalized = value.trim();
  return normalized ? normalized : null;
}

export function resolveUploadBusinessId(
  command: UploadInitCommand,
  profileSession: VerifiedUploadSession | null
) {
  if (!profileSession) {
    return command.businessId;
  }
  if (command.fileKind === 'avatar') {
    return profileSession.userId;
  }
  if (command.fileKind === 'business_license') {
    return profileSession.organizationId?.trim() ?? command.businessId;
  }
  if (command.fileKind === 'id_card_front') {
    return profileSession.organizationId?.trim() ?? command.businessId;
  }
  return command.businessId;
}

function ensureSupportedUploadBinding(
  businessType: string,
  fileKind: string,
  mimeType: string,
  size: number
) {
  const normalizedMimeType = mimeType.toLowerCase();
  if (
    businessType === 'project' &&
    (fileKind === 'evidence' ||
      fileKind === 'project_attachment' ||
      fileKind === PROJECT_COMMUNICATION_ATTACHMENT_FILE_KIND)
  ) {
    return;
  }
  if (businessType === 'project' && fileKind === PROJECT_ALBUM_PHOTO_FILE_KIND) {
    if (!normalizedMimeType.startsWith('image/')) {
      throw uploadInitInvalid('Current project album upload only supports image mime types.');
    }
    return;
  }
  if (businessType === 'project' && isBidSubmitFileKind(fileKind)) {
    ensureBidSubmitMimeType(fileKind, normalizedMimeType);
    return;
  }
  if (businessType === 'profile' && isProfileImageFileKind(fileKind)) {
    if (!normalizedMimeType.startsWith('image/')) {
      throw uploadInitInvalid(`Current profile ${fileKind} upload only supports image mime types.`);
    }
    return;
  }
  if (businessType === 'enterprise_display' && isEnterpriseDisplayImageFileKind(fileKind)) {
    if (!normalizedMimeType.startsWith('image/')) {
      throw uploadInitInvalid('Current enterprise display upload only supports image mime types.');
    }
    return;
  }
  if (businessType === FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE) {
    ensureForumDraftAttachmentMimeType(fileKind, normalizedMimeType, size);
    return;
  }
  throw uploadInitInvalid(
    'Current upload init only supports project/evidence, project/project_attachment, project/project_communication_attachment, project/project_album_photo, project bid attachments, profile/avatar, profile/business_license, profile/id_card_front, enterprise_display image bindings, or forum_draft_attachment bindings.'
  );
}

function isProfileImageFileKind(fileKind: string) {
  return fileKind === 'avatar' || fileKind === 'business_license' || fileKind === 'id_card_front';
}

function isEnterpriseDisplayImageFileKind(fileKind: string) {
  return (
    fileKind === 'enterprise_logo' ||
    fileKind === 'enterprise_album' ||
    fileKind === 'enterprise_factory_showcase' ||
    fileKind === 'enterprise_case_media'
  );
}

function isBidSubmitFileKind(fileKind: string) {
  return (
    fileKind === BID_PROJECT_UNDERSTANDING_FILE_KIND ||
    fileKind === BID_QUOTE_SHEET_FILE_KIND ||
    fileKind === BID_SCHEDULE_PLAN_FILE_KIND
  );
}

function ensureBidSubmitMimeType(fileKind: string, mimeType: string) {
  const isImage = mimeType === 'image/png' || mimeType === 'image/jpeg' || mimeType === 'image/webp';
  const isDocument =
    mimeType === 'application/pdf' ||
    mimeType === 'application/msword' ||
    mimeType === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  const isSpreadsheet =
    mimeType === 'application/vnd.ms-excel' ||
    mimeType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  if (fileKind === BID_PROJECT_UNDERSTANDING_FILE_KIND && (isImage || isDocument)) {
    return;
  }
  if (
    (fileKind === BID_QUOTE_SHEET_FILE_KIND || fileKind === BID_SCHEDULE_PLAN_FILE_KIND) &&
    (isDocument || isSpreadsheet)
  ) {
    return;
  }
  throw uploadInitInvalid('Current bid submit upload only supports the configured attachment mime types.');
}

function ensureForumDraftAttachmentMimeType(fileKind: string, mimeType: string, size: number) {
  if (fileKind === FORUM_DRAFT_MEDIA_FILE_KIND) {
    if (mimeType.startsWith('image/') || mimeType.startsWith('video/')) {
      return;
    }
    throw uploadInitInvalid('Current forum draft media upload supports image or video media only.');
  }

  if (size > FORUM_DOCUMENT_MAX_SIZE_IN_BYTES) {
    throw uploadInitInvalid('Current forum draft document attachment upload cannot exceed 20 MiB.');
  }

  if (isForumDocumentMimeType(mimeType)) {
    return;
  }

  throw uploadInitInvalid('Current forum draft attachment upload supports bounded document attachments only.');
}

function isForumDocumentMimeType(mimeType: string) {
  return (
    mimeType === 'application/pdf' ||
    mimeType === 'text/plain' ||
    mimeType === 'application/msword' ||
    mimeType === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
    mimeType === 'application/vnd.ms-excel' ||
    mimeType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    mimeType === 'application/vnd.ms-powerpoint' ||
    mimeType === 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  );
}

function readRequiredString(value: unknown, field: string) {
  if (typeof value !== 'string') {
    throw uploadInitInvalid(
      `Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum. Missing \`${field}\`.`
    );
  }
  const normalized = value.trim();
  if (!normalized) {
    throw uploadInitInvalid(
      `Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum. Missing \`${field}\`.`
    );
  }
  return normalized;
}

function readBusinessId(value: unknown) {
  if (value === null) {
    return null;
  }
  if (typeof value !== 'string') {
    throw uploadInitInvalid(
      'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.'
    );
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readPositiveSize(value: unknown) {
  const size = typeof value === 'number' ? value : Number(value);
  if (!Number.isInteger(size) || size <= 0) {
    throw uploadInitInvalid('Field `size` must be a positive integer for upload init.');
  }
  return size;
}

function asRecord(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw uploadInitInvalid('Upload init body must be an object.');
  }
  return value as Record<string, unknown>;
}

import type {
  AdminApiError,
  EnterpriseHubAdminChangeReviewRequest,
} from '../../core/server/admin-api-client';

export function readChangeRequestId(formData: FormData) {
  return readRequired(formData, 'changeRequestId', 96);
}

export function buildApproveChangeReviewPayload(
  formData: FormData,
): EnterpriseHubAdminChangeReviewRequest {
  return {
    action: 'approved',
    reviewNote: readOptional(formData, 'reviewNote', 500),
  };
}

export function buildRevisionRequiredChangeReviewPayload(
  formData: FormData,
): EnterpriseHubAdminChangeReviewRequest {
  return {
    action: 'revision_required',
    reviewNote: readRequiredReason(formData),
  };
}

export function buildRejectedChangeReviewPayload(
  formData: FormData,
): EnterpriseHubAdminChangeReviewRequest {
  return {
    action: 'rejected',
    reviewNote: readRequiredReason(formData),
  };
}

export function toPublishedChangeActionError(error: unknown) {
  if (isAdminApiError(error)) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

function readRequiredReason(formData: FormData) {
  return readRequired(formData, 'reviewNote', 500);
}

function readRequired(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function readOptional(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    return null;
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function isAdminApiError(error: unknown): error is AdminApiError {
  return error instanceof Error && 'code' in error && 'status' in error;
}

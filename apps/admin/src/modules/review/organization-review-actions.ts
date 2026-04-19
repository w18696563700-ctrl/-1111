'use server';

import { redirect } from 'next/navigation';
import {
  AdminApiError,
  approveAdminOrganizationReview,
  rejectAdminOrganizationReview
} from '@/core/server/admin-api-client';

export async function approveOrganizationReviewAction(formData: FormData) {
  const organizationId = readOrganizationId(formData);
  let nextUrl = buildOrganizationReviewUrl({
    organizationId,
    filterOrganizationId: readOptionalString(formData, 'filterOrganizationId'),
    status: readOptionalString(formData, 'status'),
    keyword: readOptionalString(formData, 'keyword'),
    notice: 'organization_review_approved'
  });
  try {
    await approveAdminOrganizationReview(
      organizationId,
      buildApproveOrganizationReviewPayload(formData)
    );
  } catch (error) {
    nextUrl = buildOrganizationReviewUrl({
      organizationId,
      filterOrganizationId: readOptionalString(formData, 'filterOrganizationId'),
      status: readOptionalString(formData, 'status'),
      keyword: readOptionalString(formData, 'keyword'),
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

export async function rejectOrganizationReviewAction(formData: FormData) {
  const organizationId = readOrganizationId(formData);
  let nextUrl = buildOrganizationReviewUrl({
    organizationId,
    filterOrganizationId: readOptionalString(formData, 'filterOrganizationId'),
    status: readOptionalString(formData, 'status'),
    keyword: readOptionalString(formData, 'keyword'),
    notice: 'organization_review_rejected'
  });
  try {
    await rejectAdminOrganizationReview(
      organizationId,
      buildRejectOrganizationReviewPayload(formData)
    );
  } catch (error) {
    nextUrl = buildOrganizationReviewUrl({
      organizationId,
      filterOrganizationId: readOptionalString(formData, 'filterOrganizationId'),
      status: readOptionalString(formData, 'status'),
      keyword: readOptionalString(formData, 'keyword'),
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

function buildApproveOrganizationReviewPayload(formData: FormData) {
  const note = readOptionalString(formData, 'note');
  return note ? { note } : {};
}

function buildRejectOrganizationReviewPayload(formData: FormData) {
  const reason = readRequiredString(formData, 'reason');
  const note = readOptionalString(formData, 'note');
  return note ? { reason, note } : { reason };
}

function buildOrganizationReviewUrl(input: {
  organizationId: string;
  filterOrganizationId?: string | null;
  status?: string | null;
  keyword?: string | null;
  notice?: string | null;
  error?: string | null;
}) {
  const params = new URLSearchParams();
  if (input.filterOrganizationId) {
    params.set('organizationId', input.filterOrganizationId);
  }
  if (input.status) {
    params.set('status', input.status);
  }
  if (input.keyword) {
    params.set('keyword', input.keyword);
  }
  if (input.notice) {
    params.set('notice', input.notice);
  }
  if (input.error) {
    params.set('error', input.error);
  }
  const query = params.toString();
  return query
    ? `/review/organizations/${encodeURIComponent(input.organizationId)}?${query}`
    : `/review/organizations/${encodeURIComponent(input.organizationId)}`;
}

function readOrganizationId(formData: FormData) {
  return readRequiredString(formData, 'organizationId');
}

function readRequiredString(formData: FormData, key: string) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  return value.trim();
}

function readOptionalString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function toActionError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

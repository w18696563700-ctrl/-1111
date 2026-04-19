'use server';

import { redirect } from 'next/navigation';
import {
  approveProfileSafetySubmission,
  rejectProfileSafetySubmission
} from '@/core/server/admin-api-client';

export async function approveProfileSubmissionAction(formData: FormData) {
  const submissionId = readRequiredFormString(formData, 'submissionId');
  const reviewNote = readOptionalFormString(formData, 'reviewNote');
  const taskId = `profile_safety_submission:${submissionId}`;
  let nextUrl = `/review?taskId=${encodeURIComponent(taskId)}&notice=profile_approved`;

  try {
    await approveProfileSafetySubmission(
      submissionId,
      reviewNote ? { reviewNote } : {}
    );
  } catch (error) {
    nextUrl = buildErrorUrl(taskId, error);
  }
  redirect(nextUrl);
}

export async function rejectProfileSubmissionAction(formData: FormData) {
  const submissionId = readRequiredFormString(formData, 'submissionId');
  const reason = readRequiredFormString(formData, 'reason');
  const taskId = `profile_safety_submission:${submissionId}`;
  let nextUrl = `/review?taskId=${encodeURIComponent(taskId)}&notice=profile_rejected`;

  try {
    await rejectProfileSafetySubmission(submissionId, { reason });
  } catch (error) {
    nextUrl = buildErrorUrl(taskId, error);
  }
  redirect(nextUrl);
}

function readRequiredFormString(formData: FormData, key: string) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  return value.trim();
}

function readOptionalFormString(formData: FormData, key: string) {
  const value = formData.get(key);
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function buildErrorUrl(taskId: string, error: unknown) {
  const message = error instanceof Error ? error.message : '服务端管理接口请求失败。';
  return `/review?taskId=${encodeURIComponent(taskId)}&error=${encodeURIComponent(message)}`;
}

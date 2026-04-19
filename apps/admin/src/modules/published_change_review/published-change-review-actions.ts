'use server';

import { redirect } from 'next/navigation';
import {
  applyEnterpriseHubChangeRequest,
  reviewEnterpriseHubChangeRequest,
} from '@/core/server/admin-api-client';
import {
  buildApproveChangeReviewPayload,
  buildRejectedChangeReviewPayload,
  buildRevisionRequiredChangeReviewPayload,
  readChangeRequestId,
  toPublishedChangeActionError,
} from './published-change-review-form';

export async function approveEnterpriseHubChangeRequestAction(formData: FormData) {
  const changeRequestId = readChangeRequestId(formData);
  let nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
    notice: 'change_request_approved',
  });
  try {
    await reviewEnterpriseHubChangeRequest(
      changeRequestId,
      buildApproveChangeReviewPayload(formData),
    );
  } catch (error) {
    nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
      error: toPublishedChangeActionError(error),
    });
  }
  redirect(nextUrl);
}

export async function requestEnterpriseHubChangeRevisionAction(formData: FormData) {
  const changeRequestId = readChangeRequestId(formData);
  let nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
    notice: 'change_request_revision_required',
  });
  try {
    await reviewEnterpriseHubChangeRequest(
      changeRequestId,
      buildRevisionRequiredChangeReviewPayload(formData),
    );
  } catch (error) {
    nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
      error: toPublishedChangeActionError(error),
    });
  }
  redirect(nextUrl);
}

export async function rejectEnterpriseHubChangeRequestAction(formData: FormData) {
  const changeRequestId = readChangeRequestId(formData);
  let nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
    notice: 'change_request_rejected',
  });
  try {
    await reviewEnterpriseHubChangeRequest(
      changeRequestId,
      buildRejectedChangeReviewPayload(formData),
    );
  } catch (error) {
    nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
      error: toPublishedChangeActionError(error),
    });
  }
  redirect(nextUrl);
}

export async function applyEnterpriseHubChangeRequestAction(formData: FormData) {
  const changeRequestId = readChangeRequestId(formData);
  let nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
    notice: 'change_request_applied',
  });
  try {
    await applyEnterpriseHubChangeRequest(changeRequestId);
  } catch (error) {
    nextUrl = buildPublishedChangeDetailUrl(changeRequestId, {
      error: toPublishedChangeActionError(error),
    });
  }
  redirect(nextUrl);
}

function buildPublishedChangeDetailUrl(
  changeRequestId: string,
  input: {
    notice?: string;
    error?: string;
  },
) {
  const params = new URLSearchParams();
  if (input.notice) {
    params.set('notice', input.notice);
  }
  if (input.error) {
    params.set('error', input.error);
  }
  const query = params.toString();
  return query
    ? `/review/change_requests/${encodeURIComponent(changeRequestId)}?${query}`
    : `/review/change_requests/${encodeURIComponent(changeRequestId)}`;
}

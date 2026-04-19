'use server';

import { redirect } from 'next/navigation';
import { reviewEnterpriseHubApplication } from '@/core/server/admin-api-client';
import {
  buildEnterpriseHubApplicationApprovePayload,
  buildEnterpriseHubApplicationRejectedPayload,
  buildEnterpriseHubApplicationRevisionRequiredPayload,
  readEnterpriseHubApplicationId,
  toEnterpriseHubApplicationReviewActionError,
} from './enterprise-hub-application-review-form';

export async function approveEnterpriseHubApplicationReviewAction(formData: FormData) {
  const applicationId = readEnterpriseHubApplicationId(formData);
  let nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
    applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
    boardType: readOptionalString(formData, 'filterBoardType'),
    notice: 'enterprise_hub_application_approved',
  });
  try {
    await reviewEnterpriseHubApplication(
      applicationId,
      buildEnterpriseHubApplicationApprovePayload(formData),
    );
  } catch (error) {
    nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
      applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
      boardType: readOptionalString(formData, 'filterBoardType'),
      error: toEnterpriseHubApplicationReviewActionError(error),
    });
  }
  redirect(nextUrl);
}

export async function requestEnterpriseHubApplicationRevisionAction(formData: FormData) {
  const applicationId = readEnterpriseHubApplicationId(formData);
  let nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
    applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
    boardType: readOptionalString(formData, 'filterBoardType'),
    notice: 'enterprise_hub_application_revision_required',
  });
  try {
    await reviewEnterpriseHubApplication(
      applicationId,
      buildEnterpriseHubApplicationRevisionRequiredPayload(formData),
    );
  } catch (error) {
    nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
      applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
      boardType: readOptionalString(formData, 'filterBoardType'),
      error: toEnterpriseHubApplicationReviewActionError(error),
    });
  }
  redirect(nextUrl);
}

export async function rejectEnterpriseHubApplicationReviewAction(formData: FormData) {
  const applicationId = readEnterpriseHubApplicationId(formData);
  let nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
    applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
    boardType: readOptionalString(formData, 'filterBoardType'),
    notice: 'enterprise_hub_application_rejected',
  });
  try {
    await reviewEnterpriseHubApplication(
      applicationId,
      buildEnterpriseHubApplicationRejectedPayload(formData),
    );
  } catch (error) {
    nextUrl = buildEnterpriseHubApplicationReviewUrl(applicationId, {
      applicationStatus: readOptionalString(formData, 'filterApplicationStatus'),
      boardType: readOptionalString(formData, 'filterBoardType'),
      error: toEnterpriseHubApplicationReviewActionError(error),
    });
  }
  redirect(nextUrl);
}

function buildEnterpriseHubApplicationReviewUrl(
  applicationId: string,
  input: {
    applicationStatus?: string | null;
    boardType?: string | null;
    notice?: string | null;
    error?: string | null;
  },
) {
  const params = new URLSearchParams();
  if (input.applicationStatus) {
    params.set('applicationStatus', input.applicationStatus);
  }
  if (input.boardType) {
    params.set('boardType', input.boardType);
  }
  if (input.notice) {
    params.set('notice', input.notice);
  }
  if (input.error) {
    params.set('error', input.error);
  }
  const query = params.toString();
  return query
    ? `/review/enterprise_hub_applications/${encodeURIComponent(applicationId)}?${query}`
    : `/review/enterprise_hub_applications/${encodeURIComponent(applicationId)}`;
}

function readOptionalString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

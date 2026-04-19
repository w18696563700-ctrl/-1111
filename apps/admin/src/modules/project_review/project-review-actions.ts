'use server';

import { redirect } from 'next/navigation';
import {
  decideExhibitionReportCase,
  escalateExhibitionReportCase,
  requestExhibitionReportExplanation
} from '@/core/server/admin-api-client';
import {
  buildDecideReportCasePayload,
  buildEscalateReportCasePayload,
  buildRequestExplanationPayload,
  readReportCaseId
} from './project-review-form';

export async function requestExhibitionReportExplanationAction(formData: FormData) {
  const reportCaseId = readReportCaseId(formData);
  let nextUrl = `/project_review/${encodeURIComponent(reportCaseId)}?notice=explanation_requested`;
  try {
    await requestExhibitionReportExplanation(
      reportCaseId,
      buildRequestExplanationPayload(formData)
    );
  } catch (error) {
    nextUrl = buildErrorUrl(reportCaseId, error);
  }
  redirect(nextUrl);
}

export async function decideExhibitionReportCaseAction(formData: FormData) {
  const reportCaseId = readReportCaseId(formData);
  let nextUrl = `/project_review/${encodeURIComponent(reportCaseId)}?notice=report_case_decided`;
  try {
    await decideExhibitionReportCase(reportCaseId, buildDecideReportCasePayload(formData));
  } catch (error) {
    nextUrl = buildErrorUrl(reportCaseId, error);
  }
  redirect(nextUrl);
}

export async function escalateExhibitionReportCaseAction(formData: FormData) {
  const reportCaseId = readReportCaseId(formData);
  let nextUrl = `/project_review/${encodeURIComponent(reportCaseId)}?notice=report_case_escalated`;
  try {
    await escalateExhibitionReportCase(reportCaseId, buildEscalateReportCasePayload(formData));
  } catch (error) {
    nextUrl = buildErrorUrl(reportCaseId, error);
  }
  redirect(nextUrl);
}

function buildErrorUrl(reportCaseId: string, error: unknown) {
  const message = error instanceof Error ? error.message : '服务端管理接口请求失败。';
  return `/project_review/${encodeURIComponent(reportCaseId)}?error=${encodeURIComponent(message)}`;
}

'use server';

import { redirect } from 'next/navigation';
import {
  archiveAdminTemplateConfigVersion,
  createAdminTemplateConfigTemplate,
  createAdminTemplateConfigVersion,
  publishAdminTemplateConfigVersion,
  updateAdminTemplateConfigGrouping
} from '@/core/server/admin-api-client';
import {
  buildArchiveTemplateVersionPayload,
  buildCreateTemplatePayload,
  buildCreateTemplateVersionPayload,
  buildPublishTemplateVersionPayload,
  buildUpdateGroupingPayload,
  readTemplateId,
  readTemplateVersionId
} from './template-config-form';

export async function createTemplateConfigAction(formData: FormData) {
  let nextUrl = '/template_config?notice=template_created';
  try {
    const template = await createAdminTemplateConfigTemplate(buildCreateTemplatePayload(formData));
    nextUrl = buildTemplateConfigUrl({
      templateId: template.templateId,
      notice: 'template_created'
    });
  } catch (error) {
    nextUrl = buildTemplateConfigUrl({
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

export async function createTemplateVersionAction(formData: FormData) {
  const templateId = readTemplateId(formData);
  let nextUrl = buildTemplateConfigUrl({
    templateId,
    notice: 'template_version_created'
  });
  try {
    const version = await createAdminTemplateConfigVersion(
      templateId,
      buildCreateTemplateVersionPayload(formData)
    );
    nextUrl = buildTemplateConfigUrl({
      templateId,
      templateVersionId: version.templateVersionId,
      notice: 'template_version_created'
    });
  } catch (error) {
    nextUrl = buildTemplateConfigUrl({
      templateId,
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

export async function publishTemplateVersionAction(formData: FormData) {
  const templateId = readTemplateId(formData);
  const templateVersionId = readTemplateVersionId(formData);
  let nextUrl = buildTemplateConfigUrl({
    templateId,
    templateVersionId,
    notice: 'template_version_published'
  });
  try {
    const result = await publishAdminTemplateConfigVersion(
      templateId,
      templateVersionId,
      buildPublishTemplateVersionPayload(formData)
    );
    nextUrl = buildTemplateConfigUrl({
      templateId: result.template.templateId,
      templateVersionId: result.version.templateVersionId,
      notice: 'template_version_published'
    });
  } catch (error) {
    nextUrl = buildTemplateConfigUrl({
      templateId,
      templateVersionId,
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

export async function archiveTemplateVersionAction(formData: FormData) {
  const templateId = readTemplateId(formData);
  const templateVersionId = readTemplateVersionId(formData);
  let nextUrl = buildTemplateConfigUrl({
    templateId,
    templateVersionId,
    notice: 'template_version_archived'
  });
  try {
    const result = await archiveAdminTemplateConfigVersion(
      templateId,
      templateVersionId,
      buildArchiveTemplateVersionPayload(formData)
    );
    nextUrl = buildTemplateConfigUrl({
      templateId: result.template.templateId,
      templateVersionId: result.template.activeVersionId ?? result.version.templateVersionId,
      notice: 'template_version_archived'
    });
  } catch (error) {
    nextUrl = buildTemplateConfigUrl({
      templateId,
      templateVersionId,
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

export async function updateTemplateGroupingAction(formData: FormData) {
  const templateId = readTemplateId(formData);
  const templateVersionId = readOptionalString(formData, 'templateVersionId');
  let nextUrl = buildTemplateConfigUrl({
    templateId,
    templateVersionId,
    notice: 'template_grouping_updated'
  });
  try {
    const template = await updateAdminTemplateConfigGrouping(
      templateId,
      buildUpdateGroupingPayload(formData)
    );
    nextUrl = buildTemplateConfigUrl({
      templateId: template.templateId,
      templateVersionId,
      notice: 'template_grouping_updated'
    });
  } catch (error) {
    nextUrl = buildTemplateConfigUrl({
      templateId,
      templateVersionId,
      error: toActionError(error)
    });
  }
  redirect(nextUrl);
}

function buildTemplateConfigUrl(input: {
  templateId?: string | null;
  templateVersionId?: string | null;
  notice?: string | null;
  error?: string | null;
}) {
  const params = new URLSearchParams();
  if (input.templateId) {
    params.set('templateId', input.templateId);
  }
  if (input.templateVersionId) {
    params.set('templateVersionId', input.templateVersionId);
  }
  if (input.notice) {
    params.set('notice', input.notice);
  }
  if (input.error) {
    params.set('error', input.error);
  }
  const query = params.toString();
  return query ? `/template_config?${query}` : '/template_config';
}

function readOptionalString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function toActionError(error: unknown) {
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

'use server';

import { redirect } from 'next/navigation';
import {
  ApplyGovernancePenaltyPayload,
  applyGovernancePenalty
} from '@/core/server/admin-api-client';

const SUBJECT_TYPES = ['organization', 'organization_member'] as const;
const PENALTY_TYPES = [
  'warning',
  'watchlist',
  'restrict_publish',
  'restrict_bid',
  'blacklist'
] as const;

export async function applyGovernancePenaltyAction(formData: FormData) {
  let nextUrl = '/governance/penalties?notice=penalty_applied';
  try {
    const result = await applyGovernancePenalty(toPenaltyPayload(formData));
    const penaltyId = typeof result.penaltyId === 'string' ? result.penaltyId : '';
    if (penaltyId) {
      nextUrl = `/governance/penalties/${encodeURIComponent(penaltyId)}?notice=penalty_applied`;
    }
  } catch (error) {
    nextUrl = `/governance/penalties?error=${encodeURIComponent(toErrorMessage(error))}`;
  }
  redirect(nextUrl);
}

function toPenaltyPayload(formData: FormData): ApplyGovernancePenaltyPayload {
  return {
    subjectType: readEnum(formData, 'subjectType', SUBJECT_TYPES),
    subjectId: readRequired(formData, 'subjectId', 64),
    penaltyType: readEnum(formData, 'penaltyType', PENALTY_TYPES),
    reasonCode: readRequired(formData, 'reasonCode', 64),
    reasonSummary: readOptional(formData, 'reasonSummary', 500),
    effectiveUntil: readOptionalDate(formData, 'effectiveUntil'),
    evidenceFileAssetIds: readEvidenceFileAssetIds(formData)
  };
}

function readEnum<T extends readonly string[]>(
  formData: FormData,
  key: string,
  allowed: T
): T[number] {
  const value = readRequired(formData, key, 64);
  if (!allowed.includes(value)) {
    throw new Error(`${key} 不在当前有界服务端接口支持范围内。`);
  }
  return value as T[number];
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

function readOptionalDate(formData: FormData, key: string) {
  const value = readOptional(formData, key, 64);
  if (!value) {
    return null;
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`${key} 必须是合法的日期时间。`);
  }
  return parsed.toISOString();
}

function readEvidenceFileAssetIds(formData: FormData) {
  const value = readOptional(formData, 'evidenceFileAssetIds', 1000);
  if (!value) {
    return [];
  }
  const ids = value
    .split(/[\n,]/)
    .map((item) => item.trim())
    .filter(Boolean);
  if (new Set(ids).size !== ids.length) {
    throw new Error('evidenceFileAssetIds 不能重复。');
  }
  return ids;
}

function toErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

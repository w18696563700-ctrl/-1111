'use server';

import { redirect } from 'next/navigation';
import {
  GovernanceAppealDecision,
  decideGovernanceAppeal
} from '@/core/server/admin-api-client';

const DECISIONS = ['uphold', 'modify', 'revoke'] as const;

export async function decideGovernanceAppealAction(formData: FormData) {
  const appealCaseId = readRequired(formData, 'appealCaseId', 64);
  let nextUrl = `/governance/appeals/${encodeURIComponent(appealCaseId)}?notice=appeal_decided`;
  try {
    await decideGovernanceAppeal(appealCaseId, {
      decision: readEnum(formData, 'decision', DECISIONS),
      decisionNote: readOptional(formData, 'decisionNote', 500)
    });
  } catch (error) {
    nextUrl = `/governance/appeals/${encodeURIComponent(appealCaseId)}?error=${encodeURIComponent(toErrorMessage(error))}`;
  }
  redirect(nextUrl);
}

function readEnum<T extends readonly string[]>(formData: FormData, key: string, allowed: T): T[number] {
  const value = readRequired(formData, key, 32);
  if (!allowed.includes(value)) {
    throw new Error(`${key} 不在当前有界服务端接口支持范围内。`);
  }
  return value as GovernanceAppealDecision;
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

function toErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : '服务端管理接口请求失败。';
}

import { personalAvatarInvalid, profileSafetySubmissionInvalid } from './profile.errors';

const NICKNAME_PATTERN = /^[\p{Script=Han}]{1,10}$/u;
const INTRO_MAX_LENGTH = 100;

export function readProfileSafetyNickname(payload: Record<string, unknown>) {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw profileSafetySubmissionInvalid('Personal nickname body must be an object.');
  }
  if (typeof payload.nickname !== 'string') {
    throw profileSafetySubmissionInvalid('Field `nickname` is required.');
  }
  const nickname = payload.nickname.trim();
  if (!NICKNAME_PATTERN.test(nickname)) {
    throw profileSafetySubmissionInvalid('Nickname must contain only 1 to 10 Chinese Han characters.');
  }
  return nickname;
}

export function readProfileSafetyIntro(payload: Record<string, unknown>) {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw profileSafetySubmissionInvalid('Personal intro body must be an object.');
  }
  if (typeof payload.intro !== 'string') {
    throw profileSafetySubmissionInvalid('Field `intro` is required.');
  }
  const intro = payload.intro.trim();
  if (intro.length > INTRO_MAX_LENGTH) {
    throw profileSafetySubmissionInvalid('Personal intro exceeds the P0 length boundary.');
  }
  return intro;
}

export function readProfileSafetyFileAssetId(payload: Record<string, unknown>) {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw personalAvatarInvalid('Personal avatar body must be an object.');
  }
  if (typeof payload.fileAssetId !== 'string' || !payload.fileAssetId.trim()) {
    throw personalAvatarInvalid('Field `fileAssetId` is required.');
  }
  return payload.fileAssetId.trim();
}

export function readProfileSafetyRequiredReason(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw profileSafetySubmissionInvalid('Profile safety reject body must be an object.');
  }
  const reason = (value as Record<string, unknown>).reason;
  if (typeof reason !== 'string' || !reason.trim()) {
    throw profileSafetySubmissionInvalid('Field `reason` is required for profile safety reject.');
  }
  return reason.trim().slice(0, 200);
}

export function readProfileSafetyOptionalReason(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return null;
  }
  const reason = (value as Record<string, unknown>).reviewNote;
  if (typeof reason !== 'string') {
    return null;
  }
  const normalized = reason.trim();
  return normalized ? normalized.slice(0, 200) : null;
}

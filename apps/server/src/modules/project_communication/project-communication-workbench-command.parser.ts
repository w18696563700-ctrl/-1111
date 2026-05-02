import {
  projectCommunicationInvalid,
  projectCommunicationWorkbenchInvalid
} from './project-communication.errors';
import {
  ProjectCommunicationMaterialReviewEntryKey,
  projectCommunicationMaterialReviewEntryKeySet
} from './project-communication-workbench.types';

export type ProjectCommunicationMaterialReviewCommand = {
  projectId: string;
  threadId: string;
  bidId: string | null;
  entryKey: ProjectCommunicationMaterialReviewEntryKey;
  reviewAction: 'confirm' | 'request_supplement';
  feedbackReasonCodes: string[];
  feedbackText: string | null;
  sourceVersionToken: string | null;
  idempotencyKey: string;
};

export function toProjectCommunicationMaterialReviewCommand(
  payload: Record<string, unknown>
): ProjectCommunicationMaterialReviewCommand {
  const entryKey = readRequiredString(payload.entryKey, 'entryKey') as ProjectCommunicationMaterialReviewEntryKey;
  if (!projectCommunicationMaterialReviewEntryKeySet.has(entryKey)) {
    throw projectCommunicationWorkbenchInvalid(
      'PROJECT_COMMUNICATION_MATERIAL_REVIEW_ENTRY_REQUIRED',
      'Material review only accepts the first 8 workbench entries.'
    );
  }
  const reviewAction = readRequiredString(payload.reviewAction, 'reviewAction');
  if (reviewAction !== 'confirm' && reviewAction !== 'request_supplement') {
    throw projectCommunicationInvalid('Field `reviewAction` must be confirm or request_supplement.');
  }
  return {
    projectId: readRequiredString(payload.projectId, 'projectId'),
    threadId: readRequiredString(payload.threadId, 'threadId'),
    bidId: readOptionalString(payload.bidId),
    entryKey,
    reviewAction,
    feedbackReasonCodes: readStringArray(payload.feedbackReasonCodes),
    feedbackText: readOptionalString(payload.feedbackText),
    sourceVersionToken: readOptionalString(payload.sourceVersionToken),
    idempotencyKey: readRequiredString(payload.idempotencyKey, 'idempotencyKey')
  };
}

export function readRequiredString(value: unknown, field: string) {
  const normalized = typeof value === 'string' ? value.trim() : '';
  if (!normalized) {
    throw projectCommunicationInvalid(`Field \`${field}\` is required.`);
  }
  return normalized;
}

export function readOptionalString(value: unknown) {
  const normalized = typeof value === 'string' ? value.trim() : '';
  return normalized || null;
}

function readStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => (typeof item === 'string' ? item.trim() : ''))
    .filter(Boolean);
}

import { projectCancellationResponseInvalid } from './project.errors';
import { randomUUID } from 'crypto';
import { EntityManager } from 'typeorm';
import { VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { CurrentOrganizationScope } from '../organization/current-actor-eligibility.service';
import { ProjectOrderEntity } from '../order/entities/project-order.entity';
import { ProjectExitCaseEntity } from './entities/project-exit-case.entity';
import { ProjectEntity } from './entities/project.entity';

export const PROJECT_SUBMITTED_STATE = 'submitted';
export const PROJECT_PUBLISHED_STATE = 'published';
export const PROJECT_AWARDED_STATE = 'awarded';
export const PROJECT_CONVERTED_TO_ORDER_STATE = 'converted_to_order';
export const PROJECT_ARCHIVED_STATE = 'archived';

export const TERMINAL_AUTHORIZATION_STATES = new Set([
  'authorization_released',
  'cancelled',
  'failed',
  'expired'
]);

export const ACTIVE_CASE_STATUSES = new Set(['requested']);

export type ProjectExitInvalidFactory = (message: string) => Error;

export function readProjectExitAction(
  payload: Record<string, unknown>,
  invalidFactory: ProjectExitInvalidFactory
) {
  const source = asProjectExitRecord(payload, invalidFactory, 'Project exit body must be an object.');
  return {
    projectId: readRequiredProjectExitString(
      source.projectId,
      invalidFactory,
      'Field `projectId` is required.'
    )
  };
}

export function readPenaltySafeProjectExitAction(
  payload: Record<string, unknown>,
  invalidFactory: ProjectExitInvalidFactory
) {
  const source = asProjectExitRecord(payload, invalidFactory, 'Project exit body must be an object.');
  if (source.noAutomaticPenaltyConfirmed !== true) {
    throw invalidFactory('Field `noAutomaticPenaltyConfirmed` must be true.');
  }
  return {
    projectId: readRequiredProjectExitString(
      source.projectId,
      invalidFactory,
      'Field `projectId` is required.'
    ),
    orderId: readOptionalProjectExitString(source.orderId)
  };
}

export function readProjectCancellationResponse(payload: Record<string, unknown>) {
  const source = asProjectExitRecord(
    payload,
    projectCancellationResponseInvalid,
    'Project cancellation response body must be an object.'
  );
  if (source.noAutomaticPenaltyConfirmed !== true) {
    throw projectCancellationResponseInvalid('Field `noAutomaticPenaltyConfirmed` must be true.');
  }
  const decision = readRequiredProjectExitString(
    source.decision,
    projectCancellationResponseInvalid,
    'Field `decision` is required.'
  );
  if (decision !== 'accept' && decision !== 'reject') {
    throw projectCancellationResponseInvalid('Field `decision` must be accept or reject.');
  }
  return {
    projectId: readRequiredProjectExitString(
      source.projectId,
      projectCancellationResponseInvalid,
      'Field `projectId` is required.'
    ),
    exitCaseId: readRequiredProjectExitString(
      source.exitCaseId,
      projectCancellationResponseInvalid,
      'Field `exitCaseId` is required.'
    ),
    decision
  };
}

export function buildProjectExitSummary(state: string) {
  if (state === PROJECT_ARCHIVED_STATE) {
    return {
      heading: '项目已作废归档，已退出当前活跃流转。',
      stateLabel: '当前项目已归档，可在历史项目中查看。'
    };
  }
  return {
    heading: '项目已撤回到预发布列表，可补充资料后重新确认发布。',
    stateLabel: '当前项目已下架公域展示，回到预发布列表。'
  };
}

export function readOptionalProjectExitString(value: unknown) {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

export function saveProjectExitCase(
  manager: EntityManager,
  input: {
    project: ProjectEntity;
    currentSession: VerifiedCurrentSessionContext;
    scope: CurrentOrganizationScope;
    order?: ProjectOrderEntity;
    exitType: string;
    status: string;
    counterpartyOrganizationId?: string | null;
    breachParty?: string | null;
    reasonCode: string;
    reasonText: string | null;
    creditImpactCandidate?: boolean;
    noAutomaticPenaltyConfirmed: boolean;
    requestedAt?: Date | null;
    closedAt?: Date | null;
  }
) {
  const exitCase = manager.getRepository(ProjectExitCaseEntity).create({
    id: randomUUID(),
    projectId: input.project.id,
    orderId: input.order?.id ?? null,
    contractId: null,
    exitType: input.exitType,
    status: input.status,
    initiatorOrganizationId: input.scope.organization.id,
    counterpartyOrganizationId: input.counterpartyOrganizationId ?? null,
    breachParty: input.breachParty ?? null,
    reasonCode: input.reasonCode,
    reasonText: input.reasonText,
    creditImpactCandidate: input.creditImpactCandidate ?? false,
    noAutomaticPenaltyConfirmed: input.noAutomaticPenaltyConfirmed,
    requestedAt: input.requestedAt ?? null,
    respondedAt: null,
    closedAt: input.closedAt ?? null,
    requestId: input.currentSession.requestId,
    traceId: input.currentSession.traceId,
    createdByUserId: input.currentSession.userId,
    respondedByUserId: null
  });
  return manager.getRepository(ProjectExitCaseEntity).save(exitCase);
}

function asProjectExitRecord(value: unknown, invalidFactory: ProjectExitInvalidFactory, message: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw invalidFactory(message);
  }
  return value as Record<string, unknown>;
}

function readRequiredProjectExitString(
  value: unknown,
  invalidFactory: ProjectExitInvalidFactory,
  message: string
) {
  const normalized = readOptionalProjectExitString(value);
  if (!normalized) {
    throw invalidFactory(message);
  }
  return normalized;
}

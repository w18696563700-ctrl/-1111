import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';
import { uploadInitInvalid, uploadSessionMissingFileAssetTruth } from './upload.errors';
import { UploadInitCommand, VerifiedUploadSession } from './upload-write-command.support';

export async function loadProfileSessionForInit(
  command: UploadInitCommand,
  context: RequestContext,
  verifier: CurrentSessionVerificationService
) {
  if (command.businessType !== 'profile') {
    return null;
  }

  const currentSession = await requireVerifiedCurrentSessionContext(context, verifier);
  if (command.fileKind === 'avatar') {
    if (command.businessId && command.businessId !== currentSession.userId) {
      throw uploadInitInvalid('Current profile avatar upload must bind to the current user.');
    }
    return currentSession;
  }
  if (command.fileKind === 'business_license' || command.fileKind === 'id_card_front') {
    const currentOrganizationId = currentSession.organizationId?.trim() ?? '';
    if (!currentOrganizationId) {
      throw uploadInitInvalid('Current organization-scoped profile upload requires an active organization scope.');
    }
    if (command.businessId && command.businessId !== currentOrganizationId) {
      throw uploadInitInvalid('Current organization-scoped profile upload must bind to the current organization.');
    }
    return currentSession;
  }
  return null;
}

export async function loadProjectSessionForInit(
  command: UploadInitCommand,
  context: RequestContext,
  verifier: CurrentSessionVerificationService
) {
  if (command.businessType !== 'project') {
    return null;
  }

  const currentSession = await requireVerifiedCurrentSessionContext(context, verifier);
  if (!currentSession.organizationId?.trim()) {
    throw uploadInitInvalid('Current project upload requires an active organization scope.');
  }
  return currentSession;
}

export async function loadProfileSessionForConfirm(
  session: UploadSessionEntity,
  context: RequestContext,
  verifier: CurrentSessionVerificationService
) {
  if (session.businessType !== 'profile') {
    return null;
  }

  const currentSession = await requireVerifiedCurrentSessionContext(context, verifier);
  if (session.fileKind === 'avatar') {
    if (session.businessId !== currentSession.userId || session.userId !== currentSession.userId) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar upload session does not belong to the current user.'
      );
    }
    ensureImageSession(session, 'Current profile avatar upload session is missing image mime truth.');
    return currentSession;
  }
  if (session.fileKind === 'business_license' || session.fileKind === 'id_card_front') {
    const currentOrganizationId = currentSession.organizationId?.trim() ?? '';
    if (
      !currentOrganizationId ||
      session.businessId !== currentOrganizationId ||
      session.organizationId !== currentOrganizationId
    ) {
      throw uploadSessionMissingFileAssetTruth(
        'Current organization-scoped profile upload session does not belong to the current organization.'
      );
    }
    ensureImageSession(session, 'Current organization-scoped profile upload session is missing image mime truth.');
    return currentSession;
  }
  return null;
}

export async function loadProjectSessionForConfirm(
  session: UploadSessionEntity,
  context: RequestContext,
  verifier: CurrentSessionVerificationService
) {
  if (session.businessType !== 'project') {
    return null;
  }

  const currentSession = await requireVerifiedCurrentSessionContext(context, verifier);
  const currentOrganizationId = currentSession.organizationId?.trim() ?? '';
  if (!currentOrganizationId) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project upload confirm requires an active organization scope.'
    );
  }
  ensureProjectSessionOwnership(session, currentSession, currentOrganizationId);
  return currentSession;
}

export function ensureProfileFileAsset(
  fileAsset: FileAssetEntity,
  session: UploadSessionEntity,
  currentSession: Pick<VerifiedUploadSession, 'userId' | 'organizationId'> | null
) {
  if (session.businessType !== 'profile') {
    return;
  }

  if (session.fileKind === 'avatar') {
    if (
      fileAsset.businessType !== 'profile' ||
      fileAsset.fileKind !== 'avatar' ||
      !fileAsset.mimeType.toLowerCase().startsWith('image/')
    ) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar FileAsset truth is not aligned with the upload session.'
      );
    }
    if (
      !currentSession?.userId ||
      fileAsset.businessId !== currentSession.userId ||
      fileAsset.userId !== currentSession.userId
    ) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar FileAsset truth does not belong to the current user.'
      );
    }
    return;
  }

  if (session.fileKind === 'business_license' || session.fileKind === 'id_card_front') {
    ensureOrganizationProfileFileAsset(fileAsset, session, currentSession);
  }
}

export function ensureProjectFileAsset(
  fileAsset: FileAssetEntity,
  session: UploadSessionEntity,
  currentSession: VerifiedUploadSession | null
) {
  if (session.businessType !== 'project') {
    return;
  }
  if (
    fileAsset.businessType !== 'project' ||
    fileAsset.businessId !== session.businessId ||
    fileAsset.fileKind !== session.fileKind
  ) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project FileAsset truth is not aligned with the upload session.'
    );
  }
  const organizationId = currentSession?.organizationId?.trim() ?? '';
  if (
    !currentSession ||
    !organizationId ||
    fileAsset.actorId !== currentSession.actorId ||
    fileAsset.userId !== currentSession.userId ||
    fileAsset.organizationId !== organizationId
  ) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project FileAsset truth does not belong to the current organization session.'
    );
  }
}

function ensureOrganizationProfileFileAsset(
  fileAsset: FileAssetEntity,
  session: UploadSessionEntity,
  currentSession: Pick<VerifiedUploadSession, 'userId' | 'organizationId'> | null
) {
  const currentOrganizationId = currentSession?.organizationId?.trim() ?? '';
  if (
    fileAsset.businessType !== 'profile' ||
    fileAsset.fileKind !== session.fileKind ||
    !fileAsset.mimeType.toLowerCase().startsWith('image/')
  ) {
    throw uploadSessionMissingFileAssetTruth(
      'Current organization-scoped profile FileAsset truth is not aligned with the upload session.'
    );
  }
  if (
    !currentOrganizationId ||
    fileAsset.businessId !== currentOrganizationId ||
    fileAsset.organizationId !== currentOrganizationId
  ) {
    throw uploadSessionMissingFileAssetTruth(
      'Current organization-scoped profile FileAsset truth does not belong to the current organization.'
    );
  }
}

function ensureProjectSessionOwnership(
  session: UploadSessionEntity,
  currentSession: { actorId: string; userId: string },
  currentOrganizationId: string
) {
  if (session.actorId && session.actorId !== currentSession.actorId) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project upload session actor does not match the current session.'
    );
  }
  if (session.userId && session.userId !== currentSession.userId) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project upload session user does not match the current session.'
    );
  }
  if (session.organizationId && session.organizationId !== currentOrganizationId) {
    throw uploadSessionMissingFileAssetTruth(
      'Current project upload session organization does not match the current session.'
    );
  }
}

function ensureImageSession(session: UploadSessionEntity, message: string) {
  if (!session.mimeType.toLowerCase().startsWith('image/')) {
    throw uploadSessionMissingFileAssetTruth(message);
  }
}

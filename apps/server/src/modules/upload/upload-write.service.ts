import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { RequestContext } from '../../shared/request-context';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';
import {
  uploadConfirmRequired,
  uploadInitInvalid,
  uploadSessionMissingFileAssetTruth,
  uploadSessionUnavailable
} from './upload.errors';
import { UploadPresenter } from './upload.presenter';
import { UploadStorageService } from './upload-storage.service';

type UploadInitCommand = {
  businessType: string;
  businessId: string | null;
  fileKind: string;
  mimeType: string;
  size: number;
  checksum: string;
};

@Injectable()
export class UploadWriteService {
  constructor(
    @InjectRepository(UploadSessionEntity)
    private readonly uploadSessionRepository: Repository<UploadSessionEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly presenter: UploadPresenter,
    private readonly storageService: UploadStorageService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService
  ) {}

  async initUpload(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toInitCommand(payload);
    const profileSession = await this.loadProfileSessionForInit(command, context);
    const businessId = profileSession?.userId ?? command.businessId;
    await this.ensureUploadBindingForInit(command.businessType, businessId);
    const sessionId = randomUUID();

    const directive = await this.storageService.buildDirective({
      sessionId,
      businessType: command.businessType,
      fileKind: command.fileKind,
      mimeType: command.mimeType,
      checksum: command.checksum
    });
    const session = this.uploadSessionRepository.create({
      id: sessionId,
      businessType: command.businessType,
      businessId,
      fileKind: command.fileKind,
      mimeType: command.mimeType,
      size: command.size,
      checksum: command.checksum,
      objectKey: directive.objectKey,
      directUploadUrl: directive.directUploadUrl,
      directUploadMethod: directive.directUploadMethod,
      directUploadHeaders: directive.directUploadHeaders,
      sessionStatus: 'initiated',
      fileAssetId: null,
      actorId: profileSession?.actorId ?? this.nullable(context.actorId),
      userId: profileSession?.userId ?? this.nullable(context.userId),
      organizationId: profileSession?.organizationId ?? context.organizationId ?? '',
      confirmedAt: null
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(UploadSessionEntity).save(session);
      await this.auditService.record(
        {
          aggregateType: 'upload_session',
          aggregateId: session.id,
          eventType: 'upload_init_requested',
          payload: {
            businessType: session.businessType,
            businessId: session.businessId,
            fileKind: session.fileKind,
            mimeType: session.mimeType,
            size: session.size
          }
        },
        context,
        manager
      );
    });

    return this.presenter.toInitResponse(session);
  }

  async confirmUpload(payload: Record<string, unknown>, context: RequestContext) {
    const uploadSessionId = this.readUploadSessionId(payload.uploadSessionId);

    return this.dataSource.transaction(async (manager) => {
      const sessionRepository = manager.getRepository(UploadSessionEntity);
      const fileAssetRepository = manager.getRepository(FileAssetEntity);
      const session = await sessionRepository.findOneBy({ id: uploadSessionId });
      if (!session) {
        throw uploadSessionUnavailable('Upload session does not exist for upload confirm.');
      }
      const profileSession = await this.loadProfileSessionForConfirm(session, context);

      if (session.fileAssetId) {
        const existing = await fileAssetRepository.findOneBy({ id: session.fileAssetId });
        if (!existing) {
          throw uploadSessionMissingFileAssetTruth('Upload session is confirmed but missing FileAsset truth.');
        }
        this.ensureProfileAvatarFileAsset(existing, session, profileSession?.userId ?? null);
        return this.presenter.toConfirmResponse(existing);
      }

      await this.ensureUploadBindingForConfirm(session.businessType, session.businessId, manager);
      await this.storageService.verifyTransportObject(session);

      const fileAsset = fileAssetRepository.create({
        id: randomUUID(),
        uploadSessionId: session.id,
        businessType: session.businessType,
        businessId: session.businessId,
        fileKind: session.fileKind,
        objectKey: session.objectKey,
        mimeType: session.mimeType,
        size: session.size,
        checksum: session.checksum,
        actorId: profileSession?.actorId ?? this.nullable(context.actorId) ?? session.actorId,
        userId: profileSession?.userId ?? this.nullable(context.userId) ?? session.userId,
        organizationId:
          profileSession?.organizationId ?? context.organizationId ?? session.organizationId
      });

      session.fileAssetId = fileAsset.id;
      session.sessionStatus = 'confirmed';
      session.confirmedAt = new Date();

      this.ensureProfileAvatarFileAsset(fileAsset, session, profileSession?.userId ?? null);
      await fileAssetRepository.save(fileAsset);
      await sessionRepository.save(session);
      await this.auditService.record(
        {
          aggregateType: 'upload_session',
          aggregateId: session.id,
          eventType: 'upload_confirmed',
          payload: {
            businessType: session.businessType,
            businessId: session.businessId,
            fileKind: session.fileKind,
            fileAssetId: fileAsset.id
          }
        },
        context,
        manager
      );
      await this.auditService.record(
        {
          aggregateType: 'file_asset',
          aggregateId: fileAsset.id,
          eventType: 'file_asset_created',
          payload: {
            businessType: fileAsset.businessType,
            businessId: fileAsset.businessId,
            fileKind: fileAsset.fileKind,
            uploadSessionId: fileAsset.uploadSessionId
          }
        },
        context,
        manager
      );
      return this.presenter.toConfirmResponse(fileAsset);
    });
  }

  private toInitCommand(payload: Record<string, unknown>): UploadInitCommand {
    const source = this.asRecord(payload);
    if (!('businessId' in source)) {
      throw uploadInitInvalid(
        'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.'
      );
    }

    const businessType = this.readRequiredString(source.businessType, 'businessType');
    const fileKind = this.readRequiredString(source.fileKind, 'fileKind');
    const mimeType = this.readRequiredString(source.mimeType, 'mimeType');
    const checksum = this.readRequiredString(source.checksum, 'checksum');
    const size = this.readPositiveSize(source.size);
    const businessId = this.readBusinessId(source.businessId);
    this.ensureSupportedUploadBinding(businessType, fileKind, mimeType);

    return {
      businessType,
      businessId,
      fileKind,
      mimeType,
      size,
      checksum
    };
  }

  private readUploadSessionId(value: unknown) {
    if (typeof value !== 'string') {
      throw uploadConfirmRequired('uploadSessionId is required for upload confirm.');
    }
    const normalized = value.trim();
    if (!normalized) {
      throw uploadConfirmRequired('uploadSessionId is required for upload confirm.');
    }
    return normalized;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw uploadInitInvalid(
        `Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum. Missing \`${field}\`.`
      );
    }
    const normalized = value.trim();
    if (!normalized) {
      throw uploadInitInvalid(
        `Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum. Missing \`${field}\`.`
      );
    }
    return normalized;
  }

  private readBusinessId(value: unknown) {
    if (value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw uploadInitInvalid(
        'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.'
      );
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readPositiveSize(value: unknown) {
    const size = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(size) || size <= 0) {
      throw uploadInitInvalid('Field `size` must be a positive integer for upload init.');
    }
    return size;
  }

  private async ensureProjectBindingForInit(projectId: string | null, manager?: EntityManager) {
    if (!projectId) {
      return;
    }
    const repository = manager?.getRepository(ProjectEntity) ?? this.projectRepository;
    const project = await repository.findOneBy({ id: projectId });
    if (!project) {
      throw uploadInitInvalid('Current project binding is unavailable for upload init.');
    }
  }

  private async ensureProjectBindingForConfirm(projectId: string | null, manager?: EntityManager) {
    if (!projectId) {
      return;
    }
    const repository = manager?.getRepository(ProjectEntity) ?? this.projectRepository;
    const project = await repository.findOneBy({ id: projectId });
    if (!project) {
      throw uploadSessionMissingFileAssetTruth('Upload session points to an unavailable project binding.');
    }
  }

  private nullable(value: string) {
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private async ensureUploadBindingForInit(
    businessType: string,
    businessId: string | null,
    manager?: EntityManager
  ) {
    if (businessType === 'project') {
      await this.ensureProjectBindingForInit(businessId, manager);
    }
  }

  private async ensureUploadBindingForConfirm(
    businessType: string,
    businessId: string | null,
    manager?: EntityManager
  ) {
    if (businessType === 'project') {
      await this.ensureProjectBindingForConfirm(businessId, manager);
    }
  }

  private ensureSupportedUploadBinding(
    businessType: string,
    fileKind: string,
    mimeType: string
  ) {
    if (businessType === 'project' && fileKind === 'evidence') {
      return;
    }
    if (businessType === 'profile' && fileKind === 'avatar') {
      if (!mimeType.toLowerCase().startsWith('image/')) {
        throw uploadInitInvalid('Current profile avatar upload only supports image mime types.');
      }
      return;
    }
    throw uploadInitInvalid(
      'Current upload init only supports project/evidence or profile/avatar bindings.'
    );
  }

  private async loadProfileSessionForInit(
    command: UploadInitCommand,
    context: RequestContext
  ) {
    if (command.businessType !== 'profile' || command.fileKind !== 'avatar') {
      return null;
    }

    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    if (command.businessId && command.businessId !== currentSession.userId) {
      throw uploadInitInvalid('Current profile avatar upload must bind to the current user.');
    }
    return currentSession;
  }

  private async loadProfileSessionForConfirm(
    session: UploadSessionEntity,
    context: RequestContext
  ) {
    if (session.businessType !== 'profile' || session.fileKind !== 'avatar') {
      return null;
    }

    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    if (session.businessId !== currentSession.userId || session.userId !== currentSession.userId) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar upload session does not belong to the current user.'
      );
    }
    if (!session.mimeType.toLowerCase().startsWith('image/')) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar upload session is missing image mime truth.'
      );
    }
    return currentSession;
  }

  private ensureProfileAvatarFileAsset(
    fileAsset: FileAssetEntity,
    session: UploadSessionEntity,
    currentUserId: string | null
  ) {
    if (session.businessType !== 'profile' || session.fileKind !== 'avatar') {
      return;
    }
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
      !currentUserId ||
      fileAsset.businessId !== currentUserId ||
      fileAsset.userId !== currentUserId
    ) {
      throw uploadSessionMissingFileAssetTruth(
        'Current profile avatar FileAsset truth does not belong to the current user.'
      );
    }
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw uploadInitInvalid('Upload init body must be an object.');
    }
    return value as Record<string, unknown>;
  }
}

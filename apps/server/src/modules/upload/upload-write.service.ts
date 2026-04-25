import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { RequestContext } from '../../shared/request-context';
import { FileAssetEntity } from './entities/file-asset.entity';
import { UploadSessionEntity } from './entities/upload-session.entity';
import { uploadInitInvalid, uploadSessionMissingFileAssetTruth, uploadSessionUnavailable } from './upload.errors';
import { UploadPresenter } from './upload.presenter';
import { UploadEnterpriseDisplayBindingService } from './upload-enterprise-display-binding.service';
import { UploadStorageService } from './upload-storage.service';
import {
  nullable,
  readUploadSessionId,
  resolveUploadBusinessId,
  toUploadInitCommand
} from './upload-write-command.support';
import {
  ensureProfileFileAsset,
  ensureProjectFileAsset,
  loadProfileSessionForConfirm,
  loadProfileSessionForInit,
  loadProjectSessionForConfirm,
  loadProjectSessionForInit
} from './upload-write-session.support';

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
    private readonly enterpriseDisplayBinding: UploadEnterpriseDisplayBindingService,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService
  ) {}

  async initUpload(payload: Record<string, unknown>, context: RequestContext) {
    const command = toUploadInitCommand(payload);
    const profileSession = await loadProfileSessionForInit(
      command,
      context,
      this.currentSessionVerificationService
    );
    const projectSession = await loadProjectSessionForInit(
      command,
      context,
      this.currentSessionVerificationService
    );
    const enterpriseDisplayListing = await this.loadEnterpriseDisplayListingForInit(command, context);
    const businessId =
      enterpriseDisplayListing?.id ?? resolveUploadBusinessId(command, profileSession);
    const verifiedSession = profileSession ?? projectSession;
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
      actorId: verifiedSession?.actorId ?? nullable(context.actorId),
      userId: verifiedSession?.userId ?? nullable(context.userId),
      organizationId: verifiedSession?.organizationId ?? context.organizationId ?? '',
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
    const uploadSessionId = readUploadSessionId(payload.uploadSessionId);

    return this.dataSource.transaction(async (manager) => {
      const sessionRepository = manager.getRepository(UploadSessionEntity);
      const fileAssetRepository = manager.getRepository(FileAssetEntity);
      const session = await sessionRepository.findOneBy({ id: uploadSessionId });
      if (!session) {
        throw uploadSessionUnavailable('Upload session does not exist for upload confirm.');
      }
      const profileSession = await loadProfileSessionForConfirm(
        session,
        context,
        this.currentSessionVerificationService
      );
      const projectSession = await loadProjectSessionForConfirm(
        session,
        context,
        this.currentSessionVerificationService
      );
      const enterpriseDisplayListing = await this.loadEnterpriseDisplayListingForConfirm(
        session,
        context,
        manager
      );
      const verifiedSession = profileSession ?? projectSession;

      if (session.fileAssetId) {
        const existing = await fileAssetRepository.findOneBy({ id: session.fileAssetId });
        if (!existing) {
          throw uploadSessionMissingFileAssetTruth('Upload session is confirmed but missing FileAsset truth.');
        }
        ensureProfileFileAsset(existing, session, profileSession);
        ensureProjectFileAsset(existing, session, projectSession);
        this.enterpriseDisplayBinding.ensureFileAsset(existing, session, enterpriseDisplayListing);
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
        actorId: verifiedSession?.actorId ?? nullable(context.actorId) ?? session.actorId,
        userId: verifiedSession?.userId ?? nullable(context.userId) ?? session.userId,
        organizationId:
          verifiedSession?.organizationId ?? context.organizationId ?? session.organizationId
      });

      session.fileAssetId = fileAsset.id;
      session.sessionStatus = 'confirmed';
      session.confirmedAt = new Date();
      if (projectSession) {
        session.actorId = projectSession.actorId;
        session.userId = projectSession.userId;
        session.organizationId = projectSession.organizationId ?? '';
      }

      ensureProfileFileAsset(fileAsset, session, profileSession);
      ensureProjectFileAsset(fileAsset, session, projectSession);
      this.enterpriseDisplayBinding.ensureFileAsset(fileAsset, session, enterpriseDisplayListing);
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

  private async loadEnterpriseDisplayListingForInit(
    command: { businessType: string; businessId: string | null },
    context: RequestContext
  ) {
    if (command.businessType !== 'enterprise_display') {
      return null;
    }
    return this.enterpriseDisplayBinding.loadOwnedListingForInit(command.businessId, context);
  }

  private async loadEnterpriseDisplayListingForConfirm(
    session: UploadSessionEntity,
    context: RequestContext,
    manager?: EntityManager
  ) {
    if (session.businessType !== 'enterprise_display') {
      return null;
    }
    return this.enterpriseDisplayBinding.loadOwnedListingForConfirm(session, context, manager);
  }

}

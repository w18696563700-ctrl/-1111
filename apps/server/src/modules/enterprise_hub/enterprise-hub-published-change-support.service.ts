import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  ENTERPRISE_HUB_ACTIVE_CHANGE_REQUEST_STATUSES,
  ENTERPRISE_HUB_EDITABLE_CHANGE_REQUEST_STATUSES,
} from './enterprise-hub.constants';
import {
  changeCorridorNotAvailable,
  enterpriseNotFound,
  invalidBoardType,
  invalidStateTransition,
  caseNotFound,
} from './enterprise-hub.errors';
import { EnterpriseHubListingWriteSupportService } from './enterprise-hub-listing-write-support.service';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';
import { EnterpriseHubPublishedChangeSnapshotService } from './enterprise-hub-published-change-snapshot.service';
import {
  EnterpriseHubPublishedChangeBasic,
  EnterpriseHubPublishedChangeCase,
  EnterpriseHubPublishedChangePrimaryContact,
  EnterpriseHubPublishedChangeSnapshot,
} from './enterprise-hub-published-change.types';
import { canonicalizeEnterpriseHubRegionDisplayFields } from './enterprise-hub-region-lookup';
import { EnterpriseChangeRequestEntity } from './entities/enterprise-change-request.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { RequestContext } from '../../shared/request-context';

@Injectable()
export class EnterpriseHubPublishedChangeSupportService {
  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(EnterpriseChangeRequestEntity)
    private readonly changeRequestRepository: Repository<EnterpriseChangeRequestEntity>,
    private readonly listingWriteSupportService: EnterpriseHubListingWriteSupportService,
    private readonly snapshotService: EnterpriseHubPublishedChangeSnapshotService,
    private readonly mediaTruthService: EnterpriseHubMediaTruthService,
  ) {}

  async loadPublishedOwnedListing(enterpriseId: string, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(
      enterpriseId,
      context,
    );
    this.ensureCorridorAvailable(listing);
    return listing;
  }

  async loadChangeRequestById(changeRequestId: string) {
    const request = await this.changeRequestRepository.findOneBy({ id: changeRequestId });
    if (!request) {
      throw invalidStateTransition(
        'Enterprise hub published change request is unavailable for the governed corridor.',
      );
    }
    const listing = await this.listingRepository.findOneBy({ id: request.enterpriseId });
    if (!listing) {
      throw enterpriseNotFound();
    }
    if (request.boardType !== listing.primaryBoardType) {
      throw invalidStateTransition(
        'Enterprise hub published change request no longer matches the current live listing board truth.',
      );
    }
    return {
      request,
      listing,
      snapshot: await this.readSnapshotWithMedia(listing, request),
    };
  }

  async loadCurrentView(enterpriseId: string, context: RequestContext) {
    const listing = await this.loadPublishedOwnedListing(enterpriseId, context);
    const active = await this.loadCurrentActiveChangeRequest(enterpriseId);
    if (active) {
      return {
        listing,
        request: active,
        snapshot: await this.readSnapshotWithMedia(listing, active),
      };
    }

    const latest = await this.loadLatestChangeRequest(enterpriseId);
    if (!latest || latest.changeStatus === 'applied') {
      return {
        listing,
        request: null,
        snapshot: await this.snapshotService.buildLiveSnapshot(listing),
      };
    }
    return {
      listing,
      request: latest,
      snapshot: await this.readSnapshotWithMedia(listing, latest),
    };
  }

  async loadStatusRequest(enterpriseId: string, context: RequestContext) {
    const listing = await this.loadPublishedOwnedListing(enterpriseId, context);
    const active = await this.loadCurrentActiveChangeRequest(enterpriseId);
    if (active) {
      return {
        listing,
        request: active,
      };
    }

    const latest = await this.loadLatestChangeRequest(enterpriseId);
    if (!latest) {
      return {
        listing,
        request: this.buildEphemeralDraftStatus(listing),
      };
    }

    return {
      listing,
      request: latest,
    };
  }

  async getOrCreateEditableRequest(enterpriseId: string, context: RequestContext) {
    const listing = await this.loadPublishedOwnedListing(enterpriseId, context);
    const latest = await this.loadCurrentActiveChangeRequest(enterpriseId);
    if (latest && ENTERPRISE_HUB_EDITABLE_CHANGE_REQUEST_STATUSES.includes(latest.changeStatus as never)) {
      return {
        listing,
        request: latest,
        snapshot: await this.readSnapshotWithMedia(listing, latest),
      };
    }
    if (latest && ['submitted', 'under_review', 'approved'].includes(latest.changeStatus)) {
      throw invalidStateTransition(
        'Current enterprise published change request is not editable in its current governance state.',
      );
    }
    const created = await this.createDraftRequestFromLive(listing);
    return {
      listing,
      request: created,
      snapshot: await this.readSnapshotWithMedia(listing, created),
    };
  }

  async saveDraftSnapshot(
    request: EnterpriseChangeRequestEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    request.draftBasic = snapshot.basic;
    request.draftBoardProfile = snapshot.boardProfile;
    request.draftPrimaryContact = snapshot.primaryContact;
    request.draftCases = snapshot.cases;
    return this.changeRequestRepository.save(request);
  }

  buildReadiness(input: {
    boardType: string;
    request: EnterpriseChangeRequestEntity | null;
    snapshot: EnterpriseHubPublishedChangeSnapshot;
  }) {
    const blockers: string[] = [];
    if (!this.isBasicComplete(input.snapshot.basic)) {
      blockers.push('基础资料未完成，请补齐企业名称、一句话简介和组织所在城市。');
    }
    if (!this.isProfileCompleted(input.boardType, input.snapshot.boardProfile)) {
      blockers.push('板块画像未完成，请补齐当前主板块的必填资料。');
    }
    if (input.snapshot.cases.length === 0) {
      blockers.push('当前至少需要 1 个案例才能提交展示变更。');
    }
    if (!this.hasContact(input.snapshot.primaryContact)) {
      blockers.push('当前缺少主联系人，请先填写联系人。');
    }

    const changeStatus = input.request?.changeStatus ?? 'draft';
    const draftEditable =
      input.request == null ||
      ENTERPRISE_HUB_EDITABLE_CHANGE_REQUEST_STATUSES.includes(changeStatus as never);

    return {
      draftEditable,
      submitReady: draftEditable && blockers.length === 0,
      blockers,
    };
  }

  async buildCaseCreateSnapshot(
    listing: EnterpriseListingEntity,
    payload: Record<string, unknown>,
  ): Promise<EnterpriseHubPublishedChangeCase> {
    const caseMediaFileAssetIds = this.readStringArray(payload.caseMediaFileAssetIds).slice(0, 6);
    const caseCoverFileAssetId =
      this.readNullableString(payload.caseCoverFileAssetId) ?? caseMediaFileAssetIds[0] ?? null;
    if (!caseCoverFileAssetId) {
      throw invalidStateTransition(
        'Field `caseCoverFileAssetId` is required unless caseMediaFileAssetIds provides at least one image.',
      );
    }
    await this.mediaTruthService.validateCaseMedia(listing, {
      caseCoverFileAssetId,
      caseMediaFileAssetIds,
    });
    return {
      caseId: randomUUID(),
      boardType: listing.primaryBoardType,
      title: this.readText(payload.title, 'title'),
      exhibitionType: this.readNullableString(payload.exhibitionType),
      city: this.readNullableString(payload.city),
      eventTime: this.readNullableString(payload.eventTime),
      summary: this.readText(payload.summary, 'summary'),
      caseCoverFileAssetId,
      caseMediaFileAssetIds,
      caseImageUrlMap: {},
      isFeatured: payload.isFeatured === true,
      caseStatus: 'draft',
    };
  }

  async updateCaseSnapshot(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
    caseId: string,
    payload: Record<string, unknown>,
  ) {
    if (Object.prototype.hasOwnProperty.call(payload, 'boardType')) {
      throw invalidBoardType(
        'Case boardType is immutable inside the published change corridor.',
      );
    }
    const index = snapshot.cases.findIndex((item) => item.caseId === caseId);
    if (index < 0) {
      throw caseNotFound();
    }
    const current = snapshot.cases[index];
    const caseMediaFileAssetIds = Array.isArray(payload.caseMediaFileAssetIds)
      ? this.readStringArray(payload.caseMediaFileAssetIds).slice(0, 6)
      : current.caseMediaFileAssetIds;
    const requestedCover = Object.prototype.hasOwnProperty.call(payload, 'caseCoverFileAssetId')
      ? this.readNullableString(payload.caseCoverFileAssetId)
      : current.caseCoverFileAssetId;
    const nextCase = {
      ...current,
      title: this.readText(payload.title, 'title'),
      exhibitionType: Object.prototype.hasOwnProperty.call(payload, 'exhibitionType')
        ? this.readNullableString(payload.exhibitionType)
        : current.exhibitionType,
      city: Object.prototype.hasOwnProperty.call(payload, 'city')
        ? this.readNullableString(payload.city)
        : current.city,
      eventTime: Object.prototype.hasOwnProperty.call(payload, 'eventTime')
        ? this.readNullableString(payload.eventTime)
        : current.eventTime,
      summary: this.readText(payload.summary, 'summary'),
      caseMediaFileAssetIds,
      caseCoverFileAssetId:
        requestedCover ?? caseMediaFileAssetIds[0] ?? current.caseCoverFileAssetId,
      isFeatured: Object.prototype.hasOwnProperty.call(payload, 'isFeatured')
        ? payload.isFeatured === true
        : current.isFeatured,
    };
    await this.mediaTruthService.validateCaseMedia(listing, {
      caseCoverFileAssetId: nextCase.caseCoverFileAssetId,
      caseMediaFileAssetIds: nextCase.caseMediaFileAssetIds,
    });
    snapshot.cases[index] = nextCase;
  }

  async validateDraftBasicMedia(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    await this.mediaTruthService.validateListingBasicMedia(listing, {
      logoFileAssetId: snapshot.basic.logoFileAssetId,
      albumImageFileAssetIds: snapshot.basic.albumImageFileAssetIds,
    });
  }

  async validateDraftBoardProfileMedia(
    listing: EnterpriseListingEntity,
    boardProfile: Record<string, unknown> | null,
  ) {
    if (listing.primaryBoardType !== 'factory' || !boardProfile) {
      return;
    }
    await this.mediaTruthService.validateFactoryShowcaseMedia(
      listing,
      this.readStringArray(boardProfile.showcaseImageFileAssetIds).slice(0, 6),
    );
  }

  deleteCaseSnapshot(snapshot: EnterpriseHubPublishedChangeSnapshot, caseId: string) {
    const nextCases = snapshot.cases.filter((item) => item.caseId !== caseId);
    if (nextCases.length === snapshot.cases.length) {
      throw caseNotFound();
    }
    snapshot.cases = nextCases;
  }

  private async loadLatestChangeRequest(enterpriseId: string) {
    return this.changeRequestRepository.findOne({
      where: { enterpriseId },
      order: { createdAt: 'DESC', updatedAt: 'DESC' },
    });
  }

  private async loadCurrentActiveChangeRequest(enterpriseId: string) {
    const requests = await this.changeRequestRepository.find({
      where: { enterpriseId },
      order: { createdAt: 'DESC', updatedAt: 'DESC' },
    });
    const activeRequests = requests.filter((item) =>
      ENTERPRISE_HUB_ACTIVE_CHANGE_REQUEST_STATUSES.includes(item.changeStatus as never),
    );
    if (activeRequests.length <= 1) {
      return activeRequests[0] ?? null;
    }
    throw invalidStateTransition(
      'Current enterprise listing has multiple active published change requests.',
    );
  }

  private async createDraftRequestFromLive(listing: EnterpriseListingEntity) {
    const snapshot = await this.snapshotService.buildLiveSnapshot(listing);
    const request = this.changeRequestRepository.create({
      id: randomUUID(),
      enterpriseId: listing.id,
      boardType: listing.primaryBoardType,
      changeStatus: 'draft',
      draftBasic: snapshot.basic,
      draftBoardProfile: snapshot.boardProfile,
      draftPrimaryContact: snapshot.primaryContact,
      draftCases: snapshot.cases,
      submittedAt: null,
      reviewedAt: null,
      appliedAt: null,
      rejectionReason: null,
      reviewNote: null,
      reviewerActorId: null,
      appliedByActorId: null,
    });
    return this.changeRequestRepository.save(request);
  }

  private ensureCorridorAvailable(listing: EnterpriseListingEntity) {
    if (listing.enterpriseStatus === 'published' && listing.displayStatus === 'visible') {
      return;
    }
    throw changeCorridorNotAvailable(
      'Current enterprise listing does not enter the published-governed change corridor.',
    );
  }

  private readSnapshot(request: EnterpriseChangeRequestEntity): EnterpriseHubPublishedChangeSnapshot {
    const basic = (request.draftBasic ?? {}) as EnterpriseHubPublishedChangeBasic;
    const canonicalBasic = canonicalizeEnterpriseHubRegionDisplayFields(basic);
    const canonicalLocation = basic.location
      ? canonicalizeEnterpriseHubRegionDisplayFields(basic.location)
      : basic.location;
    return {
      basic: {
        ...canonicalBasic,
        location: canonicalLocation,
      },
      boardProfile: (request.draftBoardProfile ?? null) as Record<string, unknown> | null,
      primaryContact:
        (request.draftPrimaryContact ?? null) as EnterpriseHubPublishedChangePrimaryContact | null,
      cases: (request.draftCases ?? []) as EnterpriseHubPublishedChangeCase[],
    };
  }

  private async readSnapshotWithMedia(
    listing: EnterpriseListingEntity,
    request: EnterpriseChangeRequestEntity,
  ) {
    return this.snapshotService.hydrateSnapshotMedia(
      listing,
      this.readSnapshot(request),
    );
  }

  private buildEphemeralDraftStatus(listing: EnterpriseListingEntity): EnterpriseChangeRequestEntity {
    return {
      id: `${listing.id}:draft`,
      enterpriseId: listing.id,
      boardType: listing.primaryBoardType,
      changeStatus: 'draft',
      draftBasic: {},
      draftBoardProfile: null,
      draftPrimaryContact: null,
      draftCases: [],
      submittedAt: null,
      reviewedAt: null,
      appliedAt: null,
      rejectionReason: null,
      reviewNote: null,
      reviewerActorId: null,
      appliedByActorId: null,
      createdAt: listing.createdAt ?? new Date(0),
      updatedAt: listing.updatedAt ?? new Date(0),
    };
  }

  private isBasicComplete(basic: EnterpriseHubPublishedChangeBasic) {
    return !!basic.name?.trim() && !!basic.shortIntro?.trim() && !!basic.provinceName?.trim() && !!basic.cityName?.trim();
  }

  private isProfileCompleted(boardType: string, boardProfile: Record<string, unknown> | null) {
    if (!boardProfile) {
      return false;
    }
    if (boardType === 'company') {
      return this.hasNonEmptyArray(boardProfile.exhibitionTypes) &&
        this.hasNonEmptyArray(boardProfile.serviceItems) &&
        this.hasNonEmptyArray(boardProfile.serviceCities);
    }
    if (boardType === 'factory') {
      return this.hasText(boardProfile.factoryName) &&
        this.hasNonEmptyArray(boardProfile.processTypes) &&
        this.hasNonEmptyArray(boardProfile.coreProducts);
    }
    return this.hasNonEmptyArray(boardProfile.supplyCategories) &&
      this.hasNonEmptyArray(boardProfile.supplyMode) &&
      this.hasNonEmptyArray(boardProfile.coreProductsOrServices);
  }

  private hasContact(contact: EnterpriseHubPublishedChangePrimaryContact | null) {
    return !!contact?.contactName?.trim() && !!contact.mobile?.trim();
  }

  private hasNonEmptyArray(value: unknown) {
    return Array.isArray(value) && value.length > 0;
  }

  private hasText(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0;
  }

  private readText(value: unknown, field: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw invalidStateTransition(`Field \`${field}\` is required for enterprise hub published change draft.`);
  }

  private readNullableString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private readStringArray(value: unknown) {
    return Array.isArray(value) ? value.filter((item): item is string => typeof item === 'string') : [];
  }
}

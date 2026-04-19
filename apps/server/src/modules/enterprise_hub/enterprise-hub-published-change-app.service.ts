import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import {
  EnterpriseHubPublishedChangeBasic,
  EnterpriseHubPublishedChangeLocation,
  EnterpriseHubPublishedChangePrimaryContact,
} from './enterprise-hub-published-change.types';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubPublishedChangePresenter } from './enterprise-hub-published-change.presenter';
import { EnterpriseHubPublishedChangeSupportService } from './enterprise-hub-published-change-support.service';
import { missingRequiredFields } from './enterprise-hub.errors';

@Injectable()
export class EnterpriseHubPublishedChangeAppService {
  constructor(
    private readonly supportService: EnterpriseHubPublishedChangeSupportService,
    private readonly presenter: EnterpriseHubPublishedChangePresenter,
    private readonly locationService: EnterpriseHubLocationService,
  ) {}

  async getCurrentChange(enterpriseId: string, context: RequestContext) {
    const view = await this.supportService.loadCurrentView(enterpriseId, context);
    return this.presenter.toWorkbenchResponse({
      listing: view.listing,
      snapshot: view.snapshot,
      request: view.request,
      changeReadiness: this.supportService.buildReadiness({
        boardType: view.listing.primaryBoardType,
        request: view.request,
        snapshot: view.snapshot,
      }),
    });
  }

  async updateCurrentBasic(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    current.snapshot.basic = this.mergeBasic(current.snapshot.basic, payload);
    current.snapshot.primaryContact = this.mergePrimaryContact(
      current.snapshot.primaryContact,
      current.snapshot.basic,
      payload,
    );
    await this.supportService.validateDraftBasicMedia(
      current.listing,
      current.snapshot,
    );
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    return this.ack(context.traceId);
  }

  async updateCurrentCompanyProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    return this.updateCurrentBoardProfile(enterpriseId, 'company', payload, context);
  }

  async updateCurrentFactoryProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    return this.updateCurrentBoardProfile(enterpriseId, 'factory', payload, context);
  }

  async updateCurrentSupplierProfile(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    return this.updateCurrentBoardProfile(enterpriseId, 'supplier', payload, context);
  }

  async createCurrentCase(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    current.snapshot.cases.unshift(
      await this.supportService.buildCaseCreateSnapshot(current.listing, payload),
    );
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    const created = current.snapshot.cases[0];
    return {
      caseId: created.caseId,
      caseStatus: created.caseStatus,
    };
  }

  async updateCurrentCase(
    enterpriseId: string,
    caseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    this.requireEnterpriseScope(enterpriseId, current.listing.id);
    await this.supportService.updateCaseSnapshot(
      current.listing,
      current.snapshot,
      caseId,
      payload,
    );
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    const updated = current.snapshot.cases.find((item) => item.caseId === caseId);
    return {
      caseId,
      caseStatus: updated?.caseStatus ?? 'draft',
    };
  }

  async deleteCurrentCase(
    enterpriseId: string,
    caseId: string,
    context: RequestContext,
  ) {
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    this.requireEnterpriseScope(enterpriseId, current.listing.id);
    this.supportService.deleteCaseSnapshot(current.snapshot, caseId);
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    return this.ack(context.traceId);
  }

  async submitCurrentChange(
    enterpriseId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    if (payload.confirm !== true) {
      throw missingRequiredFields('Field `confirm` must be true for enterprise hub change submit.');
    }
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    const readiness = this.supportService.buildReadiness({
      boardType: current.listing.primaryBoardType,
      request: current.request,
      snapshot: current.snapshot,
    });
    if (!readiness.submitReady) {
      throw missingRequiredFields(
        `Current enterprise hub change request is not submit-ready: ${readiness.blockers.join(' / ')}`,
      );
    }
    current.request.changeStatus = 'submitted';
    current.request.submittedAt = new Date();
    current.request.reviewedAt = null;
    current.request.rejectionReason = null;
    current.request.reviewNote = null;
    current.request.reviewerActorId = null;
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    return this.ack(context.traceId);
  }

  async getCurrentChangeStatus(enterpriseId: string, context: RequestContext) {
    const current = await this.supportService.loadStatusRequest(enterpriseId, context);
    return this.presenter.toStatusResponse(current.listing.id, current.request);
  }

  private async updateCurrentBoardProfile(
    enterpriseId: string,
    boardType: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const current = await this.supportService.getOrCreateEditableRequest(enterpriseId, context);
    this.requireBoardType(current.listing.primaryBoardType, boardType);
    current.snapshot.boardProfile = {
      ...(current.snapshot.boardProfile ?? {}),
      ...payload,
    };
    await this.supportService.validateDraftBoardProfileMedia(
      current.listing,
      current.snapshot.boardProfile,
    );
    await this.supportService.saveDraftSnapshot(current.request, current.snapshot);
    return this.ack(context.traceId);
  }

  private mergeBasic(
    current: EnterpriseHubPublishedChangeBasic,
    payload: Record<string, unknown>,
  ): EnterpriseHubPublishedChangeBasic {
    const next = { ...current };
    if (typeof payload.name === 'string') next.name = payload.name.trim();
    if (typeof payload.logoFileAssetId === 'string' || payload.logoFileAssetId === null) {
      next.logoFileAssetId = this.readNullableString(payload.logoFileAssetId);
    }
    if (Array.isArray(payload.albumImageFileAssetIds)) {
      next.albumImageFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
        payload.albumImageFileAssetIds,
      );
    }
    if (typeof payload.shortIntro === 'string') next.shortIntro = payload.shortIntro.trim();
    if (typeof payload.fullIntro === 'string' || payload.fullIntro === null) {
      next.fullIntro = this.readNullableString(payload.fullIntro)?.slice(0, 2000) ?? null;
    }
    if (typeof payload.provinceCode === 'string') next.provinceCode = payload.provinceCode.trim();
    if (typeof payload.provinceName === 'string') next.provinceName = payload.provinceName.trim();
    if (typeof payload.cityCode === 'string') next.cityCode = payload.cityCode.trim();
    if (typeof payload.cityName === 'string') next.cityName = payload.cityName.trim();
    if (typeof payload.address === 'string' || payload.address === null) {
      next.address = this.readNullableString(payload.address);
    }
    const normalizedLocation = this.mergeBasicLocation(next.location, payload, {
      addressText: next.address,
      provinceCode: next.provinceCode,
      provinceName: next.provinceName,
      cityCode: next.cityCode,
      cityName: next.cityName,
    });
    next.location = normalizedLocation;
    next.provinceCode = normalizedLocation.provinceCode;
    next.provinceName = normalizedLocation.provinceName;
    next.cityCode = normalizedLocation.cityCode;
    next.cityName = normalizedLocation.cityName;
    next.address = normalizedLocation.addressText ?? next.address;
    if (typeof payload.foundedAt === 'string' || payload.foundedAt === null) {
      next.foundedAt = this.readNullableString(payload.foundedAt);
    }
    if (typeof payload.teamSizeRange === 'string' || payload.teamSizeRange === null) {
      next.teamSizeRange = this.readNullableString(payload.teamSizeRange);
    }
    if (Array.isArray(payload.cooperationModes)) {
      next.cooperationModes = payload.cooperationModes.filter((item): item is string => typeof item === 'string');
    }
    if (typeof payload.contactVisible === 'boolean') {
      next.contactVisible = payload.contactVisible;
    }
    return next;
  }

  private mergeBasicLocation(
    current: EnterpriseHubPublishedChangeLocation | null,
    payload: Record<string, unknown>,
    fallback: {
      addressText: string | null;
      provinceCode: string | null;
      provinceName: string | null;
      cityCode: string | null;
      cityName: string | null;
    },
  ): EnterpriseHubPublishedChangeLocation {
    return this.locationService.normalizeWriteLocation(
      payload.location ??
        current ?? {
          addressText: fallback.addressText,
          publicDisplayAddress: fallback.addressText,
          provinceCode: fallback.provinceCode,
          provinceName: fallback.provinceName,
          cityCode: fallback.cityCode,
          cityName: fallback.cityName,
          districtCode: null,
          districtName: null,
          latitude: null,
          longitude: null,
          geoSource: 'unknown',
          geoStatus: 'not_provided',
          lastGeocodedAt: null,
          mapProvider: null,
          mapPreviewUrl: null,
          mapLinkUrl: null,
        },
      fallback,
    );
  }

  private mergePrimaryContact(
    current: EnterpriseHubPublishedChangePrimaryContact | null,
    basic: EnterpriseHubPublishedChangeBasic,
    payload: Record<string, unknown>,
  ): EnterpriseHubPublishedChangePrimaryContact | null {
    const nextContactName =
      this.readNullableString(payload.contactName) ?? current?.contactName?.trim() ?? null;
    const nextContactMobile =
      this.readNullableString(payload.contactMobile) ?? current?.mobile?.trim() ?? null;
    if (!nextContactName || !nextContactMobile) {
      return current;
    }
    return {
      contactName: nextContactName,
      mobile: nextContactMobile,
      wechat: current?.wechat ?? null,
      phone: current?.phone ?? null,
      email: current?.email ?? null,
      position: current?.position ?? null,
      isPrimary: current?.isPrimary ?? true,
      visibleToPublic: basic.contactVisible,
    };
  }

  private requireBoardType(currentBoardType: string, expectedBoardType: string) {
    if (currentBoardType !== expectedBoardType) {
      throw missingRequiredFields('Current enterprise published change request does not match requested board profile path.');
    }
  }

  private requireEnterpriseScope(requestedEnterpriseId: string, actualEnterpriseId: string) {
    if (requestedEnterpriseId !== actualEnterpriseId) {
      throw missingRequiredFields('Current enterprise published change request scope is mismatched.');
    }
  }

  private readNullableString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private ack(traceId: string) {
    return { ok: true, traceId };
  }
}

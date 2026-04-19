import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  normalizeEnterpriseAlbumFileAssetIds,
} from './enterprise-hub-album-truth';
import { EnterpriseHubContactWriteService } from './enterprise-hub-contact-write.service';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubListingWriteSupportService } from './enterprise-hub-listing-write-support.service';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';
import { EnterpriseHubPublishedChangeSnapshot } from './enterprise-hub-published-change.types';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';

@Injectable()
export class EnterpriseHubPublishedChangeLiveWriteService {
  constructor(
    @InjectRepository(EnterpriseProfileCompanyEntity)
    private readonly companyRepository: Repository<EnterpriseProfileCompanyEntity>,
    @InjectRepository(EnterpriseProfileFactoryEntity)
    private readonly factoryRepository: Repository<EnterpriseProfileFactoryEntity>,
    @InjectRepository(EnterpriseProfileSupplierEntity)
    private readonly supplierRepository: Repository<EnterpriseProfileSupplierEntity>,
    @InjectRepository(EnterpriseCaseEntity)
    private readonly caseRepository: Repository<EnterpriseCaseEntity>,
    private readonly contactWriteService: EnterpriseHubContactWriteService,
    private readonly listingWriteSupportService: EnterpriseHubListingWriteSupportService,
    private readonly locationService: EnterpriseHubLocationService,
    private readonly mediaTruthService: EnterpriseHubMediaTruthService,
  ) {}

  async applyToLiveListing(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    await this.mediaTruthService.validateListingBasicMedia(listing, {
      logoFileAssetId: snapshot.basic.logoFileAssetId,
      albumImageFileAssetIds: normalizeEnterpriseAlbumFileAssetIds(
        snapshot.basic.albumImageFileAssetIds,
      ),
    });
    await this.mediaTruthService.syncListingBasicRefs(listing, {
      logoFileAssetId: snapshot.basic.logoFileAssetId,
      albumImageFileAssetIds: normalizeEnterpriseAlbumFileAssetIds(
        snapshot.basic.albumImageFileAssetIds,
      ),
    });
    this.applyBasic(listing, snapshot);
    await this.applyBoardProfile(listing, snapshot.boardProfile);
    await this.applyCases(listing, snapshot);
    await this.contactWriteService.upsertPrimaryContactFromBasic(listing.id, {
      contactName: snapshot.primaryContact?.contactName ?? null,
      contactMobile: snapshot.primaryContact?.mobile ?? null,
      defaultVisibleToPublic: listing.contactVisible,
    });
    await this.listingWriteSupportService.upsertRegisteredArea(listing);
  }

  private applyBasic(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    listing.name = snapshot.basic.name?.trim() ?? '';
    listing.logoFileAssetId = snapshot.basic.logoFileAssetId;
    listing.coverFileAssetId = null;
    listing.albumImageFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
      snapshot.basic.albumImageFileAssetIds,
    );
    listing.shortIntro = snapshot.basic.shortIntro?.trim() ?? '';
    listing.fullIntro = snapshot.basic.fullIntro;
    listing.provinceCode = snapshot.basic.provinceCode?.trim() ?? '';
    listing.provinceName = snapshot.basic.provinceName?.trim() ?? '';
    listing.cityCode = snapshot.basic.cityCode?.trim() ?? '';
    listing.cityName = snapshot.basic.cityName?.trim() ?? '';
    listing.address = snapshot.basic.address;
    this.locationService.applyToListing(listing, snapshot.basic.location);
    listing.foundedAt = snapshot.basic.foundedAt;
    listing.teamSizeRange = snapshot.basic.teamSizeRange;
    listing.cooperationModes = snapshot.basic.cooperationModes ?? [];
    listing.contactVisible = snapshot.basic.contactVisible === true;
  }

  private async applyBoardProfile(
    listing: EnterpriseListingEntity,
    snapshot: Record<string, unknown> | null,
  ) {
    if (!snapshot) {
      return;
    }
    if (listing.primaryBoardType === 'company') {
      const existing = await this.companyRepository.findOneBy({ enterpriseId: listing.id });
      await this.companyRepository.save(
        this.companyRepository.create({
          ...(existing ?? { enterpriseId: listing.id }),
          exhibitionTypes: this.readStringArray(snapshot.exhibitionTypes),
          serviceItems: this.readStringArray(snapshot.serviceItems),
          serviceCities: this.readStringArray(snapshot.serviceCities),
          teamSize: this.readNullableNumber(snapshot.teamSize),
          maxProjectScale: this.readNullableString(snapshot.maxProjectScale),
          averageDeliveryCycleDays: this.readNullableNumber(snapshot.averageDeliveryCycleDays),
          knownClients: this.readStringArray(snapshot.knownClients),
          qualificationDesc: this.readNullableString(snapshot.qualificationDesc),
          projectManagementCapability: this.readNullableString(snapshot.projectManagementCapability),
          onsiteExecutionCapability: this.readNullableString(snapshot.onsiteExecutionCapability),
        }),
      );
      return;
    }
    if (listing.primaryBoardType === 'factory') {
      const existing = await this.factoryRepository.findOneBy({ enterpriseId: listing.id });
      const showcaseImageFileAssetIds = this.readStringArray(
        snapshot.showcaseImageFileAssetIds,
      ).slice(0, 6);
      await this.mediaTruthService.validateFactoryShowcaseMedia(
        listing,
        showcaseImageFileAssetIds,
      );
      await this.factoryRepository.save(
        this.factoryRepository.create({
          ...(existing ?? { enterpriseId: listing.id }),
          factoryName: this.readNullableString(snapshot.factoryName),
          processTypes: this.readStringArray(snapshot.processTypes),
          coreProducts: this.readStringArray(snapshot.coreProducts),
          equipmentList: this.readStringArray(snapshot.equipmentList),
          showcaseImageFileAssetIds,
          plantAreaSqm: this.readNullableNumber(snapshot.plantAreaSqm),
          monthlyCapacityDesc: this.readNullableString(snapshot.monthlyCapacityDesc),
          urgentOrderCapability: this.readNullableString(snapshot.urgentOrderCapability),
          urgentCycleDesc: this.readNullableString(snapshot.urgentCycleDesc),
          warehouseCapability: this.readNullableBoolean(snapshot.warehouseCapability),
          transportCapability: this.readNullableString(snapshot.transportCapability),
          maxOrderCapacityDesc: this.readNullableString(snapshot.maxOrderCapacityDesc),
          productionQualificationDesc: this.readNullableString(snapshot.productionQualificationDesc),
          deliveryRadiusDesc: this.readNullableString(snapshot.deliveryRadiusDesc),
        }),
      );
      await this.mediaTruthService.syncFactoryShowcaseRefs(listing, showcaseImageFileAssetIds);
      return;
    }

    const existing = await this.supplierRepository.findOneBy({ enterpriseId: listing.id });
    await this.supplierRepository.save(
      this.supplierRepository.create({
        ...(existing ?? { enterpriseId: listing.id }),
        supplyCategories: this.readStringArray(snapshot.supplyCategories),
        supplyMode: this.readStringArray(snapshot.supplyMode),
        coreProductsOrServices: this.readStringArray(snapshot.coreProductsOrServices),
        responseSlaDesc: this.readNullableString(snapshot.responseSlaDesc),
        stockStatusDesc: this.readNullableString(snapshot.stockStatusDesc),
        deliveryRange: this.readNullableString(snapshot.deliveryRange),
        aftersalesPolicy: this.readNullableString(snapshot.aftersalesPolicy),
        partnerCasesDesc: this.readNullableString(snapshot.partnerCasesDesc),
        supplyQualificationDesc: this.readNullableString(snapshot.supplyQualificationDesc),
      }),
    );
  }

  private async applyCases(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    const existing = await this.caseRepository.findBy({
      enterpriseId: listing.id,
      boardType: listing.primaryBoardType,
    });
    const targetSnapshotCases = snapshot.cases.filter(
      (item) => item.boardType === listing.primaryBoardType,
    );
    const snapshotIds = new Set(targetSnapshotCases.map((item) => item.caseId));
    for (const item of existing) {
      if (!snapshotIds.has(item.id)) {
        await this.caseRepository.delete({ id: item.id });
        await this.mediaTruthService.clearCaseRefs(listing.id, 'enterprise_case', item.id);
      }
    }

    for (const item of targetSnapshotCases) {
      await this.mediaTruthService.validateCaseMedia(listing, {
        caseCoverFileAssetId:
          item.caseCoverFileAssetId ?? item.caseMediaFileAssetIds[0] ?? null,
        caseMediaFileAssetIds: item.caseMediaFileAssetIds,
      });
      await this.caseRepository.save(
        this.caseRepository.create({
          ...(existing.find((candidate) => candidate.id === item.caseId) ?? {
            id: item.caseId,
            enterpriseId: listing.id,
            sortOrder: null,
            reviewNote: null,
          }),
          enterpriseId: listing.id,
          boardType: listing.primaryBoardType,
          title: item.title,
          exhibitionType: item.exhibitionType,
          city: item.city,
          eventTime: item.eventTime,
          summary: item.summary,
          caseCoverFileAssetId:
            item.caseCoverFileAssetId ?? item.caseMediaFileAssetIds[0] ?? null,
          caseMediaFileAssetIds: item.caseMediaFileAssetIds,
          isFeatured: item.isFeatured,
          caseStatus: 'approved',
        }),
      );
      await this.mediaTruthService.syncCaseRefs(listing, 'enterprise_case', item.caseId, {
        caseCoverFileAssetId:
          item.caseCoverFileAssetId ?? item.caseMediaFileAssetIds[0] ?? null,
        caseMediaFileAssetIds: item.caseMediaFileAssetIds,
      });
    }
  }

  private readNullableString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private readStringArray(value: unknown) {
    return Array.isArray(value) ? value.filter((item): item is string => typeof item === 'string') : [];
  }

  private readNullableNumber(value: unknown) {
    return typeof value === 'number' && Number.isFinite(value) ? value : null;
  }

  private readNullableBoolean(value: unknown) {
    return typeof value === 'boolean' ? value : null;
  }
}

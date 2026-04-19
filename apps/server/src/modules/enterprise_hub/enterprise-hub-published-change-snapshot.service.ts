import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import {
  EnterpriseHubPublishedChangeBasic,
  EnterpriseHubPublishedChangePrimaryContact,
  EnterpriseHubPublishedChangeSnapshot,
} from './enterprise-hub-published-change.types';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubMediaProjectionService } from './enterprise-hub-media-projection.service';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';

@Injectable()
export class EnterpriseHubPublishedChangeSnapshotService {
  constructor(
    @InjectRepository(EnterpriseProfileCompanyEntity)
    private readonly companyRepository: Repository<EnterpriseProfileCompanyEntity>,
    @InjectRepository(EnterpriseProfileFactoryEntity)
    private readonly factoryRepository: Repository<EnterpriseProfileFactoryEntity>,
    @InjectRepository(EnterpriseProfileSupplierEntity)
    private readonly supplierRepository: Repository<EnterpriseProfileSupplierEntity>,
    @InjectRepository(EnterpriseCaseEntity)
    private readonly caseRepository: Repository<EnterpriseCaseEntity>,
    @InjectRepository(EnterpriseContactEntity)
    private readonly contactRepository: Repository<EnterpriseContactEntity>,
    private readonly locationService: EnterpriseHubLocationService,
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionService,
  ) {}

  async buildLiveSnapshot(listing: EnterpriseListingEntity) {
    const [boardProfile, primaryContact, cases] = await Promise.all([
      this.loadBoardProfile(listing.id, listing.primaryBoardType),
      this.loadPrimaryContact(listing.id),
      this.caseRepository.find({
        where: {
          enterpriseId: listing.id,
          boardType: listing.primaryBoardType,
        },
        order: { createdAt: 'DESC', updatedAt: 'DESC' },
      }),
    ]);
    const location = this.locationService.toReadModel(listing);
    const albumImageFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
      listing.albumImageFileAssetIds,
    );
    const factoryShowcaseImageFileAssetIds =
      listing.primaryBoardType === 'factory'
        ? this.readStringArray(
            (boardProfile as Record<string, unknown> | null)?.showcaseImageFileAssetIds,
          )
        : [];
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap([
      listing.logoFileAssetId,
      ...albumImageFileAssetIds,
      ...factoryShowcaseImageFileAssetIds,
      ...cases.flatMap((item) => [item.caseCoverFileAssetId, ...item.caseMediaFileAssetIds]),
    ]);
    const boardProfileWithMedia =
      listing.primaryBoardType === 'factory'
        ? {
            ...boardProfile,
            showcaseImageUrlMap: Object.fromEntries(
              factoryShowcaseImageFileAssetIds.flatMap((item) => {
                const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
                return url ? [[item, url] as const] : [];
              }),
            ),
          }
        : boardProfile;

    return {
      basic: {
        name: listing.name || null,
        logoFileAssetId: listing.logoFileAssetId,
        coverFileAssetId: listing.coverFileAssetId,
        logoUrl: this.mediaProjectionService.readDisplayUrl(
          listing.logoFileAssetId,
          displayUrlMap,
        ),
        albumImageFileAssetIds,
        albumImageUrlMap: Object.fromEntries(
          albumImageFileAssetIds.flatMap((item) => {
            const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
            return url ? [[item, url] as const] : [];
          }),
        ),
        shortIntro: listing.shortIntro || null,
        fullIntro: listing.fullIntro,
        provinceCode: location.provinceCode,
        provinceName: location.provinceName,
        cityCode: location.cityCode,
        cityName: location.cityName,
        address: listing.address,
        location,
        foundedAt: listing.foundedAt,
        teamSizeRange: listing.teamSizeRange,
        cooperationModes: listing.cooperationModes ?? [],
        contactVisible: listing.contactVisible,
      } satisfies EnterpriseHubPublishedChangeBasic,
      boardProfile: boardProfileWithMedia,
      primaryContact,
      cases: cases.map((item) => ({
        caseId: item.id,
        boardType: item.boardType,
        title: item.title,
        exhibitionType: item.exhibitionType,
        city: item.city,
        eventTime: item.eventTime,
        summary: item.summary,
        caseCoverFileAssetId: item.caseCoverFileAssetId,
        caseMediaFileAssetIds: item.caseMediaFileAssetIds,
        caseImageUrlMap: Object.fromEntries(
          [item.caseCoverFileAssetId, ...item.caseMediaFileAssetIds].flatMap((fileAssetId) => {
            const url = this.mediaProjectionService.readDisplayUrl(fileAssetId, displayUrlMap);
            return url ? [[fileAssetId, url] as const] : [];
          }),
        ),
        isFeatured: item.isFeatured,
        caseStatus: item.caseStatus,
      })),
    } satisfies EnterpriseHubPublishedChangeSnapshot;
  }

  async hydrateSnapshotMedia(
    listing: EnterpriseListingEntity,
    snapshot: EnterpriseHubPublishedChangeSnapshot,
  ) {
    const albumImageFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
      snapshot.basic.albumImageFileAssetIds,
    );
    const factoryShowcaseImageFileAssetIds =
      listing.primaryBoardType === 'factory'
        ? this.readStringArray(
            (snapshot.boardProfile as Record<string, unknown> | null)
                ?.showcaseImageFileAssetIds,
          )
        : [];
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap([
      snapshot.basic.logoFileAssetId,
      ...albumImageFileAssetIds,
      ...factoryShowcaseImageFileAssetIds,
      ...snapshot.cases.flatMap((item) => [
        item.caseCoverFileAssetId,
        ...item.caseMediaFileAssetIds,
      ]),
    ]);
    const boardProfileWithMedia =
      listing.primaryBoardType === 'factory' && snapshot.boardProfile
        ? {
            ...snapshot.boardProfile,
            showcaseImageUrlMap: Object.fromEntries(
              factoryShowcaseImageFileAssetIds.flatMap((item) => {
                const url = this.mediaProjectionService.readDisplayUrl(
                  item,
                  displayUrlMap,
                );
                return url ? [[item, url] as const] : [];
              }),
            ),
          }
        : snapshot.boardProfile;

    return {
      ...snapshot,
      basic: {
        ...snapshot.basic,
        logoUrl: this.mediaProjectionService.readDisplayUrl(
          snapshot.basic.logoFileAssetId,
          displayUrlMap,
        ),
        albumImageFileAssetIds,
        albumImageUrlMap: Object.fromEntries(
          albumImageFileAssetIds.flatMap((item) => {
            const url = this.mediaProjectionService.readDisplayUrl(
              item,
              displayUrlMap,
            );
            return url ? [[item, url] as const] : [];
          }),
        ),
      },
      boardProfile: boardProfileWithMedia,
      cases: snapshot.cases.map((item) => ({
        ...item,
        caseImageUrlMap: Object.fromEntries(
          [item.caseCoverFileAssetId, ...item.caseMediaFileAssetIds].flatMap((
            fileAssetId,
          ) => {
            const url = this.mediaProjectionService.readDisplayUrl(
              fileAssetId,
              displayUrlMap,
            );
            return url ? [[fileAssetId, url] as const] : [];
          }),
        ),
      })),
    } satisfies EnterpriseHubPublishedChangeSnapshot;
  }

  private async loadBoardProfile(enterpriseId: string, boardType: string) {
    if (boardType === 'company') {
      const company = await this.companyRepository.findOneBy({ enterpriseId });
      return company
        ? {
            exhibitionTypes: company.exhibitionTypes,
            serviceItems: company.serviceItems,
            serviceCities: company.serviceCities,
            teamSize: company.teamSize,
            maxProjectScale: company.maxProjectScale,
            averageDeliveryCycleDays: company.averageDeliveryCycleDays,
            knownClients: company.knownClients,
            qualificationDesc: company.qualificationDesc,
            projectManagementCapability: company.projectManagementCapability,
            onsiteExecutionCapability: company.onsiteExecutionCapability,
          }
        : {
            exhibitionTypes: [],
            serviceItems: [],
            serviceCities: [],
            teamSize: null,
            maxProjectScale: null,
            averageDeliveryCycleDays: null,
            knownClients: [],
            qualificationDesc: null,
            projectManagementCapability: null,
            onsiteExecutionCapability: null,
          };
    }
    if (boardType === 'factory') {
      const factory = await this.factoryRepository.findOneBy({ enterpriseId });
      return factory
        ? {
            factoryName: factory.factoryName,
            processTypes: factory.processTypes,
            coreProducts: factory.coreProducts,
            equipmentList: factory.equipmentList,
            showcaseImageFileAssetIds: factory.showcaseImageFileAssetIds,
            plantAreaSqm: factory.plantAreaSqm,
            monthlyCapacityDesc: factory.monthlyCapacityDesc,
            urgentOrderCapability: factory.urgentOrderCapability,
            urgentCycleDesc: factory.urgentCycleDesc,
            warehouseCapability: factory.warehouseCapability,
            transportCapability: factory.transportCapability,
            maxOrderCapacityDesc: factory.maxOrderCapacityDesc,
            productionQualificationDesc: factory.productionQualificationDesc,
            deliveryRadiusDesc: factory.deliveryRadiusDesc,
          }
        : {
            factoryName: null,
            processTypes: [],
            coreProducts: [],
            equipmentList: [],
            showcaseImageFileAssetIds: [],
            plantAreaSqm: null,
            monthlyCapacityDesc: null,
            urgentOrderCapability: null,
            urgentCycleDesc: null,
            warehouseCapability: null,
            transportCapability: null,
            maxOrderCapacityDesc: null,
            productionQualificationDesc: null,
            deliveryRadiusDesc: null,
          };
    }
    const supplier = await this.supplierRepository.findOneBy({ enterpriseId });
    return supplier
      ? {
          supplyCategories: supplier.supplyCategories,
          supplyMode: supplier.supplyMode,
          coreProductsOrServices: supplier.coreProductsOrServices,
          responseSlaDesc: supplier.responseSlaDesc,
          stockStatusDesc: supplier.stockStatusDesc,
          deliveryRange: supplier.deliveryRange,
          aftersalesPolicy: supplier.aftersalesPolicy,
          partnerCasesDesc: supplier.partnerCasesDesc,
          supplyQualificationDesc: supplier.supplyQualificationDesc,
        }
      : {
          supplyCategories: [],
          supplyMode: [],
          coreProductsOrServices: [],
          responseSlaDesc: null,
          stockStatusDesc: null,
          deliveryRange: null,
          aftersalesPolicy: null,
          partnerCasesDesc: null,
          supplyQualificationDesc: null,
        };
  }

  private async loadPrimaryContact(enterpriseId: string) {
    const primary = await this.contactRepository.findOneBy({
      enterpriseId,
      isPrimary: true,
    });
    const contact = primary ?? (await this.contactRepository.findOneBy({ enterpriseId, visibleToPublic: true }));
    if (!contact) {
      return null;
    }
    return {
      contactName: contact.contactName,
      mobile: contact.mobile,
      wechat: contact.wechat,
      phone: contact.phone,
      email: contact.email,
      position: contact.position,
      isPrimary: contact.isPrimary,
      visibleToPublic: contact.visibleToPublic,
    } satisfies EnterpriseHubPublishedChangePrimaryContact;
  }

  private readStringArray(value: unknown) {
    return Array.isArray(value)
      ? value.filter((item): item is string => typeof item === 'string')
      : [];
  }
}

import { Injectable } from '@nestjs/common';
import { BOARD_LABELS } from './enterprise-hub.constants';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseCertificationSnapshotEntity } from './entities/enterprise-certification-snapshot.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';
import { EnterpriseRecommendationSlotEntity } from './entities/enterprise-recommendation-slot.entity';
import { EnterpriseReviewSummaryEntity } from './entities/enterprise-review-summary.entity';
import { EnterpriseServiceAreaEntity } from './entities/enterprise-service-area.entity';

@Injectable()
export class EnterpriseHubPresenter {
  constructor(private readonly locationService: EnterpriseHubLocationService) {}

  toPagination(page: number, pageSize: number, total: number) {
    return { page, pageSize, total, hasMore: page * pageSize < total };
  }

  toListItem(
    listing: EnterpriseListingEntity,
    reviewSummary: EnterpriseReviewSummaryEntity | null,
    caseCount: number,
    company: EnterpriseProfileCompanyEntity | null,
    factory: EnterpriseProfileFactoryEntity | null,
    supplier: EnterpriseProfileSupplierEntity | null,
    logoUrl: string | null
  ) {
    const location = this.locationService.toReadModel(listing) ?? {
      provinceName: listing.provinceName,
      cityName: listing.cityName,
    };
    const displayName = this.readPublicDisplayName(listing, factory);
    return {
      enterpriseId: listing.id,
      boardType: listing.primaryBoardType,
      name: displayName,
      logoUrl,
      provinceCode: listing.provinceCode,
      provinceName: location.provinceName ?? listing.provinceName,
      cityCode: listing.cityCode,
      cityName: location.cityName ?? listing.cityName,
      primaryBoardLabel: BOARD_LABELS[listing.primaryBoardType] ?? listing.primaryBoardType,
      secondaryCapabilityLabels: (listing.secondaryCapabilities ?? []).map(
        (item) => BOARD_LABELS[item] ?? item
      ),
      shortIntro: listing.shortIntro,
      certificationLabel: this.toCertificationLabel(listing.verificationStatusSnapshot),
      caseCount,
      avgScore: reviewSummary?.avgScore ?? null,
      keywordTags: reviewSummary?.keywordTags ?? [],
      boardHighlights: {
        company: company
          ? {
              exhibitionTypes: company.exhibitionTypes,
              serviceItems: company.serviceItems,
              serviceCities: company.serviceCities
            }
          : null,
        factory: factory
          ? {
              factoryName: factory.factoryName,
              processTypes: factory.processTypes,
              coreProducts: factory.coreProducts,
              deliveryRadiusDesc: factory.deliveryRadiusDesc,
              warehouseCapability: factory.warehouseCapability,
              showcaseImageFileAssetIds: factory.showcaseImageFileAssetIds
            }
          : null,
        supplier: supplier
          ? {
              supplyCategories: supplier.supplyCategories,
              supplyMode: supplier.supplyMode,
              responseSlaDesc: supplier.responseSlaDesc
            }
          : null
      }
    };
  }

  toDetailResponse(input: {
    listing: EnterpriseListingEntity;
    company: EnterpriseProfileCompanyEntity | null;
    factory: EnterpriseProfileFactoryEntity | null;
    supplier: EnterpriseProfileSupplierEntity | null;
    serviceAreas: EnterpriseServiceAreaEntity[];
    cases: EnterpriseCaseEntity[];
    certifications: EnterpriseCertificationSnapshotEntity[];
    reviewSummary: EnterpriseReviewSummaryEntity | null;
    contacts: EnterpriseContactEntity[];
    logoUrl: string | null;
    showcaseImageUrls: string[];
    albumImageUrls: string[];
    caseCoverImageUrls: Map<string, string | null>;
  }) {
    const {
      listing,
      company,
      factory,
      supplier,
      serviceAreas,
      cases,
      certifications,
      reviewSummary,
      contacts,
      logoUrl,
      showcaseImageUrls,
      albumImageUrls,
      caseCoverImageUrls,
    } = input;
    const location = this.locationService.toReadModel(listing);
    const displayName = this.readPublicDisplayName(listing, factory);

    return {
      header: {
        enterpriseId: listing.id,
        name: displayName,
        logoUrl,
        primaryBoardType: listing.primaryBoardType,
        secondaryCapabilities: listing.secondaryCapabilities ?? [],
        shortIntro: listing.shortIntro,
        provinceName: location.provinceName,
        cityName: location.cityName,
        verificationStatus: listing.verificationStatusSnapshot ?? null
      },
      basicInfo: {
        legalName: listing.legalNameSnapshot,
        foundedAt: listing.foundedAt,
        teamSizeRange: listing.teamSizeRange,
        fullIntro: listing.fullIntro,
        address: listing.address
      },
      visualGallery: this.toVisualGallery(albumImageUrls),
      location,
      boardProfile: this.toBoardProfile(
        listing.primaryBoardType,
        company,
        factory,
        supplier,
        showcaseImageUrls,
      ),
      serviceAreas: serviceAreas.map((item) => ({
        areaType: item.areaType,
        provinceName:
          item.areaType === 'registered_location'
            ? location.provinceName
            : item.provinceName,
        cityName:
          item.areaType === 'registered_location' ? location.cityName : item.cityName
      })),
      casesState: cases.length > 0 ? 'available' : 'empty',
      cases: cases.map((item) => ({
        id: item.id,
        title: item.title,
        summary: item.summary,
        coverImageUrl: caseCoverImageUrls.get(item.id) ?? null,
        eventTime: item.eventTime,
        caseStatus: item.caseStatus
      })),
      certifications: certifications.map((item) => ({
        type: item.certificationType,
        name: item.certificationName,
        status: item.certStatus
      })),
      reviewSummary: {
        avgScore: reviewSummary?.avgScore ?? null,
        reviewCount: reviewSummary?.reviewCount ?? null,
        keywordTags: reviewSummary?.keywordTags ?? [],
        deliveryScore: reviewSummary?.deliveryScore ?? null,
        qualityScore: reviewSummary?.qualityScore ?? null,
        communicationScore: reviewSummary?.communicationScore ?? null
      },
      contacts: contacts
        .filter((item) => listing.contactVisible || item.visibleToPublic)
        .map((item) => ({
          contactName: item.contactName,
          mobile: item.mobile,
          wechat: item.wechat,
          phone: item.phone,
          email: item.email,
        position: item.position
        }))
    };
  }

  private readPreferredDisplayName(listing: EnterpriseListingEntity) {
    const legalName = listing.legalNameSnapshot?.trim() ?? '';
    if (legalName.length > 0) {
      return legalName;
    }
    return listing.name;
  }

  private readPublicDisplayName(
    listing: EnterpriseListingEntity,
    factory: EnterpriseProfileFactoryEntity | null,
  ) {
    if (listing.primaryBoardType === 'factory') {
      const factoryName = factory?.factoryName?.trim() ?? '';
      if (factoryName.length > 0) {
        return factoryName;
      }
    }
    return this.readPreferredDisplayName(listing);
  }

  private toVisualGallery(albumImageUrls: string[]) {
    const normalizedAlbum = albumImageUrls
      .map((item) => this.readNormalizedImageUrl(item))
      .filter((item): item is string => item !== null && item.length > 0)
      .filter((item, index, all) => all.indexOf(item) === index)
      .slice(0, 6);
    return {
      albumImageUrls: normalizedAlbum,
      source: normalizedAlbum.length > 0 ? 'enterprise_album' : 'empty',
    };
  }

  private readNormalizedImageUrl(value: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized.length > 0 ? normalized : null;
  }

  toApplicationStatus(application: EnterpriseApplicationEntity) {
    return {
      applicationId: application.id,
      enterpriseId: application.enterpriseId,
      applyBoardType: application.applyBoardType,
      applicationStatus: application.applicationStatus,
      rejectionReason: application.rejectionReason,
      reviewNote: application.reviewNote,
      submittedAt: application.submittedAt?.toISOString() ?? null,
      reviewedAt: application.reviewedAt?.toISOString() ?? null
    };
  }

  toAdminApplicationListItem(
    application: EnterpriseApplicationEntity,
    listing: EnterpriseListingEntity | null
  ) {
    return {
      applicationId: application.id,
      enterpriseId: application.enterpriseId,
      boardType: application.applyBoardType,
      name: listing?.name ?? '',
      provinceName: listing?.provinceName ?? null,
      cityName: listing?.cityName ?? null,
      applicationStatus: application.applicationStatus,
      submittedAt: application.submittedAt?.toISOString() ?? null
    };
  }

  toAdminRecommendationSlotItem(slot: EnterpriseRecommendationSlotEntity) {
    return {
      boardType: slot.boardType,
      slotPosition: slot.slotPosition,
      enterpriseId: slot.enterpriseId,
      startAt: slot.startAt.toISOString(),
      endAt: slot.endAt.toISOString(),
      sourceType: slot.sourceType,
      scoreSnapshot: slot.scoreSnapshot,
      slotStatus: slot.slotStatus
    };
  }

  private toCertificationLabel(value: string | null) {
    if (value === 'verified') {
      return '已认证';
    }
    if (value === 'pending') {
      return '认证审核中';
    }
    if (value === 'failed') {
      return '认证未通过';
    }
    return '未认证';
  }

  private toBoardProfile(
    boardType: string,
    company: EnterpriseProfileCompanyEntity | null,
    factory: EnterpriseProfileFactoryEntity | null,
    supplier: EnterpriseProfileSupplierEntity | null,
    showcaseImageUrls: string[] = [],
  ) {
    if (boardType === 'company') {
      return (
        company ?? {
          exhibitionTypes: [],
          serviceItems: [],
          serviceCities: [],
          teamSize: null,
          maxProjectScale: null,
          averageDeliveryCycleDays: null,
          knownClients: [],
          qualificationDesc: null,
          projectManagementCapability: null,
          onsiteExecutionCapability: null
        }
      );
    }
    if (boardType === 'factory') {
      return (
        factory
          ? {
              ...factory,
              showcaseImageUrls,
            }
          : {
              factoryName: null,
              processTypes: [],
              coreProducts: [],
              equipmentList: [],
              showcaseImageFileAssetIds: [],
              showcaseImageUrls: [],
              plantAreaSqm: null,
              monthlyCapacityDesc: null,
              urgentOrderCapability: null,
              urgentCycleDesc: null,
              warehouseCapability: null,
              transportCapability: null,
              maxOrderCapacityDesc: null,
              productionQualificationDesc: null,
              deliveryRadiusDesc: null
            }
      );
    }
    return (
      supplier ?? {
        supplyCategories: [],
        supplyMode: [],
        coreProductsOrServices: [],
        responseSlaDesc: null,
        stockStatusDesc: null,
        deliveryRange: null,
        aftersalesPolicy: null,
        partnerCasesDesc: null,
        supplyQualificationDesc: null
      }
    );
  }
}

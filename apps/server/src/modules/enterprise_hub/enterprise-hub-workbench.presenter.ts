import { Injectable } from '@nestjs/common';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';

@Injectable()
export class EnterpriseHubWorkbenchPresenter {
  constructor(private readonly locationService: EnterpriseHubLocationService) {}

  toResponse(input: {
    organizationId: string;
    boardType: string | null;
    listing: EnterpriseListingEntity | null;
    latestApplication: EnterpriseApplicationEntity | null;
    company: EnterpriseProfileCompanyEntity | null;
    factory: EnterpriseProfileFactoryEntity | null;
    supplier: EnterpriseProfileSupplierEntity | null;
    cases: EnterpriseCaseEntity[];
    primaryContact: EnterpriseContactEntity | null;
    certification: OrganizationCertificationEntity | null;
    logoUrl: string | null;
    factoryShowcaseImageUrlMap: Record<string, string>;
    caseImageUrlMapByCase: Record<string, Record<string, string>>;
    albumImageUrlMap: Record<string, string>;
    readiness: {
      hasApplication: boolean;
      draftEditable: boolean;
      basicCompleted: boolean;
      profileCompleted: boolean;
      hasCase: boolean;
      hasContact: boolean;
      certificationApproved: boolean;
      submitReady: boolean;
      blockers: string[];
    };
  }) {
    const { listing, latestApplication, company, factory, supplier, cases, primaryContact, certification, readiness } =
      input;
    const location = listing ? this.locationService.toReadModel(listing) : null;
    const displayName = listing
      ? this.readPreferredDisplayName(listing, certification)
      : null;

    return {
      organizationId: input.organizationId,
      enterpriseId: listing?.id ?? null,
      boardType: listing?.primaryBoardType ?? input.boardType ?? null,
      latestApplication: latestApplication
        ? {
            applicationId: latestApplication.id,
            applicationStatus: latestApplication.applicationStatus,
            submittedAt: latestApplication.submittedAt?.toISOString() ?? null,
            reviewedAt: latestApplication.reviewedAt?.toISOString() ?? null,
            rejectionReason: latestApplication.rejectionReason,
            reviewNote: latestApplication.reviewNote
          }
        : null,
      basic: listing
        ? {
            name: displayName,
            logoFileAssetId: listing.logoFileAssetId,
            logoUrl: input.logoUrl,
            albumImageFileAssetIds: normalizeEnterpriseAlbumFileAssetIds(
              listing.albumImageFileAssetIds,
            ),
            albumImageUrlMap: input.albumImageUrlMap,
            shortIntro: listing.shortIntro,
            fullIntro: listing.fullIntro,
            provinceCode: listing.provinceCode,
            provinceName: location?.provinceName ?? listing.provinceName,
            cityCode: listing.cityCode,
            cityName: location?.cityName ?? listing.cityName,
            address: listing.address ?? certification?.address ?? null,
            location,
            foundedAt: listing.foundedAt ?? certification?.establishedAt ?? null,
            teamSizeRange: listing.teamSizeRange,
            cooperationModes: listing.cooperationModes ?? [],
            contactVisible: listing.contactVisible
          }
        : null,
      boardProfile: this.toBoardProfile(
        listing?.primaryBoardType ?? null,
        company,
        factory,
        supplier,
        input.factoryShowcaseImageUrlMap,
      ),
      primaryContact: primaryContact
        ? {
            contactName: primaryContact.contactName,
            mobile: primaryContact.mobile,
            wechat: primaryContact.wechat,
            phone: primaryContact.phone,
            email: primaryContact.email,
            position: primaryContact.position,
            isPrimary: primaryContact.isPrimary,
            visibleToPublic: primaryContact.visibleToPublic
          }
        : null,
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
        caseImageUrlMap: input.caseImageUrlMapByCase[item.id] ?? {},
        isFeatured: item.isFeatured,
        caseStatus: item.caseStatus
      })),
      certification: certification
        ? {
            certificationStatus: certification.certificationStatus,
            legalName: certification.legalName,
            uscc: certification.uscc,
            licenseFileId: certification.licenseFileId,
            address: certification.address,
            establishedAt: certification.establishedAt,
            submittedAt: certification.submittedAt?.toISOString() ?? null,
            reviewedAt: certification.reviewedAt?.toISOString() ?? null,
            rejectReason: certification.rejectReason
          }
        : {
            certificationStatus: 'not_submitted',
            legalName: null,
            uscc: null,
            licenseFileId: null,
            address: null,
            establishedAt: null,
            submittedAt: null,
            reviewedAt: null,
            rejectReason: null
          },
      readiness
    };
  }

  private readPreferredDisplayName(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
  ) {
    const certifiedName = certification?.legalName?.trim() ?? '';
    if (certifiedName.length > 0) {
      return certifiedName;
    }
    const snapshotName = listing.legalNameSnapshot?.trim() ?? '';
    if (snapshotName.length > 0) {
      return snapshotName;
    }
    const listingName = listing.name.trim();
    return listingName.length > 0 ? listingName : null;
  }

  private toBoardProfile(
    boardType: string | null,
    company: EnterpriseProfileCompanyEntity | null,
    factory: EnterpriseProfileFactoryEntity | null,
    supplier: EnterpriseProfileSupplierEntity | null,
    factoryShowcaseImageUrlMap: Record<string, string>,
  ) {
    if (boardType === 'company') {
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
            onsiteExecutionCapability: company.onsiteExecutionCapability
          }
        : null;
    }
    if (boardType === 'factory') {
      return factory
        ? {
            factoryName: factory.factoryName,
            processTypes: factory.processTypes,
            coreProducts: factory.coreProducts,
            equipmentList: factory.equipmentList,
            showcaseImageFileAssetIds: factory.showcaseImageFileAssetIds,
            showcaseImageUrlMap: factoryShowcaseImageUrlMap,
            plantAreaSqm: factory.plantAreaSqm,
            monthlyCapacityDesc: factory.monthlyCapacityDesc,
            urgentOrderCapability: factory.urgentOrderCapability,
            urgentCycleDesc: factory.urgentCycleDesc,
            warehouseCapability: factory.warehouseCapability,
            transportCapability: factory.transportCapability,
            maxOrderCapacityDesc: factory.maxOrderCapacityDesc,
            productionQualificationDesc: factory.productionQualificationDesc,
            deliveryRadiusDesc: factory.deliveryRadiusDesc
          }
        : null;
    }
    if (boardType === 'supplier') {
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
            supplyQualificationDesc: supplier.supplyQualificationDesc
          }
        : null;
    }
    return null;
  }
}

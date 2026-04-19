import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import { EnterpriseHubCertificationSyncService } from './enterprise-hub-certification-sync.service';
import { EnterpriseHubContactWriteService } from './enterprise-hub-contact-write.service';
import { EnterpriseHubListingWriteSupportService } from './enterprise-hub-listing-write-support.service';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';
import { EnterpriseHubAutoReviewService } from './enterprise-hub-auto-review.service';
import { EnterpriseHubAutoSlotService } from './enterprise-hub-auto-slot.service';
import {
  BOARD_LABELS,
  ENTERPRISE_HUB_BOARD_TYPES
} from './enterprise-hub.constants';
import {
  applicationNotFound,
  caseNotFound,
  caseRequired,
  certificationRequired,
  invalidBoardType,
  missingRequiredFields,
  profileNotCompleted
} from './enterprise-hub.errors';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseCertificationSnapshotEntity } from './entities/enterprise-certification-snapshot.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';
import { EnterpriseReviewSummaryEntity } from './entities/enterprise-review-summary.entity';
import { EnterpriseServiceAreaEntity } from './entities/enterprise-service-area.entity';

@Injectable()
export class EnterpriseHubWriteService {
  private readonly autoReviewService = new EnterpriseHubAutoReviewService();

  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
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
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
    @InjectRepository(EnterpriseCertificationSnapshotEntity)
    private readonly certificationRepository: Repository<EnterpriseCertificationSnapshotEntity>,
    @InjectRepository(EnterpriseServiceAreaEntity)
    private readonly serviceAreaRepository: Repository<EnterpriseServiceAreaEntity>,
    @InjectRepository(EnterpriseReviewSummaryEntity)
    private readonly reviewSummaryRepository: Repository<EnterpriseReviewSummaryEntity>,
    private readonly certificationSyncService: EnterpriseHubCertificationSyncService,
    private readonly contactWriteService: EnterpriseHubContactWriteService,
    private readonly listingWriteSupportService: EnterpriseHubListingWriteSupportService,
    private readonly locationService: EnterpriseHubLocationService,
    private readonly autoSlotService: EnterpriseHubAutoSlotService,
    private readonly mediaTruthService: EnterpriseHubMediaTruthService,
  ) {}

  async resolveLocation(
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    return this.locationService.resolve(payload, context);
  }

  async ensureShell(payload: Record<string, unknown>, context: RequestContext) {
    const boardType = this.readBoardType(payload.boardType);
    const ensured = await this.ensureOwnedListingShell(boardType, context);
    return {
      enterpriseId: ensured.listing.id,
      boardType: ensured.listing.primaryBoardType,
      shellStatus: ensured.shellStatus,
    };
  }

  async createApplication(payload: Record<string, unknown>, context: RequestContext) {
    const boardType = this.readBoardType(payload.applyBoardType);
    const applicantName = this.readText(payload.applicantName, 'applicantName');
    const applicantMobile = this.readText(payload.applicantMobile, 'applicantMobile');
    const { listing } = await this.ensureOwnedListingShell(boardType, context);
    await this.contactWriteService.upsertPrimaryContactFromApplication(
      listing.id,
      applicantName,
      applicantMobile,
    );

    const existingDraft = await this.applicationRepository.findOne({
      where: {
        enterpriseId: listing.id,
        applicationStatus: 'draft'
      },
      order: { updatedAt: 'DESC', createdAt: 'DESC' }
    });
    if (existingDraft) {
      if (existingDraft.applicantName !== applicantName) {
        existingDraft.applicantName = applicantName;
      }
      if (existingDraft.applicantMobile !== applicantMobile) {
        existingDraft.applicantMobile = applicantMobile;
      }
      await this.applicationRepository.save(existingDraft);
      return {
        applicationId: existingDraft.id,
        enterpriseId: listing.id,
        applicationStatus: existingDraft.applicationStatus
      };
    }

    const application = this.applicationRepository.create({
      id: randomUUID(),
      enterpriseId: listing.id,
      applyBoardType: boardType,
      applicantName,
      applicantMobile,
      applicationStatus: 'draft'
    });
    await this.applicationRepository.save(application);

    return {
      applicationId: application.id,
      enterpriseId: listing.id,
      applicationStatus: application.applicationStatus
    };
  }

  private async ensureOwnedListingShell(
    boardType: string,
    context: RequestContext,
  ): Promise<{ listing: EnterpriseListingEntity; shellStatus: 'created' | 'existing' }> {
    const organizationId =
      await this.listingWriteSupportService.resolveOrganizationContext(context);
    let listing = await this.listingRepository.findOneBy({
      organizationId,
      primaryBoardType: boardType,
    });
    let shellStatus: 'created' | 'existing' = 'existing';
    if (!listing) {
      shellStatus = 'created';
      listing = this.listingRepository.create({
        id: randomUUID(),
        organizationId,
        primaryBoardType: boardType,
        secondaryCapabilities: [],
        name: '',
        shortIntro: '',
        provinceCode: '',
        provinceName: '',
        cityCode: '',
        cityName: '',
        cooperationModes: [],
        enterpriseStatus: 'unpublished',
        displayStatus: 'hidden',
        contactVisible: false
      });
      await this.listingRepository.save(listing);
    }
    await this.ensureReviewSummaryShell(listing.id);
    await this.certificationSyncService.syncForListing(listing);
    return { listing, shellStatus };
  }

  private async ensureReviewSummaryShell(enterpriseId: string) {
    const existing = await this.reviewSummaryRepository.findOneBy({ enterpriseId });
    if (existing) {
      return existing;
    }
    return this.reviewSummaryRepository.save(
      this.reviewSummaryRepository.create({
        enterpriseId,
        keywordTags: []
      }),
    );
  }

  async updateBasic(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    const patch = payload ?? {};

    if (typeof patch.name === 'string') listing.name = patch.name.trim();
    if (typeof patch.logoFileAssetId === 'string' || patch.logoFileAssetId === null) {
      listing.logoFileAssetId = this.readNullableString(patch.logoFileAssetId);
    }
    if (Array.isArray(patch.albumImageFileAssetIds)) {
      listing.coverFileAssetId = null;
      listing.albumImageFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
        patch.albumImageFileAssetIds,
      );
    }
    if (typeof patch.shortIntro === 'string') listing.shortIntro = patch.shortIntro.trim();
    if (typeof patch.fullIntro === 'string' || patch.fullIntro === null) {
      listing.fullIntro = this.readNullableString(patch.fullIntro)?.slice(0, 2000) ?? null;
    }
    if (typeof patch.provinceCode === 'string') listing.provinceCode = patch.provinceCode.trim();
    if (typeof patch.provinceName === 'string') listing.provinceName = patch.provinceName.trim();
    if (typeof patch.cityCode === 'string') listing.cityCode = patch.cityCode.trim();
    if (typeof patch.cityName === 'string') listing.cityName = patch.cityName.trim();
    if (typeof patch.address === 'string' || patch.address === null) {
      listing.address = this.readNullableString(patch.address);
    }
    if (typeof patch.foundedAt === 'string' || patch.foundedAt === null) {
      listing.foundedAt = this.readNullableString(patch.foundedAt);
    }
    if (typeof patch.teamSizeRange === 'string' || patch.teamSizeRange === null) {
      listing.teamSizeRange = this.readNullableString(patch.teamSizeRange);
    }
    if (Array.isArray(patch.cooperationModes)) {
      listing.cooperationModes = patch.cooperationModes.filter((item): item is string => typeof item === 'string');
    }
    if (typeof patch.contactVisible === 'boolean') {
      listing.contactVisible = patch.contactVisible;
    }

    const normalizedLocation = this.locationService.normalizeWriteLocation(
      patch.location,
      {
        addressText: this.readNullableString(patch.address) ?? listing.address,
        provinceCode:
          this.readNullableString(patch.provinceCode) ?? listing.provinceCode,
        provinceName:
          this.readNullableString(patch.provinceName) ?? listing.provinceName,
        cityCode: this.readNullableString(patch.cityCode) ?? listing.cityCode,
        cityName: this.readNullableString(patch.cityName) ?? listing.cityName,
      },
    );
    this.locationService.applyToListing(listing, normalizedLocation);

    await this.mediaTruthService.validateListingBasicMedia(listing, {
      logoFileAssetId: listing.logoFileAssetId,
      albumImageFileAssetIds: listing.albumImageFileAssetIds,
    });
    await this.listingRepository.save(listing);
    await this.mediaTruthService.syncListingBasicRefs(listing, {
      logoFileAssetId: listing.logoFileAssetId,
      albumImageFileAssetIds: listing.albumImageFileAssetIds,
    });
    await this.contactWriteService.upsertPrimaryContactFromBasic(listing.id, {
      contactName: this.readNullableString(patch.contactName),
      contactMobile: this.readNullableString(patch.contactMobile),
      defaultVisibleToPublic: listing.contactVisible,
    });
    await this.listingWriteSupportService.upsertRegisteredArea(listing);
    return this.ack(context.traceId);
  }

  async updateCompanyProfile(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'company') {
      throw invalidBoardType('当前企业主板块不是优秀公司。');
    }
    const entity = await this.companyRepository.findOneBy({ enterpriseId });
    const profile = this.companyRepository.create({
      ...(entity ?? { enterpriseId }),
      exhibitionTypes: this.readStringArray(payload.exhibitionTypes),
      serviceItems: this.readStringArray(payload.serviceItems),
      serviceCities: this.readStringArray(payload.serviceCities),
      teamSize: this.readNullableNumber(payload.teamSize),
      maxProjectScale: this.readNullableString(payload.maxProjectScale),
      averageDeliveryCycleDays: this.readNullableNumber(payload.averageDeliveryCycleDays),
      knownClients: this.readStringArray(payload.knownClients),
      qualificationDesc: this.readNullableString(payload.qualificationDesc),
      projectManagementCapability: this.readNullableString(payload.projectManagementCapability),
      onsiteExecutionCapability: this.readNullableString(payload.onsiteExecutionCapability)
    });
    await this.companyRepository.save(profile);
    return this.ack(context.traceId);
  }

  async updateFactoryProfile(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'factory') {
      throw invalidBoardType('当前企业主板块不是优秀工厂。');
    }
    const entity = await this.factoryRepository.findOneBy({ enterpriseId });
    const hasField = (field: string) => Object.prototype.hasOwnProperty.call(payload, field);
    const profile = this.factoryRepository.create({
      ...(entity ?? { enterpriseId }),
      factoryName: hasField('factoryName')
        ? this.readNullableString(payload.factoryName)
        : entity?.factoryName ?? null,
      processTypes: hasField('processTypes')
        ? this.readStringArray(payload.processTypes)
        : entity?.processTypes ?? [],
      coreProducts: hasField('coreProducts')
        ? this.readStringArray(payload.coreProducts)
        : entity?.coreProducts ?? [],
      equipmentList: hasField('equipmentList')
        ? this.readStringArray(payload.equipmentList)
        : entity?.equipmentList ?? [],
      showcaseImageFileAssetIds: hasField('showcaseImageFileAssetIds')
        ? this.readStringArray(payload.showcaseImageFileAssetIds).slice(0, 6)
        : entity?.showcaseImageFileAssetIds ?? [],
      plantAreaSqm: hasField('plantAreaSqm')
        ? this.readNullableNumber(payload.plantAreaSqm)
        : entity?.plantAreaSqm ?? null,
      monthlyCapacityDesc: hasField('monthlyCapacityDesc')
        ? this.readNullableString(payload.monthlyCapacityDesc)
        : entity?.monthlyCapacityDesc ?? null,
      urgentOrderCapability: hasField('urgentOrderCapability')
        ? this.readNullableString(payload.urgentOrderCapability)
        : entity?.urgentOrderCapability ?? null,
      urgentCycleDesc: hasField('urgentCycleDesc')
        ? this.readNullableString(payload.urgentCycleDesc)
        : entity?.urgentCycleDesc ?? null,
      warehouseCapability: hasField('warehouseCapability')
        ? this.readNullableBoolean(payload.warehouseCapability)
        : entity?.warehouseCapability ?? null,
      transportCapability: hasField('transportCapability')
        ? this.readNullableString(payload.transportCapability)
        : entity?.transportCapability ?? null,
      maxOrderCapacityDesc: hasField('maxOrderCapacityDesc')
        ? this.readNullableString(payload.maxOrderCapacityDesc)
        : entity?.maxOrderCapacityDesc ?? null,
      productionQualificationDesc: hasField('productionQualificationDesc')
        ? this.readNullableString(payload.productionQualificationDesc)
        : entity?.productionQualificationDesc ?? null,
      deliveryRadiusDesc: hasField('deliveryRadiusDesc')
        ? this.readNullableString(payload.deliveryRadiusDesc)
        : entity?.deliveryRadiusDesc ?? null
    });
    await this.mediaTruthService.validateFactoryShowcaseMedia(
      listing,
      profile.showcaseImageFileAssetIds ?? [],
    );
    await this.factoryRepository.save(profile);
    await this.mediaTruthService.syncFactoryShowcaseRefs(
      listing,
      profile.showcaseImageFileAssetIds ?? [],
    );
    return this.ack(context.traceId);
  }

  async updateSupplierProfile(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'supplier') {
      throw invalidBoardType('当前企业主板块不是优秀供应商。');
    }
    const entity = await this.supplierRepository.findOneBy({ enterpriseId });
    const profile = this.supplierRepository.create({
      ...(entity ?? { enterpriseId }),
      supplyCategories: this.readStringArray(payload.supplyCategories),
      supplyMode: this.readStringArray(payload.supplyMode),
      coreProductsOrServices: this.readStringArray(payload.coreProductsOrServices),
      responseSlaDesc: this.readNullableString(payload.responseSlaDesc),
      stockStatusDesc: this.readNullableString(payload.stockStatusDesc),
      deliveryRange: this.readNullableString(payload.deliveryRange),
      aftersalesPolicy: this.readNullableString(payload.aftersalesPolicy),
      partnerCasesDesc: this.readNullableString(payload.partnerCasesDesc),
      supplyQualificationDesc: this.readNullableString(payload.supplyQualificationDesc)
    });
    await this.supplierRepository.save(profile);
    return this.ack(context.traceId);
  }

  async createCase(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    const boardType = this.readBoardType(payload.boardType);
    const caseMediaFileAssetIds = this.readStringArray(payload.caseMediaFileAssetIds).slice(0, 6);
    const caseCoverFileAssetId =
      this.readNullableString(payload.caseCoverFileAssetId) ?? caseMediaFileAssetIds[0] ?? null;
    if (listing.primaryBoardType !== boardType) {
      throw invalidBoardType('Case boardType must match current enterprise primary board type.');
    }
    if (!caseCoverFileAssetId) {
      throw missingRequiredFields(
        'Field `caseCoverFileAssetId` is required unless caseMediaFileAssetIds provides at least one image.'
      );
    }
    await this.mediaTruthService.validateCaseMedia(listing, {
      caseCoverFileAssetId,
      caseMediaFileAssetIds,
    });
    const entity = this.caseRepository.create({
      id: randomUUID(),
      enterpriseId,
      boardType,
      title: this.readText(payload.title, 'title'),
      exhibitionType: this.readNullableString(payload.exhibitionType),
      city: this.readNullableString(payload.city),
      eventTime: this.readNullableString(payload.eventTime),
      summary: this.readText(payload.summary, 'summary'),
      caseCoverFileAssetId,
      caseMediaFileAssetIds,
      isFeatured: payload.isFeatured === true,
      caseStatus: 'draft'
    });
    await this.caseRepository.save(entity);
    await this.mediaTruthService.syncCaseRefs(listing, 'enterprise_case', entity.id, {
      caseCoverFileAssetId: entity.caseCoverFileAssetId,
      caseMediaFileAssetIds: entity.caseMediaFileAssetIds,
    });
    return {
      caseId: entity.id,
      caseStatus: entity.caseStatus
    };
  }

  async deleteCase(caseId: string, context: RequestContext) {
    const entity = await this.caseRepository.findOneBy({ id: caseId });
    if (!entity) {
      throw caseNotFound();
    }
    const listing = await this.listingWriteSupportService.loadOwnedListing(entity.enterpriseId, context);
    await this.caseRepository.delete({ id: caseId });
    await this.mediaTruthService.clearCaseRefs(listing.id, 'enterprise_case', caseId);
    return this.ack(context.traceId);
  }

  async deleteEnterprise(enterpriseId: string, context: RequestContext) {
    const listing = await this.listingWriteSupportService.loadOwnedListing(enterpriseId, context);
    await this.applicationRepository.delete({ enterpriseId: listing.id });
    await this.caseRepository.delete({ enterpriseId: listing.id });
    await this.contactRepository.delete({ enterpriseId: listing.id });
    await this.serviceAreaRepository.delete({ enterpriseId: listing.id });
    await this.certificationRepository.delete({ enterpriseId: listing.id });
    await this.companyRepository.delete({ enterpriseId: listing.id });
    await this.factoryRepository.delete({ enterpriseId: listing.id });
    await this.supplierRepository.delete({ enterpriseId: listing.id });
    await this.reviewSummaryRepository.delete({ enterpriseId: listing.id });
    await this.mediaTruthService.clearEnterpriseRefs(listing.id);
    await this.listingRepository.delete({ id: listing.id });
    return this.ack(context.traceId);
  }

  async submitApplication(applicationId: string, payload: Record<string, unknown>, context: RequestContext) {
    if (payload.confirm !== true) {
      throw missingRequiredFields('Field `confirm` must be true for enterprise hub application submit.');
    }
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }
    const listing = await this.listingWriteSupportService.loadOwnedListing(application.enterpriseId, context);
    await this.certificationSyncService.syncForListing(listing);

    this.ensureListingMinimum(listing);
    await this.contactWriteService.ensureContactMinimum(listing.id);
    await this.ensureCertificationMinimum(listing);
    await this.ensurePrimaryProfileMinimum(listing);
    await this.ensureCaseMinimum(listing.id);
    const enterpriseCases = await this.caseRepository.findBy({ enterpriseId: listing.id });
    const reviewDecision = this.autoReviewService.evaluate({
      application,
      listing,
      cases: enterpriseCases,
    });
    const reviewNote = this.autoReviewService.readReviewNote(
      {
        application,
        listing,
        cases: enterpriseCases,
      },
      reviewDecision,
    );
    const decidedAt = new Date();

    application.applicationStatus =
      reviewDecision === 'manual_review_required' ? 'submitted' : reviewDecision;
    application.submittedAt = decidedAt;
    application.submittedMaterialSnapshot = {
      boardLabel: BOARD_LABELS[listing.primaryBoardType] ?? listing.primaryBoardType,
      enterpriseStatus: listing.enterpriseStatus
    };
    application.rejectionReason =
      reviewDecision === 'revision_required' ? 'case_incomplete' : null;
    application.reviewedAt =
      reviewDecision === 'manual_review_required' ? null : decidedAt;
    application.reviewerId =
      reviewDecision === 'manual_review_required' ? null : 'system:auto-review';
    application.reviewNote = reviewNote;
    if (reviewDecision === 'approved') {
      listing.enterpriseStatus = 'published';
      listing.displayStatus = 'visible';
      listing.publishedAt = decidedAt;
      await this.promoteCasesToApproved(enterpriseCases);
    }
    await this.applicationRepository.save(application);
    if (reviewDecision === 'approved') {
      await this.listingRepository.save(listing);
      if (listing.primaryBoardType === 'factory') {
        await this.autoSlotService.ensureFactoryRecommendationSlot(listing, decidedAt);
      }
    }
    return this.ack(context.traceId);
  }

  private async promoteCasesToApproved(cases: EnterpriseCaseEntity[]) {
    for (const item of cases) {
      if (item.caseStatus === 'approved') {
        continue;
      }
      item.caseStatus = 'approved';
      await this.caseRepository.save(item);
    }
  }

  private async ensurePrimaryProfileMinimum(listing: EnterpriseListingEntity) {
    if (listing.primaryBoardType === 'company') {
      const company = await this.companyRepository.findOneBy({ enterpriseId: listing.id });
      if (!company || !company.exhibitionTypes.length || !company.serviceItems.length || !company.serviceCities.length) {
        throw profileNotCompleted('Company profile minimum submit boundary is not complete.');
      }
      return;
    }
    if (listing.primaryBoardType === 'factory') {
      const factory = await this.factoryRepository.findOneBy({ enterpriseId: listing.id });
      if (!factory || !factory.processTypes.length || !factory.coreProducts.length) {
        throw profileNotCompleted('Factory profile minimum submit boundary is not complete.');
      }
      return;
    }
    const supplier = await this.supplierRepository.findOneBy({ enterpriseId: listing.id });
    if (!supplier || !supplier.supplyCategories.length || !supplier.supplyMode.length || !supplier.coreProductsOrServices.length) {
      throw profileNotCompleted('Supplier profile minimum submit boundary is not complete.');
    }
  }

  private async ensureCaseMinimum(enterpriseId: string) {
    const count = await this.caseRepository.count({
      where: { enterpriseId }
    });
    if (count === 0) {
      throw caseRequired('At least one enterprise case is required before submit.');
    }
  }

  private async ensureCertificationMinimum(listing: EnterpriseListingEntity) {
    if (listing.verificationStatusSnapshot !== 'verified') {
      throw certificationRequired('Current organization certification is not approved for enterprise hub submit.');
    }
    const count = await this.certificationRepository.countBy({
      enterpriseId: listing.id,
      certStatus: 'approved'
    });
    if (count === 0) {
      throw certificationRequired('At least one approved certification snapshot is required before submit.');
    }
  }

  private ensureListingMinimum(listing: EnterpriseListingEntity) {
    if (
      !listing.name.trim() ||
      !listing.primaryBoardType.trim() ||
      !listing.shortIntro.trim() ||
      !listing.provinceName.trim() ||
      !listing.cityName.trim()
    ) {
      throw missingRequiredFields('Enterprise hub basic listing minimum submit fields are incomplete.');
    }
  }

  private readBoardType(value: unknown) {
    if (typeof value === 'string' && ENTERPRISE_HUB_BOARD_TYPES.includes(value as never)) {
      return value;
    }
    throw invalidBoardType();
  }

  private readText(value: unknown, field: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw missingRequiredFields(`Field \`${field}\` is required for enterprise hub truth write.`);
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

  private ack(traceId: string) {
    return { ok: true, traceId };
  }
}

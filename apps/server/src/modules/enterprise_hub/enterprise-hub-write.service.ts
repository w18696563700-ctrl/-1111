import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import {
  BOARD_LABELS,
  ENTERPRISE_HUB_BOARD_TYPES
} from './enterprise-hub.constants';
import {
  applicationNotFound,
  caseRequired,
  certificationRequired,
  contactRequired,
  enterpriseNotFound,
  invalidBoardType,
  missingRequiredFields,
  permissionDenied,
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
    private readonly reviewSummaryRepository: Repository<EnterpriseReviewSummaryEntity>
  ) {}

  async createApplication(payload: Record<string, unknown>, context: RequestContext) {
    this.requireOrganizationContext(context);
    const boardType = this.readBoardType(payload.applyBoardType);
    const applicantName = this.readText(payload.applicantName, 'applicantName');
    const applicantMobile = this.readText(payload.applicantMobile, 'applicantMobile');

    let listing = await this.listingRepository.findOneBy({ organizationId: context.organizationId });
    if (!listing) {
      listing = this.listingRepository.create({
        id: randomUUID(),
        organizationId: context.organizationId,
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
      await this.reviewSummaryRepository.save(
        this.reviewSummaryRepository.create({
          enterpriseId: listing.id,
          keywordTags: []
        })
      );
    }

    await this.upsertPrimaryContact(listing.id, applicantName, applicantMobile);

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

  async updateBasic(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.loadOwnedListing(enterpriseId, context);
    const patch = payload ?? {};

    if (typeof patch.name === 'string') listing.name = patch.name.trim();
    if (typeof patch.logoFileAssetId === 'string' || patch.logoFileAssetId === null) {
      listing.logoFileAssetId = this.readNullableString(patch.logoFileAssetId);
    }
    if (typeof patch.coverFileAssetId === 'string' || patch.coverFileAssetId === null) {
      listing.coverFileAssetId = this.readNullableString(patch.coverFileAssetId);
    }
    if (typeof patch.shortIntro === 'string') listing.shortIntro = patch.shortIntro.trim();
    if (typeof patch.fullIntro === 'string' || patch.fullIntro === null) {
      listing.fullIntro = this.readNullableString(patch.fullIntro);
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

    await this.listingRepository.save(listing);
    await this.upsertRegisteredArea(listing);
    return this.ack(context.traceId);
  }

  async updateCompanyProfile(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'company') {
      throw invalidBoardType('Current enterprise primary board type is not company.');
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
    const listing = await this.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'factory') {
      throw invalidBoardType('Current enterprise primary board type is not factory.');
    }
    const entity = await this.factoryRepository.findOneBy({ enterpriseId });
    const profile = this.factoryRepository.create({
      ...(entity ?? { enterpriseId }),
      processTypes: this.readStringArray(payload.processTypes),
      coreProducts: this.readStringArray(payload.coreProducts),
      equipmentList: this.readStringArray(payload.equipmentList),
      plantAreaSqm: this.readNullableNumber(payload.plantAreaSqm),
      monthlyCapacityDesc: this.readNullableString(payload.monthlyCapacityDesc),
      urgentOrderCapability: this.readNullableString(payload.urgentOrderCapability),
      urgentCycleDesc: this.readNullableString(payload.urgentCycleDesc),
      warehouseCapability: this.readNullableBoolean(payload.warehouseCapability),
      transportCapability: this.readNullableString(payload.transportCapability),
      maxOrderCapacityDesc: this.readNullableString(payload.maxOrderCapacityDesc),
      productionQualificationDesc: this.readNullableString(payload.productionQualificationDesc),
      deliveryRadiusDesc: this.readNullableString(payload.deliveryRadiusDesc)
    });
    await this.factoryRepository.save(profile);
    return this.ack(context.traceId);
  }

  async updateSupplierProfile(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.loadOwnedListing(enterpriseId, context);
    if (listing.primaryBoardType !== 'supplier') {
      throw invalidBoardType('Current enterprise primary board type is not supplier.');
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
    const listing = await this.loadOwnedListing(enterpriseId, context);
    const boardType = this.readBoardType(payload.boardType);
    if (listing.primaryBoardType !== boardType) {
      throw invalidBoardType('Case boardType must match current enterprise primary board type.');
    }
    const entity = this.caseRepository.create({
      id: randomUUID(),
      enterpriseId,
      boardType,
      title: this.readText(payload.title, 'title'),
      exhibitionType: this.readNullableString(payload.exhibitionType),
      city: this.readNullableString(payload.city),
      eventTime: this.readNullableString(payload.eventTime),
      summary: this.readText(payload.summary, 'summary'),
      caseCoverFileAssetId: this.readText(payload.caseCoverFileAssetId, 'caseCoverFileAssetId'),
      caseMediaFileAssetIds: this.readStringArray(payload.caseMediaFileAssetIds),
      isFeatured: payload.isFeatured === true,
      caseStatus: 'draft'
    });
    await this.caseRepository.save(entity);
    return {
      caseId: entity.id,
      caseStatus: entity.caseStatus
    };
  }

  async submitApplication(applicationId: string, payload: Record<string, unknown>, context: RequestContext) {
    this.requireOrganizationContext(context);
    if (payload.confirm !== true) {
      throw missingRequiredFields('Field `confirm` must be true for enterprise hub application submit.');
    }
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }
    const listing = await this.loadOwnedListing(application.enterpriseId, context);

    this.ensureListingMinimum(listing);
    await this.ensureContactMinimum(listing.id);
    await this.ensureCertificationMinimum(listing.id);
    await this.ensureCaseMinimum(listing.id);
    await this.ensurePrimaryProfileMinimum(listing);

    application.applicationStatus = 'submitted';
    application.submittedAt = new Date();
    application.submittedMaterialSnapshot = {
      boardLabel: BOARD_LABELS[listing.primaryBoardType] ?? listing.primaryBoardType,
      enterpriseStatus: listing.enterpriseStatus
    };
    await this.applicationRepository.save(application);
    return this.ack(context.traceId);
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

  private async ensureContactMinimum(enterpriseId: string) {
    const count = await this.contactRepository.count({
      where: [
        { enterpriseId, isPrimary: true },
        { enterpriseId, visibleToPublic: true }
      ]
    });
    if (count === 0) {
      throw contactRequired('At least one primary or public contact is required before submit.');
    }
  }

  private async ensureCertificationMinimum(enterpriseId: string) {
    const count = await this.certificationRepository.countBy({ enterpriseId });
    if (count === 0) {
      throw certificationRequired('At least one certification snapshot is required before submit.');
    }
  }

  private async ensureCaseMinimum(enterpriseId: string) {
    const count = await this.caseRepository.countBy({ enterpriseId });
    if (count === 0) {
      throw caseRequired('At least one enterprise case is required before submit.');
    }
  }

  private ensureListingMinimum(listing: EnterpriseListingEntity) {
    if (
      !listing.name.trim() ||
      !listing.primaryBoardType.trim() ||
      !listing.shortIntro.trim() ||
      !listing.provinceCode.trim() ||
      !listing.provinceName.trim() ||
      !listing.cityCode.trim() ||
      !listing.cityName.trim()
    ) {
      throw missingRequiredFields('Enterprise hub basic listing minimum submit fields are incomplete.');
    }
  }

  private async loadOwnedListing(enterpriseId: string, context: RequestContext) {
    this.requireOrganizationContext(context);
    const listing = await this.listingRepository.findOneBy({ id: enterpriseId });
    if (!listing) {
      throw enterpriseNotFound();
    }
    if (listing.organizationId !== context.organizationId) {
      throw permissionDenied('Current actor organization scope cannot mutate this enterprise listing.');
    }
    return listing;
  }

  private requireOrganizationContext(context: RequestContext) {
    if (context.actorId && context.organizationId) {
      return;
    }
    throw permissionDenied('Current actor must carry organization context for enterprise hub write truth.');
  }

  private async upsertPrimaryContact(enterpriseId: string, applicantName: string, applicantMobile: string) {
    const existing = await this.contactRepository.findOne({
      where: { enterpriseId, isPrimary: true },
      order: { id: 'ASC' }
    });
    const contact = this.contactRepository.create({
      ...(existing ?? { id: randomUUID(), enterpriseId }),
      contactName: applicantName,
      mobile: applicantMobile,
      isPrimary: true,
      visibleToPublic: true
    });
    await this.contactRepository.save(contact);
  }

  private async upsertRegisteredArea(listing: EnterpriseListingEntity) {
    const existing = await this.serviceAreaRepository.findOneBy({
      enterpriseId: listing.id,
      areaType: 'registered_location'
    });
    const entity = this.serviceAreaRepository.create({
      ...(existing ?? { id: randomUUID(), enterpriseId: listing.id, areaType: 'registered_location' }),
      provinceCode: listing.provinceCode,
      provinceName: listing.provinceName,
      cityCode: listing.cityCode,
      cityName: listing.cityName
    });
    await this.serviceAreaRepository.save(entity);
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

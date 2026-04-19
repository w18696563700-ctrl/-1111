import { Inject, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { permissionDenied } from './enterprise-hub.errors';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import { resolveEnterpriseHubRegionDisplayTruth } from './enterprise-hub-region-lookup';
import { EnterpriseHubWorkbenchPresenter } from './enterprise-hub-workbench.presenter';
import { EnterpriseHubMediaProjectionService } from './enterprise-hub-media-projection.service';
import { EnterpriseHubAutoReviewService } from './enterprise-hub-auto-review.service';
import { EnterpriseHubAutoSlotService } from './enterprise-hub-auto-slot.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseContactEntity } from './entities/enterprise-contact.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseProfileCompanyEntity } from './entities/enterprise-profile-company.entity';
import { EnterpriseProfileFactoryEntity } from './entities/enterprise-profile-factory.entity';
import { EnterpriseProfileSupplierEntity } from './entities/enterprise-profile-supplier.entity';

type EnterpriseHubMediaProjectionPort = Pick<
  EnterpriseHubMediaProjectionService,
  'buildDisplayUrlMap' | 'readDisplayUrl'
>;

type EnterpriseHubAutoSlotPort = Pick<
  EnterpriseHubAutoSlotService,
  'ensureFactoryRecommendationSlot'
>;

const defaultMediaProjectionPort: EnterpriseHubMediaProjectionPort = {
  async buildDisplayUrlMap() {
    return new Map<string, string>();
  },
  readDisplayUrl(fileAssetId, urlMap) {
    if (!fileAssetId) {
      return null;
    }
    return urlMap.get(fileAssetId) ?? null;
  },
};

const defaultAutoSlotPort: EnterpriseHubAutoSlotPort = {
  async ensureFactoryRecommendationSlot() {
    return false;
  },
};

@Injectable()
export class EnterpriseHubWorkbenchQueryService {
  private readonly autoReviewService = new EnterpriseHubAutoReviewService();

  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
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
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: EnterpriseHubWorkbenchPresenter,
    @Inject(EnterpriseHubMediaProjectionService)
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionPort = defaultMediaProjectionPort,
    @Inject(EnterpriseHubAutoSlotService)
    private readonly autoSlotService: EnterpriseHubAutoSlotPort = defaultAutoSlotPort,
  ) {}

  async getWorkbench(context: RequestContext, boardType: string) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = this.requireOrganizationScope(scope?.organization.id ?? null);
    const resolvedBoardType = this.readBoardType(boardType);
    const listing = await this.listingRepository.findOneBy({
      organizationId,
      primaryBoardType: resolvedBoardType,
    });
    const certification =
      await this.organizationCertificationRepository.findOne({
        where: { organizationId },
        order: { updatedAt: "DESC", createdAt: "DESC" },
      });

    if (!listing) {
      return this.presenter.toResponse({
        organizationId,
        boardType: resolvedBoardType,
        listing: null,
        latestApplication: null,
        company: null,
        factory: null,
        supplier: null,
        cases: [],
        primaryContact: null,
        certification,
        logoUrl: null,
        factoryShowcaseImageUrlMap: {},
        caseImageUrlMapByCase: {},
        albumImageUrlMap: {},
        readiness: {
          hasApplication: false,
          draftEditable: false,
          basicCompleted: false,
          profileCompleted: false,
          hasCase: false,
          hasContact: false,
          certificationApproved:
            certification?.certificationStatus === 'approved',
          submitReady: false,
          blockers: ['当前还没有展示档，请先保存资料或上传图片创建展示档。'],
        },
      });
    }

    const [
      latestApplication,
      company,
      factory,
      supplier,
      cases,
      primaryContact,
    ] = await Promise.all([
      this.applicationRepository.findOne({
        where: { enterpriseId: listing.id },
        order: { createdAt: "DESC", updatedAt: "DESC" },
      }),
      this.companyRepository.findOneBy({ enterpriseId: listing.id }),
      this.factoryRepository.findOneBy({ enterpriseId: listing.id }),
      this.supplierRepository.findOneBy({ enterpriseId: listing.id }),
      this.caseRepository.find({
        where: {
          enterpriseId: listing.id,
          boardType: listing.primaryBoardType,
        },
        order: { createdAt: "DESC", updatedAt: "DESC" },
      }),
      this.loadPrimaryContact(listing.id),
    ]);
    await this.repairPublishedListingCasesFromApprovedHistory(listing, cases);
    await this.maybeFinalizeApplication(latestApplication, listing, cases);
    const normalizedAlbumIds = normalizeEnterpriseAlbumFileAssetIds(
      listing.albumImageFileAssetIds,
    );
    const factoryShowcaseImageFileAssetIds =
      listing.primaryBoardType === 'factory' && factory
        ? factory.showcaseImageFileAssetIds
        : [];
    const caseImageFileAssetIds = cases.flatMap((item) => [
      item.caseCoverFileAssetId,
      ...(Array.isArray(item.caseMediaFileAssetIds)
        ? item.caseMediaFileAssetIds
        : []),
    ]);
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap([
      listing.logoFileAssetId,
      ...normalizedAlbumIds,
      ...factoryShowcaseImageFileAssetIds,
      ...caseImageFileAssetIds,
    ]);

    const readiness = this.buildReadiness({
      listing,
      latestApplication,
      company,
      factory,
      supplier,
      cases,
      primaryContact,
      certification,
    });

    return this.presenter.toResponse({
      organizationId,
      boardType: resolvedBoardType,
      listing,
      latestApplication,
      company,
      factory,
      supplier,
      cases,
      primaryContact,
      certification,
      logoUrl: this.mediaProjectionService.readDisplayUrl(
        listing.logoFileAssetId,
        displayUrlMap,
      ),
      factoryShowcaseImageUrlMap: Object.fromEntries(
        factoryShowcaseImageFileAssetIds.flatMap((item) => {
          const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
          return url ? [[item, url] as const] : [];
        }),
      ),
      caseImageUrlMapByCase: Object.fromEntries(
        cases.map((item) => {
          const imageUrlMap = Object.fromEntries(
            [
              item.caseCoverFileAssetId,
              ...(Array.isArray(item.caseMediaFileAssetIds)
                ? item.caseMediaFileAssetIds
                : []),
            ].flatMap((fileAssetId) => {
              const url = this.mediaProjectionService.readDisplayUrl(
                fileAssetId,
                displayUrlMap,
              );
              return url ? [[fileAssetId, url] as const] : [];
            }),
          );
          return [item.id, imageUrlMap] as const;
        }),
      ),
      albumImageUrlMap: Object.fromEntries(
        normalizedAlbumIds.flatMap((item) => {
          const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
          return url ? [[item, url] as const] : [];
        }),
      ),
      readiness,
    });
  }

  private async loadPrimaryContact(enterpriseId: string) {
    const primary = await this.contactRepository.findOneBy({
      enterpriseId,
      isPrimary: true,
    });
    if (primary) {
      return primary;
    }
    return this.contactRepository.findOneBy({
      enterpriseId,
      visibleToPublic: true,
    });
  }

  private buildReadiness(input: {
    listing: EnterpriseListingEntity;
    latestApplication: EnterpriseApplicationEntity | null;
    company: EnterpriseProfileCompanyEntity | null;
    factory: EnterpriseProfileFactoryEntity | null;
    supplier: EnterpriseProfileSupplierEntity | null;
    cases: EnterpriseCaseEntity[];
    primaryContact: EnterpriseContactEntity | null;
    certification: OrganizationCertificationEntity | null;
  }) {
    const draftEditable =
      input.latestApplication?.applicationStatus === 'draft';
    const displayRegion = resolveEnterpriseHubRegionDisplayTruth({
      provinceCode: input.listing.provinceCode,
      provinceName: input.listing.provinceName,
      cityCode: input.listing.cityCode,
      cityName: input.listing.cityName,
    });
    const basicCompleted =
      !!input.listing.name.trim() &&
      !!input.listing.shortIntro.trim() &&
      !!displayRegion.provinceName?.trim() &&
      !!displayRegion.cityName?.trim();
    const profileCompleted = this.isProfileCompleted(
      input.listing.primaryBoardType,
      input.company,
      input.factory,
      input.supplier,
    );
    const hasCase = input.cases.length > 0;
    const hasContact = input.primaryContact != null;
    const certificationApproved =
      input.certification?.certificationStatus === "approved";
    const blockers: string[] = [];

    if (!input.latestApplication) {
      blockers.push(
        '当前还没有申请草稿；保存资料和上传图片不受影响，真正提交前仍需补齐联系人并进入申请流。',
      );
    } else if (!draftEditable) {
      blockers.push('当前最近一次申请不可直接编辑，请新建一条可编辑申请后再提交。');
    }
    if (!basicCompleted) {
      blockers.push('基础资料未完成，请补齐企业名称、一句话简介和组织所在城市。');
    }
    if (!profileCompleted) {
      blockers.push('板块画像未完成，请补齐当前主板块的必填资料。');
    }
    if (!hasCase) {
      blockers.push('当前至少需要 1 个已保存案例，请先保存案例到当前展示档。');
    }
    if (!hasContact) {
      blockers.push('当前缺少主联系人，请先填写联系人。');
    }
    if (!certificationApproved) {
      blockers.push('当前企业认证未通过，请先回到我的公司完成企业认证。');
    }

    return {
      hasApplication: input.latestApplication != null,
      draftEditable,
      basicCompleted,
      profileCompleted,
      hasCase,
      hasContact,
      certificationApproved,
      submitReady:
        draftEditable &&
        basicCompleted &&
        profileCompleted &&
        hasCase &&
        hasContact &&
        certificationApproved,
      blockers,
    };
  }

  private async maybeFinalizeApplication(
    application: EnterpriseApplicationEntity | null,
    listing: EnterpriseListingEntity,
    cases: EnterpriseCaseEntity[],
  ) {
    if (!application) {
      return;
    }
    if (application.applyBoardType !== listing.primaryBoardType) {
      return;
    }
    if (application.applicationStatus === 'approved') {
      await this.promoteCasesToApproved(
        listing.id,
        listing.primaryBoardType,
        cases,
      );
      if (
        listing.enterpriseStatus !== 'published' ||
        listing.displayStatus !== 'visible'
      ) {
        listing.enterpriseStatus = 'published';
        listing.displayStatus = 'visible';
        listing.publishedAt = listing.publishedAt ?? application.reviewedAt ?? new Date();
        await this.listingRepository.save(listing);
      }
      if (listing.primaryBoardType === 'factory') {
        await this.autoSlotService.ensureFactoryRecommendationSlot(
          listing,
          application.reviewedAt ?? new Date(),
        );
      }
      return;
    }
    if (application.applicationStatus !== 'submitted') {
      return;
    }
    const reviewDecision = this.autoReviewService.evaluate({
      application,
      listing,
      cases,
    });
    const reviewNote = this.autoReviewService.readReviewNote(
      {
        application,
        listing,
        cases,
      },
      reviewDecision,
    );
    if (reviewDecision === 'manual_review_required') {
      if (application.reviewNote !== reviewNote) {
        application.reviewNote = reviewNote;
        await this.applicationRepository.save(application);
      }
      return;
    }
    const decidedAt = new Date();
    application.applicationStatus = reviewDecision;
    application.rejectionReason =
      reviewDecision === 'revision_required' ? 'case_incomplete' : null;
    application.reviewedAt = decidedAt;
    application.reviewerId = 'system:auto-review';
    application.reviewNote = reviewNote;
    await this.applicationRepository.save(application);
    if (reviewDecision === 'approved') {
      await this.promoteCasesToApproved(
        listing.id,
        listing.primaryBoardType,
        cases,
      );
      listing.enterpriseStatus = 'published';
      listing.displayStatus = 'visible';
      listing.publishedAt = decidedAt;
      await this.listingRepository.save(listing);
      if (listing.primaryBoardType === 'factory') {
        await this.autoSlotService.ensureFactoryRecommendationSlot(
          listing,
          decidedAt,
        );
      }
    }
  }

  private async repairPublishedListingCasesFromApprovedHistory(
    listing: EnterpriseListingEntity,
    cases: EnterpriseCaseEntity[],
  ) {
    if (
      listing.enterpriseStatus !== 'published' ||
      listing.displayStatus !== 'visible'
    ) {
      return;
    }
    const approvedApplication = await this.applicationRepository.findOne({
      where: {
        enterpriseId: listing.id,
        applicationStatus: 'approved',
      },
      order: { reviewedAt: 'DESC', updatedAt: 'DESC' },
    });
    if (!approvedApplication) {
      return;
    }
    if (approvedApplication.applyBoardType !== listing.primaryBoardType) {
      return;
    }
    await this.promoteCasesToApproved(
      listing.id,
      listing.primaryBoardType,
      cases,
    );
  }

  private async promoteCasesToApproved(
    enterpriseId: string,
    boardType: string,
    cases?: EnterpriseCaseEntity[],
  ) {
    const targetCases =
      cases ?? (await this.caseRepository.findBy({ enterpriseId, boardType }));
    for (const item of targetCases) {
      if (item.caseStatus === 'approved') {
        continue;
      }
      item.caseStatus = 'approved';
      await this.caseRepository.save(item);
    }
  }

  private isProfileCompleted(
    boardType: string,
    company: EnterpriseProfileCompanyEntity | null,
    factory: EnterpriseProfileFactoryEntity | null,
    supplier: EnterpriseProfileSupplierEntity | null,
  ) {
    if (boardType === 'company') {
      return (
        !!company?.exhibitionTypes.length &&
        !!company.serviceItems.length &&
        !!company.serviceCities.length
      );
    }
    if (boardType === 'factory') {
      return (
        !!factory?.factoryName?.trim() &&
        !!factory.processTypes.length &&
        !!factory.coreProducts.length
      );
    }
    if (boardType === 'supplier') {
      return (
        !!supplier?.supplyCategories.length &&
        !!supplier.supplyMode.length &&
        !!supplier.coreProductsOrServices.length
      );
    }
    return false;
  }

  private requireOrganizationScope(organizationId: string | null) {
    if (organizationId) {
      return organizationId;
    }
    throw permissionDenied(
      'Current actor must carry organization scope for enterprise display workbench.'
    );
  }

  private readBoardType(value: unknown) {
    if (value === 'company' || value === 'factory' || value === 'supplier') {
      return value;
    }
    throw permissionDenied('Current enterprise display workbench request is missing board type.');
  }
}

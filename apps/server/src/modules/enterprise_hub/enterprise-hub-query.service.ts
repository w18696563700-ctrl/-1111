import { Inject, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ENTERPRISE_HUB_BOARD_TYPES } from './enterprise-hub.constants';
import {
  applicationNotFound,
  caseNotFound,
  enterpriseNotFound,
  invalidBoardType,
  permissionDenied
} from './enterprise-hub.errors';
import { normalizeEnterpriseAlbumFileAssetIds } from './enterprise-hub-album-truth';
import { EnterpriseHubMediaProjectionService } from './enterprise-hub-media-projection.service';
import { EnterpriseHubAutoReviewService } from './enterprise-hub-auto-review.service';
import { EnterpriseHubAutoSlotService } from './enterprise-hub-auto-slot.service';
import { EnterpriseHubPresenter } from './enterprise-hub.presenter';
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
import { EnterpriseHubPublicReadRepairService } from './enterprise-hub-public-read-repair.service';

type EnterpriseHubPublicReadRepairPort = Pick<
  EnterpriseHubPublicReadRepairService,
  'repairListingFromCertificationIfNeeded' | 'repairListingsFromCertificationIfNeeded'
>;

@Injectable()
export class EnterpriseHubQueryService {
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
    @InjectRepository(EnterpriseCertificationSnapshotEntity)
    private readonly certificationRepository: Repository<EnterpriseCertificationSnapshotEntity>,
    @InjectRepository(EnterpriseContactEntity)
    private readonly contactRepository: Repository<EnterpriseContactEntity>,
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
    @InjectRepository(EnterpriseReviewSummaryEntity)
    private readonly reviewSummaryRepository: Repository<EnterpriseReviewSummaryEntity>,
    @InjectRepository(EnterpriseRecommendationSlotEntity)
    private readonly recommendationSlotRepository: Repository<EnterpriseRecommendationSlotEntity>,
    @InjectRepository(EnterpriseServiceAreaEntity)
    private readonly serviceAreaRepository: Repository<EnterpriseServiceAreaEntity>,
    private readonly presenter: EnterpriseHubPresenter,
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionService,
    private readonly autoSlotService: EnterpriseHubAutoSlotService,
    @Inject(EnterpriseHubPublicReadRepairService)
    private readonly publicReadRepairService: EnterpriseHubPublicReadRepairPort = {
      async repairListingFromCertificationIfNeeded() {},
      async repairListingsFromCertificationIfNeeded() {},
    },
  ) {}

  async getEnterprises(query: Record<string, unknown>) {
    const boardType = this.readBoardType(query.boardType);
    const page = this.readPositiveInt(query.page, 1);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 50);

    const qb = this.createPublicListingQuery(boardType);

    if (typeof query.keyword === 'string' && query.keyword.trim().length > 0) {
      qb.andWhere('(listing.name ILIKE :keyword OR listing.shortIntro ILIKE :keyword)', {
        keyword: `%${query.keyword.trim()}%`
      });
    }
    if (typeof query.provinceCode === 'string' && query.provinceCode.trim().length > 0) {
      qb.andWhere('listing.provinceCode = :provinceCode', { provinceCode: query.provinceCode.trim() });
    }
    if (typeof query.cityCode === 'string' && query.cityCode.trim().length > 0) {
      qb.andWhere('listing.cityCode = :cityCode', { cityCode: query.cityCode.trim() });
    }
    if (boardType === 'factory') {
      const plantAreaRange = this.readPlantAreaRange(query.plantAreaRange);
      if (plantAreaRange) {
        qb.leftJoin(EnterpriseProfileFactoryEntity, 'factory', 'factory.enterpriseId = listing.id');
        if (plantAreaRange.min != null) {
          qb.andWhere('factory.plantAreaSqm >= :plantAreaMin', {
            plantAreaMin: plantAreaRange.min
          });
        }
        if (plantAreaRange.max != null) {
          qb.andWhere('factory.plantAreaSqm < :plantAreaMax', {
            plantAreaMax: plantAreaRange.max
          });
        }
      }
    }
    const total = await qb.getCount();
    const listings = await qb
      .orderBy('listing.publishedAt', 'DESC')
      .addOrderBy('listing.updatedAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize)
      .getMany();
    await this.publicReadRepairService.repairListingsFromCertificationIfNeeded(listings);

    const itemModels = await this.toListItems(listings);
    const recommended = await this.getRecommendations({ boardType });
    return {
      recommended: recommended.items,
      items: itemModels,
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async getEnterpriseDetail(enterpriseId: string, boardType: string) {
    const resolvedBoardType = this.readBoardType(boardType);
    const listing = await this.loadPublicListing(enterpriseId, resolvedBoardType);
    if (!listing) {
      throw enterpriseNotFound();
    }
    await this.settlePublicListingReadState(listing);

    const [company, factory, supplier, serviceAreas, cases, certifications, reviewSummary, contacts] =
      await Promise.all([
        this.companyRepository.findOneBy({ enterpriseId }),
        this.factoryRepository.findOneBy({ enterpriseId }),
        this.supplierRepository.findOneBy({ enterpriseId }),
        this.serviceAreaRepository.findBy({ enterpriseId }),
        this.caseRepository.findBy({
          enterpriseId,
          boardType: listing.primaryBoardType,
          caseStatus: 'approved',
        }),
        this.certificationRepository.findBy({ enterpriseId }),
        this.reviewSummaryRepository.findOneBy({ enterpriseId }),
        this.contactRepository.findBy({ enterpriseId })
      ]);
    const albumFileAssetIds = normalizeEnterpriseAlbumFileAssetIds(
      listing.albumImageFileAssetIds,
    );
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap([
      listing.logoFileAssetId,
      ...albumFileAssetIds,
      ...(factory?.showcaseImageFileAssetIds ?? []),
      ...cases.map((item) => item.caseCoverFileAssetId),
    ]);

    return this.presenter.toDetailResponse({
      listing,
      company,
      factory,
      supplier,
      serviceAreas,
      cases,
      certifications,
      reviewSummary,
      contacts,
      logoUrl: this.mediaProjectionService.readDisplayUrl(
        listing.logoFileAssetId,
        displayUrlMap,
      ),
      showcaseImageUrls: (factory?.showcaseImageFileAssetIds ?? [])
        .map((item) => this.mediaProjectionService.readDisplayUrl(item, displayUrlMap))
        .filter((item): item is string => typeof item === 'string' && item.trim().length > 0),
      albumImageUrls: albumFileAssetIds
        .map((item) => this.mediaProjectionService.readDisplayUrl(item, displayUrlMap))
        .filter((item): item is string => typeof item === 'string' && item.trim().length > 0),
      caseCoverImageUrls: new Map(
        cases.map((item) => [
          item.id,
          this.mediaProjectionService.readDisplayUrl(
            item.caseCoverFileAssetId,
            displayUrlMap,
          ),
        ]),
      ),
    });
  }

  async getPublicCaseDetail(caseId: string) {
    const candidate = await this.caseRepository.findOneBy({ id: caseId });
    if (!candidate) {
      throw caseNotFound();
    }
    const listing = await this.listingRepository.findOneBy({
      id: candidate.enterpriseId,
      primaryBoardType: candidate.boardType,
    });
    if (!listing) {
      throw caseNotFound();
    }
    await this.settlePublicListingReadState(listing);
    const [entity, settledListing] = await Promise.all([
      this.caseRepository.findOneBy({
        id: caseId,
        enterpriseId: candidate.enterpriseId,
        boardType: candidate.boardType,
        caseStatus: 'approved',
      }),
      this.listingRepository.findOneBy({
        id: candidate.enterpriseId,
        primaryBoardType: candidate.boardType,
      }),
    ]);
    if (
      !entity ||
      !settledListing ||
      settledListing.enterpriseStatus !== 'published' ||
      settledListing.displayStatus !== 'visible'
    ) {
      throw caseNotFound();
    }
    const imageFileAssetIds = [
      entity.caseCoverFileAssetId,
      ...(entity.caseMediaFileAssetIds ?? []),
    ];
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap(
      imageFileAssetIds,
    );

    return {
      caseId: entity.id,
      enterpriseId: entity.enterpriseId,
      boardType: entity.boardType,
      title: entity.title,
      exhibitionType: entity.exhibitionType,
      city: entity.city,
      eventTime: entity.eventTime,
      summary: entity.summary,
      caseCoverFileAssetId: entity.caseCoverFileAssetId ?? null,
      caseMediaFileAssetIds: entity.caseMediaFileAssetIds ?? [],
      caseImageUrlMap: Object.fromEntries(
        imageFileAssetIds.flatMap((item) => {
          const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
          return url ? [[item, url] as const] : [];
        }),
      ),
      isFeatured: entity.isFeatured,
      caseStatus: entity.caseStatus,
    };
  }

  private async settlePublicListingReadState(listing: EnterpriseListingEntity) {
    await this.publicReadRepairService.repairListingFromCertificationIfNeeded(listing);
    await this.repairPublishedListingCasesFromApprovedHistory([listing]);
    const latestApplication = await this.applicationRepository.findOne({
      where: { enterpriseId: listing.id },
      order: { createdAt: 'DESC', updatedAt: 'DESC' },
    });
    if (latestApplication) {
      await this.maybeFinalizeApplication(latestApplication, listing);
    }
  }

  async getRecommendations(query: Record<string, unknown>) {
    const boardType = this.readBoardType(query.boardType);
    const now = new Date();
    const slots = await this.recommendationSlotRepository.find({
      where: { boardType, slotStatus: In(['pending', 'active']) },
      order: { slotPosition: 'ASC', createdAt: 'DESC' }
    });
    const activeSlots = slots.filter((slot) => slot.startAt <= now && slot.endAt >= now);
    const slotOrder = new Map(
      activeSlots.map((slot, index) => [slot.enterpriseId, index]),
    );
    const listings = await this.loadPublicListings(
      boardType,
      activeSlots.map((slot) => slot.enterpriseId),
    );
    await this.publicReadRepairService.repairListingsFromCertificationIfNeeded(listings);
    listings.sort(
      (left, right) =>
        (slotOrder.get(left.id) ?? Number.MAX_SAFE_INTEGER) -
        (slotOrder.get(right.id) ?? Number.MAX_SAFE_INTEGER),
    );
    const items = await this.toListItems(listings);
    return { boardType, items };
  }

  async getApplicationStatus(applicationId: string, context: RequestContext) {
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }
    const listing = await this.listingRepository.findOneBy({ id: application.enterpriseId });
    if (!listing || listing.organizationId !== context.organizationId) {
      throw permissionDenied('Current actor organization scope cannot read this enterprise application.');
    }
    await this.maybeFinalizeApplication(application, listing);
    return this.presenter.toApplicationStatus(application);
  }

  private async maybeFinalizeApplication(
    application: EnterpriseApplicationEntity,
    listing: EnterpriseListingEntity,
  ) {
    if (application.applyBoardType !== listing.primaryBoardType) {
      return;
    }
    if (application.applicationStatus === 'approved') {
      await this.promoteCasesToApproved(listing.id, listing.primaryBoardType);
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
    const cases = await this.caseRepository.findBy({
      enterpriseId: listing.id,
      boardType: listing.primaryBoardType,
    });
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
      await this.promoteCasesToApproved(listing.id, listing.primaryBoardType, cases);
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
    listings: EnterpriseListingEntity[],
  ) {
    const publishedListings = listings.filter(
      (item) =>
        item.enterpriseStatus === 'published' &&
        item.displayStatus === 'visible',
    );
    const publishedEnterpriseIds = publishedListings
      .map((item) => item.id);
    if (!publishedEnterpriseIds.length) {
      return;
    }
    const publishedListingMap = new Map(
      publishedListings.map((item) => [item.id, item] as const),
    );
    const approvedApplications =
      publishedEnterpriseIds.length === 1
        ? await this.applicationRepository.findBy({
            enterpriseId: publishedEnterpriseIds[0],
            applicationStatus: 'approved',
          })
        : await this.applicationRepository.findBy({
            enterpriseId: In(publishedEnterpriseIds),
            applicationStatus: 'approved',
          });
    const approvedListings = [
      ...new Map(
        approvedApplications
          .map((item) => {
            const listing = publishedListingMap.get(item.enterpriseId?.trim() ?? '');
            if (!listing || item.applyBoardType !== listing.primaryBoardType) {
              return null;
            }
            return [listing.id, listing] as const;
          })
          .filter((item): item is readonly [string, EnterpriseListingEntity] => item !== null),
      ).values(),
    ];
    if (!approvedListings.length) {
      return;
    }
    const approvedEnterpriseIds = approvedListings.map((item) => item.id);
    const boardTypeByEnterpriseId = new Map(
      approvedListings.map((item) => [item.id, item.primaryBoardType] as const),
    );
    const cases =
      approvedEnterpriseIds.length === 1
        ? await this.caseRepository.findBy({
            enterpriseId: approvedEnterpriseIds[0],
          })
        : await this.caseRepository.findBy({
            enterpriseId: In(approvedEnterpriseIds),
          });
    const casesByEnterpriseId = new Map<string, EnterpriseCaseEntity[]>();
    for (const item of cases) {
      const boardType = boardTypeByEnterpriseId.get(item.enterpriseId);
      if (boardType !== item.boardType) {
        continue;
      }
      const bucket = casesByEnterpriseId.get(item.enterpriseId) ?? [];
      bucket.push(item);
      casesByEnterpriseId.set(item.enterpriseId, bucket);
    }
    for (const listing of approvedListings) {
      await this.promoteCasesToApproved(
        listing.id,
        listing.primaryBoardType,
        casesByEnterpriseId.get(listing.id),
      );
    }
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

  private async toListItems(listings: EnterpriseListingEntity[]) {
    if (!listings.length) {
      return [];
    }
    await this.repairPublishedListingCasesFromApprovedHistory(listings);
    const enterpriseIds = listings.map((item) => item.id);
    const [reviewSummaries, cases, companies, factories, suppliers, displayUrlMap] = await Promise.all([
      this.reviewSummaryRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.caseRepository.findBy({
        enterpriseId: In(enterpriseIds),
        caseStatus: 'approved',
      }),
      this.companyRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.factoryRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.supplierRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.mediaProjectionService.buildDisplayUrlMap(
        listings.map((item) => item.logoFileAssetId),
      ),
    ]);

    const boardTypeByEnterpriseId = new Map(
      listings.map((item) => [item.id, item.primaryBoardType] as const),
    );
    const reviewSummaryMap = new Map(reviewSummaries.map((item) => [item.enterpriseId, item]));
    const caseCountMap = new Map<string, number>();
    for (const item of cases) {
      if (boardTypeByEnterpriseId.get(item.enterpriseId) !== item.boardType) {
        continue;
      }
      caseCountMap.set(item.enterpriseId, (caseCountMap.get(item.enterpriseId) ?? 0) + 1);
    }
    const companyMap = new Map(companies.map((item) => [item.enterpriseId, item]));
    const factoryMap = new Map(factories.map((item) => [item.enterpriseId, item]));
    const supplierMap = new Map(suppliers.map((item) => [item.enterpriseId, item]));

    return listings.map((listing) =>
      this.presenter.toListItem(
        listing,
        reviewSummaryMap.get(listing.id) ?? null,
        caseCountMap.get(listing.id) ?? 0,
        companyMap.get(listing.id) ?? null,
        factoryMap.get(listing.id) ?? null,
        supplierMap.get(listing.id) ?? null,
        this.mediaProjectionService.readDisplayUrl(
          listing.logoFileAssetId,
          displayUrlMap,
        ),
      )
    );
  }

  private createPublicListingQuery(boardType: string) {
    return this.listingRepository
      .createQueryBuilder('listing')
      .where('listing.primaryBoardType = :boardType', { boardType })
      .andWhere('listing.enterpriseStatus = :enterpriseStatus', {
        enterpriseStatus: 'published',
      })
      .andWhere('listing.displayStatus = :displayStatus', {
        displayStatus: 'visible',
      });
  }

  private async loadPublicListing(enterpriseId: string, boardType: string) {
    return this.listingRepository.findOneBy({
      id: enterpriseId,
      primaryBoardType: boardType,
      enterpriseStatus: 'published',
      displayStatus: 'visible',
    });
  }

  private async loadPublicListings(boardType: string, enterpriseIds: string[]) {
    const uniqueEnterpriseIds = [...new Set(enterpriseIds.filter((item) => item.trim().length > 0))];
    if (!uniqueEnterpriseIds.length) {
      return [];
    }
    return this.listingRepository.findBy({
      id: In(uniqueEnterpriseIds),
      primaryBoardType: boardType,
      enterpriseStatus: 'published',
      displayStatus: 'visible',
    });
  }

  private readBoardType(value: unknown) {
    if (typeof value === 'string' && ENTERPRISE_HUB_BOARD_TYPES.includes(value as never)) {
      return value;
    }
    throw invalidBoardType();
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound = 10_000) {
    const parsed =
      typeof value === 'string' ? Number.parseInt(value, 10) : typeof value === 'number' ? value : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }

  private readPlantAreaRange(value: unknown): { min: number | null; max: number | null } | null {
    if (typeof value !== 'string' || value.trim().length === 0) {
      return null;
    }
    switch (value.trim()) {
      case 'under_500':
        return { min: null, max: 500 };
      case 'from_500_to_1199':
        return { min: 500, max: 1200 };
      case 'from_1200_to_1999':
        return { min: 1200, max: 2000 };
      case 'from_2000_to_3499':
        return { min: 2000, max: 3500 };
      case 'over_3500':
        return { min: 3500, max: null };
      default:
        return null;
    }
  }
}

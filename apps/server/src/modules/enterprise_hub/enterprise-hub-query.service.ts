import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ENTERPRISE_HUB_BOARD_TYPES } from './enterprise-hub.constants';
import {
  applicationNotFound,
  enterpriseNotFound,
  invalidBoardType,
  permissionDenied
} from './enterprise-hub.errors';
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

@Injectable()
export class EnterpriseHubQueryService {
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
    private readonly presenter: EnterpriseHubPresenter
  ) {}

  async getEnterprises(query: Record<string, unknown>) {
    const boardType = this.readBoardType(query.boardType);
    const page = this.readPositiveInt(query.page, 1);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 50);

    const qb = this.listingRepository
      .createQueryBuilder('listing')
      .where('listing.primaryBoardType = :boardType', { boardType })
      .andWhere('listing.enterpriseStatus = :enterpriseStatus', { enterpriseStatus: 'published' })
      .andWhere('listing.displayStatus = :displayStatus', { displayStatus: 'visible' });

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
    const total = await qb.getCount();
    const listings = await qb
      .orderBy('listing.publishedAt', 'DESC')
      .addOrderBy('listing.updatedAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize)
      .getMany();

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
    const listing = await this.listingRepository.findOneBy({ id: enterpriseId });
    if (
      !listing ||
      listing.primaryBoardType !== resolvedBoardType ||
      listing.enterpriseStatus !== 'published' ||
      listing.displayStatus !== 'visible'
    ) {
      throw enterpriseNotFound();
    }

    const [company, factory, supplier, serviceAreas, cases, certifications, reviewSummary, contacts] =
      await Promise.all([
        this.companyRepository.findOneBy({ enterpriseId }),
        this.factoryRepository.findOneBy({ enterpriseId }),
        this.supplierRepository.findOneBy({ enterpriseId }),
        this.serviceAreaRepository.findBy({ enterpriseId }),
        this.caseRepository.findBy({ enterpriseId, caseStatus: 'approved' }),
        this.certificationRepository.findBy({ enterpriseId }),
        this.reviewSummaryRepository.findOneBy({ enterpriseId }),
        this.contactRepository.findBy({ enterpriseId })
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
      contacts
    });
  }

  async getRecommendations(query: Record<string, unknown>) {
    const boardType = this.readBoardType(query.boardType);
    const now = new Date();
    const slots = await this.recommendationSlotRepository.find({
      where: { boardType, slotStatus: In(['pending', 'active']) },
      order: { slotPosition: 'ASC', createdAt: 'DESC' }
    });
    const activeSlots = slots.filter((slot) => slot.startAt <= now && slot.endAt >= now);
    const listings = await this.listingRepository.findBy({
      id: In(activeSlots.map((slot) => slot.enterpriseId)),
      primaryBoardType: boardType,
      enterpriseStatus: 'published',
      displayStatus: 'visible'
    });
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
    return this.presenter.toApplicationStatus(application);
  }

  private async toListItems(listings: EnterpriseListingEntity[]) {
    if (!listings.length) {
      return [];
    }
    const enterpriseIds = listings.map((item) => item.id);
    const [reviewSummaries, cases, companies, factories, suppliers] = await Promise.all([
      this.reviewSummaryRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.caseRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.companyRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.factoryRepository.findBy({ enterpriseId: In(enterpriseIds) }),
      this.supplierRepository.findBy({ enterpriseId: In(enterpriseIds) })
    ]);

    const reviewSummaryMap = new Map(reviewSummaries.map((item) => [item.enterpriseId, item]));
    const caseCountMap = new Map<string, number>();
    for (const item of cases) {
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
        supplierMap.get(listing.id) ?? null
      )
    );
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
}

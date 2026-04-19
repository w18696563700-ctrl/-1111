import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  applicationNotFound,
  enterpriseNotFound,
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

@Injectable()
export class EnterpriseHubApplicationReviewAdminQueryService {
  constructor(
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
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
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: EnterpriseHubPresenter,
  ) {}

  async listApplications(query: Record<string, unknown>, context: RequestContext) {
    await this.requireReviewer(context);
    const listQuery = this.readListQuery(query);
    const qb = this.applicationRepository.createQueryBuilder('application');

    if (listQuery.applicationStatus) {
      qb.andWhere('application.applicationStatus = :applicationStatus', {
        applicationStatus: listQuery.applicationStatus,
      });
    }
    if (listQuery.boardType) {
      qb.andWhere('application.applyBoardType = :boardType', {
        boardType: listQuery.boardType,
      });
    }

    const total = await qb.getCount();
    const applications = await qb
      .orderBy('application.createdAt', 'DESC')
      .skip((listQuery.page - 1) * listQuery.pageSize)
      .take(listQuery.pageSize)
      .getMany();
    const listings = await this.listingRepository.findBy({
      id: In(applications.map((item) => item.enterpriseId)),
    });
    const listingMap = new Map(listings.map((item) => [item.id, item]));

    return {
      items: applications.map((item) =>
        this.presenter.toAdminApplicationListItem(item, listingMap.get(item.enterpriseId) ?? null),
      ),
      pagination: this.presenter.toPagination(listQuery.page, listQuery.pageSize, total),
    };
  }

  async getApplicationDetail(applicationId: string, context: RequestContext) {
    await this.requireReviewer(context);
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }
    const listing = await this.listingRepository.findOneBy({ id: application.enterpriseId });
    if (!listing) {
      throw enterpriseNotFound();
    }

    const [company, factory, supplier, cases, certifications, contacts] = await Promise.all([
      this.companyRepository.findOneBy({ enterpriseId: listing.id }),
      this.factoryRepository.findOneBy({ enterpriseId: listing.id }),
      this.supplierRepository.findOneBy({ enterpriseId: listing.id }),
      this.caseRepository.findBy({ enterpriseId: listing.id }),
      this.certificationRepository.findBy({ enterpriseId: listing.id }),
      this.contactRepository.findBy({ enterpriseId: listing.id }),
    ]);

    return {
      application: this.presenter.toApplicationStatus(application),
      enterprise: {
        enterpriseId: listing.id,
        organizationId: listing.organizationId,
        name: listing.name || null,
        primaryBoardType: listing.primaryBoardType,
        secondaryCapabilities: listing.secondaryCapabilities ?? [],
        enterpriseStatus: listing.enterpriseStatus,
        displayStatus: listing.displayStatus,
      },
      profiles: {
        company,
        factory,
        supplier,
      },
      cases: cases.map((item) => ({
        id: item.id,
        title: item.title,
        summary: item.summary,
        coverImageUrl: null,
        eventTime: item.eventTime,
        caseStatus: item.caseStatus,
      })),
      certifications: certifications.map((item) => ({
        type: item.certificationType,
        name: item.certificationName,
        status: item.certStatus,
      })),
      contacts: contacts.map((item) => ({
        contactName: item.contactName,
        mobile: item.mobile,
        wechat: item.wechat,
        phone: item.phone,
        email: item.email,
        position: item.position,
      })),
    };
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    return this.eligibilityService.requireReviewer(currentSession);
  }

  private readListQuery(query: Record<string, unknown>) {
    return {
      page: this.readPositiveInt(query.page, 1),
      pageSize: this.readPositiveInt(query.pageSize, 20, 50),
      applicationStatus: this.readOptionalString(query.applicationStatus),
      boardType: this.readOptionalString(query.boardType),
    };
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound = 50) {
    const parsed =
      typeof value === 'string'
        ? Number.parseInt(value, 10)
        : typeof value === 'number'
          ? value
          : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }
}

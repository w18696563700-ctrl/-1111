import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import {
  applicationNotFound,
  duplicateRecommendationSlot,
  enterpriseNotApproved,
  enterpriseNotFound,
  invalidStateTransition
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

@Injectable()
export class EnterpriseHubAdminService {
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
    @InjectRepository(EnterpriseRecommendationSlotEntity)
    private readonly recommendationSlotRepository: Repository<EnterpriseRecommendationSlotEntity>,
    private readonly presenter: EnterpriseHubPresenter
  ) {}

  async listApplications(query: Record<string, unknown>) {
    const page = this.readPositiveInt(query.page, 1);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 50);
    const qb = this.applicationRepository.createQueryBuilder('application');

    if (typeof query.applicationStatus === 'string' && query.applicationStatus.trim().length > 0) {
      qb.andWhere('application.applicationStatus = :applicationStatus', {
        applicationStatus: query.applicationStatus.trim()
      });
    }
    if (typeof query.boardType === 'string' && query.boardType.trim().length > 0) {
      qb.andWhere('application.applyBoardType = :boardType', { boardType: query.boardType.trim() });
    }

    const total = await qb.getCount();
    const applications = await qb
      .orderBy('application.createdAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize)
      .getMany();
    const listings = await this.listingRepository.findBy({
      id: In(applications.map((item) => item.enterpriseId))
    });
    const listingMap = new Map(listings.map((item) => [item.id, item]));
    return {
      items: applications.map((item) =>
        this.presenter.toAdminApplicationListItem(item, listingMap.get(item.enterpriseId) ?? null)
      ),
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async getApplicationDetail(applicationId: string) {
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
      this.contactRepository.findBy({ enterpriseId: listing.id })
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
        displayStatus: listing.displayStatus
      },
      profiles: {
        company,
        factory,
        supplier
      },
      cases: cases.map((item) => ({
        id: item.id,
        title: item.title,
        summary: item.summary,
        coverImageUrl: null,
        eventTime: item.eventTime,
        caseStatus: item.caseStatus
      })),
      certifications: certifications.map((item) => ({
        type: item.certificationType,
        name: item.certificationName,
        status: item.certStatus
      })),
      contacts: contacts.map((item) => ({
        contactName: item.contactName,
        mobile: item.mobile,
        wechat: item.wechat,
        phone: item.phone,
        email: item.email,
        position: item.position
      }))
    };
  }

  async reviewApplication(applicationId: string, payload: Record<string, unknown>, context: RequestContext) {
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }
    const action = typeof payload.action === 'string' ? payload.action.trim() : '';
    if (!['approved', 'revision_required', 'rejected'].includes(action)) {
      throw invalidStateTransition('Review action is invalid for enterprise hub application.');
    }
    if (!['submitted', 'under_review'].includes(application.applicationStatus)) {
      throw invalidStateTransition('Application is not in a reviewable state.');
    }
    application.applicationStatus = action;
    application.reviewedAt = new Date();
    application.reviewerId = context.actorId || null;
    application.reviewNote = typeof payload.reviewNote === 'string' ? payload.reviewNote.trim() : null;
    application.rejectionReason = action === 'rejected' ? application.reviewNote : null;
    await this.applicationRepository.save(application);
    return { ok: true, traceId: context.traceId };
  }

  async publishListing(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.requireListing(enterpriseId);
    const latestApproved = await this.applicationRepository.findOne({
      where: { enterpriseId, applicationStatus: 'approved' },
      order: { reviewedAt: 'DESC', updatedAt: 'DESC' }
    });
    if (!latestApproved) {
      throw enterpriseNotApproved('Enterprise listing publish requires an approved application first.');
    }
    if (!this.readText(payload.operatorId)) {
      throw invalidStateTransition('operatorId is required for enterprise hub publish.');
    }
    listing.enterpriseStatus = 'published';
    listing.displayStatus = 'visible';
    listing.publishedAt = new Date();
    await this.listingRepository.save(listing);
    return { ok: true, traceId: context.traceId };
  }

  async offlineListing(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.requireListing(enterpriseId);
    if (!this.readText(payload.reason)) {
      throw invalidStateTransition('reason is required for enterprise hub offline.');
    }
    listing.enterpriseStatus = 'offline';
    listing.displayStatus = 'hidden';
    await this.listingRepository.save(listing);
    await this.disableSlotsForEnterprise(enterpriseId);
    return { ok: true, traceId: context.traceId };
  }

  async freezeListing(enterpriseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const listing = await this.requireListing(enterpriseId);
    if (!this.readText(payload.reason)) {
      throw invalidStateTransition('reason is required for enterprise hub freeze.');
    }
    listing.enterpriseStatus = 'frozen';
    listing.displayStatus = 'hidden';
    await this.listingRepository.save(listing);
    await this.disableSlotsForEnterprise(enterpriseId);
    return { ok: true, traceId: context.traceId };
  }

  async listRecommendationSlots(query: Record<string, unknown>) {
    const where: Record<string, unknown> = {};
    if (typeof query.boardType === 'string' && query.boardType.trim().length > 0) {
      where.boardType = query.boardType.trim();
    }
    if (typeof query.slotStatus === 'string' && query.slotStatus.trim().length > 0) {
      where.slotStatus = query.slotStatus.trim();
    }
    const slots = await this.recommendationSlotRepository.find({
      where,
      order: { boardType: 'ASC', slotPosition: 'ASC', createdAt: 'DESC' }
    });
    return {
      items: slots.map((item) => this.presenter.toAdminRecommendationSlotItem(item))
    };
  }

  async createRecommendationSlot(payload: Record<string, unknown>, context: RequestContext) {
    const boardType = this.readText(payload.boardType);
    const slotPosition = this.readPositiveInt(payload.slotPosition, 1, 3);
    const enterpriseId = this.readText(payload.enterpriseId);
    const startAt = new Date(this.readText(payload.startAt));
    const endAt = new Date(this.readText(payload.endAt));
    const sourceType = this.readText(payload.sourceType);
    const listing = await this.requireListing(enterpriseId);

    if (listing.enterpriseStatus === 'frozen') {
      throw invalidStateTransition('Frozen enterprise listings cannot continue recommendation placement.');
    }
    if (listing.enterpriseStatus !== 'published' || listing.displayStatus !== 'visible') {
      throw enterpriseNotApproved('Only published and visible enterprise listings may occupy recommendation slots.');
    }

    const overlaps = await this.recommendationSlotRepository.findBy({
      boardType,
      slotPosition,
      slotStatus: In(['pending', 'active'])
    });
    if (
      overlaps.some((item) => !(item.endAt <= startAt || item.startAt >= endAt))
    ) {
      throw duplicateRecommendationSlot(
        'Recommendation slot overlaps an existing active or pending slot in the same board position.'
      );
    }

    const now = new Date();
    const slot = this.recommendationSlotRepository.create({
      id: randomUUID(),
      boardType,
      slotPosition,
      enterpriseId,
      startAt,
      endAt,
      sourceType,
      scoreSnapshot:
        typeof payload.scoreSnapshot === 'number' && Number.isFinite(payload.scoreSnapshot)
          ? payload.scoreSnapshot
          : null,
      slotStatus: startAt <= now && endAt >= now ? 'active' : 'pending'
    });
    await this.recommendationSlotRepository.save(slot);
    return { ok: true, traceId: context.traceId };
  }

  private async disableSlotsForEnterprise(enterpriseId: string) {
    const slots = await this.recommendationSlotRepository.findBy({
      enterpriseId,
      slotStatus: In(['pending', 'active'])
    });
    for (const slot of slots) {
      slot.slotStatus = 'disabled';
    }
    if (slots.length > 0) {
      await this.recommendationSlotRepository.save(slots);
    }
  }

  private async requireListing(enterpriseId: string) {
    const listing = await this.listingRepository.findOneBy({ id: enterpriseId });
    if (!listing) {
      throw enterpriseNotFound();
    }
    return listing;
  }

  private readText(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : '';
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound = 50) {
    const parsed =
      typeof value === 'string' ? Number.parseInt(value, 10) : typeof value === 'number' ? value : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }
}

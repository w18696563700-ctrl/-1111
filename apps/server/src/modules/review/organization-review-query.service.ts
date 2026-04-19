import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationReviewPresenter } from './organization-review.presenter';
import { organizationReviewResourceUnavailable } from './review.errors';

@Injectable()
export class OrganizationReviewQueryService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: OrganizationReviewPresenter
  ) {}

  async list(query: Record<string, unknown>, context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireReviewer(currentSession);
    const page = this.readPositiveInt(query.page, 1, 10_000);
    const pageSize = this.readPositiveInt(query.pageSize, 20, 100);
    const qb = this.certificationRepository
      .createQueryBuilder('certification')
      .innerJoin(
        OrganizationEntity,
        'organization',
        'organization.id = certification.organization_id'
      );

    if (typeof query.status === 'string' && query.status.trim().length > 0) {
      qb.andWhere('certification.certification_status = :status', {
        status: query.status.trim()
      });
    }
    if (typeof query.organizationId === 'string' && query.organizationId.trim().length > 0) {
      qb.andWhere('organization.id = :organizationId', {
        organizationId: query.organizationId.trim()
      });
    }
    if (typeof query.keyword === 'string' && query.keyword.trim().length > 0) {
      qb.andWhere(
        '(organization.name ILIKE :keyword OR certification.legal_name ILIKE :keyword OR certification.uscc ILIKE :keyword)',
        { keyword: `%${query.keyword.trim()}%` }
      );
    }

    const total = await qb.getCount();
    const rows = await qb
      .select([
        'organization.id AS organization_id',
        'organization.name AS organization_name',
        'organization.organization_type AS organization_type',
        'certification.certification_status AS certification_status',
        'certification.submitted_at AS submitted_at'
      ])
      .orderBy('certification.submitted_at', 'DESC')
      .addOrderBy('organization.created_at', 'DESC')
      .offset((page - 1) * pageSize)
      .limit(pageSize)
      .getRawMany<Record<string, unknown>>();

    return {
      items: rows.map((row) =>
        this.presenter.toListItem({
          organizationId: String(row.organization_id),
          name: String(row.organization_name),
          organizationType: String(row.organization_type),
          certificationStatus: String(row.certification_status),
          submittedAt: row.submitted_at ? new Date(String(row.submitted_at)) : null
        })
      ),
      pagination: this.presenter.toPagination(page, pageSize, total)
    };
  }

  async detail(organizationId: string, context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireReviewer(currentSession);
    const normalized = organizationId.trim();
    if (!normalized) {
      throw organizationReviewResourceUnavailable('Current organization review resource is unavailable.');
    }

    const organization = await this.organizationRepository.findOneBy({ id: normalized });
    const certification = await this.certificationRepository.findOne({
      where: { organizationId: normalized },
      order: { updatedAt: 'DESC' }
    });
    if (!organization || !certification) {
      throw organizationReviewResourceUnavailable('Current organization review resource is unavailable.');
    }

    return this.presenter.toDetail({
      organizationId: organization.id,
      name: organization.name,
      organizationType: organization.organizationType,
      certificationStatus: certification.certificationStatus,
      legalName: certification.legalName,
      uscc: certification.uscc,
      licenseFileId: certification.licenseFileId,
      contactName: organization.contactName,
      contactMobile: organization.contactMobile,
      submittedAt: certification.submittedAt,
      reviewedAt: certification.reviewedAt,
      rejectReason: certification.rejectReason
    });
  }

  private readPositiveInt(value: unknown, fallback: number, upperBound: number) {
    const parsed =
      typeof value === 'string' ? Number.parseInt(value, 10) : typeof value === 'number' ? value : fallback;
    if (!Number.isInteger(parsed) || parsed <= 0) {
      return fallback;
    }
    return Math.min(parsed, upperBound);
  }
}
